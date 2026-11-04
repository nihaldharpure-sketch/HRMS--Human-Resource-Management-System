package com.hrms.service;

import com.hrms.entity.Attendance;
import com.hrms.entity.AttendanceCorrection;
import com.hrms.entity.Employee;
import com.hrms.repository.AttendanceCorrectionRepository;
import com.hrms.repository.AttendanceRepository;
import com.hrms.repository.EmployeeRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

@Service
public class AttendanceService {

    private final AttendanceRepository attendanceRepository;
    private final AttendanceCorrectionRepository correctionRepository;
    private final EmployeeRepository employeeRepository;

    private static final LocalTime WORK_START_TIME = LocalTime.of(9, 30);
    private static final LocalTime WORK_END_TIME = LocalTime.of(18, 0);
    private static final double STANDARD_DAILY_HOURS = 8.0;

    public AttendanceService(AttendanceRepository attendanceRepository,
                             AttendanceCorrectionRepository correctionRepository,
                             EmployeeRepository employeeRepository) {
        this.attendanceRepository = attendanceRepository;
        this.correctionRepository = correctionRepository;
        this.employeeRepository = employeeRepository;
    }

    public List<Attendance> getAttendanceForDate(LocalDate date) {
        return attendanceRepository.findByAttendanceDateOrderByEmployeeFirstNameAsc(date);
    }

    public List<Attendance> getAttendanceForEmployee(Long employeeId) {
        return attendanceRepository.findByEmployeeIdOrderByAttendanceDateDesc(employeeId);
    }

    public Optional<Attendance> getTodayAttendanceForEmployee(Long employeeId) {
        return attendanceRepository.findByEmployeeIdAndAttendanceDate(employeeId, LocalDate.now());
    }

    @Transactional
    public Attendance checkIn(Long employeeId) {
        Employee employee = employeeRepository.findById(employeeId)
                .orElseThrow(() -> new IllegalArgumentException("Employee not found with id: " + employeeId));

        LocalDate today = LocalDate.now();
        LocalDateTime now = LocalDateTime.now();

        Optional<Attendance> existing = attendanceRepository.findByEmployeeIdAndAttendanceDate(employeeId, today);
        if (existing.isPresent()) {
            throw new IllegalStateException("Employee has already checked in today at " + existing.get().getCheckIn().toLocalTime());
        }

        Attendance attendance = new Attendance();
        attendance.setEmployee(employee);
        attendance.setAttendanceDate(today);
        attendance.setCheckIn(now);

        // Check if late (after 09:30 AM)
        if (now.toLocalTime().isAfter(WORK_START_TIME)) {
            int lateMins = (int) Duration.between(WORK_START_TIME, now.toLocalTime()).toMinutes();
            attendance.setLateMinutes(lateMins);
            attendance.setStatus("LATE");
        } else {
            attendance.setLateMinutes(0);
            attendance.setStatus("PRESENT");
        }

        return attendanceRepository.save(attendance);
    }

    @Transactional
    public Attendance checkOut(Long employeeId) {
        LocalDate today = LocalDate.now();
        LocalDateTime now = LocalDateTime.now();

        Attendance attendance = attendanceRepository.findByEmployeeIdAndAttendanceDate(employeeId, today)
                .orElseThrow(() -> new IllegalStateException("No active check-in found for today. Please check in first."));

        if (attendance.getCheckOut() != null) {
            throw new IllegalStateException("Employee has already checked out today at " + attendance.getCheckOut().toLocalTime());
        }

        attendance.setCheckOut(now);

        Duration duration = Duration.between(attendance.getCheckIn(), now);
        double hours = Math.round((duration.toMinutes() / 60.0) * 10.0) / 10.0;
        attendance.setTotalHours(hours);

        // Calculate overtime or early exit
        if (hours > STANDARD_DAILY_HOURS) {
            attendance.setOvertimeHours(Math.round((hours - STANDARD_DAILY_HOURS) * 10.0) / 10.0);
        } else {
            attendance.setOvertimeHours(0.0);
        }

        if (now.toLocalTime().isBefore(WORK_END_TIME)) {
            int earlyMins = (int) Duration.between(now.toLocalTime(), WORK_END_TIME).toMinutes();
            attendance.setEarlyExitMinutes(earlyMins);
        } else {
            attendance.setEarlyExitMinutes(0);
        }

        return attendanceRepository.save(attendance);
    }

