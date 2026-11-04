package com.hrms.controller;

import com.hrms.repository.*;
import com.hrms.security.SecurityUtil;
import com.hrms.service.ReportService;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.io.ByteArrayInputStream;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/reports")
public class ReportWebController {

    private final ReportService reportService;
    private final EmployeeRepository employeeRepository;
    private final AttendanceRepository attendanceRepository;
    private final LeaveRequestRepository leaveRequestRepository;
    private final PayrollRepository payrollRepository;
    private final SecurityUtil securityUtil;

    public ReportWebController(ReportService reportService,
                               EmployeeRepository employeeRepository,
                               AttendanceRepository attendanceRepository,
                               LeaveRequestRepository leaveRequestRepository,
                               PayrollRepository payrollRepository,
                               SecurityUtil securityUtil) {
        this.reportService = reportService;
        this.employeeRepository = employeeRepository;
        this.attendanceRepository = attendanceRepository;
        this.leaveRequestRepository = leaveRequestRepository;
        this.payrollRepository = payrollRepository;
        this.securityUtil = securityUtil;
    }

    @GetMapping
    public String reportsDashboard(Model model) {
        LocalDate today = LocalDate.now();

        long totalEmployees = employeeRepository.count();
        long activeEmployees = employeeRepository.countByStatus("ACTIVE");
        long presentToday = attendanceRepository.countByAttendanceDateAndStatus(today, "PRESENT");
        long pendingLeaves = leaveRequestRepository.countByStatus("PENDING");

        // Department counts
        List<Object[]> deptCounts = employeeRepository.countEmployeesByDepartment();
        List<String> deptLabels = new ArrayList<>();
        List<Long> deptData = new ArrayList<>();
        for (Object[] row : deptCounts) {
            deptLabels.add((String) row[0]);
            deptData.add((Long) row[1]);
        }

        model.addAttribute("totalEmployees", totalEmployees);
        model.addAttribute("activeEmployees", activeEmployees);
        model.addAttribute("presentToday", presentToday);
        model.addAttribute("pendingLeaves", pendingLeaves);
        model.addAttribute("deptLabels", deptLabels);
        model.addAttribute("deptData", deptData);

        securityUtil.getCurrentUser().ifPresent(u -> model.addAttribute("currentUser", u));
        return "reports";
    }

    @GetMapping("/export/employees")
    public ResponseEntity<InputStreamResource> exportEmployees() {
        ByteArrayInputStream in = reportService.exportEmployeesToCsv();
        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-Disposition", "attachment; filename=employees_directory.csv");
        return ResponseEntity.ok()
                .headers(headers)
                .contentType(MediaType.parseMediaType("text/csv"))
                .body(new InputStreamResource(in));
    }

    @GetMapping("/export/attendance")
    public ResponseEntity<InputStreamResource> exportAttendance(@RequestParam(required = false) String date) {
        LocalDate d = date != null && !date.isBlank() ? LocalDate.parse(date) : LocalDate.now();
        ByteArrayInputStream in = reportService.exportAttendanceToCsv(d);
        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-Disposition", "attachment; filename=attendance_" + d + ".csv");
        return ResponseEntity.ok()
                .headers(headers)
                .contentType(MediaType.parseMediaType("text/csv"))
                .body(new InputStreamResource(in));
    }

    @GetMapping("/export/payroll")
    public ResponseEntity<InputStreamResource> exportPayroll(@RequestParam(required = false) String month) {
        LocalDate m = month != null && !month.isBlank() ? LocalDate.parse(month) : LocalDate.now();
        ByteArrayInputStream in = reportService.exportPayrollToCsv(m);
        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-Disposition", "attachment; filename=payroll_" + m.getMonth() + ".csv");
        return ResponseEntity.ok()
                .headers(headers)
                .contentType(MediaType.parseMediaType("text/csv"))
                .body(new InputStreamResource(in));
    }

    @GetMapping("/export/leaves")
    public ResponseEntity<InputStreamResource> exportLeaves() {
        ByteArrayInputStream in = reportService.exportLeavesToCsv();
        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-Disposition", "attachment; filename=leave_history.csv");
        return ResponseEntity.ok()
                .headers(headers)
                .contentType(MediaType.parseMediaType("text/csv"))
                .body(new InputStreamResource(in));
    }
}
