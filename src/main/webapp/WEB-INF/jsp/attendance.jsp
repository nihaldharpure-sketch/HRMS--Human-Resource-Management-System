<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Attendance & Shift Management | HRMS Operations</title>
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
                <h1 class="page-title">Attendance & Shift Management</h1>
                <p class="page-subtitle">Track daily check-ins, late arrivals, overtime hours, shift rosters, and review attendance adjustment requests.</p>
            </div>
            <div class="header-actions">
                <a href="/reports/export/attendance?date=${selectedDate}" class="btn-enterprise btn-secondary-enterprise">
                    <i class="bi bi-file-earmark-arrow-down"></i>
                    <span>Export Attendance</span>
                </a>
                <button type="button" class="btn-enterprise btn-primary-enterprise" data-bs-toggle="modal" data-bs-target="#manualAttendanceModal">
                    <i class="bi bi-plus-lg"></i>
                    <span>Manual Entry</span>
                </button>
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

        <!-- Attendance Stats Overview -->
        <div class="stats-grid-4">
            <div class="stat-box">
                <div class="stat-box-top">
                    <span class="stat-label">Present Today</span>
                    <div class="stat-icon emerald"><i class="bi bi-check2-circle"></i></div>
                </div>
                <div class="stat-value text-success">${presentCount}</div>
                <div class="stat-footer text-muted">Active in office / remote</div>
            </div>
            <div class="stat-box">
                <div class="stat-box-top">
                    <span class="stat-label">Late Arrivals</span>
                    <div class="stat-icon amber"><i class="bi bi-alarm-fill"></i></div>
                </div>
                <div class="stat-value text-warning">${lateCount}</div>
                <div class="stat-footer text-muted">Checked in after 09:30 AM</div>
            </div>
            <div class="stat-box">
                <div class="stat-box-top">
                    <span class="stat-label">On Approved Leave</span>
                    <div class="stat-icon purple"><i class="bi bi-calendar2-heart-fill"></i></div>
                </div>
                <div class="stat-value text-purple">${onLeaveCount}</div>
                <div class="stat-footer text-muted">Official approved leave</div>
            </div>
            <div class="stat-box">
                <div class="stat-box-top">
                    <span class="stat-label">Absent / Unreported</span>
                    <div class="stat-icon crimson"><i class="bi bi-x-circle-fill"></i></div>
                </div>
                <div class="stat-value text-danger">${absentCount}</div>
                <div class="stat-footer text-muted">No check-in recorded</div>
            </div>
        </div>

        <!-- Date Filter & Quick Punch Bar -->
        <div class="card-enterprise mb-4 p-3">
            <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
                <form method="get" action="/attendance" class="d-flex align-items-center gap-2">
                    <label class="form-label-enterprise mb-0">Select Date:</label>
                    <input type="date" name="date" class="form-control-enterprise" style="width: 180px;" value="${selectedDate}" onchange="this.form.submit()">
                    <button type="submit" class="btn-enterprise btn-secondary-enterprise btn-sm-enterprise">View</button>
                    <a href="/attendance" class="btn-enterprise btn-secondary-enterprise btn-sm-enterprise">Today</a>
                </form>

                <div class="d-flex align-items-center gap-2">
                    <!-- Quick Punch for current user -->
                    <c:choose>
                        <c:when test="${empty todayAttendance || empty todayAttendance.checkIn}">
                            <form method="post" action="/attendance/check-in" class="d-inline">
                                <button type="submit" class="btn-enterprise btn-success-enterprise">
                                    <i class="bi bi-box-arrow-in-right"></i> Punch Check-In
                                </button>
                            </form>
                        </c:when>
                        <c:when test="${empty todayAttendance.checkOut}">
                            <form method="post" action="/attendance/check-out" class="d-inline">
                                <button type="submit" class="btn-enterprise btn-danger-enterprise">
                                    <i class="bi bi-box-arrow-right"></i> Punch Check-Out
                                </button>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <span class="badge bg-light text-success border px-3 py-2 fw-bold">
                                <i class="bi bi-check2"></i> Workday Completed
                            </span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <!-- Tabs: Daily Records & Attendance Corrections -->
        <ul class="nav nav-pills tabs-enterprise" id="attTabs" role="tablist">
            <li class="nav-item">
                <button class="nav-link tab-btn active" id="records-tab" data-bs-toggle="tab" data-bs-target="#records" type="button">
                    <i class="bi bi-table me-1"></i> Daily Records for ${selectedDate} (${attendances.size()})
                </button>
            </li>
            <li class="nav-item">
                <button class="nav-link tab-btn" id="corrections-tab" data-bs-toggle="tab" data-bs-target="#corrections" type="button">
                    <i class="bi bi-pencil-square me-1"></i> Adjustment Requests (${corrections.size()})
                </button>
            </li>
        </ul>

        <div class="tab-content" id="attTabContent">
            <!-- Tab 1: Daily Attendance Table -->
            <div class="tab-pane fade show active" id="records" role="tabpanel">
                <div class="card-enterprise p-0 overflow-hidden">
                    <div class="table-responsive-enterprise">
                        <table class="table-enterprise">
                            <thead>
                                <tr>
                                    <th>Employee</th>
                                    <th>Department</th>
                                    <th>Check In</th>
                                    <th>Check Out</th>
                                    <th>Total Working Hours</th>
                                    <th>Overtime</th>
                                    <th>Late (Mins)</th>
                                    <th>Status</th>
                                    <th>Remarks</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="att" items="${attendances}">
                                    <tr>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="user-avatar" style="width: 32px; height: 32px; font-size: 0.75rem;">
                                                    ${att.employee.firstName.substring(0, 1)}
                                                </div>
                                                <div>
                                                    <a href="/employees/${att.employee.id}" class="text-decoration-none fw-bold text-dark">
                                                        ${att.employee.fullName}
                                                    </a>
                                                    <small class="text-muted d-block">${att.employee.employeeCode}</small>
                                                </div>
                                            </div>
                                        </td>
                                        <td>${not empty att.employee.department ? att.employee.department.name : 'General'}</td>
                                        <td>${not empty att.checkIn ? att.checkIn.toLocalTime() : '-'}</td>
                                        <td>${not empty att.checkOut ? att.checkOut.toLocalTime() : '<span class="text-muted">Working...</span>'}</td>
                                        <td class="fw-bold">${att.totalHours} hrs</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${att.overtimeHours > 0}">
                                                    <span class="badge bg-success-subtle text-success border border-success-subtle">${att.overtimeHours} hrs OT</span>
                                                </c:when>
                                                <c:otherwise>-</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${att.lateMinutes > 0}">
                                                    <span class="text-danger fw-bold">+${att.lateMinutes} mins</span>
                                                </c:when>
                                                <c:otherwise>On time</c:otherwise>
                                            </c:choose>
                                        </td>
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
                                        <td colspan="9" class="text-center text-muted py-5">
                                            No attendance logs for this date. Check in above or use manual entry.
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Tab 2: Attendance Corrections Review -->
            <div class="tab-pane fade" id="corrections" role="tabpanel">
                <div class="card-enterprise p-0 overflow-hidden">
                    <div class="table-responsive-enterprise">
                        <table class="table-enterprise">
                            <thead>
                                <tr>
                                    <th>Employee</th>
                                    <th>Date</th>
                                    <th>Requested Check-In</th>
                                    <th>Requested Check-Out</th>
                                    <th>Reason</th>
                                    <th>Status</th>
                                    <th class="text-end">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="c" items="${corrections}">
                                    <tr>
                                        <td class="fw-bold">${c.employee.fullName}</td>
                                        <td>${c.attendanceDate}</td>
                                        <td>${c.requestedCheckIn}</td>
                                        <td>${not empty c.requestedCheckOut ? c.requestedCheckOut : '-'}</td>
                                        <td class="text-muted small">${c.reason}</td>
                                        <td><span class="badge-status badge-pending">${c.status}</span></td>
                                        <td class="text-end">
                                            <form method="post" action="/attendance/correction/review" class="d-inline">
                                                <input type="hidden" name="correctionId" value="${c.id}">
                                                <input type="hidden" name="approve" value="true">
                                                <input type="hidden" name="remarks" value="Approved by HR">
                                                <button type="submit" class="btn-enterprise btn-sm-enterprise btn-success-enterprise me-1">
                                                    Approve
                                                </button>
                                            </form>
                                            <form method="post" action="/attendance/correction/review" class="d-inline">
                                                <input type="hidden" name="correctionId" value="${c.id}">
                                                <input type="hidden" name="approve" value="false">
                                                <input type="hidden" name="remarks" value="Discrepancy in explanation">
                                                <button type="submit" class="btn-enterprise btn-sm-enterprise btn-danger-enterprise">
                                                    Reject
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty corrections}">
                                    <tr>
                                        <td colspan="7" class="text-center text-muted py-4">No pending attendance correction requests.</td>
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