    @Transactional
    public Attendance markManualAttendance(Long employeeId, LocalDate date, LocalDateTime checkIn, LocalDateTime checkOut, String status, String remarks) {
        Employee employee = employeeRepository.findById(employeeId)
                .orElseThrow(() -> new IllegalArgumentException("Employee not found"));

        Attendance attendance = attendanceRepository.findByEmployeeIdAndAttendanceDate(employeeId, date)
                .orElse(new Attendance());

        attendance.setEmployee(employee);
        attendance.setAttendanceDate(date);
        attendance.setCheckIn(checkIn);
        attendance.setCheckOut(checkOut);
        attendance.setStatus(status != null ? status : "PRESENT");
        attendance.setRemarks(remarks);

        if (checkIn != null && checkOut != null) {
            double hours = Math.round((Duration.between(checkIn, checkOut).toMinutes() / 60.0) * 10.0) / 10.0;
            attendance.setTotalHours(hours);
            if (hours > STANDARD_DAILY_HOURS) {
                attendance.setOvertimeHours(Math.round((hours - STANDARD_DAILY_HOURS) * 10.0) / 10.0);
            }
        }

        return attendanceRepository.save(attendance);
    }

    // Attendance Corrections
    @Transactional
    public AttendanceCorrection submitCorrection(Long employeeId, LocalDate date, LocalDateTime reqCheckIn, LocalDateTime reqCheckOut, String reason) {
        Employee employee = employeeRepository.findById(employeeId)
                .orElseThrow(() -> new IllegalArgumentException("Employee not found"));

        AttendanceCorrection ac = new AttendanceCorrection();
        ac.setEmployee(employee);
        ac.setAttendanceDate(date);
        ac.setRequestedCheckIn(reqCheckIn);
        ac.setRequestedCheckOut(reqCheckOut);
        ac.setReason(reason);
        ac.setStatus("PENDING");

        return correctionRepository.save(ac);
    }

    public List<AttendanceCorrection> getPendingCorrections() {
        return correctionRepository.findByStatusOrderBySubmittedAtDesc("PENDING");
    }

    public List<AttendanceCorrection> getCorrectionsForEmployee(Long employeeId) {
        return correctionRepository.findByEmployeeIdOrderBySubmittedAtDesc(employeeId);
    }

    @Transactional
    public void reviewCorrection(Long correctionId, boolean approve, String remarks, Employee reviewer) {
        AttendanceCorrection ac = correctionRepository.findById(correctionId)
                .orElseThrow(() -> new IllegalArgumentException("Correction request not found"));

        ac.setStatus(approve ? "APPROVED" : "REJECTED");
        ac.setReviewerRemarks(remarks);
        ac.setReviewedBy(reviewer);
        ac.setReviewedAt(LocalDateTime.now());
        correctionRepository.save(ac);

        if (approve) {
            markManualAttendance(
                    ac.getEmployee().getId(),
                    ac.getAttendanceDate(),
                    ac.getRequestedCheckIn(),
                    ac.getRequestedCheckOut(),
                    "PRESENT",
                    "Approved correction: " + remarks
            );
        }
    }

    public long countPresentToday() {
        return attendanceRepository.countByAttendanceDateAndStatus(LocalDate.now(), "PRESENT");
    }

    public long countLateToday() {
        return attendanceRepository.countLateEmployees(LocalDate.now());
    }

    public long countOnLeaveToday() {
        return attendanceRepository.countByAttendanceDateAndStatus(LocalDate.now(), "ON_LEAVE");
    }
}
