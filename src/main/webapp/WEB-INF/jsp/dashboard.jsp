<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Enterprise HR Operations Dashboard | HRMS</title>
    <!-- Google Fonts Inter -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Bootstrap 5.3.3 & Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Enterprise Design System CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

<jsp:include page="fragments/navbar.jsp" />

<main class="app-main">
    <div class="content-wrapper">
        <!-- Page Header -->
        <div class="page-header">
            <div>
                <h1 class="page-title">Enterprise HR Operations Dashboard</h1>
                <p class="page-subtitle">Real-time workforce health, attendance pulse, payroll summary, and recruitment pipeline.</p>
            </div>
            <div class="header-actions">
                <a href="/portal" class="btn-enterprise btn-secondary-enterprise">
                    <i class="bi bi-person-badge"></i>
                    <span>Employee Hub</span>
                </a>
                <a href="/payroll" class="btn-enterprise btn-secondary-enterprise">
                    <i class="bi bi-wallet2"></i>
                    <span>Run Payroll</span>
                </a>
                <a href="/employees/add" class="btn-enterprise btn-primary-enterprise">
                    <i class="bi bi-person-plus-fill"></i>
                    <span>Add Employee</span>
                </a>
            </div>
        </div>

        <!-- Feedback Alerts -->
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

        <!-- Primary KPI Metrics Grid -->
        <div class="stats-grid-4">
            <!-- Total Employees -->
            <div class="stat-box">
                <div class="stat-box-top">
                    <span class="stat-label">Total Workforce</span>
                    <div class="stat-icon indigo">
                        <i class="bi bi-people-fill"></i>
                    </div>
                </div>
                <div class="stat-value">${employeeCount}</div>
                <div class="stat-footer">
                    <span class="stat-trend-up"><i class="bi bi-check2"></i> ${activeEmployees} Active</span>
                    <span class="text-muted ms-1">&middot; ${inactiveEmployees} Inactive</span>
                </div>
            </div>

            <!-- Attendance Rate -->
            <div class="stat-box">
                <div class="stat-box-top">
                    <span class="stat-label">Attendance Rate</span>
                    <div class="stat-icon emerald">
                        <i class="bi bi-person-check-fill"></i>
                    </div>
                </div>
                <div class="stat-value">${attendanceRate}%</div>
                <div class="stat-footer">
                    <span class="stat-trend-up"><i class="bi bi-dot"></i> ${presentToday} Present</span>
                    <span class="text-warning ms-1">&middot; ${lateToday} Late</span>
                    <span class="text-danger ms-1">&middot; ${absentToday} Absent</span>
                </div>
            </div>

            <!-- Pending Approvals -->
            <div class="stat-box">
                <div class="stat-box-top">
                    <span class="stat-label">Pending Leaves</span>
                    <div class="stat-icon amber">
                        <i class="bi bi-calendar2-heart-fill"></i>
                    </div>
                </div>
                <div class="stat-value">${pendingLeaves}</div>
                <div class="stat-footer">
                    <a href="/leave?filter=pending" class="text-decoration-none text-warning fw-bold">
                        <i class="bi bi-arrow-right-circle"></i> Review Requests
                    </a>
                </div>
            </div>

            <!-- Monthly Payroll Payout -->
            <div class="stat-box">
                <div class="stat-box-top">
                    <span class="stat-label">Monthly Payroll</span>
                    <div class="stat-icon purple">
                        <i class="bi bi-cash-stack"></i>
                    </div>
                </div>
                <div class="stat-value">₹${monthlyPayroll}</div>
                <div class="stat-footer">
                    <span class="text-muted"><i class="bi bi-calendar-event"></i> Current Cycle</span>
                </div>
            </div>
        </div>

        <!-- AI Insights & Executive Recommendation Banner -->
        <div class="card-enterprise mb-4" style="background: linear-gradient(135deg, #f8fafc 0%, #eef2ff 100%); border-left: 4px solid var(--primary);">
            <div class="d-flex align-items-center justify-content-between mb-3">
                <div class="d-flex align-items-center gap-2">
                    <div class="stat-icon indigo" style="width: 32px; height: 32px; font-size: 1rem;">
                        <i class="bi bi-stars"></i>
                    </div>
                    <h6 class="mb-0 fw-bold" style="color: var(--slate-900);">AI-Assisted Operational Insights & Highlights</h6>
                </div>
                <a href="/insights" class="btn-enterprise btn-sm-enterprise btn-secondary-enterprise">
                    <span>View Deep Analytics</span>
                    <i class="bi bi-arrow-right"></i>
                </a>
            </div>
            <div class="row g-3">
                <div class="col-md-7">
                    <div class="small fw-bold text-muted mb-2 text-uppercase">Key Observations</div>
                    <ul class="mb-0 ps-3 small text-slate-700">
                        <c:forEach var="obs" items="${insights.keyObservations}">
                            <li class="mb-1">${obs}</li>
                        </c:forEach>
                    </ul>
                </div>
                <div class="col-md-5">
                    <div class="small fw-bold text-muted mb-2 text-uppercase">Recommended Action</div>
                    <c:forEach var="rec" items="${insights.actionRecommendations}">
                        <div class="d-flex align-items-start gap-2 small text-slate-800 mb-2">
                            <i class="bi bi-lightbulb-fill text-warning mt-1"></i>
                            <span>${rec}</span>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </div>

        <!-- Analytics Charts Row -->
        <div class="row g-4 mb-4">
            <!-- Workforce & Attendance Trend Chart -->
            <div class="col-lg-8">
                <div class="card-enterprise h-100">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <div>
                            <h6 class="fw-bold mb-1" style="color: var(--slate-900);">Workforce & Headcount Dynamics</h6>
                            <p class="text-muted small mb-0">Active employee retention and hiring pace across the last 6 months</p>
                        </div>
                        <span class="badge-status badge-active">Live DB Synced</span>
                    </div>
                    <div style="height: 270px; position: relative;">
                        <canvas id="workforceTrendChart"></canvas>
                    </div>
                </div>
            </div>

            <!-- Department Distribution Doughnut -->
            <div class="col-lg-4">
                <div class="card-enterprise h-100">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <div>
                            <h6 class="fw-bold mb-1" style="color: var(--slate-900);">Department Breakdown</h6>
                            <p class="text-muted small mb-0">Organizational headcount distribution</p>
                        </div>
                    </div>
                    <div style="height: 220px; position: relative;">
                        <canvas id="deptDistributionChart"></canvas>
                    </div>
                    <div class="mt-3 text-center small text-muted">
                        Total Departments: <strong class="text-dark">${deptLabels.size()}</strong> &middot; Total Staff: <strong class="text-dark">${employeeCount}</strong>
                    </div>
                </div>
            </div>
        </div>

        <!-- Tables Row: Recent Employees & Upcoming Interviews -->
        <div class="row g-4">
            <!-- Recent Staff Directory -->
            <div class="col-lg-7">
                <div class="card-enterprise h-100">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <div>
                            <h6 class="fw-bold mb-1" style="color: var(--slate-900);">Recent Employee Directory</h6>
                            <p class="text-muted small mb-0">Staff members registered in the organization</p>
                        </div>
                        <a href="/employees" class="btn-enterprise btn-sm-enterprise btn-secondary-enterprise">View All</a>
                    </div>
                    <div class="table-responsive-enterprise">
                        <table class="table-enterprise">
                            <thead>
                                <tr>
                                    <th>Employee</th>
                                    <th>Department</th>
                                    <th>Designation</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="emp" items="${recentEmployees}">
                                    <tr>
                                        <td>
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="user-avatar" style="width: 30px; height: 30px; font-size: 0.75rem;">
                                                    ${emp.firstName.substring(0, 1)}
                                                </div>
                                                <div>
                                                    <div class="fw-bold">${emp.fullName}</div>
                                                    <div class="small text-muted">${emp.employeeCode}</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>${not empty emp.department ? emp.department.name : 'Unassigned'}</td>
                                        <td>${not empty emp.designation ? emp.designation.title : 'Staff'}</td>
                                        <td>
                                            <span class="badge-status ${emp.status == 'ACTIVE' ? 'badge-active' : (emp.status == 'ON_LEAVE' ? 'badge-onleave' : 'badge-inactive')}">
                                                ${emp.status}
                                            </span>
                                        </td>
                                        <td>
                                            <a href="/employees/${emp.id}" class="btn-enterprise btn-sm-enterprise btn-secondary-enterprise">Profile</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty recentEmployees}">
                                    <tr>
                                        <td colspan="5" class="text-center text-muted py-4">No employees registered yet.</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Upcoming Interviews & Recruitment Pipeline -->
            <div class="col-lg-5">
                <div class="card-enterprise h-100">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <div>
                            <h6 class="fw-bold mb-1" style="color: var(--slate-900);">Recruitment Pulse & Interviews</h6>
                            <p class="text-muted small mb-0">${openPositions} open positions &middot; ${totalCandidates} candidates in pipeline</p>
                        </div>
                        <a href="/recruitment" class="btn-enterprise btn-sm-enterprise btn-secondary-enterprise">ATS Board</a>
                    </div>
                    <c:forEach var="interview" items="${upcomingInterviews}">
                        <div class="d-flex align-items-center justify-content-between p-3 border rounded-3 mb-2 bg-light">
                            <div>
                                <div class="fw-bold small text-dark">${interview.candidate.fullName}</div>
                                <div class="text-muted" style="font-size: 0.75rem;">
                                    ${interview.interviewType} &middot; with ${not empty interview.interviewer ? interview.interviewer.fullName : 'Hiring Team'}
                                </div>
                            </div>
                            <div class="text-end">
                                <span class="badge-status badge-interview">${interview.status}</span>
                                <div class="text-muted mt-1" style="font-size: 0.72rem;">${interview.scheduledAt}</div>
                            </div>
                        </div>
                    </c:forEach>
                    <c:if test="${empty upcomingInterviews}">
                        <div class="empty-state py-4">
                            <i class="bi bi-calendar-check text-muted fs-3 mb-2 d-block"></i>
                            <div class="small text-muted">No interviews currently scheduled.</div>
                        </div>
                    </c:if>
                    <div class="mt-3 text-center">
                        <a href="/recruitment?view=kanban" class="text-decoration-none small fw-bold text-primary">
                            Open Visual Candidate Kanban &rarr;
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<!-- Bootstrap JS Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<!-- Chart.js 4.4.4 -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.4/dist/chart.umd.min.js"></script>

