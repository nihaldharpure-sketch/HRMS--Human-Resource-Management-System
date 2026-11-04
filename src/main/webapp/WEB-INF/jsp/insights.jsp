<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI HR Operational Insights | HRMS Operations</title>
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
                <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-2 py-1 font-monospace mb-2">INTELLIGENT WORKFORCE ANALYTICS</span>
                <h1 class="page-title">AI-Assisted HR Insights & Operational Pulse</h1>
                <p class="page-subtitle">Aggregated organizational pattern detection, absenteeism forecasting, hiring pipeline health, and payroll compliance checks.</p>
            </div>
            <div class="header-actions">
                <span class="badge bg-light text-secondary border px-3 py-2">
                    <i class="bi bi-shield-lock-fill text-success me-1"></i> Privacy Protected: Zero PII Egress
                </span>
            </div>
        </div>

        <!-- Privacy & AI Guardrail Notice -->
        <div class="card-enterprise mb-4" style="background: #f8fafc; border-left: 4px solid var(--info);">
            <div class="d-flex align-items-start gap-3">
                <div class="stat-icon indigo" style="width: 36px; height: 36px; font-size: 1.1rem; flex-shrink: 0;">
                    <i class="bi bi-cpu-fill"></i>
                </div>
                <div>
                    <h6 class="fw-bold mb-1 text-dark">Automated Insights & Governance Principles</h6>
                    <p class="text-muted small mb-0">
                        In accordance with enterprise HR security policies, AI assistance serves strictly advisory operational purposes. Employee personally identifiable information (PII) and banking data are never exposed externally. Disciplinary, payroll approval, and termination decisions remain under human executive governance.
                    </p>
                </div>
            </div>
        </div>

        <!-- Executive Summary Cards -->
        <div class="row g-4 mb-4">
            <!-- Key Observations -->
            <div class="col-lg-6">
                <div class="card-enterprise h-100">
                    <div class="d-flex align-items-center justify-content-between mb-3 border-bottom pb-2">
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-graph-up-arrow text-primary fs-5"></i>
                            <h6 class="fw-bold mb-0 text-dark">Key Operational Observations</h6>
                        </div>
                        <span class="badge bg-light text-dark border">Real-time DB Analysis</span>
                    </div>

                    <div class="list-group list-group-flush">
                        <c:forEach var="obs" items="${insights.keyObservations}">
                            <div class="list-group-item px-0 py-3 d-flex align-items-start gap-3">
                                <i class="bi bi-check-circle-fill text-success mt-1"></i>
                                <span class="small text-slate-800">${obs}</span>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </div>

            <!-- Action Recommendations -->
            <div class="col-lg-6">
                <div class="card-enterprise h-100">
                    <div class="d-flex align-items-center justify-content-between mb-3 border-bottom pb-2">
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-lightbulb-fill text-warning fs-5"></i>
                            <h6 class="fw-bold mb-0 text-dark">Strategic Action Recommendations</h6>
                        </div>
                        <span class="badge bg-warning-subtle text-warning border border-warning-subtle">HR Operations</span>
                    </div>

                    <div class="list-group list-group-flush">
                        <c:forEach var="rec" items="${insights.actionRecommendations}">
                            <div class="list-group-item px-0 py-3 d-flex align-items-start gap-3">
                                <i class="bi bi-arrow-right-circle-fill text-primary mt-1"></i>
                                <span class="small text-slate-800">${rec}</span>
                            </div>
                        </c:forEach>
                        <c:if test="${empty insights.actionRecommendations}">
                            <div class="p-3 text-center text-muted small">
                                Operations are performing within standard thresholds. No critical interventions required.
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>

        <!-- Quick Module Jumpers -->
        <div class="card-enterprise">
            <h6 class="fw-bold mb-3 text-dark">Execute Recommended Actions</h6>
            <div class="row g-3">
                <div class="col-md-3">
                    <a href="/attendance" class="btn-enterprise btn-secondary-enterprise w-100 justify-content-start">
                        <i class="bi bi-clock-history text-primary"></i>
                        <span>Audit Attendance</span>
                    </a>
                </div>
                <div class="col-md-3">
                    <a href="/leave?filter=pending" class="btn-enterprise btn-secondary-enterprise w-100 justify-content-start">
                        <i class="bi bi-calendar-check text-warning"></i>
                        <span>Clear Leave Backlog</span>
                    </a>
                </div>
                <div class="col-md-3">
                    <a href="/payroll" class="btn-enterprise btn-secondary-enterprise w-100 justify-content-start">
                        <i class="bi bi-wallet2 text-success"></i>
                        <span>Run Monthly Payroll</span>
                    </a>
                </div>
                <div class="col-md-3">
                    <a href="/recruitment" class="btn-enterprise btn-secondary-enterprise w-100 justify-content-start">
                        <i class="bi bi-briefcase text-purple"></i>
                        <span>Manage Requisitions</span>
                    </a>
                </div>
            </div>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
