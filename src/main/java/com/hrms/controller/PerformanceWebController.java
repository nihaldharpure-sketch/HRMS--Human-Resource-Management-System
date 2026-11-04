package com.hrms.controller;

import com.hrms.entity.Employee;
import com.hrms.entity.PerformanceReview;
import com.hrms.security.SecurityUtil;
import com.hrms.service.EmployeeService;
import com.hrms.service.PerformanceService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/performance")
public class PerformanceWebController {

    private final PerformanceService performanceService;
    private final EmployeeService employeeService;
    private final SecurityUtil securityUtil;

    public PerformanceWebController(PerformanceService performanceService,
                                    EmployeeService employeeService,
                                    SecurityUtil securityUtil) {
        this.performanceService = performanceService;
        this.employeeService = employeeService;
        this.securityUtil = securityUtil;
    }

    @GetMapping
    public String performanceDashboard(Model model) {
        List<PerformanceReview> reviews = performanceService.getAllReviews();
        List<Employee> employees = employeeService.getAllEmployees();

        model.addAttribute("reviews", reviews);
        model.addAttribute("employees", employees);
        model.addAttribute("reviewCount", reviews.size());

        securityUtil.getCurrentUser().ifPresent(u -> {
            model.addAttribute("currentUser", u);
            if (u.getEmployee() != null) {
                model.addAttribute("myReviews", performanceService.getReviewsForEmployee(u.getEmployee().getId()));
            }
        });

        return "performance";
    }

    @PostMapping("/create")
    public String createReview(@RequestParam Long employeeId,
                               @RequestParam String reviewPeriod,
                               @RequestParam(required = false) String goals,
                               @RequestParam(required = false) String kpis,
                               @RequestParam(required = false) Long reviewerId,
                               RedirectAttributes redirectAttributes) {
        try {
            PerformanceReview pr = new PerformanceReview();
            pr.setEmployee(employeeService.getEmployeeById(employeeId));
            if (reviewerId != null) {
                pr.setReviewer(employeeService.getEmployeeById(reviewerId));
            }
            pr.setReviewPeriod(reviewPeriod);
            pr.setGoals(goals);
            pr.setKpis(kpis);
            pr.setStatus("DRAFT");

            performanceService.createReview(pr);
            redirectAttributes.addFlashAttribute("successMessage", "Performance review cycle initiated for " + pr.getEmployee().getFullName() + ".");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/performance";
    }

    @PostMapping("/self-eval")
    public String submitSelfEval(@RequestParam Long reviewId,
                                 @RequestParam String selfAssessment,
                                 @RequestParam Integer selfRating,
                                 RedirectAttributes redirectAttributes) {
        try {
            performanceService.submitSelfAssessment(reviewId, selfAssessment, selfRating);
            redirectAttributes.addFlashAttribute("successMessage", "Self-appraisal submitted for manager review.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/performance";
    }

    @PostMapping("/manager-eval")
    public String submitManagerEval(@RequestParam Long reviewId,
                                    @RequestParam String feedback,
                                    @RequestParam Integer managerRating,
                                    RedirectAttributes redirectAttributes) {
        try {
            Employee reviewer = securityUtil.getCurrentEmployee().orElse(null);
            performanceService.submitManagerReview(reviewId, reviewer, feedback, managerRating);
            redirectAttributes.addFlashAttribute("successMessage", "Manager review and rating recorded.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/performance";
    }
}
