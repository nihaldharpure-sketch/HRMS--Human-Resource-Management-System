<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports & HR Analytics | HRMS Operations</title>
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
                <h1 class="page-title">Reports & Human Capital Analytics</h1>
                <p class="page-subtitle">Export auditable workforce rosters, payroll registers, attendance logs, and download compliance spreadsheets.</p>
            </div>
        </div>

        <!-- Four Standard Export Cards -->
        <div class="row g-4 mb-4">
            <!-- Employee Directory Export -->
            <div class="col-md-6 col-lg-3">
                <div class="card-enterprise h-100 d-flex flex-column justify-content-between">
                    <div>
                        <div class="stat-icon indigo mb-3"><i class="bi bi-people-fill"></i></div>
                        <h6 class="fw-bold text-dark">Employee Master File</h6>
                        <p class="text-muted small">Complete roster containing IDs, contact info, departments, designations, and employment statuses.</p>
                    </div>
                    <a href="/reports/export/employees" class="btn-enterprise btn-secondary-enterprise w-100">
                        <i class="bi bi-download"></i> Download CSV
                    </a>
                </div>
            </div>

            <!-- Attendance Logs Export -->
            <div class="col-md-6 col-lg-3">
                <div class="card-enterprise h-100 d-flex flex-column justify-content-between">
                    <div>
                        <div class="stat-icon emerald mb-3"><i class="bi bi-clock-history"></i></div>
                        <h6 class="fw-bold text-dark">Attendance Register</h6>
                        <p class="text-muted small">Comprehensive daily check-ins, check-outs, total working hours, overtime hours, and late arrival minutes.</p>
                    </div>
                    <a href="/reports/export/attendance" class="btn-enterprise btn-secondary-enterprise w-100">
                        <i class="bi bi-download"></i> Download CSV
                    </a>
                </div>
            </div>

            <!-- Payroll Summary Export -->
            <div class="col-md-6 col-lg-3">
                <div class="card-enterprise h-100 d-flex flex-column justify-content-between">
                    <div>
                        <div class="stat-icon purple mb-3"><i class="bi bi-wallet2"></i></div>
                        <h6 class="fw-bold text-dark">Payroll Disbursal Register</h6>
                        <p class="text-muted small">Monthly gross salaries, allowances, statutory PF and tax deductions, overtime earnings, and net pay.</p>
                    </div>
                    <a href="/reports/export/payroll" class="btn-enterprise btn-secondary-enterprise w-100">
                        <i class="bi bi-download"></i> Download CSV
                    </a>
                </div>
            </div>

            <!-- Leave Usage Export -->
            <div class="col-md-6 col-lg-3">
                <div class="card-enterprise h-100 d-flex flex-column justify-content-between">
                    <div>
                        <div class="stat-icon amber mb-3"><i class="bi bi-calendar2-heart-fill"></i></div>
                        <h6 class="fw-bold text-dark">Leave & Absence Records</h6>
                        <p class="text-muted small">Historical applications, approved absences, quota utilization, and manager review audit trails.</p>
                    </div>
                    <a href="/reports/export/leaves" class="btn-enterprise btn-secondary-enterprise w-100">
                        <i class="bi bi-download"></i> Download CSV
                    </a>
                </div>
            </div>
        </div>

        <!-- Visual Analytics Chart Section -->
        <div class="card-enterprise mb-4">
            <h6 class="fw-bold mb-3 text-dark">Department Headcount Distribution</h6>
            <div style="height: 280px; position: relative;">
                <canvas id="reportsDeptChart"></canvas>
            </div>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.4/dist/chart.umd.min.js"></script>
<script>
    const ctx = document.getElementById('reportsDeptChart').getContext('2d');
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: [
                <c:forEach var="lbl" items="${deptLabels}" varStatus="loop">
                    "${lbl}"${!loop.last ? ',' : ''}
                </c:forEach>
            ],
            datasets: [{
                label: 'Assigned Employees',
                data: [
                    <c:forEach var="val" items="${deptData}" varStatus="loop">
                        ${val}${!loop.last ? ',' : ''}
                    </c:forEach>
                ],
                backgroundColor: '#4f46e5',
                borderRadius: 6
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                y: { beginAtZero: true, ticks: { precision: 0 } }
            }
        }
    });
</script>
</body>
</html>
