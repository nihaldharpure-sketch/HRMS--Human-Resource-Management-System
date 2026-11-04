<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notification & Approval Center | HRMS Operations</title>
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
                <h1 class="page-title">Notification & Approval Center</h1>
                <p class="page-subtitle">Centralized alerts for leave applications, attendance adjustment requests, payroll reviews, and candidate interviews.</p>
            </div>
            <div class="header-actions">
                <form method="post" action="/notifications/read-all" class="d-inline">
                    <button type="submit" class="btn-enterprise btn-secondary-enterprise">
                        <i class="bi bi-check2-all"></i>
                        <span>Mark All as Read</span>
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

        <div class="card-enterprise p-0 overflow-hidden">
            <div class="p-3 border-bottom fw-bold text-dark d-flex align-items-center justify-content-between">
                <span>All Alerts & Notifications (${notifications.size()})</span>
            </div>
            <div class="list-group list-group-flush">
                <c:forEach var="n" items="${notifications}">
                    <div class="list-group-item p-3 ${!n.isRead ? 'bg-light' : ''} d-flex align-items-start justify-content-between gap-3">
                        <div class="d-flex align-items-start gap-3">
                            <div class="stat-icon ${n.type == 'LEAVE' ? 'amber' : (n.type == 'RECRUITMENT' ? 'indigo' : (n.type == 'PAYROLL' ? 'purple' : 'emerald'))}" style="width: 38px; height: 38px; font-size: 1.1rem; flex-shrink: 0;">
                                <i class="bi ${n.type == 'LEAVE' ? 'bi-calendar-event' : (n.type == 'RECRUITMENT' ? 'bi-person-plus' : (n.type == 'PAYROLL' ? 'bi-wallet2' : 'bi-bell'))}"></i>
                            </div>
                            <div>
                                <div class="d-flex align-items-center gap-2 mb-1">
                                    <h6 class="mb-0 fw-bold text-dark">${n.title}</h6>
                                    <c:if test="${!n.isRead}">
                                        <span class="badge bg-primary-subtle text-primary border border-primary-subtle" style="font-size: 0.65rem;">NEW</span>
                                    </c:if>
                                </div>
                                <p class="text-muted small mb-2">${n.message}</p>
                                <div class="d-flex align-items-center gap-3">
                                    <small class="text-muted" style="font-size: 0.72rem;">
                                        <i class="bi bi-clock me-1"></i>${n.createdAt}
                                    </small>
                                    <c:if test="${not empty n.link}">
                                        <a href="${n.link}" class="small text-primary fw-bold text-decoration-none">
                                            Open Related Record &rarr;
                                        </a>
                                    </c:if>
                                </div>
                            </div>
                        </div>

                        <div>
                            <c:if test="${!n.isRead}">
                                <form method="post" action="/notifications/read/${n.id}" class="d-inline">
                                    <button type="submit" class="btn btn-sm btn-outline-secondary" title="Mark Read">
                                        <i class="bi bi-check2"></i>
                                    </button>
                                </form>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
                <c:if test="${empty notifications}">
                    <div class="empty-state py-5">
                        <i class="bi bi-bell-slash text-muted fs-2 mb-2 d-block"></i>
                        <div class="empty-title">You're all caught up!</div>
                        <div class="empty-desc">No active notifications or pending approval alerts.</div>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
