<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leave Management & Approvals | HRMS Operations</title>
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
                <h1 class="page-title">Leave Management & Approvals</h1>
                <p class="page-subtitle">Configure leave policies, process employee requests, monitor quotas, and prevent absenteeism overlap.</p>
            </div>
            <div class="header-actions">
                <a href="/reports/export/leaves" class="btn-enterprise btn-secondary-enterprise">
                    <i class="bi bi-file-earmark-arrow-down"></i>
                    <span>Export Leaves CSV</span>
                </a>
                <button type="button" class="btn-enterprise btn-primary-enterprise" data-bs-toggle="modal" data-bs-target="#newLeaveModal">
                    <i class="bi bi-calendar-plus-fill"></i>
                    <span>Apply for Leave</span>
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

        <!-- KPI Metrics -->
        <div class="stats-grid-3">
            <div class="stat-box">
                <div class="stat-box-top">
                    <span class="stat-label">Pending Review</span>
                    <div class="stat-icon amber"><i class="bi bi-clock-history"></i></div>
                </div>
                <div class="stat-value text-warning">${pendingCount}</div>
                <div class="stat-footer text-muted">Awaiting supervisor / HR sign-off</div>
            </div>
            <div class="stat-box">
                <div class="stat-box-top">
                    <span class="stat-label">Total Applications</span>
                    <div class="stat-icon indigo"><i class="bi bi-file-earmark-text"></i></div>
                </div>
                <div class="stat-value">${leaves.size()}</div>
                <div class="stat-footer text-muted">All active & past cycles</div>
            </div>
            <div class="stat-box">
                <div class="stat-box-top">
                    <span class="stat-label">Standard Quota Structure</span>
                    <div class="stat-icon emerald"><i class="bi bi-shield-check"></i></div>
                </div>
                <div class="stat-value text-dark" style="font-size: 1.3rem;">18 Annual &middot; 12 Casual &middot; 10 Sick</div>
                <div class="stat-footer text-muted">Enterprise paid time off allotment</div>
            </div>
        </div>

        <!-- Filter Tabs -->
        <div class="d-flex align-items-center justify-content-between mb-3">
            <div class="d-flex gap-2">
                <a href="/leave" class="btn-enterprise ${activeFilter != 'pending' ? 'btn-primary-enterprise' : 'btn-secondary-enterprise'} btn-sm-enterprise">
                    All Leave Applications (${leaves.size()})
                </a>
                <a href="/leave?filter=pending" class="btn-enterprise ${activeFilter == 'pending' ? 'btn-primary-enterprise' : 'btn-secondary-enterprise'} btn-sm-enterprise">
                    <i class="bi bi-exclamation-circle"></i> Pending Review Only (${pendingCount})
                </a>
            </div>
        </div>

        <!-- Leave Requests Table -->
        <div class="card-enterprise p-0 overflow-hidden">
            <div class="table-responsive-enterprise">
                <table class="table-enterprise">
                    <thead>
                        <tr>
                            <th>Employee</th>
                            <th>Department</th>
                            <th>Leave Type</th>
                            <th>Date Range</th>
                            <th>Days Deducted</th>
                            <th>Status</th>
                            <th>Reason / Explanation</th>
                            <th>Reviewer</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="lr" items="${leaves}">
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="user-avatar" style="width: 32px; height: 32px; font-size: 0.75rem;">
                                            ${lr.employee.firstName.substring(0, 1)}
                                        </div>
                                        <div>
                                            <a href="/employees/${lr.employee.id}" class="fw-bold text-dark text-decoration-none">
                                                ${lr.employee.fullName}
                                            </a>
                                            <small class="text-muted d-block">${lr.employee.employeeCode}</small>
                                        </div>
                                    </div>
                                </td>
                                <td>${not empty lr.employee.department ? lr.employee.department.name : 'General'}</td>
                                <td><span class="badge bg-light text-dark border">${lr.leaveType}</span></td>
                                <td>
                                    <div class="small fw-bold text-dark">${lr.startDate} &rarr; ${lr.endDate}</div>
                                    <c:if test="${lr.halfDay}">
                                        <span class="badge bg-info-subtle text-info border">Half-Day</span>
                                    </c:if>
                                </td>
                                <td class="fw-bold">${lr.days} day(s)</td>
                                <td>
                                    <span class="badge-status ${lr.status == 'APPROVED' ? 'badge-approved' : (lr.status == 'PENDING' ? 'badge-pending' : 'badge-rejected')}">
                                        ${lr.status}
                                    </span>
                                </td>
                                <td class="text-muted small" style="max-width: 220px;">${lr.reason}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty lr.reviewedBy}">
                                            <div class="small fw-bold text-dark">${lr.reviewedBy.fullName}</div>
                                            <small class="text-muted">${not empty lr.reviewComment ? lr.reviewComment : 'No comment'}</small>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted small">Pending review</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-end">
                                    <c:if test="${lr.status == 'PENDING'}">
                                        <form method="post" action="/leave/approve" class="d-inline">
                                            <input type="hidden" name="requestId" value="${lr.id}">
                                            <input type="hidden" name="comment" value="Approved by authorized HR/Manager">
                                            <button type="submit" class="btn-enterprise btn-sm-enterprise btn-success-enterprise me-1" title="Approve">
                                                <i class="bi bi-check2"></i> Approve
                                            </button>
                                        </form>
                                        <form method="post" action="/leave/reject" class="d-inline">
                                            <input type="hidden" name="requestId" value="${lr.id}">
                                            <input type="hidden" name="comment" value="Insufficient coverage or scheduling conflict">
                                            <button type="submit" class="btn-enterprise btn-sm-enterprise btn-danger-enterprise" title="Reject">
                                                <i class="bi bi-x-lg"></i> Reject
                                            </button>
                                        </form>
                                    </c:if>
                                    <c:if test="${lr.status == 'APPROVED'}">
                                        <form method="post" action="/leave/cancel" class="d-inline">
                                            <input type="hidden" name="requestId" value="${lr.id}">
                                            <button type="submit" class="btn-enterprise btn-sm-enterprise btn-secondary-enterprise" title="Cancel Leave">
                                                Cancel
                                            </button>
                                        </form>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty leaves}">
                            <tr>
                                <td colspan="9" class="text-center text-muted py-5">
                                    No leave requests match the current filter.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<!-- Modal: New Leave Application -->
