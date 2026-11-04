package com.hrms.controller;

import com.hrms.entity.Department;
import com.hrms.entity.Designation;
import com.hrms.security.SecurityUtil;
import com.hrms.service.DepartmentService;
import com.hrms.service.DesignationService;
import com.hrms.service.EmployeeService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/departments")
public class DepartmentWebController {

    private final DepartmentService departmentService;
    private final DesignationService designationService;
    private final EmployeeService employeeService;
    private final SecurityUtil securityUtil;

    public DepartmentWebController(DepartmentService departmentService,
                                   DesignationService designationService,
                                   EmployeeService employeeService,
                                   SecurityUtil securityUtil) {
        this.departmentService = departmentService;
        this.designationService = designationService;
        this.employeeService = employeeService;
        this.securityUtil = securityUtil;
    }

    @GetMapping
    public String organizationDashboard(Model model) {
        List<Department> departments = departmentService.getAllDepartments();
        List<Designation> designations = designationService.getAllDesignations();

        model.addAttribute("departments", departments);
        model.addAttribute("designations", designations);
        model.addAttribute("employees", employeeService.getAllEmployees());
        model.addAttribute("deptCount", departments.size());
        model.addAttribute("desigCount", designations.size());

        securityUtil.getCurrentUser().ifPresent(u -> model.addAttribute("currentUser", u));
        return "departments";
    }

    @PostMapping("/add")
    public String addDepartment(@RequestParam String name,
                                @RequestParam(required = false) String description,
                                RedirectAttributes redirectAttributes) {
        try {
            Department d = new Department();
            d.setName(name);
            d.setDescription(description);
            departmentService.saveDepartment(d);
            redirectAttributes.addFlashAttribute("successMessage", "Department '" + name + "' created successfully.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/departments";
    }

    @PostMapping("/designations/add")
    public String addDesignation(@RequestParam String title,
                                 @RequestParam(required = false) String description,
                                 RedirectAttributes redirectAttributes) {
        try {
            Designation d = new Designation();
            d.setTitle(title);
            d.setDescription(description);
            designationService.saveDesignation(d);
            redirectAttributes.addFlashAttribute("successMessage", "Designation '" + title + "' created successfully.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/departments";
    }
}
