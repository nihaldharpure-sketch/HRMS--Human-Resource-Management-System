<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${moduleTitle} | HRMS Operations</title>
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
                <h1 class="page-title">${moduleTitle}</h1>
                <p class="page-subtitle">${moduleDescription}</p>
            </div>
            <div class="header-actions">
                <a href="/dashboard" class="btn-enterprise btn-secondary-enterprise">Back to Dashboard</a>
            </div>
        </div>

        <div class="card-enterprise">
            <div class="empty-state">
                <div class="empty-icon"><i class="bi bi-grid-fill"></i></div>
                <div class="empty-title">${moduleTitle} Workspace</div>
                <div class="empty-desc">Module loaded successfully. Access specific actions using the navigation sidebar.</div>
                <a href="/dashboard" class="btn-enterprise btn-primary-enterprise">Return to Dashboard</a>
            </div>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>