package com.hrms.controller;

import com.hrms.entity.*;
import com.hrms.security.SecurityUtil;
import com.hrms.service.DepartmentService;
import com.hrms.service.DesignationService;
import com.hrms.service.EmployeeService;
import com.hrms.service.RecruitmentService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

@Controller
@RequestMapping("/recruitment")
public class RecruitmentWebController {

    private final RecruitmentService recruitmentService;
    private final DepartmentService departmentService;
    private final DesignationService designationService;
    private final EmployeeService employeeService;
    private final SecurityUtil securityUtil;

    public RecruitmentWebController(RecruitmentService recruitmentService,
                                    DepartmentService departmentService,
                                    DesignationService designationService,
                                    EmployeeService employeeService,
                                    SecurityUtil securityUtil) {
        this.recruitmentService = recruitmentService;
        this.departmentService = departmentService;
        this.designationService = designationService;
        this.employeeService = employeeService;
        this.securityUtil = securityUtil;
    }

    @GetMapping
    public String recruitmentDashboard(@RequestParam(defaultValue = "kanban") String view, Model model) {
        List<JobPosting> jobs = recruitmentService.getAllJobs();
        List<Candidate> allCandidates = recruitmentService.getAllCandidates();
        List<Interview> interviews = recruitmentService.getAllInterviews();

        // Group candidates by Kanban stage
        Map<String, List<Candidate>> kanban = new LinkedHashMap<>();
        String[] stages = {"APPLIED", "SCREENING", "SHORTLISTED", "INTERVIEW", "SELECTED", "OFFER", "HIRED", "REJECTED"};
        for (String st : stages) {
            kanban.put(st, new ArrayList<>());
        }
        for (Candidate c : allCandidates) {
            String st = c.getStage().toUpperCase();
            if (kanban.containsKey(st)) {
                kanban.get(st).add(c);
            } else {
                kanban.get("APPLIED").add(c);
            }
        }

        model.addAttribute("activeView", view);
        model.addAttribute("jobs", jobs);
        model.addAttribute("kanban", kanban);
        model.addAttribute("stages", stages);
        model.addAttribute("allCandidates", allCandidates);
        model.addAttribute("interviews", interviews);
        model.addAttribute("openJobsCount", recruitmentService.countOpenJobs());
        model.addAttribute("candidatesCount", recruitmentService.countCandidates());
        model.addAttribute("departments", departmentService.getAllDepartments());
        model.addAttribute("designations", designationService.getAllDesignations());
        model.addAttribute("employees", employeeService.getAllEmployees());

        securityUtil.getCurrentUser().ifPresent(u -> model.addAttribute("currentUser", u));
        return "recruitment";
    }

