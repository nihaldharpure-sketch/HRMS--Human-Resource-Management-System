<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee Self-Service Portal | HRMS Operations</title>
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
        <!-- Self Service Welcome Banner -->
        <div class="card-enterprise mb-4" style="background: linear-gradient(135deg, #1e1b4b 0%, #312e81 100%); color: #ffffff;">
            <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
                <div class="d-flex align-items-center gap-4">
                    <div class="user-avatar" style="width: 68px; height: 68px; font-size: 1.7rem; background: rgba(255, 255, 255, 0.15); border: 2px solid rgba(255, 255, 255, 0.3);">
                        ${not empty employee ? employee.firstName.substring(0, 1) : 'E'}
                    </div>
                    <div>
                        <span class="badge bg-white text-dark font-monospace mb-1 px-2 py-1">SELF-SERVICE HUB</span>
                        <h2 class="fw-bold mb-1 text-white">${not empty employee ? employee.fullName : currentUser.fullName}</h2>
                        <div class="text-slate-300 small">
                            ${not empty employee.designation ? employee.designation.title : 'Team Member'} &middot;
                            ${not empty employee.department ? employee.department.name : 'Corporate'} &middot;
                            ID: <strong class="text-white">${not empty employee ? employee.employeeCode : 'EMP-CURRENT'}</strong>
                        </div>
                    </div>
                </div>

                <div class="d-flex align-items-center gap-2">
                    <button type="button" class="btn-enterprise btn-secondary-enterprise" data-bs-toggle="modal" data-bs-target="#updateProfileModal">
                        <i class="bi bi-person-gear"></i> Update My Details
                    </button>
                    <button type="button" class="btn-enterprise btn-primary-enterprise" data-bs-toggle="modal" data-bs-target="#applyLeaveModal">
                        <i class="bi bi-calendar-plus"></i> Apply for Leave
                    </button>
                </div>
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

        <!-- Punch & Live Time Tracker Row -->
        <div class="row g-4 mb-4">
            <!-- Digital Clock & Punch Widget -->
            <div class="col-lg-4">
                <div class="card-enterprise h-100 text-center">
                    <span class="stat-label">Daily Attendance Punch</span>
                    <div class="my-3">
                        <div class="fs-1 fw-bold text-dark font-monospace" id="liveClock">--:--:--</div>
                        <div class="text-muted small">${java.time.LocalDate.now()}</div>
                    </div>

                    <div class="p-3 bg-light rounded-3 mb-3 border">
                        <div class="d-flex justify-content-between small text-muted mb-1">
                            <span>Check-In:</span>
                            <strong class="text-dark">${not empty todayAttendance && not empty todayAttendance.checkIn ? todayAttendance.checkIn.toLocalTime() : 'Not recorded'}</strong>
                        </div>
                        <div class="d-flex justify-content-between small text-muted">
                            <span>Check-Out:</span>
                            <strong class="text-dark">${not empty todayAttendance && not empty todayAttendance.checkOut ? todayAttendance.checkOut.toLocalTime() : 'Pending'}</strong>
                        </div>
                        <c:if test="${not empty todayAttendance}">
                            <div class="mt-2 text-center">
                                <span class="badge-status ${todayAttendance.status == 'PRESENT' ? 'badge-present' : (todayAttendance.status == 'LATE' ? 'badge-late' : 'badge-onleave')}">
                                    Status: ${todayAttendance.status}
                                </span>
                            </div>
                        </c:if>
                    </div>

                    <div class="d-flex gap-2 justify-content-center">
                        <c:choose>
                            <c:when test="${empty todayAttendance || empty todayAttendance.checkIn}">
                                <form method="post" action="/portal/check-in" class="w-100">
                                    <button type="submit" class="btn-enterprise btn-success-enterprise w-100 py-2">
                                        <i class="bi bi-box-arrow-in-right fs-5"></i>
                                        <span>Check In Now</span>
                                    </button>
                                </form>
                            </c:when>
                            <c:when test="${empty todayAttendance.checkOut}">
                                <form method="post" action="/portal/check-out" class="w-100">
                                    <button type="submit" class="btn-enterprise btn-danger-enterprise w-100 py-2">
                                        <i class="bi bi-box-arrow-right fs-5"></i>
                                        <span>Check Out Now</span>
                                    </button>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <button type="button" class="btn-enterprise btn-secondary-enterprise w-100 py-2" disabled>
                                    <i class="bi bi-check2-circle"></i> Workday Complete
                                </button>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="mt-3">
                        <button type="button" class="btn btn-link btn-sm text-decoration-none text-muted p-0" data-bs-toggle="modal" data-bs-target="#correctionModal">
                            <i class="bi bi-clock-history"></i> Request Attendance Correction
                        </button>
                    </div>
                </div>
            </div>

            <!-- Leave Quota Balances -->
            <div class="col-lg-8">
                <div class="card-enterprise h-100">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <h6 class="fw-bold mb-0 text-dark">My Leave Balances (${leaveBalance.year})</h6>
                        <button type="button" class="btn-enterprise btn-sm-enterprise btn-primary-enterprise" data-bs-toggle="modal" data-bs-target="#applyLeaveModal">
                            <i class="bi bi-plus-lg"></i> Apply Leave
                        </button>
                    </div>
                    <div class="row g-3">
                        <div class="col-md-4">
                            <div class="p-3 border rounded-3 bg-light">
                                <div class="stat-label">Annual Leave</div>
                                <div class="fs-2 fw-bold text-success mt-1">${leaveBalance.annualRemaining} <small class="fs-6 text-muted">days left</small></div>
                                <div class="small text-muted mt-1">${leaveBalance.annualUsed} days utilized of ${leaveBalance.annualTotal}</div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="p-3 border rounded-3 bg-light">
                                <div class="stat-label">Casual Leave</div>
                                <div class="fs-2 fw-bold text-warning mt-1">${leaveBalance.casualRemaining} <small class="fs-6 text-muted">days left</small></div>
                                <div class="small text-muted mt-1">${leaveBalance.casualUsed} days utilized of ${leaveBalance.casualTotal}</div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="p-3 border rounded-3 bg-light">
                                <div class="stat-label">Sick Leave</div>
                                <div class="fs-2 fw-bold text-purple mt-1">${leaveBalance.sickRemaining} <small class="fs-6 text-muted">days left</small></div>
                                <div class="small text-muted mt-1">${leaveBalance.sickUsed} days utilized of ${leaveBalance.sickTotal}</div>
                            </div>
                        </div>
                    </div>

                    <!-- My Pending Leave Requests -->
                    <div class="mt-4">
                        <div class="small fw-bold text-muted mb-2 text-uppercase">My Recent Leave Requests</div>
                        <div class="table-responsive-enterprise">
                            <table class="table-enterprise">
                                <thead>
                                    <tr>
                                        <th>Type</th>
                                        <th>Duration</th>
                                        <th>Days</th>
                                        <th>Status</th>
                                        <th>Reason</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="lr" items="${myLeaves}">
                                        <tr>
                                            <td><strong>${lr.leaveType}</strong></td>
                                            <td>${lr.startDate} &rarr; ${lr.endDate}</td>
                                            <td>${lr.days}</td>
                                            <td>
                                                <span class="badge-status ${lr.status == 'APPROVED' ? 'badge-approved' : (lr.status == 'PENDING' ? 'badge-pending' : 'badge-rejected')}">
                                                    ${lr.status}
                                                </span>
                                            </td>
                                            <td class="text-muted small">${lr.reason}</td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty myLeaves}">
                                        <tr><td colspan="5" class="text-center text-muted py-3">No leaves requested yet.</td></tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Payslips & Onboarding Tasks Row -->
        <div class="row g-4">
            <!-- My Payslips -->
            <div class="col-lg-6">
                <div class="card-enterprise h-100">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <h6 class="fw-bold mb-0 text-dark">My Salary Payslips</h6>
                        <span class="badge bg-light text-dark border">Direct Deposit</span>
                    </div>
                    <div class="table-responsive-enterprise">
                        <table class="table-enterprise">
                            <thead>
                                <tr>
                                    <th>Pay Period</th>
                                    <th>Gross Pay</th>
                                    <th>Deductions</th>
                                    <th>Net Salary</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="pay" items="${myPayrolls}">
                                    <tr>
                                        <td class="fw-bold">${pay.payrollMonth}</td>
                                        <td>₹${pay.basicSalary.add(pay.allowances)}</td>
                                        <td class="text-danger">- ₹${pay.deductions}</td>
                                        <td class="fw-bold text-dark">₹${pay.netSalary}</td>
                                        <td>
                                            <a href="/payroll/payslip/${pay.id}" class="btn-enterprise btn-sm-enterprise btn-secondary-enterprise" target="_blank">
                                                <i class="bi bi-printer"></i> Payslip
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty myPayrolls}">
                                    <tr><td colspan="5" class="text-center text-muted py-4">No payslips generated for your account yet.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- My Onboarding & Action Tasks -->
            <div class="col-lg-6">
                <div class="card-enterprise h-100">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <h6 class="fw-bold mb-0 text-dark">My Assigned Tasks & Action Items</h6>
                        <span class="badge-status badge-active">${myTasks.size()} Total</span>
                    </div>
                    <c:forEach var="task" items="${myTasks}">
                        <div class="p-3 border rounded-3 mb-2 bg-light d-flex align-items-center justify-content-between">
                            <div>
                                <div class="fw-bold small text-dark">${task.title}</div>
                                <div class="text-muted" style="font-size: 0.75rem;">${task.description} &middot; Due ${task.dueDate}</div>
                            </div>
                            <div>
                                <c:choose>
                                    <c:when test="${task.status == 'COMPLETED'}">
                                        <span class="badge-status badge-approved"><i class="bi bi-check2"></i> Completed</span>
                                    </c:when>
                                    <c:otherwise>
                                        <form method="post" action="/portal/task/complete" class="d-inline">
                                            <input type="hidden" name="taskId" value="${task.id}">
                                            <button type="submit" class="btn-enterprise btn-sm-enterprise btn-success-enterprise">
                                                Mark Done
                                            </button>
                                        </form>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:forEach>
                    <c:if test="${empty myTasks}">
                        <div class="empty-state py-4">
                            <i class="bi bi-check2-all text-success fs-3 mb-2 d-block"></i>
                            <div class="small text-muted">All assigned employee tasks are completed!</div>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
