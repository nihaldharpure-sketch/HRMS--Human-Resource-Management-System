package com.hrms.service;

import com.hrms.entity.Attendance;
import com.hrms.entity.Employee;
import com.hrms.entity.Payroll;
import com.hrms.entity.SalaryStructure;
import com.hrms.repository.AttendanceRepository;
import com.hrms.repository.EmployeeRepository;
import com.hrms.repository.PayrollRepository;
import com.hrms.repository.SalaryStructureRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class PayrollService {

    private final PayrollRepository payrollRepository;
    private final SalaryStructureRepository salaryStructureRepository;
    private final EmployeeRepository employeeRepository;
    private final AttendanceRepository attendanceRepository;

    public PayrollService(PayrollRepository payrollRepository,
                          SalaryStructureRepository salaryStructureRepository,
                          EmployeeRepository employeeRepository,
                          AttendanceRepository attendanceRepository) {
        this.payrollRepository = payrollRepository;
        this.salaryStructureRepository = salaryStructureRepository;
        this.employeeRepository = employeeRepository;
        this.attendanceRepository = attendanceRepository;
    }

    public List<Payroll> getPayrollForMonth(LocalDate month) {
        LocalDate normalizedMonth = month.withDayOfMonth(1);
        return payrollRepository.findByPayrollMonthOrderByEmployeeFirstNameAsc(normalizedMonth);
    }

    public List<Payroll> getPayrollHistoryForEmployee(Long employeeId) {
        return payrollRepository.findByEmployeeIdOrderByPayrollMonthDesc(employeeId);
    }

    public Payroll getPayrollById(Long id) {
        return payrollRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Payroll record not found with id: " + id));
    }

    public SalaryStructure getOrCreateSalaryStructure(Long employeeId) {
        return salaryStructureRepository.findByEmployeeId(employeeId)
                .orElseGet(() -> {
                    Employee employee = employeeRepository.findById(employeeId)
                            .orElseThrow(() -> new IllegalArgumentException("Employee not found"));
                    SalaryStructure ss = new SalaryStructure();
                    ss.setEmployee(employee);
                    ss.setBasicSalary(BigDecimal.valueOf(50000));
                    ss.setHra(BigDecimal.valueOf(20000));
                    ss.setConveyance(BigDecimal.valueOf(2500));
                    ss.setMedicalAllowance(BigDecimal.valueOf(1500));
                    ss.setSpecialAllowance(BigDecimal.valueOf(3000));
                    ss.setProvidentFund(BigDecimal.valueOf(6000));
                    ss.setProfessionalTax(BigDecimal.valueOf(200));
                    return salaryStructureRepository.save(ss);
                });
    }

    @Transactional
    public SalaryStructure updateSalaryStructure(Long employeeId, SalaryStructure updated) {
        SalaryStructure current = getOrCreateSalaryStructure(employeeId);
        current.setBasicSalary(updated.getBasicSalary());
        current.setHra(updated.getHra());
        current.setConveyance(updated.getConveyance());
        current.setMedicalAllowance(updated.getMedicalAllowance());
        current.setSpecialAllowance(updated.getSpecialAllowance());
        current.setProvidentFund(updated.getProvidentFund());
        current.setProfessionalTax(updated.getProfessionalTax());
        current.setIncomeTax(updated.getIncomeTax());
        return salaryStructureRepository.save(current);
    }

    @Transactional
    public List<Payroll> generateMonthlyPayroll(LocalDate month) {
        LocalDate normalizedMonth = month.withDayOfMonth(1);
        LocalDate startOfMonth = normalizedMonth;
        LocalDate endOfMonth = normalizedMonth.plusMonths(1).minusDays(1);

        List<Employee> activeEmployees = employeeRepository.findByStatus("ACTIVE");
        List<Payroll> generatedList = new ArrayList<>();

        for (Employee emp : activeEmployees) {
            // Duplicate prevention
            if (payrollRepository.existsByEmployeeIdAndPayrollMonth(emp.getId(), normalizedMonth)) {
                continue;
            }

            SalaryStructure ss = getOrCreateSalaryStructure(emp.getId());

            Payroll payroll = new Payroll();
            payroll.setEmployee(emp);
            payroll.setPayrollMonth(normalizedMonth);
            payroll.setBasicSalary(ss.getBasicSalary());
            payroll.setHra(ss.getHra());
            payroll.setConveyance(ss.getConveyance());
            payroll.setMedicalAllowance(ss.getMedicalAllowance());
            payroll.setAllowances(ss.getTotalAllowances());

            payroll.setProvidentFund(ss.getProvidentFund());
            payroll.setProfessionalTax(ss.getProfessionalTax());
            payroll.setIncomeTax(ss.getIncomeTax());
            payroll.setDeductions(ss.getTotalDeductions());

            // Attendance adjustments (overtime hours calculation)
            List<Attendance> attendances = attendanceRepository.findByEmployeeIdAndAttendanceDateBetweenOrderByAttendanceDateDesc(
                    emp.getId(), startOfMonth, endOfMonth
            );

            double totalOvertimeHours = attendances.stream()
                    .mapToDouble(a -> a.getOvertimeHours() != null ? a.getOvertimeHours() : 0.0)
                    .sum();

            // Hourly rate approx: basicSalary / 160 hours
            BigDecimal hourlyRate = ss.getBasicSalary().divide(BigDecimal.valueOf(160), 2, RoundingMode.HALF_UP);
            BigDecimal overtimePay = hourlyRate.multiply(BigDecimal.valueOf(totalOvertimeHours * 1.5)).setScale(2, RoundingMode.HALF_UP);
            payroll.setOvertimePay(overtimePay);

            payroll.setUnpaidLeaveDeduction(BigDecimal.ZERO);
            payroll.setStatus("DRAFT");
            payroll.calculateNet();

            generatedList.add(payrollRepository.save(payroll));
        }

        return generatedList;
    }

    @Transactional
    public void processAllForMonth(LocalDate month) {
        LocalDate normalizedMonth = month.withDayOfMonth(1);
        List<Payroll> drafts = payrollRepository.findByPayrollMonthOrderByEmployeeFirstNameAsc(normalizedMonth);
        for (Payroll p : drafts) {
            if ("DRAFT".equals(p.getStatus()) || "REVIEWED".equals(p.getStatus())) {
                p.setStatus("PROCESSED");
                p.setProcessedDate(LocalDateTime.now());
                payrollRepository.save(p);
            }
        }
    }

    @Transactional
    public void markPaid(Long payrollId) {
        Payroll p = getPayrollById(payrollId);
        p.setStatus("PAID");
        p.setProcessedDate(LocalDateTime.now());
        payrollRepository.save(p);
    }

    public BigDecimal getTotalMonthlyPayroll(LocalDate month) {
        return payrollRepository.getTotalNetSalaryForMonth(month.withDayOfMonth(1));
    }
}
