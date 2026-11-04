package com.hrms.controller;

import com.hrms.entity.Attendance;
import com.hrms.entity.Employee;
import com.hrms.entity.UserAccount;
import com.hrms.security.SecurityUtil;
import com.hrms.service.AttendanceService;
import com.hrms.service.EmployeeService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Controller
@RequestMapping("/attendance")
public class AttendanceWebController {

    private final AttendanceService attendanceService;
    private final EmployeeService employeeService;
    private final SecurityUtil securityUtil;

    public AttendanceWebController(AttendanceService attendanceService,
                                   EmployeeService employeeService,
                                   SecurityUtil securityUtil) {
        this.attendanceService = attendanceService;
        this.employeeService = employeeService;
        this.securityUtil = securityUtil;
    }

    @GetMapping
    public String attendanceDashboard(@RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
                                      Model model) {
        LocalDate targetDate = date != null ? date : LocalDate.now();
        List<Attendance> attendances = attendanceService.getAttendanceForDate(targetDate);
        List<Employee> allEmployees = employeeService.getAllEmployees();

        long presentCount = attendanceService.countPresentToday();
        long lateCount = attendanceService.countLateToday();
        long onLeaveCount = attendanceService.countOnLeaveToday();
        long absentCount = Math.max(0, employeeService.countActive() - (presentCount + onLeaveCount));

        model.addAttribute("selectedDate", targetDate);
        model.addAttribute("attendances", attendances);
        model.addAttribute("employees", allEmployees);
        model.addAttribute("presentCount", presentCount);
        model.addAttribute("lateCount", lateCount);
        model.addAttribute("onLeaveCount", onLeaveCount);
        model.addAttribute("absentCount", absentCount);
        model.addAttribute("corrections", attendanceService.getPendingCorrections());

        Optional<UserAccount> currentUser = securityUtil.getCurrentUser();
        currentUser.ifPresent(u -> {
            model.addAttribute("currentUser", u);
            if (u.getEmployee() != null) {
                model.addAttribute("todayAttendance", attendanceService.getTodayAttendanceForEmployee(u.getEmployee().getId()).orElse(null));
            }
        });

        return "attendance";
    }

    @PostMapping("/check-in")
    public String checkIn(@RequestParam(required = false) Long employeeId,
                          RedirectAttributes redirectAttributes) {
        try {
            Long targetEmpId = employeeId;
            if (targetEmpId == null) {
                targetEmpId = securityUtil.getCurrentEmployee().map(Employee::getId).orElse(null);
            }
            if (targetEmpId == null) {
                redirectAttributes.addFlashAttribute("errorMessage", "No employee specified for check-in.");
                return "redirect:/attendance";
            }
            attendanceService.checkIn(targetEmpId);
            redirectAttributes.addFlashAttribute("successMessage", "Check-in recorded successfully.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/attendance";
    }

    @PostMapping("/check-out")
    public String checkOut(@RequestParam(required = false) Long employeeId,
                           RedirectAttributes redirectAttributes) {
        try {
            Long targetEmpId = employeeId;
            if (targetEmpId == null) {
                targetEmpId = securityUtil.getCurrentEmployee().map(Employee::getId).orElse(null);
            }
            if (targetEmpId == null) {
                redirectAttributes.addFlashAttribute("errorMessage", "No employee specified for check-out.");
                return "redirect:/attendance";
            }
            attendanceService.checkOut(targetEmpId);
            redirectAttributes.addFlashAttribute("successMessage", "Check-out recorded successfully.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/attendance";
    }

    @PostMapping("/manual")
    public String markManual(@RequestParam Long employeeId,
                             @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
                             @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime checkIn,
                             @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime checkOut,
                             @RequestParam String status,
                             @RequestParam(required = false) String remarks,
                             RedirectAttributes redirectAttributes) {
        try {
            attendanceService.markManualAttendance(employeeId, date, checkIn, checkOut, status, remarks);
            redirectAttributes.addFlashAttribute("successMessage", "Manual attendance record saved.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/attendance?date=" + date;
    }

    @PostMapping("/correction/review")
    public String reviewCorrection(@RequestParam Long correctionId,
                                   @RequestParam boolean approve,
                                   @RequestParam(required = false) String remarks,
                                   RedirectAttributes redirectAttributes) {
        try {
            Employee reviewer = securityUtil.getCurrentEmployee().orElse(null);
            attendanceService.reviewCorrection(correctionId, approve, remarks, reviewer);
            redirectAttributes.addFlashAttribute("successMessage", "Correction request " + (approve ? "approved" : "rejected") + ".");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/attendance";
    }
}
