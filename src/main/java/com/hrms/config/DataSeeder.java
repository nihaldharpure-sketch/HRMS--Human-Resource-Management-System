package com.hrms.config;

import com.hrms.entity.*;
import com.hrms.repository.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;

@Component
public class DataSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final DepartmentRepository departmentRepository;
    private final DesignationRepository designationRepository;
    private final EmployeeRepository employeeRepository;
    private final AttendanceRepository attendanceRepository;
    private final LeaveBalanceRepository leaveBalanceRepository;
    private final LeaveRequestRepository leaveRequestRepository;
    private final SalaryStructureRepository salaryStructureRepository;
    private final PayrollRepository payrollRepository;
    private final JobPostingRepository jobPostingRepository;
    private final CandidateRepository candidateRepository;
    private final InterviewRepository interviewRepository;
    private final OnboardingTaskRepository onboardingTaskRepository;
    private final NotificationRepository notificationRepository;
    private final CompanyHolidayRepository holidayRepository;

    public DataSeeder(UserRepository userRepository,
                      PasswordEncoder passwordEncoder,
                      DepartmentRepository departmentRepository,
                      DesignationRepository designationRepository,
                      EmployeeRepository employeeRepository,
                      AttendanceRepository attendanceRepository,
                      LeaveBalanceRepository leaveBalanceRepository,
                      LeaveRequestRepository leaveRequestRepository,
                      SalaryStructureRepository salaryStructureRepository,
                      PayrollRepository payrollRepository,
                      JobPostingRepository jobPostingRepository,
                      CandidateRepository candidateRepository,
                      InterviewRepository interviewRepository,
                      OnboardingTaskRepository onboardingTaskRepository,
                      NotificationRepository notificationRepository,
                      CompanyHolidayRepository holidayRepository) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.departmentRepository = departmentRepository;
        this.designationRepository = designationRepository;
        this.employeeRepository = employeeRepository;
        this.attendanceRepository = attendanceRepository;
        this.leaveBalanceRepository = leaveBalanceRepository;
        this.leaveRequestRepository = leaveRequestRepository;
        this.salaryStructureRepository = salaryStructureRepository;
        this.payrollRepository = payrollRepository;
        this.jobPostingRepository = jobPostingRepository;
        this.candidateRepository = candidateRepository;
        this.interviewRepository = interviewRepository;
        this.onboardingTaskRepository = onboardingTaskRepository;
        this.notificationRepository = notificationRepository;
        this.holidayRepository = holidayRepository;
    }

    @Override
    @Transactional
    public void run(String... args) {
        // 1. Seed Roles & Core Admin Users
        UserAccount admin = userRepository.findByUsername("admin").orElseGet(() -> {
            UserAccount u = new UserAccount();
            u.setUsername("admin");
            u.setPassword(passwordEncoder.encode("admin123"));
            u.setFullName("System Administrator");
            u.setRoles(Set.of(Role.ADMIN, Role.HR_MANAGER, Role.MANAGER, Role.PAYROLL_MANAGER));
            return userRepository.save(u);
        });

        if (userRepository.findByUsername("hrmanager").isEmpty()) {
            UserAccount hr = new UserAccount();
            hr.setUsername("hrmanager");
            hr.setPassword(passwordEncoder.encode("hr123"));
            hr.setFullName("Elena Rostova");
            hr.setRoles(Set.of(Role.HR_MANAGER, Role.MANAGER));
            userRepository.save(hr);
        }

        if (userRepository.findByUsername("payroll").isEmpty()) {
            UserAccount pr = new UserAccount();
            pr.setUsername("payroll");
            pr.setPassword(passwordEncoder.encode("payroll123"));
            pr.setFullName("Marcus Vance");
            pr.setRoles(Set.of(Role.PAYROLL_MANAGER));
            userRepository.save(pr);
        }

        // 2. Seed Departments
        Department hrDept = departmentRepository.findAll().stream()
                .filter(d -> d.getName().equalsIgnoreCase("Human Resources")).findFirst()
                .orElseGet(() -> saveDept("Human Resources", "People operations, talent acquisition, and employee engagement."));

        Department techDept = departmentRepository.findAll().stream()
                .filter(d -> d.getName().toLowerCase().contains("tech") || d.getName().toLowerCase().contains("engineering")).findFirst()
                .orElseGet(() -> saveDept("Technology & Engineering", "Software engineering, infrastructure, and technical architecture."));

        Department finDept = departmentRepository.findAll().stream()
                .filter(d -> d.getName().toLowerCase().contains("finance")).findFirst()
                .orElseGet(() -> saveDept("Finance & Accounting", "Corporate budgeting, payroll, and financial compliance."));

        Department prodDept = departmentRepository.findAll().stream()
                .filter(d -> d.getName().toLowerCase().contains("product")).findFirst()
                .orElseGet(() -> saveDept("Product & Design", "Product management, UX/UI design, and user research."));

        // 3. Seed Designations
        Designation dirHR = designationRepository.findAll().stream()
                .filter(d -> d.getTitle().equalsIgnoreCase("HR Director")).findFirst()
                .orElseGet(() -> saveDesig("HR Director", "Oversees global HR operations."));

        Designation leadEng = designationRepository.findAll().stream()
                .filter(d -> d.getTitle().contains("Principal") || d.getTitle().contains("Lead Engineer")).findFirst()
                .orElseGet(() -> saveDesig("Principal Software Engineer", "Leads core backend services."));

        Designation srEng = designationRepository.findAll().stream()
                .filter(d -> d.getTitle().equalsIgnoreCase("Senior Software Engineer")).findFirst()
                .orElseGet(() -> saveDesig("Senior Software Engineer", "Builds enterprise web applications."));

        Designation uxLead = designationRepository.findAll().stream()
                .filter(d -> d.getTitle().contains("Design")).findFirst()
                .orElseGet(() -> saveDesig("Lead UX Designer", "Directs design systems and product UX."));

        // 4. Seed Core Baseline Employees if not present
        LocalDate now = LocalDate.now();
        Employee sarah = employeeRepository.findByEmail("sarah.johnson@hrms.local")
                .orElseGet(() -> createEmp("Sarah", "Johnson", "sarah.johnson@hrms.local", "EMP-1001", hrDept, dirHR, "ACTIVE", now.minusMonths(24), null, BigDecimal.valueOf(110000)));

        Employee david = employeeRepository.findByEmail("david.lee@hrms.local")
                .orElseGet(() -> createEmp("David", "Lee", "david.lee@hrms.local", "EMP-1002", techDept, leadEng, "ACTIVE", now.minusMonths(14), sarah, BigDecimal.valueOf(125000)));

        Employee priya = employeeRepository.findByEmail("priya.nair@hrms.local")
                .orElseGet(() -> createEmp("Priya", "Nair", "priya.nair@hrms.local", "EMP-1003", hrDept, dirHR, "ACTIVE", now.minusMonths(8), sarah, BigDecimal.valueOf(85000)));

        Employee alex = employeeRepository.findByEmail("alex.chen@hrms.local")
                .orElseGet(() -> createEmp("Alex", "Chen", "alex.chen@hrms.local", "EMP-1004", techDept, srEng, "ACTIVE", now.minusMonths(6), david, BigDecimal.valueOf(95000)));

        Employee maya = employeeRepository.findByEmail("maya.patel@hrms.local")
                .orElseGet(() -> createEmp("Maya", "Patel", "maya.patel@hrms.local", "EMP-1005", prodDept, uxLead, "ACTIVE", now.minusMonths(4), sarah, BigDecimal.valueOf(100000)));

        // 5. SYNCHRONIZE USER ACCOUNTS FOR ALL EMPLOYEES
        // Ensure every employee in the system can log in via username, corporate email, or employee code
        List<Employee> allEmployees = employeeRepository.findAll();
        int currentYear = now.getYear();

        for (Employee emp : allEmployees) {
            // Guarantee leave balance
            if (leaveBalanceRepository.findByEmployeeIdAndYear(emp.getId(), currentYear).isEmpty()) {
                LeaveBalance balance = new LeaveBalance(emp, currentYear);
                leaveBalanceRepository.save(balance);
            }

            // Guarantee salary structure
            if (salaryStructureRepository.findByEmployeeId(emp.getId()).isEmpty()) {
                SalaryStructure ss = new SalaryStructure();
                ss.setEmployee(emp);
                BigDecimal base = BigDecimal.valueOf(60000);
                ss.setBasicSalary(base);
                ss.setHra(base.multiply(BigDecimal.valueOf(0.40)));
                ss.setConveyance(BigDecimal.valueOf(3000));
                ss.setMedicalAllowance(BigDecimal.valueOf(2000));
                ss.setSpecialAllowance(BigDecimal.valueOf(5000));
                ss.setProvidentFund(base.multiply(BigDecimal.valueOf(0.12)));
                ss.setProfessionalTax(BigDecimal.valueOf(200));
                salaryStructureRepository.save(ss);
            }

            // Determine canonical username
            String preferredUsername = emp.getFirstName().toLowerCase().replaceAll("[^a-z0-9]", "");
            if (preferredUsername.isBlank()) {
                preferredUsername = emp.getEmployeeCode().toLowerCase();
            }

            // Check if user already exists for this employee
            var existingUserByEmp = userRepository.findByEmployeeId(emp.getId());
            if (existingUserByEmp.isEmpty()) {
                var existingUserByName = userRepository.findByUsername(preferredUsername);
                if (existingUserByName.isPresent()) {
                    UserAccount u = existingUserByName.get();
                    if (u.getEmployee() == null) {
                        u.setEmployee(emp);
                        userRepository.save(u);
                    }
                } else {
                    UserAccount newAccount = new UserAccount();
                    newAccount.setUsername(preferredUsername);
                    newAccount.setPassword(passwordEncoder.encode("user123"));
                    newAccount.setFullName(emp.getFullName());
                    newAccount.setEmployee(emp);

                    // Assign appropriate roles
                    if ("sarah".equals(preferredUsername)) {
                        newAccount.setRoles(Set.of(Role.HR_MANAGER, Role.MANAGER, Role.EMPLOYEE));
                    } else if ("david".equals(preferredUsername)) {
                        newAccount.setRoles(Set.of(Role.MANAGER, Role.EMPLOYEE));
                    } else if (emp.getEmail() != null && emp.getEmail().contains("nihal")) {
                        newAccount.setRoles(Set.of(Role.ADMIN, Role.HR_MANAGER, Role.EMPLOYEE));
                    } else {
                        newAccount.setRoles(Set.of(Role.EMPLOYEE));
                    }
                    userRepository.save(newAccount);
                }
            }
        }

        // Link admin to dedicated System Administrator employee record if null
        if (admin.getEmployee() == null) {
            Employee adminEmp = employeeRepository.findByEmail("admin@hrms.local").orElseGet(() -> {
                return createEmp("System", "Administrator", "admin@hrms.local", "EMP-1000", hrDept, dirHR, "ACTIVE", now.minusMonths(36), null, BigDecimal.valueOf(150000));
            });
            admin.setEmployee(adminEmp);
            userRepository.save(admin);
        }

        // 6. Seed Attendance logs if none exist for today
        if (attendanceRepository.countByAttendanceDateAndStatus(now, "PRESENT") == 0) {
            saveAttendance(sarah, now, LocalDateTime.of(now, java.time.LocalTime.of(9, 10)), LocalDateTime.of(now, java.time.LocalTime.of(17, 45)), 8.5, 0.5, 0, "PRESENT", "Regular work hours");
            saveAttendance(david, now, LocalDateTime.of(now, java.time.LocalTime.of(9, 15)), null, 0.0, 0.0, 0, "PRESENT", "Checked in via office desk");
            saveAttendance(alex, now, LocalDateTime.of(now, java.time.LocalTime.of(9, 48)), null, 0.0, 0.0, 18, "LATE", "Traffic congestion");
            saveAttendance(priya, now, null, null, 0.0, 0.0, 0, "ON_LEAVE", "Approved medical leave");

            // Past attendance
            saveAttendance(sarah, now.minusDays(1), LocalDateTime.of(now.minusDays(1), java.time.LocalTime.of(9, 20)), LocalDateTime.of(now.minusDays(1), java.time.LocalTime.of(18, 10)), 8.8, 0.8, 0, "PRESENT", "Completed sprint planning");
            saveAttendance(david, now.minusDays(1), LocalDateTime.of(now.minusDays(1), java.time.LocalTime.of(9, 10)), LocalDateTime.of(now.minusDays(1), java.time.LocalTime.of(17, 30)), 8.3, 0.3, 0, "PRESENT", "Architecture design");
            saveAttendance(alex, now.minusDays(1), LocalDateTime.of(now.minusDays(1), java.time.LocalTime.of(9, 25)), LocalDateTime.of(now.minusDays(1), java.time.LocalTime.of(17, 40)), 8.2, 0.2, 0, "PRESENT", "API testing");
        }

        // 7. Seed Leaves if none exist
        if (leaveRequestRepository.count() == 0) {
            LeaveRequest pendingLeave = new LeaveRequest();
            pendingLeave.setEmployee(alex);
            pendingLeave.setLeaveType(LeaveType.CASUAL);
            pendingLeave.setStartDate(now.plusDays(3));
            pendingLeave.setEndDate(now.plusDays(4));
            pendingLeave.setDays(2.0);
            pendingLeave.setReason("Family function and travel.");
            pendingLeave.setStatus("PENDING");
            pendingLeave.setAppliedAt(LocalDateTime.now().minusHours(4));
            leaveRequestRepository.save(pendingLeave);

            LeaveRequest approvedLeave = new LeaveRequest();
            approvedLeave.setEmployee(priya);
            approvedLeave.setLeaveType(LeaveType.SICK);
            approvedLeave.setStartDate(now);
            approvedLeave.setEndDate(now.plusDays(1));
            approvedLeave.setDays(2.0);
            approvedLeave.setReason("Doctor advised rest due to fever.");
            approvedLeave.setStatus("APPROVED");
            approvedLeave.setReviewedBy(sarah);
            approvedLeave.setReviewComment("Get well soon Priya.");
            approvedLeave.setReviewedAt(LocalDateTime.now().minusHours(12));
            leaveRequestRepository.save(approvedLeave);
        }

        // 8. Seed Job Postings & ATS Candidates if none exist
        if (jobPostingRepository.count() == 0) {
            JobPosting javaJob = new JobPosting();
            javaJob.setTitle("Senior Full Stack Java Engineer");
            javaJob.setDepartment(techDept);
            javaJob.setDesignation(srEng);
            javaJob.setLocation("San Francisco, CA / Hybrid");
            javaJob.setVacancies(2);
            javaJob.setDeadline(now.plusDays(30));
            javaJob.setDescription("Build and scale enterprise human resource SaaS platforms with Spring Boot and modern web standards.");
            javaJob.setRequirements("5+ years Java, Spring Boot, MySQL, REST APIs, and modern responsive frontends.");
            javaJob.setHiringManager(david);
            javaJob.setStatus("OPEN");
            jobPostingRepository.save(javaJob);

            JobPosting uxJob = new JobPosting();
            uxJob.setTitle("Lead UX/UI Product Designer");
            uxJob.setDepartment(prodDept);
            uxJob.setDesignation(uxLead);
            uxJob.setLocation("Remote");
            uxJob.setVacancies(1);
            uxJob.setDeadline(now.plusDays(20));
            uxJob.setDescription("Design modern, intuitive enterprise application workflows, component libraries, and design tokens.");
            uxJob.setRequirements("Figma, Tailwind CSS, design systems, usability testing, and B2B SaaS experience.");
            uxJob.setHiringManager(maya);
            uxJob.setStatus("OPEN");
            jobPostingRepository.save(uxJob);

            // Candidates
            Candidate c1 = new Candidate();
            c1.setJobPosting(javaJob);
            c1.setFullName("Daniel Evans");
            c1.setEmail("daniel.evans@example.com");
            c1.setPhone("+1 (555) 234-5678");
            c1.setExperienceYears(6.5);
            c1.setCurrentCompany("CloudTech Labs");
            c1.setExpectedSalary("$120,000");
            c1.setStage("INTERVIEW");
            candidateRepository.save(c1);

            Candidate c2 = new Candidate();
            c2.setJobPosting(javaJob);
            c2.setFullName("Jessica Miller");
            c2.setEmail("jessica.m@example.com");
            c2.setPhone("+1 (555) 876-5432");
            c2.setExperienceYears(4.0);
            c2.setCurrentCompany("Nexus Systems");
            c2.setExpectedSalary("$105,000");
            c2.setStage("SHORTLISTED");
            candidateRepository.save(c2);

            Candidate c3 = new Candidate();
            c3.setJobPosting(uxJob);
            c3.setFullName("Ethan Wright");
            c3.setEmail("ethan.ux@example.com");
            c3.setPhone("+1 (555) 345-6789");
            c3.setExperienceYears(5.2);
            c3.setCurrentCompany("PixelWave Studio");
            c3.setExpectedSalary("$115,000");
            c3.setStage("OFFER");
            candidateRepository.save(c3);

            // Scheduled Interview
            Interview interview = new Interview();
            interview.setCandidate(c1);
            interview.setInterviewer(david);
            interview.setInterviewType("TECHNICAL");
            interview.setScheduledAt(LocalDateTime.now().plusDays(2).withHour(14).withMinute(0));
            interview.setMeetingLink("https://meet.enterprise-hrms.com/tech-eval-101");
            interview.setStatus("SCHEDULED");
            interviewRepository.save(interview);
        }

        // 9. Seed Payroll history if none
        if (payrollRepository.count() == 0) {
            LocalDate lastMonth = now.minusMonths(1).withDayOfMonth(1);
            savePayroll(sarah, lastMonth, BigDecimal.valueOf(110000).divide(BigDecimal.valueOf(12), 2, java.math.RoundingMode.HALF_UP), BigDecimal.valueOf(3500), BigDecimal.valueOf(1200), "PAID");
            savePayroll(david, lastMonth, BigDecimal.valueOf(125000).divide(BigDecimal.valueOf(12), 2, java.math.RoundingMode.HALF_UP), BigDecimal.valueOf(3800), BigDecimal.valueOf(1400), "PAID");
            savePayroll(priya, lastMonth, BigDecimal.valueOf(85000).divide(BigDecimal.valueOf(12), 2, java.math.RoundingMode.HALF_UP), BigDecimal.valueOf(2500), BigDecimal.valueOf(900), "PAID");
            savePayroll(alex, lastMonth, BigDecimal.valueOf(95000).divide(BigDecimal.valueOf(12), 2, java.math.RoundingMode.HALF_UP), BigDecimal.valueOf(2800), BigDecimal.valueOf(1000), "PAID");
            savePayroll(maya, lastMonth, BigDecimal.valueOf(100000).divide(BigDecimal.valueOf(12), 2, java.math.RoundingMode.HALF_UP), BigDecimal.valueOf(3000), BigDecimal.valueOf(1100), "PAID");
        }

        // 10. Seed Onboarding Tasks if none
        if (onboardingTaskRepository.count() == 0) {
            OnboardingTask t1 = new OnboardingTask(maya, "Submit signed identity and direct deposit documents", "HR documents verification", "HR", now.plusDays(7));
            OnboardingTask t2 = new OnboardingTask(maya, "Configure development laptop and security credentials", "IT hardware provisioning", "IT", now.plusDays(3));
            t2.setStatus("COMPLETED");
            t2.setCompletedDate(LocalDate.now().minusDays(1));
            OnboardingTask t3 = new OnboardingTask(maya, "Complete mandatory workspace compliance and security training", "Online compliance course", "EMPLOYEE", now.plusDays(14));
            OnboardingTask t4 = new OnboardingTask(alex, "30-Day Check-in with Engineering Manager", "Managerial 1-on-1 alignment", "MANAGER", now.plusDays(10));
            onboardingTaskRepository.saveAll(List.of(t1, t2, t3, t4));
        }

        // 11. Seed Notifications if none
        if (notificationRepository.count() == 0) {
            Notification n1 = new Notification(admin, "Pending Leave Request", "Alex Chen submitted a casual leave request requiring review.", "LEAVE", "/leave");
            Notification n2 = new Notification(admin, "Interview Scheduled", "Technical interview with Daniel Evans is scheduled for upcoming Thursday.", "RECRUITMENT", "/recruitment");
            notificationRepository.saveAll(List.of(n1, n2));
        }

        // 12. Seed Holidays if none
        if (holidayRepository.count() == 0) {
            holidayRepository.save(new CompanyHoliday(LocalDate.of(currentYear, 1, 1), "New Year's Day", "Public Holiday"));
            holidayRepository.save(new CompanyHoliday(LocalDate.of(currentYear, 5, 26), "Memorial Day", "Federal Holiday"));
            holidayRepository.save(new CompanyHoliday(LocalDate.of(currentYear, 7, 4), "Independence Day", "National Holiday"));
            holidayRepository.save(new CompanyHoliday(LocalDate.of(currentYear, 9, 1), "Labor Day", "Federal Holiday"));
            holidayRepository.save(new CompanyHoliday(LocalDate.of(currentYear, 11, 27), "Thanksgiving Day", "Federal Holiday"));
            holidayRepository.save(new CompanyHoliday(LocalDate.of(currentYear, 12, 25), "Christmas Day", "Federal Holiday"));
        }
    }

    private Department saveDept(String name, String desc) {
        Department d = new Department();
        d.setName(name);
        d.setDescription(desc);
        return departmentRepository.save(d);
    }

    private Designation saveDesig(String title, String desc) {
        Designation d = new Designation();
        d.setTitle(title);
        d.setDescription(desc);
        return designationRepository.save(d);
    }

    private Employee createEmp(String first, String last, String email, String code, Department dept, Designation desig, String status, LocalDate joinDate, Employee manager, BigDecimal baseSalary) {
        Employee e = new Employee();
        e.setFirstName(first);
        e.setLastName(last);
        e.setEmail(email);
        e.setPhone("+1 (555) 019-" + (1000 + (int)(Math.random() * 9000)));
        e.setEmployeeCode(code);
        e.setDepartment(dept);
        e.setDesignation(desig);
        e.setStatus(status);
        e.setDateOfJoining(joinDate);
        e.setEmploymentType("FULL_TIME");
        e.setProbationPeriodMonths(3);
        e.setQualification("B.S. in Computer Science / Business Administration");
        e.setExperienceYears(4.5);
        e.setAddressStreet("120 Market Street, Suite 400");
        e.setAddressCity("San Francisco");
        e.setAddressState("CA");
        e.setAddressZip("94105");
        e.setEmergencyContactName("Emergency Contact");
        e.setEmergencyContactPhone("+1 (555) 999-0000");
        e.setEmergencyContactRelation("Spouse / Sibling");
        e.setBankName("Silicon Valley Trust");
        e.setBankAccountNumber("**** **** 8921");
        e.setBankIfsc("SVT0002134");
        e.setManager(manager);
        return employeeRepository.save(e);
    }

    private void saveAttendance(Employee emp, LocalDate date, LocalDateTime in, LocalDateTime out, double hours, double ot, int late, String status, String remarks) {
        Attendance a = new Attendance();
        a.setEmployee(emp);
        a.setAttendanceDate(date);
        a.setCheckIn(in);
        a.setCheckOut(out);
        a.setTotalHours(hours);
        a.setOvertimeHours(ot);
        a.setLateMinutes(late);
        a.setStatus(status);
        a.setRemarks(remarks);
        attendanceRepository.save(a);
    }

    private void savePayroll(Employee emp, LocalDate month, BigDecimal base, BigDecimal allowances, BigDecimal deductions, String status) {
        Payroll p = new Payroll();
        p.setEmployee(emp);
        p.setPayrollMonth(month);
        p.setBasicSalary(base);
        p.setAllowances(allowances);
        p.setDeductions(deductions);
        p.setNetSalary(base.add(allowances).subtract(deductions));
        p.setStatus(status);
        p.setProcessedDate(LocalDateTime.now());
        payrollRepository.save(p);
    }
}
