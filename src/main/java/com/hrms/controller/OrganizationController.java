package com.hrms.controller;

import com.hrms.entity.Department;
import com.hrms.entity.Designation;
import com.hrms.service.DepartmentService;
import com.hrms.service.DesignationService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
public class OrganizationController {

    private final DepartmentService departmentService;
    private final DesignationService designationService;

    public OrganizationController(DepartmentService departmentService, DesignationService designationService) {
        this.departmentService = departmentService;
        this.designationService = designationService;
    }

    @GetMapping("/departments")
    public List<Department> getDepartments() {
        return departmentService.getAllDepartments();
    }

    @PostMapping("/departments")
    public ResponseEntity<Department> createDepartment(@RequestBody Department department) {
        return ResponseEntity.ok(departmentService.saveDepartment(department));
    }

    @GetMapping("/designations")
    public List<Designation> getDesignations() {
        return designationService.getAllDesignations();
    }

    @PostMapping("/designations")
    public ResponseEntity<Designation> createDesignation(@RequestBody Designation designation) {
        return ResponseEntity.ok(designationService.saveDesignation(designation));
    }
}