</main>

<!-- Modal 1: Apply for Leave -->
<div class="modal fade" id="applyLeaveModal" tabindex="-1">
    <div class="modal-dialog">
        <form method="post" action="/portal/leave/apply" class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold">Apply for Leave</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label-enterprise">Leave Type</label>
                    <select name="leaveType" class="form-select-enterprise" required>
                        <c:forEach var="type" items="${leaveTypes}">
                            <option value="${type}">${type}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="row g-2 mb-3">
                    <div class="col-6">
                        <label class="form-label-enterprise">Start Date</label>
                        <input type="date" name="startDate" class="form-control-enterprise" required>
                    </div>
                    <div class="col-6">
                        <label class="form-label-enterprise">End Date</label>
                        <input type="date" name="endDate" class="form-control-enterprise" required>
                    </div>
                </div>
                <div class="form-check mb-3">
                    <input class="form-check-input" type="checkbox" name="halfDay" value="true" id="halfDayCheck">
                    <label class="form-check-label small" for="halfDayCheck">Half-day leave (0.5 day deduction)</label>
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Reason for Leave</label>
                    <textarea name="reason" class="form-control-enterprise" rows="3" required placeholder="Describe the reason for planned absence..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-enterprise btn-secondary-enterprise" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" class="btn-enterprise btn-primary-enterprise">Submit Application</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal 2: Attendance Correction -->
