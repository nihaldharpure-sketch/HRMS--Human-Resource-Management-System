<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${employee.fullName} | Employee Profile | HRMS</title>
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
        <div class="mb-3">
            <a href="/employees" class="text-decoration-none small text-muted">
                <i class="bi bi-arrow-left"></i> Back to Employee Directory
            </a>
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

        <!-- Employee Hero Card -->
        <div class="card-enterprise mb-4">
            <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
                <div class="d-flex align-items-center gap-4">
                    <div class="user-avatar" style="width: 72px; height: 72px; font-size: 1.8rem; border-radius: var(--radius-md);">
                        ${employee.firstName.substring(0, 1)}
                    </div>
                    <div>
                        <div class="d-flex align-items-center gap-2 mb-1">
                            <h2 class="fw-bold mb-0 text-dark">${employee.fullName}</h2>
                            <span class="badge-status ${employee.status == 'ACTIVE' ? 'badge-active' : (employee.status == 'ON_LEAVE' ? 'badge-onleave' : 'badge-inactive')}">
                                ${employee.status}
                            </span>
                        </div>
                        <div class="text-muted small">
                            <strong>${not empty employee.designation ? employee.designation.title : 'Staff'}</strong> &middot; 
                            ${not empty employee.department ? employee.department.name : 'Unassigned'} &middot;
                            <span class="font-monospace fw-bold text-dark">${employee.employeeCode}</span>
                        </div>
                        <div class="text-muted small mt-1">
                            <i class="bi bi-envelope me-1"></i>${employee.email} &middot;
                            <i class="bi bi-telephone me-1"></i>${employee.phone} &middot;
                            <i class="bi bi-calendar3 me-1"></i>Joined ${employee.dateOfJoining}
                        </div>
                    </div>
                </div>

                <div class="d-flex align-items-center gap-2">
                    <button type="button" class="btn-enterprise btn-secondary-enterprise" data-bs-toggle="modal" data-bs-target="#editProfileModal">
                        <i class="bi bi-pencil-square"></i> Edit Details
                    </button>
                    <button type="button" class="btn-enterprise btn-danger-enterprise" data-bs-toggle="modal" data-bs-target="#recordExitModal">
                        <i class="bi bi-box-arrow-right"></i> Record Exit
                    </button>
                </div>
            </div>
        </div>

        <!-- Tabbed Navigation -->
        <ul class="nav nav-pills tabs-enterprise" id="profileTabs" role="tablist">
            <li class="nav-item">
                <button class="nav-link tab-btn active" id="overview-tab" data-bs-toggle="tab" data-bs-target="#overview" type="button">
                    <i class="bi bi-person me-1"></i> Personal & Contact
                </button>
            </li>
            <li class="nav-item">
                <button class="nav-link tab-btn" id="attendance-tab" data-bs-toggle="tab" data-bs-target="#attendance" type="button">
                    <i class="bi bi-clock-history me-1"></i> Attendance Log (${attendances.size()})
                </button>
            </li>
            <li class="nav-item">
                <button class="nav-link tab-btn" id="leave-tab" data-bs-toggle="tab" data-bs-target="#leave" type="button">
                    <i class="bi bi-calendar2-heart me-1"></i> Leave Quotas (${leaves.size()})
                </button>
            </li>
            <li class="nav-item">
                <button class="nav-link tab-btn" id="payroll-tab" data-bs-toggle="tab" data-bs-target="#payroll" type="button">
                    <i class="bi bi-wallet2 me-1"></i> Compensation & Payslips
                </button>
            </li>
            <li class="nav-item">
                <button class="nav-link tab-btn" id="onboarding-tab" data-bs-toggle="tab" data-bs-target="#onboarding" type="button">
                    <i class="bi bi-check2-square me-1"></i> Onboarding Tasks (${onboardingTasks.size()})
                </button>
            </li>
        </ul>

        <!-- Tab Contents -->
        <div class="tab-content" id="profileTabContent">
            <!-- Tab 1: Overview -->
            <div class="tab-pane fade show active" id="overview" role="tabpanel">
                <div class="row g-4">
                    <div class="col-md-6">
                        <div class="card-enterprise h-100">
                            <h6 class="fw-bold mb-3 border-bottom pb-2 text-dark">
                                <i class="bi bi-info-circle text-primary me-2"></i>Personal Information
                            </h6>
                            <dl class="row mb-0 small">
                                <dt class="col-sm-5 text-muted">Full Name</dt>
                                <dd class="col-sm-7 fw-bold text-dark">${employee.fullName}</dd>

                                <dt class="col-sm-5 text-muted">Gender</dt>
                                <dd class="col-sm-7">${not empty employee.gender ? employee.gender : 'Not specified'}</dd>

                                <dt class="col-sm-5 text-muted">Date of Birth</dt>
                                <dd class="col-sm-7">${not empty employee.dateOfBirth ? employee.dateOfBirth : 'Not specified'}</dd>

                                <dt class="col-sm-5 text-muted">Marital Status</dt>
                                <dd class="col-sm-7">${not empty employee.maritalStatus ? employee.maritalStatus : 'Single'}</dd>

                                <dt class="col-sm-5 text-muted">Qualification</dt>
                                <dd class="col-sm-7">${not empty employee.qualification ? employee.qualification : 'Graduation'}</dd>

                                <dt class="col-sm-5 text-muted">Experience</dt>
                                <dd class="col-sm-7">${employee.experienceYears} Years</dd>
                            </dl>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="card-enterprise h-100">
                            <h6 class="fw-bold mb-3 border-bottom pb-2 text-dark">
                                <i class="bi bi-building text-primary me-2"></i>Employment & Hierarchy
                            </h6>
                            <dl class="row mb-0 small">
                                <dt class="col-sm-5 text-muted">Department</dt>
                                <dd class="col-sm-7 fw-bold">${not empty employee.department ? employee.department.name : 'Unassigned'}</dd>

                                <dt class="col-sm-5 text-muted">Designation</dt>
                                <dd class="col-sm-7">${not empty employee.designation ? employee.designation.title : 'Staff'}</dd>

                                <dt class="col-sm-5 text-muted">Reporting Manager</dt>
                                <dd class="col-sm-7">${not empty employee.manager ? employee.manager.fullName : 'None (Executive)'}</dd>

                                <dt class="col-sm-5 text-muted">Employment Type</dt>
                                <dd class="col-sm-7"><span class="badge bg-light text-dark border">${employee.employmentType}</span></dd>

                                <dt class="col-sm-5 text-muted">Probation End Date</dt>
                                <dd class="col-sm-7">${not empty employee.probationEndDate ? employee.probationEndDate : 'Completed'}</dd>

                                <dt class="col-sm-5 text-muted">Exit / Separation</dt>
                                <dd class="col-sm-7">${not empty employee.exitDate ? employee.exitDate : 'Active Staff'}</dd>
                            </dl>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="card-enterprise h-100">
                            <h6 class="fw-bold mb-3 border-bottom pb-2 text-dark">
                                <i class="bi bi-geo-alt text-primary me-2"></i>Address & Location
                            </h6>
                            <dl class="row mb-0 small">
                                <dt class="col-sm-5 text-muted">Street</dt>
                                <dd class="col-sm-7">${not empty employee.addressStreet ? employee.addressStreet : 'Not specified'}</dd>

                                <dt class="col-sm-5 text-muted">City, State</dt>
                                <dd class="col-sm-7">${employee.addressCity}, ${employee.addressState} ${employee.addressZip}</dd>
                            </dl>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="card-enterprise h-100">
                            <h6 class="fw-bold mb-3 border-bottom pb-2 text-dark">
                                <i class="bi bi-telephone-plus text-primary me-2"></i>Emergency Contact & Bank
                            </h6>
                            <dl class="row mb-0 small">
                                <dt class="col-sm-5 text-muted">Contact Name</dt>
                                <dd class="col-sm-7 fw-bold">${not empty employee.emergencyContactName ? employee.emergencyContactName : 'None'}</dd>

                                <dt class="col-sm-5 text-muted">Relationship / Phone</dt>
                                <dd class="col-sm-7">${employee.emergencyContactRelation} (${employee.emergencyContactPhone})</dd>

                                <dt class="col-sm-5 text-muted">Bank Name</dt>
                                <dd class="col-sm-7">${not empty employee.bankName ? employee.bankName : 'Direct Deposit'}</dd>

                                <dt class="col-sm-5 text-muted">Account & IFSC</dt>
                                <dd class="col-sm-7">${employee.bankAccountNumber} &middot; ${employee.bankIfsc}</dd>
                            </dl>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tab 2: Attendance Log -->
            <div class="tab-pane fade" id="attendance" role="tabpanel">
                <div class="card-enterprise p-0 overflow-hidden">
                    <div class="table-responsive-enterprise">
                        <table class="table-enterprise">
                            <thead>
                                <tr>
                                    <th>Date</th>
                                    <th>Check In</th>
                                    <th>Check Out</th>
                                    <th>Total Hours</th>
                                    <th>Overtime</th>
                                    <th>Late (Mins)</th>
                                    <th>Status</th>
                                    <th>Remarks</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="att" items="${attendances}">
                                    <tr>
                                        <td class="fw-bold">${att.attendanceDate}</td>
                                        <td>${not empty att.checkIn ? att.checkIn.toLocalTime() : '-'}</td>
                                        <td>${not empty att.checkOut ? att.checkOut.toLocalTime() : '-'}</td>
                                        <td>${att.totalHours} hrs</td>
                                        <td>${att.overtimeHours > 0 ? att.overtimeHours : 0.0} hrs</td>
                                        <td>${att.lateMinutes > 0 ? att.lateMinutes : 0} mins</td>
                                        <td>
                                            <span class="badge-status ${att.status == 'PRESENT' ? 'badge-present' : (att.status == 'LATE' ? 'badge-late' : (att.status == 'ON_LEAVE' ? 'badge-onleave' : 'badge-absent'))}">
                                                ${att.status}
                                            </span>
                                        </td>
                                        <td class="text-muted small">${not empty att.remarks ? att.remarks : '-'}</td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty attendances}">
                                    <tr>
                                        <td colspan="8" class="text-center text-muted py-4">No attendance history logged yet.</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Tab 3: Leave Quotas & History -->
            <div class="tab-pane fade" id="leave" role="tabpanel">
                <div class="stats-grid-3 mb-4">
                    <div class="stat-box">
                        <div class="stat-box-top">
                            <span class="stat-label">Annual Leave</span>
                            <div class="stat-icon emerald"><i class="bi bi-calendar-check"></i></div>
                        </div>
                        <div class="stat-value text-success">${not empty leaveBalance ? leaveBalance.annualRemaining : 18.0}</div>
                        <div class="stat-footer text-muted">Out of ${not empty leaveBalance ? leaveBalance.annualTotal : 18.0} days available</div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-box-top">
                            <span class="stat-label">Casual Leave</span>
                            <div class="stat-icon amber"><i class="bi bi-clock-history"></i></div>
                        </div>
                        <div class="stat-value text-warning">${not empty leaveBalance ? leaveBalance.casualRemaining : 12.0}</div>
                        <div class="stat-footer text-muted">Out of ${not empty leaveBalance ? leaveBalance.casualTotal : 12.0} days available</div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-box-top">
                            <span class="stat-label">Sick Leave</span>
                            <div class="stat-icon purple"><i class="bi bi-hospital"></i></div>
                        </div>
                        <div class="stat-value text-purple">${not empty leaveBalance ? leaveBalance.sickRemaining : 10.0}</div>
                        <div class="stat-footer text-muted">Out of ${not empty leaveBalance ? leaveBalance.sickTotal : 10.0} days available</div>
                    </div>
                </div>

                <div class="card-enterprise p-0 overflow-hidden">
                    <div class="p-3 border-bottom fw-bold text-dark">Leave Application History</div>
                    <div class="table-responsive-enterprise">
                        <table class="table-enterprise">
                            <thead>
                                <tr>
                                    <th>Type</th>
                                    <th>Start Date</th>
                                    <th>End Date</th>
                                    <th>Days</th>
                                    <th>Status</th>
                                    <th>Reason</th>
                                    <th>Reviewed By</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="lr" items="${leaves}">
                                    <tr>
                                        <td><strong>${lr.leaveType}</strong></td>
                                        <td>${lr.startDate}</td>
                                        <td>${lr.endDate}</td>
                                        <td>${lr.days} day(s)</td>
                                        <td>
                                            <span class="badge-status ${lr.status == 'APPROVED' ? 'badge-approved' : (lr.status == 'PENDING' ? 'badge-pending' : 'badge-rejected')}">
                                                ${lr.status}
                                            </span>
                                        </td>
                                        <td class="text-muted small">${lr.reason}</td>
                                        <td>${not empty lr.reviewedBy ? lr.reviewedBy.fullName : 'Pending'}</td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty leaves}">
                                    <tr>
                                        <td colspan="7" class="text-center text-muted py-4">No leave requests submitted.</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Tab 4: Compensation & Salary -->
            <div class="tab-pane fade" id="payroll" role="tabpanel">
                <div class="card-enterprise mb-4">
                    <div class="d-flex align-items-center justify-content-between mb-3 border-bottom pb-2">
                        <h6 class="fw-bold mb-0 text-dark">Salary Structure Breakdown</h6>
                        <span class="badge bg-light text-dark border">Effective Salary Plan</span>
                    </div>
                    <div class="row g-3">
                        <div class="col-md-3">
                            <div class="small text-muted">Base Salary</div>
                            <h5 class="fw-bold text-dark mt-1">₹${salaryStructure.basicSalary}</h5>
                        </div>
                        <div class="col-md-3">
                            <div class="small text-muted">Total Allowances (HRA, Travel, Medical)</div>
                            <h5 class="fw-bold text-success mt-1">+ ₹${salaryStructure.totalAllowances}</h5>
                        </div>
                        <div class="col-md-3">
                            <div class="small text-muted">Statutory Deductions (PF, Tax)</div>
                            <h5 class="fw-bold text-danger mt-1">- ₹${salaryStructure.totalDeductions}</h5>
                        </div>
                        <div class="col-md-3">
                            <div class="small text-muted">Net Monthly Take-Home</div>
                            <h5 class="fw-bold text-primary mt-1">₹${salaryStructure.netMonthlySalary}</h5>
                        </div>
                    </div>
                </div>

                <div class="card-enterprise p-0 overflow-hidden">
                    <div class="p-3 border-bottom fw-bold text-dark">Disbursed Payslips</div>
                    <div class="table-responsive-enterprise">
                        <table class="table-enterprise">
                            <thead>
                                <tr>
                                    <th>Pay Period</th>
                                    <th>Basic Salary</th>
                                    <th>Allowances</th>
                                    <th>Deductions</th>
                                    <th>Net Salary</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="pay" items="${payrolls}">
                                    <tr>
                                        <td class="fw-bold">${pay.payrollMonth}</td>
                                        <td>₹${pay.basicSalary}</td>
                                        <td class="text-success">+ ₹${pay.allowances}</td>
                                        <td class="text-danger">- ₹${pay.deductions}</td>
                                        <td class="fw-bold text-dark">₹${pay.netSalary}</td>
                                        <td>
                                            <span class="badge-status ${pay.status == 'PAID' ? 'badge-paid' : 'badge-processed'}">
                                                ${pay.status}
                                            </span>
                                        </td>
                                        <td>
                                            <a href="/payroll/payslip/${pay.id}" class="btn-enterprise btn-sm-enterprise btn-secondary-enterprise" target="_blank">
                                                <i class="bi bi-printer"></i> View Payslip
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty payrolls}">
                                    <tr>
                                        <td colspan="7" class="text-center text-muted py-4">No payrolls processed for this employee yet.</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Tab 5: Onboarding Tasks -->
            <div class="tab-pane fade" id="onboarding" role="tabpanel">
                <div class="card-enterprise p-0 overflow-hidden">
                    <div class="p-3 border-bottom fw-bold text-dark">Onboarding Checklist</div>
                    <div class="table-responsive-enterprise">
                        <table class="table-enterprise">
                            <thead>
                                <tr>
                                    <th>Task Title</th>
                                    <th>Description</th>
                                    <th>Assigned Role</th>
                                    <th>Due Date</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="task" items="${onboardingTasks}">
                                    <tr>
                                        <td class="fw-bold">${task.title}</td>
                                        <td class="text-muted small">${task.description}</td>
                                        <td><span class="badge bg-light text-dark border">${task.assignedToRole}</span></td>
                                        <td>${task.dueDate}</td>
                                        <td>
                                            <span class="badge-status ${task.status == 'COMPLETED' ? 'badge-approved' : 'badge-pending'}">
                                                ${task.status}
                                            </span>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty onboardingTasks}">
                                    <tr>
                                        <td colspan="5" class="text-center text-muted py-4">No onboarding tasks pending.</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<!-- Modal 1: Edit Profile -->
