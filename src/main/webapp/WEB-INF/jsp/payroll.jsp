<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payroll & Salary Management | HRMS Operations</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

<jsp:include page="fragments/navbar.jsp" />

<main class="app-main">
    <div class="content-wrapper">
        <div class="page-header">
            <div>
                <h1 class="page-title">Payroll & Compensation Management</h1>
                <p class="page-subtitle">Batch payroll processing, attendance overtime integration, statutory tax deductions, and automated payslip delivery.</p>
            </div>
            <div class="header-actions">
                <a href="/reports/export/payroll?month=${selectedMonth}" class="btn-enterprise btn-secondary-enterprise">
                    <i class="bi bi-file-earmark-arrow-down"></i>
                    <span>Export Payroll CSV</span>
                </a>
                <form method="post" action="/payroll/generate" class="d-inline">
                    <input type="hidden" name="month" value="${selectedMonth}">
                    <button type="submit" class="btn-enterprise btn-primary-enterprise">
                        <i class="bi bi-gear-wide-connected"></i>
                        <span>Generate Monthly Batch</span>
                    </button>
                </form>
            </div>
        </div>

        <c:if test="${not empty successMessage}">
            <div class="alert-enterprise alert-success-enterprise">
                <i class="bi bi-check-circle-fill fs-5"></i>
                <span>${successMessage}</span>
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert-enterprise alert-danger-enterprise">
                <i class="bi bi-exclamation-triangle-fill fs-5"></i>
                <span>${errorMessage}</span>
            </div>
        </c:if>

        <!-- Payroll Metrics Overview -->
        <div class="stats-grid-3">
            <div class="stat-box">
                <div class="stat-box-top">
                    <span class="stat-label">Total Net Disbursement</span>
                    <div class="stat-icon purple"><i class="bi bi-cash-stack"></i></div>
                </div>
                <div class="stat-value text-purple">₹${totalNet}</div>
                <div class="stat-footer text-muted">For ${selectedMonth.month} ${selectedMonth.year}</div>
            </div>
            <div class="stat-box">
                <div class="stat-box-top">
                    <span class="stat-label">Processed & Approved</span>
                    <div class="stat-icon emerald"><i class="bi bi-check-circle-fill"></i></div>
                </div>
                <div class="stat-value text-success">${processedCount}</div>
                <div class="stat-footer text-muted">Ready for bank transfer / paid</div>
            </div>
            <div class="stat-box">
                <div class="stat-box-top">
                    <span class="stat-label">Draft Reviews</span>
                    <div class="stat-icon amber"><i class="bi bi-file-earmark-ruled"></i></div>
                </div>
                <div class="stat-value text-warning">${draftCount}</div>
                <div class="stat-footer text-muted">Requires payroll manager sign-off</div>
            </div>
        </div>

        <!-- Month Filter & Batch Controls -->
        <div class="card-enterprise mb-4 p-3">
            <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
                <form method="get" action="/payroll" class="d-flex align-items-center gap-2">
                    <label class="form-label-enterprise mb-0">Pay Month:</label>
                    <input type="date" name="month" class="form-control-enterprise" style="width: 180px;" value="${selectedMonth}" onchange="this.form.submit()">
                    <button type="submit" class="btn-enterprise btn-secondary-enterprise btn-sm-enterprise">Filter</button>
                </form>

                <div class="d-flex align-items-center gap-2">
                    <c:if test="${draftCount > 0}">
                        <form method="post" action="/payroll/process-all" class="d-inline">
                            <input type="hidden" name="month" value="${selectedMonth}">
                            <button type="submit" class="btn-enterprise btn-success-enterprise">
                                <i class="bi bi-check2-all"></i> Approve & Process All Drafts
                            </button>
                        </form>
                    </c:if>
                </div>
            </div>
        </div>

        <!-- Payroll Register Table -->
        <div class="card-enterprise p-0 overflow-hidden">
            <div class="table-responsive-enterprise">
                <table class="table-enterprise">
                    <thead>
                        <tr>
                            <th>Employee</th>
                            <th>Department</th>
                            <th>Basic Salary</th>
                            <th>Allowances</th>
                            <th>Overtime Pay</th>
                            <th>Deductions</th>
                            <th>Net Pay</th>
                            <th>Status</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="pay" items="${payrolls}">
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="user-avatar" style="width: 32px; height: 32px; font-size: 0.75rem;">
                                            ${pay.employee.firstName.substring(0, 1)}
                                        </div>
                                        <div>
                                            <a href="/employees/${pay.employee.id}" class="text-decoration-none fw-bold text-dark">
                                                ${pay.employee.fullName}
                                            </a>
                                            <small class="text-muted d-block">${pay.employee.employeeCode}</small>
                                        </div>
                                    </div>
                                </td>
                                <td>${not empty pay.employee.department ? pay.employee.department.name : 'General'}</td>
                                <td>₹${pay.basicSalary}</td>
                                <td class="text-success">+ ₹${pay.allowances}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${pay.overtimePay > 0}">
                                            <span class="text-success fw-bold">+ ₹${pay.overtimePay}</span>
                                        </c:when>
                                        <c:otherwise>₹0.00</c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-danger">- ₹${pay.deductions}</td>
                                <td class="fw-bold text-dark fs-6">₹${pay.netSalary}</td>
                                <td>
                                    <span class="badge-status ${pay.status == 'PAID' ? 'badge-paid' : (pay.status == 'PROCESSED' ? 'badge-processed' : 'badge-draft')}">
                                        ${pay.status}
                                    </span>
                                </td>
                                <td class="text-end">
                                    <a href="/payroll/payslip/${pay.id}" class="btn-enterprise btn-sm-enterprise btn-secondary-enterprise me-1" target="_blank" title="View Payslip">
                                        <i class="bi bi-printer"></i> Payslip
                                    </a>
                                    <c:if test="${pay.status != 'PAID'}">
                                        <form method="post" action="/payroll/mark-paid" class="d-inline">
                                            <input type="hidden" name="payrollId" value="${pay.id}">
                                            <input type="hidden" name="month" value="${selectedMonth}">
                                            <button type="submit" class="btn-enterprise btn-sm-enterprise btn-success-enterprise" title="Mark as Paid">
                                                <i class="bi bi-check2"></i> Mark Paid
                                            </button>
                                        </form>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty payrolls}">
                            <tr>
                                <td colspan="9" class="text-center text-muted py-5">
                                    No payroll records for ${selectedMonth.month} ${selectedMonth.year}. Click "Generate Monthly Batch" above to calculate employee salaries.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
