package com.hrms.controller;

import com.hrms.entity.Attendance;
import com.hrms.entity.Employee;
import com.hrms.entity.LeaveType;
import com.hrms.entity.UserAccount;
import com.hrms.repository.*;
import com.hrms.security.SecurityUtil;
import com.hrms.service.*;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Optional;

@Controller
@RequestMapping("/portal")
public class SelfServiceWebController {

    private final SecurityUtil securityUtil;
    private final EmployeeService employeeService;
    private final AttendanceService attendanceService;
    private final LeaveService leaveService;
    private final PayrollRepository payrollRepository;
    private final OnboardingService onboardingService;
    private final AttendanceCorrectionRepository correctionRepository;

    public SelfServiceWebController(SecurityUtil securityUtil,
                                   EmployeeService employeeService,
                                   AttendanceService attendanceService,
                                   LeaveService leaveService,
                                   PayrollRepository payrollRepository,
                                   OnboardingService onboardingService,
                                   AttendanceCorrectionRepository correctionRepository) {
        this.securityUtil = securityUtil;
        this.employeeService = employeeService;
        this.attendanceService = attendanceService;
        this.leaveService = leaveService;
        this.payrollRepository = payrollRepository;
        this.onboardingService = onboardingService;
        this.correctionRepository = correctionRepository;
    }

    @GetMapping
    public String portalDashboard(Model model) {
        Optional<UserAccount> currentUser = securityUtil.getCurrentUser();
        if (currentUser.isEmpty()) {
            return "redirect:/login";
        }

        UserAccount user = currentUser.get();
        Employee emp = user.getEmployee();

        // If user is admin and has no linked employee, pick the first employee for demonstration or show empty state
        if (emp == null) {
            var all = employeeService.getAllEmployees();
            if (!all.isEmpty()) {
                emp = all.get(0);
            }
        }

        if (emp != null) {
            Long empId = emp.getId();
            int currentYear = LocalDate.now().getYear();

            model.addAttribute("employee", emp);
            model.addAttribute("todayAttendance", attendanceService.getTodayAttendanceForEmployee(empId).orElse(null));
            model.addAttribute("recentAttendance", attendanceService.getAttendanceForEmployee(empId));
            model.addAttribute("leaveBalance", leaveService.getOrCreateLeaveBalance(empId, currentYear));
            model.addAttribute("myLeaves", leaveService.getLeavesForEmployee(empId));
            model.addAttribute("myPayrolls", payrollRepository.findByEmployeeIdOrderByPayrollMonthDesc(empId));
            model.addAttribute("myTasks", onboardingService.getTasksForEmployee(empId));
            model.addAttribute("myCorrections", attendanceService.getCorrectionsForEmployee(empId));
            model.addAttribute("leaveTypes", LeaveType.values());
        }

        model.addAttribute("currentUser", user);
        return "portal";
    }

    @PostMapping("/check-in")
    public String checkIn(RedirectAttributes redirectAttributes) {
        try {
            Employee emp = securityUtil.getCurrentEmployee().orElse(null);
            if (emp == null) {
                var all = employeeService.getAllEmployees();
                if (!all.isEmpty()) emp = all.get(0);
            }
            if (emp != null) {
                attendanceService.checkIn(emp.getId());
                redirectAttributes.addFlashAttribute("successMessage", "Checked in successfully at " + java.time.LocalTime.now().withNano(0));
            }
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/portal";
    }

    @PostMapping("/check-out")
    public String checkOut(RedirectAttributes redirectAttributes) {
        try {
            Employee emp = securityUtil.getCurrentEmployee().orElse(null);
            if (emp == null) {
                var all = employeeService.getAllEmployees();
                if (!all.isEmpty()) emp = all.get(0);
            }
            if (emp != null) {
                attendanceService.checkOut(emp.getId());
                redirectAttributes.addFlashAttribute("successMessage", "Checked out successfully at " + java.time.LocalTime.now().withNano(0));
            }
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/portal";
    }

    @PostMapping("/leave/apply")
    public String applyLeave(@RequestParam LeaveType leaveType,
                             @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
                             @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
                             @RequestParam(defaultValue = "false") Boolean halfDay,
                             @RequestParam String reason,
                             RedirectAttributes redirectAttributes) {
        try {
            Employee emp = securityUtil.getCurrentEmployee().orElse(null);
            if (emp == null) {
                var all = employeeService.getAllEmployees();
                if (!all.isEmpty()) emp = all.get(0);
            }
            if (emp != null) {
                leaveService.applyLeave(emp.getId(), leaveType, startDate, endDate, halfDay, reason);
                redirectAttributes.addFlashAttribute("successMessage", "Leave application submitted to your manager.");
            }
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/portal";
    }

    @PostMapping("/correction/apply")
    public String applyCorrection(@RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate attendanceDate,
                                  @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime reqCheckIn,
                                  @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime reqCheckOut,
                                  @RequestParam String reason,
                                  RedirectAttributes redirectAttributes) {
        try {
            Employee emp = securityUtil.getCurrentEmployee().orElse(null);
            if (emp == null) {
                var all = employeeService.getAllEmployees();
                if (!all.isEmpty()) emp = all.get(0);
            }
            if (emp != null) {
                attendanceService.submitCorrection(emp.getId(), attendanceDate, reqCheckIn, reqCheckOut, reason);
                redirectAttributes.addFlashAttribute("successMessage", "Attendance correction request submitted.");
            }
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/portal";
    }

    @PostMapping("/task/complete")
    public String completeTask(@RequestParam Long taskId, RedirectAttributes redirectAttributes) {
        try {
            onboardingService.completeTask(taskId);
            redirectAttributes.addFlashAttribute("successMessage", "Onboarding task marked as complete.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/portal";
    }

    @PostMapping("/profile/update")
    public String updateMyProfile(@RequestParam String phone,
                                  @RequestParam(required = false) String addressStreet,
                                  @RequestParam(required = false) String addressCity,
                                  @RequestParam(required = false) String emergencyContactName,
                                  @RequestParam(required = false) String emergencyContactPhone,
                                  RedirectAttributes redirectAttributes) {
        try {
            Employee emp = securityUtil.getCurrentEmployee().orElse(null);
            if (emp != null) {
                emp.setPhone(phone);
                emp.setAddressStreet(addressStreet);
                emp.setAddressCity(addressCity);
                emp.setEmergencyContactName(emergencyContactName);
                emp.setEmergencyContactPhone(emergencyContactPhone);
                employeeService.updateEmployee(emp.getId(), toRequest(emp));
                redirectAttributes.addFlashAttribute("successMessage", "Personal details updated successfully.");
            }
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/portal";
    }

    private com.hrms.dto.EmployeeRequest toRequest(Employee e) {
        com.hrms.dto.EmployeeRequest r = new com.hrms.dto.EmployeeRequest();
        r.setFirstName(e.getFirstName());
        r.setLastName(e.getLastName());
        r.setEmail(e.getEmail());
        r.setPhone(e.getPhone());
        r.setEmployeeCode(e.getEmployeeCode());
        r.setDepartmentId(e.getDepartment() != null ? e.getDepartment().getId() : null);
        r.setDesignationId(e.getDesignation() != null ? e.getDesignation().getId() : null);
        r.setManagerId(e.getManager() != null ? e.getManager().getId() : null);
        r.setAddressStreet(e.getAddressStreet());
        r.setAddressCity(e.getAddressCity());
        r.setEmergencyContactName(e.getEmergencyContactName());
        r.setEmergencyContactPhone(e.getEmergencyContactPhone());
        return r;
    }
}
