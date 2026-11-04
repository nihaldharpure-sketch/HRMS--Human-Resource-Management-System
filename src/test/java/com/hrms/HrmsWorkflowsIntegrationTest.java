package com.hrms;

import com.hrms.dto.EmployeeRequest;
import com.hrms.entity.*;
import com.hrms.repository.*;
import com.hrms.service.*;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@Transactional
class HrmsWorkflowsIntegrationTest {

    @Autowired
    private EmployeeService employeeService;

    @Autowired
    private DepartmentService departmentService;

    @Autowired
    private DesignationService designationService;

    @Autowired
    private AttendanceService attendanceService;

    @Autowired
    private LeaveService leaveService;

    @Autowired
    private PayrollService payrollService;

    @Autowired
    private RecruitmentService recruitmentService;

    @Autowired
    private OnboardingService onboardingService;

    @Autowired
    private EmployeeRepository employeeRepository;

    @Autowired
    private DepartmentRepository departmentRepository;

    @Autowired
    private DesignationRepository designationRepository;

    @Autowired
    private AttendanceRepository attendanceRepository;

    @Autowired
    private LeaveRequestRepository leaveRequestRepository;

    @Autowired
    private PayrollRepository payrollRepository;

    @Test
    @DisplayName("Test Employee Creation, Code Generation, and Leave Quota Initialization")
    void testEmployeeCreationAndQuotaInit() {
        Department dept = departmentRepository.findAll().get(0);
        Designation desig = designationRepository.findAll().get(0);

        EmployeeRequest req = new EmployeeRequest();
        req.setFirstName("Robert");
        req.setLastName("Miller");
        req.setEmail("robert.miller." + System.currentTimeMillis() + "@hrms.local");
        req.setPhone("+1 (555) 789-0123");
        req.setDepartmentId(dept.getId());
        req.setDesignationId(desig.getId());
        req.setDateOfJoining(LocalDate.now());
        req.setBasicSalary(BigDecimal.valueOf(80000));

        Employee emp = employeeService.createEmployee(req);
        assertNotNull(emp.getId());
        assertNotNull(emp.getEmployeeCode());
        assertTrue(emp.getEmployeeCode().startsWith("EMP-"));

        // Verify Leave Balance Initialized
        LeaveBalance balance = leaveService.getOrCreateLeaveBalance(emp.getId(), LocalDate.now().getYear());
        assertNotNull(balance);
        assertEquals(18.0, balance.getAnnualRemaining());
        assertEquals(12.0, balance.getCasualRemaining());
        assertEquals(10.0, balance.getSickRemaining());
    }

    @Test
    @DisplayName("Test Attendance Check-in and Check-out calculation")
    void testAttendanceLifecycle() {
        Employee emp = employeeRepository.findAll().get(0);
        LocalDate today = LocalDate.now();

        // Ensure clean test state for today
        attendanceRepository.findByEmployeeIdAndAttendanceDate(emp.getId(), today)
                .ifPresent(attendanceRepository::delete);

        Attendance checkedIn = attendanceService.checkIn(emp.getId());
        assertNotNull(checkedIn);
        assertNotNull(checkedIn.getCheckIn());
        assertNull(checkedIn.getCheckOut());

        // Check Out
        Attendance checkedOut = attendanceService.checkOut(emp.getId());
        assertNotNull(checkedOut.getCheckOut());
        assertNotNull(checkedOut.getTotalHours());
    }

    @Test
    @DisplayName("Test Leave Application, Overlap Prevention, and Balance Deduction")
    void testLeaveWorkflowAndDeduction() {
        Employee emp = employeeRepository.findAll().get(0);
        LocalDate start = LocalDate.now().plusWeeks(2);
        LocalDate end = start.plusDays(2); // 3 days

        LeaveBalance before = leaveService.getOrCreateLeaveBalance(emp.getId(), start.getYear());
        double initialAnnual = before.getAnnualRemaining();

        LeaveRequest request = leaveService.applyLeave(emp.getId(), LeaveType.ANNUAL, start, end, false, "Annual vacation");
        assertNotNull(request.getId());
        assertEquals("PENDING", request.getStatus());

        // Overlap prevention test
        assertThrows(IllegalArgumentException.class, () -> {
            leaveService.applyLeave(emp.getId(), LeaveType.ANNUAL, start, end, false, "Conflicting dates");
        });

        // Approve Leave
        LeaveRequest approved = leaveService.approveLeave(request.getId(), emp, "Approved by manager");
        assertEquals("APPROVED", approved.getStatus());

        LeaveBalance after = leaveService.getOrCreateLeaveBalance(emp.getId(), start.getYear());
        assertTrue(after.getAnnualRemaining() < initialAnnual);
    }

    @Test
    @DisplayName("Test Monthly Payroll Generation and Duplicate Run Protection")
    void testPayrollGenerationAndDuplicateProtection() {
        LocalDate month = LocalDate.now().plusMonths(3).withDayOfMonth(1);

        List<Payroll> batch = payrollService.generateMonthlyPayroll(month);
        assertNotNull(batch);

        // Attempting to generate again for same month must not duplicate records
        List<Payroll> secondBatch = payrollService.generateMonthlyPayroll(month);
        assertTrue(secondBatch.isEmpty(), "Duplicate payroll runs for same period must be prevented");
    }

    @Test
    @DisplayName("Test Recruitment to Onboarding Conversion Workflow")
    void testRecruitmentToOnboardingConversion() {
        Department dept = departmentRepository.findAll().get(0);
        Designation desig = designationRepository.findAll().get(0);

        JobPosting job = new JobPosting();
        job.setTitle("Cloud Architect");
        job.setDepartment(dept);
        job.setDesignation(desig);
        job.setStatus("OPEN");
        job = recruitmentService.saveJob(job);

        Candidate candidate = new Candidate();
        candidate.setJobPosting(job);
        candidate.setFullName("Arthur Dent");
        candidate.setEmail("arthur.dent." + System.currentTimeMillis() + "@example.com");
        candidate.setStage("OFFER");
        candidate = recruitmentService.applyCandidate(candidate);

        // Convert Candidate to Employee & Onboard
        Employee newEmployee = recruitmentService.convertCandidateToEmployee(
                candidate.getId(),
                dept.getId(),
                desig.getId(),
                null,
                LocalDate.now(),
                BigDecimal.valueOf(90000)
        );

        assertNotNull(newEmployee.getId());
        assertEquals("Arthur", newEmployee.getFirstName());
        assertEquals("Dent", newEmployee.getLastName());

        // Check Onboarding Tasks generated
        List<OnboardingTask> tasks = onboardingService.getTasksForEmployee(newEmployee.getId());
        assertFalse(tasks.isEmpty(), "Onboarding tasks must be automatically generated upon hiring");
        assertEquals("PENDING", tasks.get(0).getStatus());

        // Complete a task
        onboardingService.completeTask(tasks.get(0).getId());
        List<OnboardingTask> updatedTasks = onboardingService.getTasksForEmployee(newEmployee.getId());
        assertEquals("COMPLETED", updatedTasks.get(0).getStatus());
    }
}
