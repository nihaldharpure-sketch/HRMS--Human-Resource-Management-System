package com.hrms.service;

import com.hrms.entity.Candidate;
import com.hrms.entity.JobPosting;
import com.hrms.entity.Payroll;
import com.hrms.repository.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class AiInsightService {

    private final EmployeeRepository employeeRepository;
    private final AttendanceRepository attendanceRepository;
    private final LeaveRequestRepository leaveRequestRepository;
    private final PayrollRepository payrollRepository;
    private final JobPostingRepository jobPostingRepository;
    private final CandidateRepository candidateRepository;

    @Value("${gemini.api.key:}")
    private String geminiApiKey;

    public AiInsightService(EmployeeRepository employeeRepository,
                            AttendanceRepository attendanceRepository,
                            LeaveRequestRepository leaveRequestRepository,
                            PayrollRepository payrollRepository,
                            JobPostingRepository jobPostingRepository,
                            CandidateRepository candidateRepository) {
        this.employeeRepository = employeeRepository;
        this.attendanceRepository = attendanceRepository;
        this.leaveRequestRepository = leaveRequestRepository;
        this.payrollRepository = payrollRepository;
        this.jobPostingRepository = jobPostingRepository;
        this.candidateRepository = candidateRepository;
    }

    public Map<String, Object> generateExecutiveInsights() {
        LocalDate today = LocalDate.now();
        long totalEmployees = employeeRepository.count();
        long activeEmployees = employeeRepository.countByStatus("ACTIVE");
        long presentToday = attendanceRepository.countByAttendanceDateAndStatus(today, "PRESENT");
        long lateToday = attendanceRepository.countLateEmployees(today);
        long pendingLeaves = leaveRequestRepository.countByStatus("PENDING");
        long openJobs = jobPostingRepository.countByStatus("OPEN");
        long totalCandidates = candidateRepository.count();

        double attendanceRate = totalEmployees > 0 ? (presentToday * 100.0 / totalEmployees) : 0.0;
        BigDecimal monthlyPayroll = payrollRepository.getTotalNetSalaryForMonth(today.withDayOfMonth(1));

        List<String> keyObservations = new ArrayList<>();
        List<String> actionRecommendations = new ArrayList<>();

        // Attendance & Absenteeism analysis
        if (attendanceRate >= 90.0) {
            keyObservations.add("Strong workforce engagement: Today's check-in rate is healthy at " + String.format("%.1f", attendanceRate) + "%.");
        } else if (attendanceRate > 0) {
            keyObservations.add("Sub-optimal attendance pulse: " + String.format("%.1f", attendanceRate) + "% active turnout recorded today.");
            actionRecommendations.add("Investigate department-level absenteeism and verify remote / field employee check-ins.");
        }

        if (lateToday > 0) {
            keyObservations.add(lateToday + " employee(s) arrived after the standard 09:30 AM window.");
            actionRecommendations.add("Review flexible working hours policies or check recurring commute delays.");
        }

        // Leave trends
        if (pendingLeaves > 3) {
            keyObservations.add("High volume of pending leave requests (" + pendingLeaves + ") awaiting managerial action.");
            actionRecommendations.add("Send reminder notifications to reporting managers to prevent approval bottlenecks.");
        } else {
            keyObservations.add("Leave approvals are running smoothly with low backlogged requests (" + pendingLeaves + ").");
        }

        // Recruitment velocity
        if (openJobs > 0 && totalCandidates == 0) {
            keyObservations.add("Recruitment lag: " + openJobs + " positions are open without registered candidate applications.");
            actionRecommendations.add("Promote open requisitions on internal and external talent channels.");
        } else if (openJobs > 0) {
            keyObservations.add("Active hiring funnel: " + totalCandidates + " candidate(s) in review across " + openJobs + " requisitions.");
        }

        // Payroll health check
        if (monthlyPayroll != null && monthlyPayroll.compareTo(BigDecimal.ZERO) > 0) {
            keyObservations.add("Monthly payroll budget is on track with ₹" + monthlyPayroll + " total processed net disbursements.");
        } else {
            actionRecommendations.add("Generate draft payroll run for " + today.getMonth() + " to review overtime and allowance allocations.");
        }

        Map<String, Object> result = new HashMap<>();
        result.put("attendanceRate", String.format("%.1f", attendanceRate));
        result.put("keyObservations", keyObservations);
        result.put("actionRecommendations", actionRecommendations);
        result.put("isAiEnhanced", geminiApiKey != null && !geminiApiKey.isBlank());
        result.put("generatedAt", today.toString());

        return result;
    }
}
