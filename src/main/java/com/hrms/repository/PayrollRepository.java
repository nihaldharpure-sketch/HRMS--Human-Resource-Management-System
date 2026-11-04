package com.hrms.repository;

import com.hrms.entity.Payroll;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface PayrollRepository extends JpaRepository<Payroll, Long> {

    long countByPayrollMonthAndStatus(LocalDate payrollMonth, String status);

    List<Payroll> findByPayrollMonthOrderByEmployeeFirstNameAsc(LocalDate payrollMonth);

    List<Payroll> findByEmployeeIdOrderByPayrollMonthDesc(Long employeeId);

    Optional<Payroll> findByEmployeeIdAndPayrollMonth(Long employeeId, LocalDate payrollMonth);

    boolean existsByEmployeeIdAndPayrollMonth(Long employeeId, LocalDate payrollMonth);

    @Query("SELECT COALESCE(SUM(p.netSalary), 0) FROM Payroll p WHERE p.payrollMonth = :month")
    BigDecimal getTotalNetSalaryForMonth(@Param("month") LocalDate month);

    @Query("SELECT p.payrollMonth, SUM(p.netSalary) FROM Payroll p GROUP BY p.payrollMonth ORDER BY p.payrollMonth DESC")
    List<Object[]> getMonthlyPayrollTotals();
}