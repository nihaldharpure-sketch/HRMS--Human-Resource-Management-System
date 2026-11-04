package com.hrms.controller;

import com.hrms.entity.Employee;
import com.hrms.entity.LeaveRequest;
import com.hrms.entity.LeaveType;
import com.hrms.security.SecurityUtil;
import com.hrms.service.EmployeeService;
import com.hrms.service.LeaveService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;
import java.util.List;

@Controller
@RequestMapping("/leave")
public class LeaveWebController {

    private final LeaveService leaveService;
    private final EmployeeService employeeService;
    private final SecurityUtil securityUtil;

    public LeaveWebController(LeaveService leaveService,
                              EmployeeService employeeService,
                              SecurityUtil securityUtil) {
        this.leaveService = leaveService;
        this.employeeService = employeeService;
        this.securityUtil = securityUtil;
    }

    @GetMapping
    public String leaveDashboard(@RequestParam(required = false) String filter, Model model) {
        List<LeaveRequest> leaves;
        if ("pending".equalsIgnoreCase(filter)) {
            leaves = leaveService.getPendingLeaves();
        } else {
            leaves = leaveService.getAllLeaves();
        }

        List<Employee> employees = employeeService.getAllEmployees();

        model.addAttribute("leaves", leaves);
        model.addAttribute("employees", employees);
        model.addAttribute("leaveTypes", LeaveType.values());
        model.addAttribute("pendingCount", leaveService.countPendingLeaves());
        model.addAttribute("activeFilter", filter != null ? filter : "all");

        securityUtil.getCurrentUser().ifPresent(u -> {
            model.addAttribute("currentUser", u);
            if (u.getEmployee() != null) {
                model.addAttribute("myBalances", leaveService.getOrCreateLeaveBalance(u.getEmployee().getId(), LocalDate.now().getYear()));
            }
        });

        return "leave";
    }

    @PostMapping("/apply")
    public String applyLeave(@RequestParam(required = false) Long employeeId,
                             @RequestParam LeaveType leaveType,
                             @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
                             @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
                             @RequestParam(defaultValue = "false") Boolean halfDay,
                             @RequestParam String reason,
                             RedirectAttributes redirectAttributes) {
        try {
            Long targetEmpId = employeeId;
            if (targetEmpId == null) {
                targetEmpId = securityUtil.getCurrentEmployee().map(Employee::getId).orElse(null);
            }
            if (targetEmpId == null) {
                redirectAttributes.addFlashAttribute("errorMessage", "No employee specified for leave request.");
                return "redirect:/leave";
            }
            leaveService.applyLeave(targetEmpId, leaveType, startDate, endDate, halfDay, reason);
            redirectAttributes.addFlashAttribute("successMessage", "Leave application submitted successfully for review.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/leave";
    }

    @PostMapping("/approve")
    public String approveLeave(@RequestParam Long requestId,
                               @RequestParam(required = false) String comment,
                               RedirectAttributes redirectAttributes) {
        try {
            Employee reviewer = securityUtil.getCurrentEmployee().orElse(null);
            leaveService.approveLeave(requestId, reviewer, comment);
            redirectAttributes.addFlashAttribute("successMessage", "Leave request approved.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/leave";
    }

    @PostMapping("/reject")
    public String rejectLeave(@RequestParam Long requestId,
                              @RequestParam(required = false) String comment,
                              RedirectAttributes redirectAttributes) {
        try {
            Employee reviewer = securityUtil.getCurrentEmployee().orElse(null);
            leaveService.rejectLeave(requestId, reviewer, comment);
            redirectAttributes.addFlashAttribute("successMessage", "Leave request rejected.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/leave";
    }

    @PostMapping("/cancel")
    public String cancelLeave(@RequestParam Long requestId, RedirectAttributes redirectAttributes) {
        try {
            leaveService.cancelLeave(requestId);
            redirectAttributes.addFlashAttribute("successMessage", "Leave request cancelled.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/leave";
    }
}
