package com.hrms.service;

import com.hrms.dto.EmployeeRequest;
import com.hrms.entity.*;
import com.hrms.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Service
public class RecruitmentService {

    private final JobPostingRepository jobPostingRepository;
    private final CandidateRepository candidateRepository;
    private final InterviewRepository interviewRepository;
    private final OnboardingTaskRepository onboardingTaskRepository;
    private final EmployeeService employeeService;

    public RecruitmentService(JobPostingRepository jobPostingRepository,
                              CandidateRepository candidateRepository,
                              InterviewRepository interviewRepository,
                              OnboardingTaskRepository onboardingTaskRepository,
                              EmployeeService employeeService) {
        this.jobPostingRepository = jobPostingRepository;
        this.candidateRepository = candidateRepository;
        this.interviewRepository = interviewRepository;
        this.onboardingTaskRepository = onboardingTaskRepository;
        this.employeeService = employeeService;
    }

    public List<JobPosting> getAllJobs() {
        return jobPostingRepository.findAllByOrderByPostedDateDesc();
    }

    public List<JobPosting> getOpenJobs() {
        return jobPostingRepository.findByStatusOrderByPostedDateDesc("OPEN");
    }

    public JobPosting getJobById(Long id) {
        return jobPostingRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Job posting not found with id: " + id));
    }

    public JobPosting saveJob(JobPosting job) {
        return jobPostingRepository.save(job);
    }

    public List<Candidate> getAllCandidates() {
        return candidateRepository.findAll();
    }

    public List<Candidate> getCandidatesByStage(String stage) {
        return candidateRepository.findByStage(stage);
    }

    public Candidate getCandidateById(Long id) {
        return candidateRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Candidate not found with id: " + id));
    }

    @Transactional
    public Candidate applyCandidate(Candidate candidate) {
        return candidateRepository.save(candidate);
    }

    @Transactional
    public Candidate updateCandidateStage(Long candidateId, String newStage, String rejectionReason) {
        Candidate candidate = getCandidateById(candidateId);
        candidate.setStage(newStage.toUpperCase());
        if ("REJECTED".equalsIgnoreCase(newStage)) {
            candidate.setRejectionReason(rejectionReason);
        }
        return candidateRepository.save(candidate);
    }

    @Transactional
    public Employee convertCandidateToEmployee(Long candidateId, Long departmentId, Long designationId, Long managerId, LocalDate joiningDate, BigDecimal basicSalary) {
        Candidate candidate = getCandidateById(candidateId);
        if (candidate.getHiredEmployee() != null) {
            return candidate.getHiredEmployee();
        }

        String[] parts = candidate.getFullName().trim().split("\\s+", 2);
        String firstName = parts[0];
        String lastName = parts.length > 1 ? parts[1] : "Employee";

        EmployeeRequest req = new EmployeeRequest();
        req.setFirstName(firstName);
        req.setLastName(lastName);
        req.setEmail(candidate.getEmail());
        req.setPhone(candidate.getPhone());
        req.setDepartmentId(departmentId != null ? departmentId : (candidate.getJobPosting().getDepartment() != null ? candidate.getJobPosting().getDepartment().getId() : null));
        req.setDesignationId(designationId != null ? designationId : (candidate.getJobPosting().getDesignation() != null ? candidate.getJobPosting().getDesignation().getId() : null));
        req.setManagerId(managerId);
        req.setDateOfJoining(joiningDate != null ? joiningDate : LocalDate.now());
        req.setBasicSalary(basicSalary != null ? basicSalary : BigDecimal.valueOf(55000));
        req.setStatus("ACTIVE");

        Employee employee = employeeService.createEmployee(req);

        // Link candidate
        candidate.setStage("HIRED");
        candidate.setHiredEmployee(employee);
        candidateRepository.save(candidate);

        // Generate Onboarding Tasks Checklist
        LocalDate join = employee.getDateOfJoining();
        onboardingTaskRepository.save(new OnboardingTask(employee, "Submit ID & Tax Documents", "Submit PAN, Aadhaar, and bank passbook", "EMPLOYEE", join.plusDays(3)));
        onboardingTaskRepository.save(new OnboardingTask(employee, "IT Hardware & Laptop Setup", "Provision enterprise workstation and setup VPN/Slack", "IT", join.plusDays(1)));
        onboardingTaskRepository.save(new OnboardingTask(employee, "HR & Company Orientation", "Attend HR welcoming session and company policies review", "HR", join.plusDays(2)));
        onboardingTaskRepository.save(new OnboardingTask(employee, "Set 90-Day Probation Objectives", "Manager meeting to assign initial team goals and KPIs", "MANAGER", join.plusDays(7)));

        return employee;
    }

    // Interview Scheduling
    public List<Interview> getAllInterviews() {
        return interviewRepository.findAllByOrderByScheduledAtDesc();
    }

    public List<Interview> getInterviewsForCandidate(Long candidateId) {
        return interviewRepository.findByCandidateIdOrderByScheduledAtDesc(candidateId);
    }

    @Transactional
    public Interview scheduleInterview(Interview interview) {
        return interviewRepository.save(interview);
    }

    @Transactional
    public Interview submitInterviewFeedback(Long interviewId, Integer rating, String feedback, String result) {
        Interview interview = interviewRepository.findById(interviewId)
                .orElseThrow(() -> new IllegalArgumentException("Interview not found with id: " + interviewId));

        interview.setRating(rating);
        interview.setFeedback(feedback);
        interview.setResult(result != null ? result : "PASSED");
        interview.setStatus("COMPLETED");

        Interview saved = interviewRepository.save(interview);

        // If interview passed, advance candidate to SELECTED or OFFER
        if ("PASSED".equalsIgnoreCase(result)) {
            Candidate candidate = interview.getCandidate();
            if ("INTERVIEW".equalsIgnoreCase(candidate.getStage()) || "SHORTLISTED".equalsIgnoreCase(candidate.getStage())) {
                candidate.setStage("SELECTED");
                candidateRepository.save(candidate);
            }
        }

        return saved;
    }

    public long countOpenJobs() {
        return jobPostingRepository.countByStatus("OPEN");
    }

    public long countCandidates() {
        return candidateRepository.count();
    }
}