<!-- Modal: Manual Attendance Entry -->
<div class="modal fade" id="manualAttendanceModal" tabindex="-1">
    <div class="modal-dialog">
        <form method="post" action="/attendance/manual" class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold">Manual Attendance Entry</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label-enterprise">Employee *</label>
                    <select name="employeeId" class="form-select-enterprise" required>
                        <c:forEach var="emp" items="${employees}">
                            <option value="${emp.id}">${emp.fullName} (${emp.employeeCode})</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Date *</label>
                    <input type="date" name="date" class="form-control-enterprise" value="${selectedDate}" required>
                </div>
                <div class="row g-2 mb-3">
                    <div class="col-6">
                        <label class="form-label-enterprise">Check-In Time</label>
                        <input type="datetime-local" name="checkIn" class="form-control-enterprise">
                    </div>
                    <div class="col-6">
                        <label class="form-label-enterprise">Check-Out Time</label>
                        <input type="datetime-local" name="checkOut" class="form-control-enterprise">
                    </div>
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Status</label>
                    <select name="status" class="form-select-enterprise">
                        <option value="PRESENT">Present</option>
                        <option value="LATE">Late Arrival</option>
                        <option value="HALF_DAY">Half Day</option>
                        <option value="ON_LEAVE">On Leave</option>
                        <option value="ABSENT">Absent</option>
                    </select>
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Remarks</label>
                    <input type="text" name="remarks" class="form-control-enterprise" placeholder="e.g. Approved remote day, field visit">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-enterprise btn-secondary-enterprise" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" class="btn-enterprise btn-primary-enterprise">Save Record</button>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
