<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Performance Management & Goals | HRMS Operations</title>
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
                <h1 class="page-title">Performance & Goals Management</h1>
                <p class="page-subtitle">Quarterly review cycles, measurable KPIs, employee self-evaluations, and manager feedback ratings.</p>
            </div>
            <div class="header-actions">
                <button type="button" class="btn-enterprise btn-primary-enterprise" data-bs-toggle="modal" data-bs-target="#newReviewModal">
                    <i class="bi bi-plus-lg"></i>
                    <span>Initiate Review Cycle</span>
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

        <!-- Performance Reviews Table -->
        <div class="card-enterprise p-0 overflow-hidden">
            <div class="table-responsive-enterprise">
                <table class="table-enterprise">
                    <thead>
                        <tr>
                            <th>Employee</th>
                            <th>Cycle Period</th>
                            <th>Assigned Goals & KPIs</th>
                            <th>Self-Rating</th>
                            <th>Manager Rating</th>
                            <th>Status</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="rev" items="${reviews}">
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="user-avatar" style="width: 32px; height: 32px; font-size: 0.75rem;">
                                            ${rev.employee.firstName.substring(0, 1)}
                                        </div>
                                        <div>
                                            <a href="/employees/${rev.employee.id}" class="text-decoration-none fw-bold text-dark">
                                                ${rev.employee.fullName}
                                            </a>
                                            <small class="text-muted d-block">${rev.employee.employeeCode}</small>
                                        </div>
                                    </div>
                                </td>
                                <td><span class="badge bg-light text-dark border font-monospace">${rev.reviewPeriod}</span></td>
                                <td style="max-width: 250px;">
                                    <div class="small fw-bold text-dark">${not empty rev.goals ? rev.goals : 'Standard Quarterly KPIs'}</div>
                                    <div class="text-muted small text-truncate">${rev.kpis}</div>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty rev.selfRating}">
                                            <span class="badge bg-info-subtle text-info border">${rev.selfRating} / 5</span>
                                        </c:when>
                                        <c:otherwise><span class="text-muted small">Pending</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty rev.managerRating}">
                                            <span class="badge bg-success-subtle text-success border fw-bold">${rev.managerRating} / 5</span>
                                        </c:when>
                                        <c:otherwise><span class="text-muted small">Pending review</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <span class="badge-status ${rev.status == 'COMPLETED' ? 'badge-approved' : (rev.status == 'SUBMITTED' ? 'badge-pending' : 'badge-draft')}">
                                        ${rev.status}
                                    </span>
                                </td>
                                <td class="text-end">
                                    <c:if test="${rev.status == 'DRAFT'}">
                                        <button type="button" class="btn-enterprise btn-sm-enterprise btn-secondary-enterprise me-1" data-bs-toggle="modal" data-bs-target="#selfEvalModal${rev.id}">
                                            Self-Appraise
                                        </button>
                                    </c:if>
                                    <c:if test="${rev.status == 'SUBMITTED' || rev.status == 'DRAFT'}">
                                        <button type="button" class="btn-enterprise btn-sm-enterprise btn-primary-enterprise" data-bs-toggle="modal" data-bs-target="#managerEvalModal${rev.id}">
                                            Manager Review
                                        </button>
                                    </c:if>

                                    <!-- Modal: Self Eval -->
                                    <div class="modal fade text-start" id="selfEvalModal${rev.id}" tabindex="-1">
                                        <div class="modal-dialog">
                                            <form method="post" action="/performance/self-eval" class="modal-content">
                                                <div class="modal-header">
                                                    <h5 class="modal-title fw-bold">Employee Self-Appraisal: ${rev.employee.fullName}</h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                </div>
                                                <div class="modal-body">
                                                    <input type="hidden" name="reviewId" value="${rev.id}">
                                                    <div class="mb-3">
                                                        <label class="form-label-enterprise">Self Rating (1 to 5)</label>
                                                        <select name="selfRating" class="form-select-enterprise" required>
                                                            <option value="5">5 - Surpassed all targets</option>
                                                            <option value="4" selected>4 - Exceeded standard expectations</option>
                                                            <option value="3">3 - Consistently met expectations</option>
                                                            <option value="2">2 - Needs guidance in core areas</option>
                                                            <option value="1">1 - Unsatisfactory</option>
                                                        </select>
                                                    </div>
                                                    <div class="mb-3">
                                                        <label class="form-label-enterprise">Self-Assessment Summary & Key Achievements</label>
                                                        <textarea name="selfAssessment" class="form-control-enterprise" rows="4" required placeholder="Highlight key deliveries, project impact, and obstacles overcome..."></textarea>
                                                    </div>
                                                </div>
                                                <div class="modal-footer">
                                                    <button type="button" class="btn-enterprise btn-secondary-enterprise" data-bs-dismiss="modal">Cancel</button>
                                                    <button type="submit" class="btn-enterprise btn-primary-enterprise">Submit for Review</button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>

                                    <!-- Modal: Manager Eval -->
                                    <div class="modal fade text-start" id="managerEvalModal${rev.id}" tabindex="-1">
                                        <div class="modal-dialog">
                                            <form method="post" action="/performance/manager-eval" class="modal-content">
                                                <div class="modal-header">
                                                    <h5 class="modal-title fw-bold">Manager Evaluation & Feedback: ${rev.employee.fullName}</h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                </div>
                                                <div class="modal-body">
                                                    <input type="hidden" name="reviewId" value="${rev.id}">
                                                    <c:if test="${not empty rev.selfAssessment}">
                                                        <div class="p-3 bg-light rounded-3 mb-3 border">
                                                            <small class="text-muted fw-bold d-block">Employee's Self Assessment (${rev.selfRating}/5):</small>
                                                            <div class="small text-dark mt-1">${rev.selfAssessment}</div>
                                                        </div>
                                                    </c:if>
                                                    <div class="mb-3">
                                                        <label class="form-label-enterprise">Official Manager Score (1 to 5)</label>
                                                        <select name="managerRating" class="form-select-enterprise" required>
                                                            <option value="5">5 - Top Tier Performer</option>
                                                            <option value="4" selected>4 - Exceeds Job Expectations</option>
                                                            <option value="3">3 - Solid Contributor</option>
                                                            <option value="2">2 - Performance Improvement Required</option>
                                                            <option value="1">1 - Unsatisfactory</option>
                                                        </select>
                                                    </div>
                                                    <div class="mb-3">
                                                        <label class="form-label-enterprise">Manager Written Feedback & Growth Recommendations</label>
                                                        <textarea name="feedback" class="form-control-enterprise" rows="4" required placeholder="Provide actionable feedback, strengths, and development roadmap..."></textarea>
                                                    </div>
                                                </div>
                                                <div class="modal-footer">
                                                    <button type="button" class="btn-enterprise btn-secondary-enterprise" data-bs-dismiss="modal">Cancel</button>
                                                    <button type="submit" class="btn-enterprise btn-success-enterprise">Finalize & Sign Review</button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty reviews}">
                            <tr>
                                <td colspan="7" class="text-center text-muted py-5">
                                    No review cycles active. Initiate a review cycle using the button above.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<!-- Modal: New Review Cycle -->
<div class="modal fade" id="newReviewModal" tabindex="-1">
    <div class="modal-dialog">
        <form method="post" action="/performance/create" class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold">Initiate Performance Appraisal Cycle</h5>
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
                    <label class="form-label-enterprise">Review Period *</label>
                    <input type="text" name="reviewPeriod" class="form-control-enterprise" required placeholder="e.g. 2026-Q3 / 2026-Annual" value="2026-Q3">
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Assigned Manager Reviewer</label>
                    <select name="reviewerId" class="form-select-enterprise">
                        <option value="">-- Direct Manager --</option>
                        <c:forEach var="m" items="${employees}">
                            <option value="${m.id}">${m.fullName}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Quarterly Goals</label>
                    <textarea name="goals" class="form-control-enterprise" rows="2" placeholder="Key objectives and deliverables for this period..."></textarea>
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Measurable KPIs & Metrics</label>
                    <textarea name="kpis" class="form-control-enterprise" rows="2" placeholder="e.g. 99.9% uptime, 100% on-time sprint deliveries, 95% satisfaction..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-enterprise btn-secondary-enterprise" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" class="btn-enterprise btn-primary-enterprise">Launch Review Cycle</button>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