<div class="modal fade" id="editProfileModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <form method="post" action="/employees/edit/${employee.id}" class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold">Edit Employee Details</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label-enterprise">First Name</label>
                        <input type="text" name="firstName" class="form-control-enterprise" value="${employee.firstName}" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-enterprise">Last Name</label>
                        <input type="text" name="lastName" class="form-control-enterprise" value="${employee.lastName}" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-enterprise">Corporate Email</label>
                        <input type="email" name="email" class="form-control-enterprise" value="${employee.email}">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-enterprise">Phone</label>
                        <input type="text" name="phone" class="form-control-enterprise" value="${employee.phone}">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-enterprise">Department</label>
                        <select name="departmentId" class="form-select-enterprise">
                            <c:forEach var="d" items="${departments}">
                                <option value="${d.id}" ${employee.department.id == d.id ? 'selected' : ''}>${d.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-enterprise">Designation</label>
                        <select name="designationId" class="form-select-enterprise">
                            <c:forEach var="des" items="${designations}">
                                <option value="${des.id}" ${employee.designation.id == des.id ? 'selected' : ''}>${des.title}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-enterprise">Employment Status</label>
                        <select name="status" class="form-select-enterprise">
                            <option value="ACTIVE" ${employee.status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                            <option value="ON_LEAVE" ${employee.status == 'ON_LEAVE' ? 'selected' : ''}>On Leave</option>
                            <option value="INACTIVE" ${employee.status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label-enterprise">Street Address</label>
                        <input type="text" name="addressStreet" class="form-control-enterprise" value="${employee.addressStreet}">
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-enterprise btn-secondary-enterprise" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" class="btn-enterprise btn-primary-enterprise">Save Changes</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal 2: Record Exit / Separation -->
<div class="modal fade" id="recordExitModal" tabindex="-1">
    <div class="modal-dialog">
        <form method="post" action="/employees/exit/${employee.id}" class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold text-danger">Record Employee Exit / Separation</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p class="small text-muted">This will record the employee's official separation date, reason, and change their active status to Inactive.</p>
                <div class="mb-3">
                    <label class="form-label-enterprise">Exit Date</label>
                    <input type="date" name="exitDate" class="form-control-enterprise" required>
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Separation Category</label>
                    <select name="exitStatus" class="form-select-enterprise">
                        <option value="RESIGNED">Voluntary Resignation</option>
                        <option value="TERMINATED">Involuntary Termination</option>
                        <option value="RETIRED">Retirement</option>
                        <option value="CONTRACT_END">End of Contract</option>
                    </select>
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Reason / Feedback Notes</label>
                    <textarea name="exitReason" class="form-control-enterprise" rows="3" placeholder="Handover notes and exit interview summary..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-enterprise btn-secondary-enterprise" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" class="btn-enterprise btn-danger-enterprise">Confirm Separation</button>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>