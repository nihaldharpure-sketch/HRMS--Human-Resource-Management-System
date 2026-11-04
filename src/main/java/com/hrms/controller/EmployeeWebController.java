package com.hrms.controller;

import com.hrms.dto.EmployeeRequest;
import com.hrms.entity.Employee;
import com.hrms.entity.SalaryStructure;
import com.hrms.repository.AttendanceRepository;
import com.hrms.repository.LeaveBalanceRepository;
import com.hrms.repository.LeaveRequestRepository;
import com.hrms.repository.OnboardingTaskRepository;
import com.hrms.repository.PayrollRepository;
import com.hrms.security.SecurityUtil;
import com.hrms.service.DepartmentService;
import com.hrms.service.DesignationService;
import com.hrms.service.EmployeeService;
import com.hrms.service.PayrollService;
import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;
import java.util.List;

@Controller
@RequestMapping("/employees")
public class EmployeeWebController {

    private final EmployeeService employeeService;
    private final DepartmentService departmentService;
    private final DesignationService designationService;
    private final AttendanceRepository attendanceRepository;
    private final LeaveRequestRepository leaveRequestRepository;
    private final LeaveBalanceRepository leaveBalanceRepository;
    private final PayrollRepository payrollRepository;
    private final PayrollService payrollService;
    private final OnboardingTaskRepository onboardingTaskRepository;
    private final SecurityUtil securityUtil;

    public EmployeeWebController(EmployeeService employeeService,
                                 DepartmentService departmentService,
                                 DesignationService designationService,
                                 AttendanceRepository attendanceRepository,
                                 LeaveRequestRepository leaveRequestRepository,
                                 LeaveBalanceRepository leaveBalanceRepository,
                                 PayrollRepository payrollRepository,
                                 PayrollService payrollService,
                                 OnboardingTaskRepository onboardingTaskRepository,
                                 SecurityUtil securityUtil) {
        this.employeeService = employeeService;
        this.departmentService = departmentService;
        this.designationService = designationService;
        this.attendanceRepository = attendanceRepository;
        this.leaveRequestRepository = leaveRequestRepository;
        this.leaveBalanceRepository = leaveBalanceRepository;
        this.payrollRepository = payrollRepository;
        this.payrollService = payrollService;
        this.onboardingTaskRepository = onboardingTaskRepository;
        this.securityUtil = securityUtil;
    }

    @GetMapping
    public String listEmployees(@RequestParam(required = false) String search,
                                @RequestParam(required = false) Long departmentId,
                                @RequestParam(required = false) String status,
                                Model model) {
        List<Employee> employees;
        if ((search != null && !search.isBlank()) || departmentId != null || (status != null && !status.isBlank())) {
            employees = employeeService.searchEmployees(search, departmentId, status);
        } else {
            employees = employeeService.getAllEmployees();
        }

        model.addAttribute("employees", employees);
        model.addAttribute("departments", departmentService.getAllDepartments());
        model.addAttribute("totalCount", employeeService.countTotal());
        model.addAttribute("activeCount", employeeService.countActive());
        model.addAttribute("inactiveCount", employeeService.countInactive());
        model.addAttribute("onLeaveCount", employeeService.countOnLeave());
        model.addAttribute("searchQuery", search);
        model.addAttribute("selectedDept", departmentId);
        model.addAttribute("selectedStatus", status);

        securityUtil.getCurrentUser().ifPresent(u -> model.addAttribute("currentUser", u));
        return "employees";
    }

    @GetMapping("/add")
    public String addEmployeeForm(Model model) {
        model.addAttribute("employeeRequest", new EmployeeRequest());
        model.addAttribute("departments", departmentService.getAllDepartments());
        model.addAttribute("designations", designationService.getAllDesignations());
        model.addAttribute("managers", employeeService.getAllEmployees());
        securityUtil.getCurrentUser().ifPresent(u -> model.addAttribute("currentUser", u));
        return "employee-form";
    }

    @PostMapping("/add")
    public String saveEmployee(@Valid @ModelAttribute EmployeeRequest request,
                               BindingResult bindingResult,
                               Model model,
                               RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            model.addAttribute("departments", departmentService.getAllDepartments());
            model.addAttribute("designations", designationService.getAllDesignations());
            model.addAttribute("managers", employeeService.getAllEmployees());
            return "employee-form";
        }
        try {
            Employee saved = employeeService.createEmployee(request);
            redirectAttributes.addFlashAttribute("successMessage", "Employee " + saved.getFullName() + " (" + saved.getEmployeeCode() + ") created successfully.");
            return "redirect:/employees/" + saved.getId();
        } catch (IllegalArgumentException ex) {
            model.addAttribute("errorMessage", ex.getMessage());
            model.addAttribute("departments", departmentService.getAllDepartments());
            model.addAttribute("designations", designationService.getAllDesignations());
            model.addAttribute("managers", employeeService.getAllEmployees());
            return "employee-form";
        }
    }

    @GetMapping("/{id}")
    public String viewProfile(@PathVariable Long id, Model model) {
        Employee employee = employeeService.getEmployeeById(id);
        int currentYear = LocalDate.now().getYear();

        model.addAttribute("employee", employee);
        model.addAttribute("attendances", attendanceRepository.findByEmployeeIdOrderByAttendanceDateDesc(id));
        model.addAttribute("leaves", leaveRequestRepository.findByEmployeeIdOrderByAppliedAtDesc(id));
        model.addAttribute("leaveBalance", leaveBalanceRepository.findByEmployeeIdAndYear(id, currentYear).orElse(null));
        model.addAttribute("payrolls", payrollRepository.findByEmployeeIdOrderByPayrollMonthDesc(id));
        model.addAttribute("salaryStructure", payrollService.getOrCreateSalaryStructure(id));
        model.addAttribute("onboardingTasks", onboardingTaskRepository.findByEmployeeIdOrderByDueDateAsc(id));
        model.addAttribute("departments", departmentService.getAllDepartments());
        model.addAttribute("designations", designationService.getAllDesignations());
        model.addAttribute("managers", employeeService.getAllEmployees());

        securityUtil.getCurrentUser().ifPresent(u -> model.addAttribute("currentUser", u));
        return "employee-profile";
    }

    @PostMapping("/edit/{id}")
    public String updateEmployee(@PathVariable Long id,
                                 @ModelAttribute EmployeeRequest request,
                                 RedirectAttributes redirectAttributes) {
        try {
            employeeService.updateEmployee(id, request);
            redirectAttributes.addFlashAttribute("successMessage", "Employee profile updated successfully.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/employees/" + id;
    }

    @PostMapping("/exit/{id}")
    public String recordExit(@PathVariable Long id,
                             @RequestParam LocalDate exitDate,
                             @RequestParam String exitReason,
                             @RequestParam String exitStatus,
                             RedirectAttributes redirectAttributes) {
        try {
            employeeService.recordExit(id, exitDate, exitReason, exitStatus);
            redirectAttributes.addFlashAttribute("successMessage", "Exit & separation details recorded.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/employees/" + id;
    }
}