<div class="modal fade" id="correctionModal" tabindex="-1">
    <div class="modal-dialog">
        <form method="post" action="/portal/correction/apply" class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold">Request Attendance Correction</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label-enterprise">Attendance Date</label>
                    <input type="date" name="attendanceDate" class="form-control-enterprise" required>
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Actual Check-In Time</label>
                    <input type="datetime-local" name="reqCheckIn" class="form-control-enterprise" required>
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Actual Check-Out Time (Optional)</label>
                    <input type="datetime-local" name="reqCheckOut" class="form-control-enterprise">
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Reason for Adjustment</label>
                    <textarea name="reason" class="form-control-enterprise" rows="2" required placeholder="e.g. Card reader was offline, external meeting..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-enterprise btn-secondary-enterprise" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" class="btn-enterprise btn-primary-enterprise">Submit Request</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal 3: Update Profile -->
<div class="modal fade" id="updateProfileModal" tabindex="-1">
    <div class="modal-dialog">
        <form method="post" action="/portal/profile/update" class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold">Update My Personal Details</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label-enterprise">Phone Number</label>
                    <input type="text" name="phone" class="form-control-enterprise" value="${employee.phone}" required>
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Street Address</label>
                    <input type="text" name="addressStreet" class="form-control-enterprise" value="${employee.addressStreet}">
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">City</label>
                    <input type="text" name="addressCity" class="form-control-enterprise" value="${employee.addressCity}">
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Emergency Contact Name</label>
                    <input type="text" name="emergencyContactName" class="form-control-enterprise" value="${employee.emergencyContactName}">
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Emergency Contact Phone</label>
                    <input type="text" name="emergencyContactPhone" class="form-control-enterprise" value="${employee.emergencyContactPhone}">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-enterprise btn-secondary-enterprise" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" class="btn-enterprise btn-primary-enterprise">Save Details</button>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function updateClock() {
        const now = new Date();
        const timeStr = now.toLocaleTimeString('en-US', { hour12: false });
        const clockEl = document.getElementById('liveClock');
        if (clockEl) clockEl.innerText = timeStr;
    }
    setInterval(updateClock, 1000);
    updateClock();
</script>
</body>
</html>
