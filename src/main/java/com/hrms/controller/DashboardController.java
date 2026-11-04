package com.hrms.controller;

import com.hrms.entity.Employee;
import com.hrms.entity.Interview;
import com.hrms.entity.UserAccount;
import com.hrms.repository.*;
import com.hrms.security.SecurityUtil;
import com.hrms.service.AiInsightService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;

@Controller
public class DashboardController {

    private final EmployeeRepository employeeRepository;
    private final AttendanceRepository attendanceRepository;
    private final LeaveRequestRepository leaveRequestRepository;
    private final PayrollRepository payrollRepository;
    private final JobPostingRepository jobPostingRepository;
    private final CandidateRepository candidateRepository;
    private final InterviewRepository interviewRepository;
    private final NotificationRepository notificationRepository;
    private final SecurityUtil securityUtil;
    private final AiInsightService aiInsightService;

    public DashboardController(EmployeeRepository employeeRepository,
                               AttendanceRepository attendanceRepository,
                               LeaveRequestRepository leaveRequestRepository,
                               PayrollRepository payrollRepository,
                               JobPostingRepository jobPostingRepository,
                               CandidateRepository candidateRepository,
                               InterviewRepository interviewRepository,
                               NotificationRepository notificationRepository,
                               SecurityUtil securityUtil,
                               AiInsightService aiInsightService) {
        this.employeeRepository = employeeRepository;
        this.attendanceRepository = attendanceRepository;
        this.leaveRequestRepository = leaveRequestRepository;
        this.payrollRepository = payrollRepository;
        this.jobPostingRepository = jobPostingRepository;
        this.candidateRepository = candidateRepository;
        this.interviewRepository = interviewRepository;
        this.notificationRepository = notificationRepository;
        this.securityUtil = securityUtil;
        this.aiInsightService = aiInsightService;
    }

    @GetMapping("/")
    public String index() {
        return "redirect:/login";
    }

    @GetMapping("/login")
    public String loginPage() {
        return "login";
    }

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        LocalDate today = LocalDate.now();
        long totalEmployees = employeeRepository.count();
        long activeEmployees = employeeRepository.countByStatus("ACTIVE");
        long inactiveEmployees = employeeRepository.countByStatus("INACTIVE") + employeeRepository.countByStatus("TERMINATED");
        long presentToday = attendanceRepository.countByAttendanceDateAndStatus(today, "PRESENT");
        long lateToday = attendanceRepository.countLateEmployees(today);
        long onLeaveToday = attendanceRepository.countByAttendanceDateAndStatus(today, "ON_LEAVE");
        long absentToday = Math.max(0, activeEmployees - (presentToday + onLeaveToday));

        long pendingLeaves = leaveRequestRepository.countByStatus("PENDING");
        long openPositions = jobPostingRepository.countByStatus("OPEN");
        long totalCandidates = candidateRepository.count();

        double attendanceRate = activeEmployees == 0 ? 0 : Math.round((presentToday * 1000.0 / activeEmployees)) / 10.0;
        BigDecimal monthlyPayroll = payrollRepository.getTotalNetSalaryForMonth(today.withDayOfMonth(1));

        // Department distribution
        List<Object[]> deptCounts = employeeRepository.countEmployeesByDepartment();
        List<String> deptLabels = new ArrayList<>();
        List<Long> deptData = new ArrayList<>();
        for (Object[] row : deptCounts) {
            deptLabels.add((String) row[0]);
            deptData.add((Long) row[1]);
        }

        // Recent Employees
        List<Employee> recentEmployees = employeeRepository.findAll();
        if (recentEmployees.size() > 5) {
            recentEmployees = recentEmployees.subList(0, 5);
        }

        // Upcoming Interviews
        List<Interview> upcomingInterviews = interviewRepository.findAllByOrderByScheduledAtDesc();
        if (upcomingInterviews.size() > 4) {
            upcomingInterviews = upcomingInterviews.subList(0, 4);
        }

        // Current User context
        Optional<UserAccount> currentUser = securityUtil.getCurrentUser();
        currentUser.ifPresent(u -> {
            model.addAttribute("currentUser", u);
            model.addAttribute("unreadCount", notificationRepository.countByRecipientIdAndIsReadFalse(u.getId()));
        });

        // AI Insights
        Map<String, Object> insights = aiInsightService.generateExecutiveInsights();
        model.addAttribute("insights", insights);

        model.addAttribute("title", "HRMS Enterprise Operations Dashboard");
        model.addAttribute("employeeCount", totalEmployees);
        model.addAttribute("activeEmployees", activeEmployees);
        model.addAttribute("inactiveEmployees", inactiveEmployees);
        model.addAttribute("presentToday", presentToday);
        model.addAttribute("lateToday", lateToday);
        model.addAttribute("onLeaveToday", onLeaveToday);
        model.addAttribute("absentToday", absentToday);
        model.addAttribute("attendanceRate", attendanceRate);
        model.addAttribute("pendingLeaves", pendingLeaves);
        model.addAttribute("openPositions", openPositions);
        model.addAttribute("totalCandidates", totalCandidates);
        model.addAttribute("monthlyPayroll", monthlyPayroll != null ? monthlyPayroll : BigDecimal.ZERO);
        model.addAttribute("deptLabels", deptLabels);
        model.addAttribute("deptData", deptData);
        model.addAttribute("recentEmployees", recentEmployees);
        model.addAttribute("upcomingInterviews", upcomingInterviews);

        return "dashboard";
    }
}
