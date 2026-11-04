package com.hrms.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "salary_structures")
public class SalaryStructure {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "employee_id", nullable = false, unique = true)
    private Employee employee;

    private BigDecimal basicSalary = BigDecimal.ZERO;
    private BigDecimal hra = BigDecimal.ZERO; // House Rent Allowance
    private BigDecimal conveyance = BigDecimal.ZERO;
    private BigDecimal medicalAllowance = BigDecimal.ZERO;
    private BigDecimal specialAllowance = BigDecimal.ZERO;

    private BigDecimal providentFund = BigDecimal.ZERO;
    private BigDecimal professionalTax = BigDecimal.ZERO;
    private BigDecimal incomeTax = BigDecimal.ZERO;

    public SalaryStructure() {
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

    public BigDecimal getBasicSalary() {
        return basicSalary != null ? basicSalary : BigDecimal.ZERO;
    }

    public void setBasicSalary(BigDecimal basicSalary) {
        this.basicSalary = basicSalary;
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

    public BigDecimal getSpecialAllowance() {
        return specialAllowance != null ? specialAllowance : BigDecimal.ZERO;
    }

    public void setSpecialAllowance(BigDecimal specialAllowance) {
        this.specialAllowance = specialAllowance;
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

    public BigDecimal getTotalAllowances() {
        return getHra().add(getConveyance()).add(getMedicalAllowance()).add(getSpecialAllowance());
    }

    public BigDecimal getTotalDeductions() {
        return getProvidentFund().add(getProfessionalTax()).add(getIncomeTax());
    }

    public BigDecimal getGrossSalary() {
        return getBasicSalary().add(getTotalAllowances());
    }

    public BigDecimal getNetMonthlySalary() {
        return getGrossSalary().subtract(getTotalDeductions());
    }
}