<div class="modal fade" id="newLeaveModal" tabindex="-1">
    <div class="modal-dialog">
        <form method="post" action="/leave/apply" class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold">Submit Leave Application</h5>
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
                    <label class="form-label-enterprise">Leave Category *</label>
                    <select name="leaveType" class="form-select-enterprise" required>
                        <c:forEach var="type" items="${leaveTypes}">
                            <option value="${type}">${type}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="row g-2 mb-3">
                    <div class="col-6">
                        <label class="form-label-enterprise">Start Date *</label>
                        <input type="date" name="startDate" class="form-control-enterprise" required>
                    </div>
                    <div class="col-6">
                        <label class="form-label-enterprise">End Date *</label>
                        <input type="date" name="endDate" class="form-control-enterprise" required>
                    </div>
                </div>
                <div class="form-check mb-3">
                    <input class="form-check-input" type="checkbox" name="halfDay" value="true" id="halfDayModal">
                    <label class="form-check-label small" for="halfDayModal">Half-day leave (0.5 day deduction)</label>
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Reason for Leave *</label>
                    <textarea name="reason" class="form-control-enterprise" rows="3" required placeholder="State reason, handover coverage, and emergency contacts..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-enterprise btn-secondary-enterprise" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" class="btn-enterprise btn-primary-enterprise">Submit Request</button>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