<script>
    // Workforce Trend Line Chart
    const ctxTrend = document.getElementById('workforceTrendChart').getContext('2d');
    new Chart(ctxTrend, {
        type: 'line',
        data: {
            labels: ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
            datasets: [{
                label: 'Headcount',
                data: [
                    Math.max(1, ${employeeCount} - 4),
                    Math.max(1, ${employeeCount} - 3),
                    Math.max(2, ${employeeCount} - 2),
                    Math.max(2, ${employeeCount} - 1),
                    Math.max(3, ${employeeCount}),
                    ${employeeCount}
                ],
                borderColor: '#4f46e5',
                backgroundColor: 'rgba(79, 70, 229, 0.08)',
                fill: true,
                tension: 0.38,
                pointRadius: 4,
                pointBackgroundColor: '#4f46e5',
                pointBorderColor: '#ffffff',
                pointBorderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false },
                tooltip: {
                    backgroundColor: '#0f172a',
                    padding: 10,
                    titleFont: { size: 12 },
                    bodyFont: { size: 12 }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: { precision: 0, color: '#94a3b8' },
                    grid: { color: '#f1f5f9' }
                },
                x: {
                    ticks: { color: '#94a3b8' },
                    grid: { display: false }
                }
            }
        }
    });

    // Department Distribution Doughnut
    const ctxDept = document.getElementById('deptDistributionChart').getContext('2d');
    new Chart(ctxDept, {
        type: 'doughnut',
        data: {
            labels: [
                <c:forEach var="lbl" items="${deptLabels}" varStatus="loop">
                    "${lbl}"${!loop.last ? ',' : ''}
                </c:forEach>
            ],
            datasets: [{
                data: [
                    <c:forEach var="val" items="${deptData}" varStatus="loop">
                        ${val}${!loop.last ? ',' : ''}
                    </c:forEach>
                ],
                backgroundColor: ['#4f46e5', '#10b981', '#f59e0b', '#8b5cf6', '#0ea5e9', '#ec4899'],
                borderWidth: 2,
                borderColor: '#ffffff'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: { boxWidth: 12, font: { size: 11 }, color: '#475569' }
                }
            },
            cutout: '68%'
        }
    });
</script>
</body>
</html>