    @PostMapping("/jobs/create")
    public String createJob(@RequestParam String title,
                            @RequestParam Long departmentId,
                            @RequestParam Long designationId,
                            @RequestParam(required = false) Long hiringManagerId,
                            @RequestParam(defaultValue = "1") Integer vacancies,
                            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate deadline,
                            @RequestParam(required = false) String location,
                            @RequestParam(required = false) String description,
                            @RequestParam(required = false) String requirements,
                            RedirectAttributes redirectAttributes) {
        try {
            JobPosting job = new JobPosting();
            job.setTitle(title);
            job.setDepartment(departmentService.getDepartmentById(departmentId));
            job.setDesignation(designationService.getDesignationById(designationId));
            if (hiringManagerId != null) {
                job.setHiringManager(employeeService.getEmployeeById(hiringManagerId));
            }
            job.setVacancies(vacancies);
            job.setDeadline(deadline);
            job.setLocation(location != null ? location : "Headquarters");
            job.setDescription(description);
            job.setRequirements(requirements);
            job.setStatus("OPEN");

            recruitmentService.saveJob(job);
            redirectAttributes.addFlashAttribute("successMessage", "Job requisition '" + title + "' published successfully.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/recruitment?view=jobs";
    }

    @PostMapping("/candidates/create")
    public String createCandidate(@RequestParam Long jobPostingId,
                                  @RequestParam String fullName,
                                  @RequestParam String email,
                                  @RequestParam(required = false) String phone,
                                  @RequestParam(defaultValue = "0.0") Double experienceYears,
                                  @RequestParam(required = false) String currentCompany,
                                  @RequestParam(required = false) String expectedSalary,
                                  @RequestParam(required = false) String notes,
                                  RedirectAttributes redirectAttributes) {
        try {
            Candidate c = new Candidate();
            c.setJobPosting(recruitmentService.getJobById(jobPostingId));
            c.setFullName(fullName);
            c.setEmail(email);
            c.setPhone(phone);
            c.setExperienceYears(experienceYears);
            c.setCurrentCompany(currentCompany);
            c.setExpectedSalary(expectedSalary);
            c.setNotes(notes);
            c.setStage("APPLIED");

            recruitmentService.applyCandidate(c);
            redirectAttributes.addFlashAttribute("successMessage", "Candidate application registered for " + fullName + ".");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/recruitment?view=kanban";
    }

    @PostMapping("/candidates/stage")
    public String updateStage(@RequestParam Long candidateId,
                              @RequestParam String stage,
                              @RequestParam(required = false) String rejectionReason,
                              RedirectAttributes redirectAttributes) {
        try {
            recruitmentService.updateCandidateStage(candidateId, stage, rejectionReason);
            redirectAttributes.addFlashAttribute("successMessage", "Candidate stage updated to " + stage + ".");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/recruitment?view=kanban";
    }

    @PostMapping("/candidates/hire")
    public String hireCandidate(@RequestParam Long candidateId,
                                @RequestParam Long departmentId,
                                @RequestParam Long designationId,
                                @RequestParam(required = false) Long managerId,
                                @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate joiningDate,
                                @RequestParam(required = false) BigDecimal basicSalary,
                                RedirectAttributes redirectAttributes) {
        try {
            Employee newEmp = recruitmentService.convertCandidateToEmployee(candidateId, departmentId, designationId, managerId, joiningDate, basicSalary);
            redirectAttributes.addFlashAttribute("successMessage", "Candidate successfully converted to Employee! Employee Code: " + newEmp.getEmployeeCode() + ", and onboarding tasks created.");
            return "redirect:/employees/" + newEmp.getId();
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
            return "redirect:/recruitment?view=kanban";
        }
    }

    @PostMapping("/interviews/schedule")
    public String scheduleInterview(@RequestParam Long candidateId,
                                    @RequestParam Long interviewerId,
                                    @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime scheduledAt,
                                    @RequestParam String interviewType,
                                    @RequestParam(required = false) String meetingLink,
                                    RedirectAttributes redirectAttributes) {
        try {
            Interview in = new Interview();
            in.setCandidate(recruitmentService.getCandidateById(candidateId));
            in.setInterviewer(employeeService.getEmployeeById(interviewerId));
            in.setScheduledAt(scheduledAt);
            in.setInterviewType(interviewType);
            in.setMeetingLink(meetingLink);
            in.setStatus("SCHEDULED");

            recruitmentService.scheduleInterview(in);

            // Also advance candidate to INTERVIEW if in APPLIED or SCREENING
            Candidate c = in.getCandidate();
            if ("APPLIED".equalsIgnoreCase(c.getStage()) || "SCREENING".equalsIgnoreCase(c.getStage()) || "SHORTLISTED".equalsIgnoreCase(c.getStage())) {
                c.setStage("INTERVIEW");
                recruitmentService.applyCandidate(c);
            }

            redirectAttributes.addFlashAttribute("successMessage", "Interview scheduled successfully.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/recruitment?view=interviews";
    }

    @PostMapping("/interviews/feedback")
    public String submitFeedback(@RequestParam Long interviewId,
                                 @RequestParam Integer rating,
                                 @RequestParam String feedback,
                                 @RequestParam String result,
                                 RedirectAttributes redirectAttributes) {
        try {
            recruitmentService.submitInterviewFeedback(interviewId, rating, feedback, result);
            redirectAttributes.addFlashAttribute("successMessage", "Interview evaluation recorded.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/recruitment?view=interviews";
    }
}
