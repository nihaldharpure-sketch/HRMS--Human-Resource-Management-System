package com.hrms.service;

import com.hrms.entity.*;
import com.hrms.repository.AttendanceRepository;
import com.hrms.repository.EmployeeRepository;
import com.hrms.repository.LeaveBalanceRepository;
import com.hrms.repository.LeaveRequestRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class LeaveService {

    private final LeaveRequestRepository leaveRequestRepository;
    private final LeaveBalanceRepository leaveBalanceRepository;
    private final EmployeeRepository employeeRepository;
    private final AttendanceRepository attendanceRepository;

    public LeaveService(LeaveRequestRepository leaveRequestRepository,
                        LeaveBalanceRepository leaveBalanceRepository,
                        EmployeeRepository employeeRepository,
                        AttendanceRepository attendanceRepository) {
        this.leaveRequestRepository = leaveRequestRepository;
        this.leaveBalanceRepository = leaveBalanceRepository;
        this.employeeRepository = employeeRepository;
        this.attendanceRepository = attendanceRepository;
    }

    public List<LeaveRequest> getAllLeaves() {
        return leaveRequestRepository.findAllByOrderByAppliedAtDesc();
    }

    public List<LeaveRequest> getPendingLeaves() {
        return leaveRequestRepository.findByStatusOrderByAppliedAtDesc("PENDING");
    }

    public List<LeaveRequest> getLeavesForEmployee(Long employeeId) {
        return leaveRequestRepository.findByEmployeeIdOrderByAppliedAtDesc(employeeId);
    }

    public LeaveBalance getOrCreateLeaveBalance(Long employeeId, int year) {
        return leaveBalanceRepository.findByEmployeeIdAndYear(employeeId, year)
                .orElseGet(() -> {
                    Employee employee = employeeRepository.findById(employeeId)
                            .orElseThrow(() -> new IllegalArgumentException("Employee not found"));
                    LeaveBalance balance = new LeaveBalance(employee, year);
                    return leaveBalanceRepository.save(balance);
                });
    }

    @Transactional
    public LeaveRequest applyLeave(Long employeeId, LeaveType leaveType, LocalDate startDate, LocalDate endDate, Boolean halfDay, String reason) {
        if (startDate == null || endDate == null) {
            throw new IllegalArgumentException("Start date and end date are required.");
        }
        if (endDate.isBefore(startDate)) {
            throw new IllegalArgumentException("End date cannot be earlier than start date.");
        }

        Employee employee = employeeRepository.findById(employeeId)
                .orElseThrow(() -> new IllegalArgumentException("Employee not found with id: " + employeeId));

        // Check overlapping approved/pending leaves
        List<LeaveRequest> overlapping = leaveRequestRepository.findOverlappingLeaves(employeeId, startDate, endDate);
        if (!overlapping.isEmpty()) {
            throw new IllegalArgumentException("You already have an existing leave application covering this date range.");
        }

        // Calculate days excluding weekends (Saturday & Sunday)
        double daysCount = 0.0;
        LocalDate curr = startDate;
        while (!curr.isAfter(endDate)) {
            DayOfWeek dow = curr.getDayOfWeek();
            if (dow != DayOfWeek.SATURDAY && dow != DayOfWeek.SUNDAY) {
                daysCount += 1.0;
            }
            curr = curr.plusDays(1);
        }

        if (daysCount == 0.0) {
            throw new IllegalArgumentException("Selected date range contains only weekends.");
        }

        if (Boolean.TRUE.equals(halfDay)) {
            daysCount = 0.5;
        }

        // Validate Leave Balance
        int year = startDate.getYear();
        LeaveBalance balance = getOrCreateLeaveBalance(employeeId, year);

        if (leaveType == LeaveType.ANNUAL && balance.getAnnualRemaining() < daysCount) {
            throw new IllegalArgumentException("Insufficient Annual Leave balance. Available: " + balance.getAnnualRemaining() + " days.");
        } else if (leaveType == LeaveType.CASUAL && balance.getCasualRemaining() < daysCount) {
            throw new IllegalArgumentException("Insufficient Casual Leave balance. Available: " + balance.getCasualRemaining() + " days.");
        } else if (leaveType == LeaveType.SICK && balance.getSickRemaining() < daysCount) {
            throw new IllegalArgumentException("Insufficient Sick Leave balance. Available: " + balance.getSickRemaining() + " days.");
        }

        LeaveRequest request = new LeaveRequest();
        request.setEmployee(employee);
        request.setLeaveType(leaveType);
        request.setStartDate(startDate);
        request.setEndDate(endDate);
        request.setDays(daysCount);
        request.setHalfDay(halfDay);
        request.setReason(reason);
        request.setStatus("PENDING");
        request.setAppliedAt(LocalDateTime.now());

        return leaveRequestRepository.save(request);
    }

    @Transactional
    public LeaveRequest approveLeave(Long requestId, Employee reviewer, String comment) {
        LeaveRequest request = leaveRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Leave request not found"));

        if (!"PENDING".equals(request.getStatus())) {
            throw new IllegalStateException("Leave request is already " + request.getStatus());
        }

        request.setStatus("APPROVED");
        request.setReviewedBy(reviewer);
        request.setReviewComment(comment);
        request.setReviewedAt(LocalDateTime.now());

        // Deduct from Leave Balance
        int year = request.getStartDate().getYear();
        LeaveBalance balance = getOrCreateLeaveBalance(request.getEmployee().getId(), year);

        if (request.getLeaveType() == LeaveType.ANNUAL) {
            balance.setAnnualUsed(balance.getAnnualUsed() + request.getDays());
        } else if (request.getLeaveType() == LeaveType.CASUAL) {
            balance.setCasualUsed(balance.getCasualUsed() + request.getDays());
        } else if (request.getLeaveType() == LeaveType.SICK) {
            balance.setSickUsed(balance.getSickUsed() + request.getDays());
        } else if (request.getLeaveType() == LeaveType.UNPAID) {
            balance.setUnpaidUsed(balance.getUnpaidUsed() + request.getDays());
        }
        leaveBalanceRepository.save(balance);

        // Mark attendance as ON_LEAVE for working days in range
        LocalDate curr = request.getStartDate();
        while (!curr.isAfter(request.getEndDate())) {
            if (curr.getDayOfWeek() != DayOfWeek.SATURDAY && curr.getDayOfWeek() != DayOfWeek.SUNDAY) {
                Attendance att = attendanceRepository.findByEmployeeIdAndAttendanceDate(request.getEmployee().getId(), curr)
                        .orElse(new Attendance());
                att.setEmployee(request.getEmployee());
                att.setAttendanceDate(curr);
                att.setStatus("ON_LEAVE");
                att.setRemarks("Approved " + request.getLeaveType() + " leave");
                attendanceRepository.save(att);
            }
            curr = curr.plusDays(1);
        }

        return leaveRequestRepository.save(request);
    }

    @Transactional
    public LeaveRequest rejectLeave(Long requestId, Employee reviewer, String comment) {
        LeaveRequest request = leaveRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Leave request not found"));

        request.setStatus("REJECTED");
        request.setReviewedBy(reviewer);
        request.setReviewComment(comment);
        request.setReviewedAt(LocalDateTime.now());

        return leaveRequestRepository.save(request);
    }

    @Transactional
    public void cancelLeave(Long requestId) {
        LeaveRequest request = leaveRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Leave request not found"));

        if ("APPROVED".equals(request.getStatus())) {
            // Restore balance
            int year = request.getStartDate().getYear();
            LeaveBalance balance = getOrCreateLeaveBalance(request.getEmployee().getId(), year);
            if (request.getLeaveType() == LeaveType.ANNUAL) {
                balance.setAnnualUsed(Math.max(0, balance.getAnnualUsed() - request.getDays()));
            } else if (request.getLeaveType() == LeaveType.CASUAL) {
                balance.setCasualUsed(Math.max(0, balance.getCasualUsed() - request.getDays()));
            } else if (request.getLeaveType() == LeaveType.SICK) {
                balance.setSickUsed(Math.max(0, balance.getSickUsed() - request.getDays()));
            }
            leaveBalanceRepository.save(balance);
        }

        request.setStatus("CANCELLED");
        leaveRequestRepository.save(request);
    }

    public long countPendingLeaves() {
        return leaveRequestRepository.countByStatus("PENDING");
    }
}
