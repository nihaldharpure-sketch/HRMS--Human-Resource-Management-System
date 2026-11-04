<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payslip - ${employee.fullName} - ${payroll.payrollMonth}</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background: #f1f5f9;
            color: #0f172a;
            padding: 30px 15px;
        }
        .payslip-container {
            max-width: 800px;
            margin: 0 auto;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            padding: 40px;
        }
        .payslip-header {
            border-bottom: 2px solid #e2e8f0;
            padding-bottom: 24px;
            margin-bottom: 24px;
        }
        .company-logo {
            width: 44px;
            height: 44px;
            background: #4f46e5;
            color: #fff;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.4rem;
            font-weight: 800;
        }
        .table-payslip th {
            background: #f8fafc;
            color: #64748b;
            font-size: 0.75rem;
            text-transform: uppercase;
            padding: 10px 14px;
            border-bottom: 1px solid #e2e8f0;
        }
        .table-payslip td {
            padding: 10px 14px;
            border-bottom: 1px solid #f1f5f9;
            font-size: 0.86rem;
        }
        .net-pay-banner {
            background: #eef2ff;
            border: 1px solid #c7d2fe;
            border-radius: 8px;
            padding: 18px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-top: 24px;
        }
        @media print {
            body { background: #fff; padding: 0; }
            .payslip-container { box-shadow: none; border: none; padding: 0; }
            .no-print { display: none !important; }
        }
    </style>
</head>
<body>

<div class="payslip-container">
    <!-- Action Bar -->
    <div class="d-flex justify-content-between align-items-center mb-4 no-print">
        <a href="/payroll" class="btn btn-sm btn-outline-secondary">
            <i class="bi bi-arrow-left"></i> Back to Payroll Register
        </a>
        <button type="button" class="btn btn-sm btn-primary" onclick="window.print()">
            <i class="bi bi-printer"></i> Print Payslip / Save PDF
        </button>
    </div>

    <!-- Payslip Header -->
    <div class="payslip-header d-flex justify-content-between align-items-start">
        <div class="d-flex align-items-center gap-3">
            <div class="company-logo">
                <i class="bi bi-layers-fill"></i>
            </div>
            <div>
                <h4 class="fw-bold mb-0 text-dark">HRMS Operations Inc.</h4>
                <div class="text-muted small">Global Human Capital & Enterprise Services</div>
                <div class="text-muted small">120 Market Street, San Francisco, CA 94105</div>
            </div>
        </div>
        <div class="text-end">
            <span class="badge bg-primary px-3 py-2 fs-6">CONFIDENTIAL PAYSLIP</span>
            <div class="text-muted small mt-2">Pay Period: <strong class="text-dark">${payroll.payrollMonth}</strong></div>
            <div class="text-muted small">Disbursement: <strong>${payroll.status}</strong></div>
        </div>
    </div>

    <!-- Employee Metadata Grid -->
    <div class="row g-3 mb-4 p-3 bg-light rounded-3 border">
        <div class="col-6 col-md-3">
            <small class="text-muted d-block">Employee Name</small>
            <strong class="text-dark">${employee.fullName}</strong>
        </div>
        <div class="col-6 col-md-3">
            <small class="text-muted d-block">Employee ID</small>
            <strong class="text-dark">${employee.employeeCode}</strong>
        </div>
        <div class="col-6 col-md-3">
            <small class="text-muted d-block">Department</small>
            <strong class="text-dark">${not empty employee.department ? employee.department.name : 'Corporate'}</strong>
        </div>
        <div class="col-6 col-md-3">
            <small class="text-muted d-block">Designation</small>
            <strong class="text-dark">${not empty employee.designation ? employee.designation.title : 'Staff'}</strong>
        </div>
        <div class="col-6 col-md-3">
            <small class="text-muted d-block">Bank Account</small>
            <strong class="text-dark">${not empty employee.bankAccountNumber ? employee.bankAccountNumber : '**** 8921'}</strong>
        </div>
        <div class="col-6 col-md-3">
            <small class="text-muted d-block">Bank Name / IFSC</small>
            <strong class="text-dark">${not empty employee.bankName ? employee.bankName : 'Direct Deposit'}</strong>
        </div>
        <div class="col-6 col-md-3">
            <small class="text-muted d-block">Payment Method</small>
            <strong class="text-dark">${payroll.paymentMethod}</strong>
        </div>
        <div class="col-6 col-md-3">
            <small class="text-muted d-block">Joining Date</small>
            <strong class="text-dark">${employee.dateOfJoining}</strong>
        </div>
    </div>

    <!-- Two-Column Breakdown: Earnings vs Deductions -->
    <div class="row g-4">
        <!-- Earnings Column -->
        <div class="col-md-6">
            <div class="border rounded-3 overflow-hidden">
                <table class="table table-payslip mb-0">
                    <thead>
                        <tr>
                            <th>Earnings / Allowances</th>
                            <th class="text-end">Amount (₹)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Basic Salary</td>
                            <td class="text-end fw-bold">₹${payroll.basicSalary}</td>
                        </tr>
                        <tr>
                            <td>House Rent Allowance (HRA)</td>
                            <td class="text-end">₹${payroll.hra}</td>
                        </tr>
                        <tr>
                            <td>Conveyance & Travel Allowance</td>
                            <td class="text-end">₹${payroll.conveyance}</td>
                        </tr>
                        <tr>
                            <td>Medical Allowance</td>
                            <td class="text-end">₹${payroll.medicalAllowance}</td>
                        </tr>
                        <c:if test="${payroll.overtimePay > 0}">
                            <tr>
                                <td>Overtime Hours Pay</td>
                                <td class="text-end text-success fw-bold">+ ₹${payroll.overtimePay}</td>
                            </tr>
                        </c:if>
                        <tr class="bg-light fw-bold">
                            <td>Total Gross Earnings</td>
                            <td class="text-end text-primary">₹${payroll.basicSalary.add(payroll.allowances).add(payroll.overtimePay)}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Deductions Column -->
        <div class="col-md-6">
            <div class="border rounded-3 overflow-hidden">
                <table class="table table-payslip mb-0">
                    <thead>
                        <tr>
                            <th>Deductions / Statutory</th>
                            <th class="text-end">Amount (₹)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Provident Fund (PF)</td>
                            <td class="text-end">₹${payroll.providentFund}</td>
                        </tr>
                        <tr>
                            <td>Professional Tax</td>
                            <td class="text-end">₹${payroll.professionalTax}</td>
                        </tr>
                        <tr>
                            <td>Income Tax / TDS</td>
                            <td class="text-end">₹${payroll.incomeTax}</td>
                        </tr>
                        <c:if test="${payroll.unpaidLeaveDeduction > 0}">
                            <tr>
                                <td>Loss of Pay (Unpaid Leave)</td>
                                <td class="text-end text-danger">- ₹${payroll.unpaidLeaveDeduction}</td>
                            </tr>
                        </c:if>
                        <tr class="bg-light fw-bold">
                            <td>Total Deductions</td>
                            <td class="text-end text-danger">- ₹${payroll.deductions.add(payroll.unpaidLeaveDeduction)}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Net Pay Banner -->
    <div class="net-pay-banner">
        <div>
            <div class="text-muted small text-uppercase fw-bold">Net Payable Take-Home Salary</div>
            <div class="fs-2 fw-bold text-primary">₹${payroll.netSalary}</div>
        </div>
        <div class="text-end">
            <span class="badge bg-success px-3 py-2 fw-bold">
                <i class="bi bi-shield-check me-1"></i> VERIFIED & AUTHORIZED
            </span>
        </div>
    </div>

    <!-- Signatures Footer -->
    <div class="row mt-5 pt-4 border-top">
        <div class="col-6">
            <div class="text-muted small">Employee Signature / Acknowledgment</div>
            <div style="height: 40px;"></div>
            <div class="border-top pt-1 text-muted" style="width: 180px; font-size: 0.75rem;">Signature Date</div>
        </div>
        <div class="col-6 text-end">
            <div class="text-muted small">Authorized HR & Payroll Officer</div>
            <div style="height: 40px;"></div>
            <div class="border-top pt-1 text-muted ms-auto" style="width: 180px; font-size: 0.75rem;">HR Operations Sign-off</div>
        </div>
    </div>
</div>

</body>
</html>
