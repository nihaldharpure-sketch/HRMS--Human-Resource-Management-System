package com.hrms.controller;

import com.hrms.entity.Employee;
import com.hrms.entity.Payroll;
import com.hrms.entity.SalaryStructure;
import com.hrms.security.SecurityUtil;
import com.hrms.service.EmployeeService;
import com.hrms.service.PayrollService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Controller
@RequestMapping("/payroll")
public class PayrollWebController {

    private final PayrollService payrollService;
    private final EmployeeService employeeService;
    private final SecurityUtil securityUtil;

    public PayrollWebController(PayrollService payrollService,
                                EmployeeService employeeService,
                                SecurityUtil securityUtil) {
        this.payrollService = payrollService;
        this.employeeService = employeeService;
        this.securityUtil = securityUtil;
    }

    @GetMapping
    public String payrollDashboard(@RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate month,
                                   Model model) {
        LocalDate selectedMonth = month != null ? month.withDayOfMonth(1) : LocalDate.now().withDayOfMonth(1);
        List<Payroll> payrolls = payrollService.getPayrollForMonth(selectedMonth);

        BigDecimal totalNet = payrollService.getTotalMonthlyPayroll(selectedMonth);
        long processedCount = payrolls.stream().filter(p -> "PROCESSED".equals(p.getStatus()) || "PAID".equals(p.getStatus())).count();
        long draftCount = payrolls.stream().filter(p -> "DRAFT".equals(p.getStatus())).count();

        model.addAttribute("selectedMonth", selectedMonth);
        model.addAttribute("payrolls", payrolls);
        model.addAttribute("totalNet", totalNet != null ? totalNet : BigDecimal.ZERO);
        model.addAttribute("processedCount", processedCount);
        model.addAttribute("draftCount", draftCount);
        model.addAttribute("employees", employeeService.getAllEmployees());

        securityUtil.getCurrentUser().ifPresent(u -> model.addAttribute("currentUser", u));
        return "payroll";
    }

    @PostMapping("/generate")
    public String generateBatch(@RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate month,
                                RedirectAttributes redirectAttributes) {
        try {
            List<Payroll> generated = payrollService.generateMonthlyPayroll(month);
            redirectAttributes.addFlashAttribute("successMessage", "Generated " + generated.size() + " payroll draft records for " + month.getMonth() + ".");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/payroll?month=" + month;
    }

    @PostMapping("/process-all")
    public String processAll(@RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate month,
                             RedirectAttributes redirectAttributes) {
        try {
            payrollService.processAllForMonth(month);
            redirectAttributes.addFlashAttribute("successMessage", "All draft payroll records for " + month.getMonth() + " marked as PROCESSED.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/payroll?month=" + month;
    }

    @PostMapping("/mark-paid")
    public String markPaid(@RequestParam Long payrollId,
                           @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate month,
                           RedirectAttributes redirectAttributes) {
        try {
            payrollService.markPaid(payrollId);
            redirectAttributes.addFlashAttribute("successMessage", "Salary marked as PAID.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/payroll?month=" + month;
    }

    @GetMapping("/payslip/{id}")
    public String viewPayslip(@PathVariable Long id, Model model) {
        Payroll payroll = payrollService.getPayrollById(id);
        model.addAttribute("payroll", payroll);
        model.addAttribute("employee", payroll.getEmployee());
        securityUtil.getCurrentUser().ifPresent(u -> model.addAttribute("currentUser", u));
        return "payslip";
    }

    @PostMapping("/structure")
    public String updateStructure(@RequestParam Long employeeId,
                                  @ModelAttribute SalaryStructure structure,
                                  RedirectAttributes redirectAttributes) {
        try {
            payrollService.updateSalaryStructure(employeeId, structure);
            redirectAttributes.addFlashAttribute("successMessage", "Salary structure updated.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/employees/" + employeeId;
    }
}
