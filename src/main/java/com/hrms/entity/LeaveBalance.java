package com.hrms.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "leave_balances", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"employee_id", "year"})
})
public class LeaveBalance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "employee_id", nullable = false)
    private Employee employee;

    @Column(nullable = false)
    private Integer year;

    private Double annualTotal = 18.0;
    private Double annualUsed = 0.0;

    private Double casualTotal = 12.0;
    private Double casualUsed = 0.0;

    private Double sickTotal = 10.0;
    private Double sickUsed = 0.0;

    private Double unpaidUsed = 0.0;

    public LeaveBalance() {
    }

    public LeaveBalance(Employee employee, Integer year) {
        this.employee = employee;
        this.year = year;
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

    public Integer getYear() {
        return year;
    }

    public void setYear(Integer year) {
        this.year = year;
    }

    public Double getAnnualTotal() {
        return annualTotal;
    }

    public void setAnnualTotal(Double annualTotal) {
        this.annualTotal = annualTotal;
    }

    public Double getAnnualUsed() {
        return annualUsed;
    }

    public void setAnnualUsed(Double annualUsed) {
        this.annualUsed = annualUsed;
    }

    public Double getAnnualRemaining() {
        return Math.max(0.0, annualTotal - annualUsed);
    }

    public Double getCasualTotal() {
        return casualTotal;
    }

    public void setCasualTotal(Double casualTotal) {
        this.casualTotal = casualTotal;
    }

    public Double getCasualUsed() {
        return casualUsed;
    }

    public void setCasualUsed(Double casualUsed) {
        this.casualUsed = casualUsed;
    }

    public Double getCasualRemaining() {
        return Math.max(0.0, casualTotal - casualUsed);
    }

    public Double getSickTotal() {
        return sickTotal;
    }

    public void setSickTotal(Double sickTotal) {
        this.sickTotal = sickTotal;
    }

    public Double getSickUsed() {
        return sickUsed;
    }

    public void setSickUsed(Double sickUsed) {
        this.sickUsed = sickUsed;
    }

    public Double getSickRemaining() {
        return Math.max(0.0, sickTotal - sickUsed);
    }

    public Double getUnpaidUsed() {
        return unpaidUsed;
    }

    public void setUnpaidUsed(Double unpaidUsed) {
        this.unpaidUsed = unpaidUsed;
    }

    public Double getTotalRemaining() {
        return getAnnualRemaining() + getCasualRemaining() + getSickRemaining();
    }
}
