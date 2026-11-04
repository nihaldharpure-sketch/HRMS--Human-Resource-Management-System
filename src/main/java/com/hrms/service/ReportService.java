package com.hrms.service;

import com.hrms.entity.Attendance;
import com.hrms.entity.Employee;
import com.hrms.entity.LeaveRequest;
import com.hrms.entity.Payroll;
import com.hrms.repository.AttendanceRepository;
import com.hrms.repository.EmployeeRepository;
import com.hrms.repository.LeaveRequestRepository;
import com.hrms.repository.PayrollRepository;
import org.springframework.stereotype.Service;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.util.List;

@Service
public class ReportService {

    private final EmployeeRepository employeeRepository;
    private final AttendanceRepository attendanceRepository;
    private final LeaveRequestRepository leaveRequestRepository;
    private final PayrollRepository payrollRepository;

    public ReportService(EmployeeRepository employeeRepository,
                         AttendanceRepository attendanceRepository,
                         LeaveRequestRepository leaveRequestRepository,
                         PayrollRepository payrollRepository) {
        this.employeeRepository = employeeRepository;
        this.attendanceRepository = attendanceRepository;
        this.leaveRequestRepository = leaveRequestRepository;
        this.payrollRepository = payrollRepository;
    }

    public ByteArrayInputStream exportEmployeesToCsv() {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        try (PrintWriter writer = new PrintWriter(out, true, StandardCharsets.UTF_8)) {
            writer.println("Employee Code,First Name,Last Name,Email,Phone,Department,Designation,Status,Joining Date,Employment Type");
            List<Employee> employees = employeeRepository.findAll();
            for (Employee e : employees) {
                writer.printf("\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"%n",
                        safe(e.getEmployeeCode()),
                        safe(e.getFirstName()),
                        safe(e.getLastName()),
                        safe(e.getEmail()),
                        safe(e.getPhone()),
                        e.getDepartment() != null ? safe(e.getDepartment().getName()) : "",
                        e.getDesignation() != null ? safe(e.getDesignation().getTitle()) : "",
                        safe(e.getStatus()),
                        e.getDateOfJoining() != null ? e.getDateOfJoining().toString() : "",
                        safe(e.getEmploymentType())
                );
            }
        }
        return new ByteArrayInputStream(out.toByteArray());
    }

    public ByteArrayInputStream exportAttendanceToCsv(LocalDate date) {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        try (PrintWriter writer = new PrintWriter(out, true, StandardCharsets.UTF_8)) {
            writer.println("Date,Employee Code,Employee Name,Department,Status,Check In,Check Out,Total Hours,Overtime Hours,Late Minutes");
            List<Attendance> attendances = attendanceRepository.findByAttendanceDateOrderByEmployeeFirstNameAsc(date);
            for (Attendance a : attendances) {
                writer.printf("\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",%.1f,%.1f,%d%n",
                        a.getAttendanceDate(),
                        safe(a.getEmployee().getEmployeeCode()),
                        safe(a.getEmployee().getFullName()),
                        a.getEmployee().getDepartment() != null ? safe(a.getEmployee().getDepartment().getName()) : "",
                        safe(a.getStatus()),
                        a.getCheckIn() != null ? a.getCheckIn().toLocalTime().toString() : "",
                        a.getCheckOut() != null ? a.getCheckOut().toLocalTime().toString() : "",
                        a.getTotalHours() != null ? a.getTotalHours() : 0.0,
                        a.getOvertimeHours() != null ? a.getOvertimeHours() : 0.0,
                        a.getLateMinutes() != null ? a.getLateMinutes() : 0
                );
            }
        }
        return new ByteArrayInputStream(out.toByteArray());
    }

    public ByteArrayInputStream exportPayrollToCsv(LocalDate month) {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        try (PrintWriter writer = new PrintWriter(out, true, StandardCharsets.UTF_8)) {
            writer.println("Month,Employee Code,Employee Name,Department,Basic Salary,Allowances,Overtime Pay,Deductions,Net Salary,Status");
            List<Payroll> payrolls = payrollRepository.findByPayrollMonthOrderByEmployeeFirstNameAsc(month.withDayOfMonth(1));
            for (Payroll p : payrolls) {
                writer.printf("\"%s\",\"%s\",\"%s\",\"%s\",%.2f,%.2f,%.2f,%.2f,%.2f,\"%s\"%n",
                        p.getPayrollMonth(),
                        safe(p.getEmployee().getEmployeeCode()),
                        safe(p.getEmployee().getFullName()),
                        p.getEmployee().getDepartment() != null ? safe(p.getEmployee().getDepartment().getName()) : "",
                        p.getBasicSalary(),
                        p.getAllowances(),
                        p.getOvertimePay(),
                        p.getDeductions(),
                        p.getNetSalary(),
                        safe(p.getStatus())
                );
            }
        }
        return new ByteArrayInputStream(out.toByteArray());
    }

    public ByteArrayInputStream exportLeavesToCsv() {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        try (PrintWriter writer = new PrintWriter(out, true, StandardCharsets.UTF_8)) {
            writer.println("Employee Code,Employee Name,Department,Leave Type,Start Date,End Date,Days,Half Day,Status,Reason");
            List<LeaveRequest> leaves = leaveRequestRepository.findAllByOrderByAppliedAtDesc();
            for (LeaveRequest lr : leaves) {
                writer.printf("\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",%.1f,%b,\"%s\",\"%s\"%n",
                        safe(lr.getEmployee().getEmployeeCode()),
                        safe(lr.getEmployee().getFullName()),
                        lr.getEmployee().getDepartment() != null ? safe(lr.getEmployee().getDepartment().getName()) : "",
                        lr.getLeaveType(),
                        lr.getStartDate(),
                        lr.getEndDate(),
                        lr.getDays() != null ? lr.getDays() : 1.0,
                        lr.getHalfDay(),
                        safe(lr.getStatus()),
                        safe(lr.getReason())
                );
            }
        }
        return new ByteArrayInputStream(out.toByteArray());
    }

    private String safe(String str) {
        if (str == null) return "";
        return str.replace("\"", "\"\"");
    }
}
