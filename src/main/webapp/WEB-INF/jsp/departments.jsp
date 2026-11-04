<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Organization & Departments | HRMS Operations</title>
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
                <h1 class="page-title">Department & Organization Structure</h1>
                <p class="page-subtitle">Configure business units, reporting hierarchy, designations, and track workforce allocation across teams.</p>
            </div>
            <div class="header-actions">
                <button type="button" class="btn-enterprise btn-secondary-enterprise" data-bs-toggle="modal" data-bs-target="#newDesigModal">
                    <i class="bi bi-person-workspace"></i>
                    <span>Add Designation</span>
                </button>
                <button type="button" class="btn-enterprise btn-primary-enterprise" data-bs-toggle="modal" data-bs-target="#newDeptModal">
                    <i class="bi bi-plus-lg"></i>
                    <span>Create Department</span>
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

        <!-- Department Cards Grid -->
        <h5 class="fw-bold mb-3 text-dark">Active Organizational Departments (${deptCount})</h5>
        <div class="row g-4 mb-5">
            <c:forEach var="dept" items="${departments}">
                <div class="col-md-6 col-lg-4">
                    <div class="card-enterprise h-100 d-flex flex-column justify-content-between">
                        <div>
                            <div class="d-flex align-items-center justify-content-between mb-3">
                                <div class="stat-icon indigo" style="width: 44px; height: 44px; font-size: 1.3rem;">
                                    <i class="bi bi-building"></i>
                                </div>
                                <span class="badge bg-light text-primary border px-2 py-1 fw-bold">
                                    ${dept.employees.size()} Members
                                </span>
                            </div>
                            <h5 class="fw-bold text-dark mb-2">${dept.name}</h5>
                            <p class="text-muted small mb-3">${not empty dept.description ? dept.description : 'Corporate operational unit'}</p>
                        </div>

                        <div class="border-top pt-3 mt-2 d-flex align-items-center justify-content-between">
                            <a href="/employees?departmentId=${dept.id}" class="text-decoration-none small fw-bold text-primary">
                                View Team Members &rarr;
                            </a>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>

        <!-- Designations Table -->
        <div class="d-flex align-items-center justify-content-between mb-3">
            <h5 class="fw-bold mb-0 text-dark">Job Titles & Designations (${desigCount})</h5>
            <button type="button" class="btn-enterprise btn-sm-enterprise btn-secondary-enterprise" data-bs-toggle="modal" data-bs-target="#newDesigModal">
                <i class="bi bi-plus-lg"></i> New Job Title
            </button>
        </div>

        <div class="card-enterprise p-0 overflow-hidden">
            <div class="table-responsive-enterprise">
                <table class="table-enterprise">
                    <thead>
                        <tr>
                            <th>Job Title / Designation</th>
                            <th>Description</th>
                            <th>Current Headcount</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="des" items="${designations}">
                            <tr>
                                <td class="fw-bold text-dark">${des.title}</td>
                                <td class="text-muted small">${not empty des.description ? des.description : 'Standard role position'}</td>
                                <td>
                                    <span class="badge bg-light text-dark border">${des.employees.size()} Employees</span>
                                </td>
                                <td class="text-end">
                                    <span class="badge-status badge-active">Active</span>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<!-- Modal: New Department -->
<div class="modal fade" id="newDeptModal" tabindex="-1">
    <div class="modal-dialog">
        <form method="post" action="/departments/add" class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold">Create New Department</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label-enterprise">Department Name *</label>
                    <input type="text" name="name" class="form-control-enterprise" required placeholder="e.g. Quality Assurance / Legal">
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Scope & Objectives Description</label>
                    <textarea name="description" class="form-control-enterprise" rows="3" placeholder="Overview of department charter and operations..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-enterprise btn-secondary-enterprise" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" class="btn-enterprise btn-primary-enterprise">Create Department</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal: New Designation -->
<div class="modal fade" id="newDesigModal" tabindex="-1">
    <div class="modal-dialog">
        <form method="post" action="/departments/designations/add" class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold">Add Job Designation</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label-enterprise">Job Title *</label>
                    <input type="text" name="title" class="form-control-enterprise" required placeholder="e.g. Senior DevOps Specialist">
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Role Expectations Description</label>
                    <textarea name="description" class="form-control-enterprise" rows="3" placeholder="Key responsibilities and scope..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-enterprise btn-secondary-enterprise" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" class="btn-enterprise btn-primary-enterprise">Save Designation</button>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
