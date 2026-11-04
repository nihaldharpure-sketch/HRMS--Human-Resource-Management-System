package com.hrms.entity;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "payroll", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"employee_id", "payrollMonth"})
})
public class Payroll {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "employee_id", nullable = false)
    private Employee employee;

    @Column(nullable = false)
    private LocalDate payrollMonth; // Stored as 1st day of month, e.g. 2026-08-01

    private BigDecimal basicSalary = BigDecimal.ZERO;
    private BigDecimal allowances = BigDecimal.ZERO;
    private BigDecimal hra = BigDecimal.ZERO;
    private BigDecimal conveyance = BigDecimal.ZERO;
    private BigDecimal medicalAllowance = BigDecimal.ZERO;
    private BigDecimal overtimePay = BigDecimal.ZERO;

    private BigDecimal deductions = BigDecimal.ZERO;
    private BigDecimal providentFund = BigDecimal.ZERO;
    private BigDecimal professionalTax = BigDecimal.ZERO;
    private BigDecimal incomeTax = BigDecimal.ZERO;
    private BigDecimal unpaidLeaveDeduction = BigDecimal.ZERO;

    private BigDecimal netSalary = BigDecimal.ZERO;

    // DRAFT, REVIEWED, PROCESSED, PAID
    @Column(nullable = false)
    private String status = "DRAFT";

    private String paymentMethod = "DIRECT_DEPOSIT";
    private LocalDateTime processedDate;
    private String notes;

    public Payroll() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Employee getEmployee() {
        return employee;
    }

    public void setEmployee(Employee employee) {
        this.employee = employee;
    }

    public LocalDate getPayrollMonth() {
        return payrollMonth;
    }

    public void setPayrollMonth(LocalDate payrollMonth) {
        this.payrollMonth = payrollMonth;
    }

    public BigDecimal getBasicSalary() {
        return basicSalary != null ? basicSalary : BigDecimal.ZERO;
    }

    public void setBasicSalary(BigDecimal basicSalary) {
        this.basicSalary = basicSalary;
    }

    public BigDecimal getAllowances() {
        return allowances != null ? allowances : BigDecimal.ZERO;
    }

    public void setAllowances(BigDecimal allowances) {
        this.allowances = allowances;
    }

    public BigDecimal getHra() {
        return hra != null ? hra : BigDecimal.ZERO;
    }

    public void setHra(BigDecimal hra) {
        this.hra = hra;
    }

    public BigDecimal getConveyance() {
        return conveyance != null ? conveyance : BigDecimal.ZERO;
    }

    public void setConveyance(BigDecimal conveyance) {
        this.conveyance = conveyance;
    }

    public BigDecimal getMedicalAllowance() {
        return medicalAllowance != null ? medicalAllowance : BigDecimal.ZERO;
    }

    public void setMedicalAllowance(BigDecimal medicalAllowance) {
        this.medicalAllowance = medicalAllowance;
    }

    public BigDecimal getOvertimePay() {
        return overtimePay != null ? overtimePay : BigDecimal.ZERO;
    }

    public void setOvertimePay(BigDecimal overtimePay) {
        this.overtimePay = overtimePay;
    }

    public BigDecimal getDeductions() {
        return deductions != null ? deductions : BigDecimal.ZERO;
    }

    public void setDeductions(BigDecimal deductions) {
        this.deductions = deductions;
    }

    public BigDecimal getProvidentFund() {
        return providentFund != null ? providentFund : BigDecimal.ZERO;
    }

    public void setProvidentFund(BigDecimal providentFund) {
        this.providentFund = providentFund;
    }

    public BigDecimal getProfessionalTax() {
        return professionalTax != null ? professionalTax : BigDecimal.ZERO;
    }

    public void setProfessionalTax(BigDecimal professionalTax) {
        this.professionalTax = professionalTax;
    }

    public BigDecimal getIncomeTax() {
        return incomeTax != null ? incomeTax : BigDecimal.ZERO;
    }

    public void setIncomeTax(BigDecimal incomeTax) {
        this.incomeTax = incomeTax;
    }

    public BigDecimal getUnpaidLeaveDeduction() {
        return unpaidLeaveDeduction != null ? unpaidLeaveDeduction : BigDecimal.ZERO;
    }

    public void setUnpaidLeaveDeduction(BigDecimal unpaidLeaveDeduction) {
        this.unpaidLeaveDeduction = unpaidLeaveDeduction;
    }

    public BigDecimal getNetSalary() {
        return netSalary != null ? netSalary : BigDecimal.ZERO;
    }

    public void setNetSalary(BigDecimal netSalary) {
        this.netSalary = netSalary;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public LocalDateTime getProcessedDate() {
        return processedDate;
    }

    public void setProcessedDate(LocalDateTime processedDate) {
        this.processedDate = processedDate;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public void calculateNet() {
        BigDecimal totalGross = getBasicSalary().add(getAllowances()).add(getOvertimePay());
        BigDecimal totalDeduct = getDeductions().add(getUnpaidLeaveDeduction());
        this.netSalary = totalGross.subtract(totalDeduct);
    }
}
