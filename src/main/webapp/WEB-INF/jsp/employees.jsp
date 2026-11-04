<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee Directory | HRMS Operations</title>
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
                <h1 class="page-title">Employee Directory</h1>
                <p class="page-subtitle">Manage organizational personnel records, roles, departmental structures, and profiles.</p>
            </div>
            <div class="header-actions">
                <a href="/reports/export/employees" class="btn-enterprise btn-secondary-enterprise">
                    <i class="bi bi-file-earmark-arrow-down"></i>
                    <span>Export CSV</span>
                </a>
                <a href="/employees/add" class="btn-enterprise btn-primary-enterprise">
                    <i class="bi bi-person-plus-fill"></i>
                    <span>Add New Employee</span>
                </a>
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

        <!-- Stats Overview -->
        <div class="stats-grid-4">
            <div class="stat-box">
                <div class="stat-box-top">
                    <span class="stat-label">Total Registered</span>
                    <div class="stat-icon indigo"><i class="bi bi-people-fill"></i></div>
                </div>
                <div class="stat-value">${totalCount}</div>
                <div class="stat-footer text-muted">All time workforce records</div>
            </div>
            <div class="stat-box">
                <div class="stat-box-top">
                    <span class="stat-label">Active Staff</span>
                    <div class="stat-icon emerald"><i class="bi bi-check-circle-fill"></i></div>
                </div>
                <div class="stat-value text-success">${activeCount}</div>
                <div class="stat-footer text-success">Fully operational</div>
            </div>
            <div class="stat-box">
                <div class="stat-box-top">
                    <span class="stat-label">On Leave</span>
                    <div class="stat-icon purple"><i class="bi bi-calendar2-heart-fill"></i></div>
                </div>
                <div class="stat-value text-purple">${onLeaveCount}</div>
                <div class="stat-footer text-muted">Approved planned absence</div>
            </div>
            <div class="stat-box">
                <div class="stat-box-top">
                    <span class="stat-label">Inactive / Separated</span>
                    <div class="stat-icon crimson"><i class="bi bi-person-x-fill"></i></div>
                </div>
                <div class="stat-value text-danger">${inactiveCount}</div>
                <div class="stat-footer text-muted">Former employees</div>
            </div>
        </div>

        <!-- Filter & Search Toolbar -->
        <div class="card-enterprise mb-4 p-3">
            <form method="get" action="/employees" class="row g-3 align-items-center">
                <div class="col-md-5">
                    <div class="position-relative">
                        <i class="bi bi-search position-absolute top-50 start-0 translate-middle-y ms-3 text-muted"></i>
                        <input type="text" name="search" class="form-control-enterprise ps-5" placeholder="Search by name, email, employee ID..." value="${searchQuery}">
                    </div>
                </div>
                <div class="col-md-3">
                    <select name="departmentId" class="form-select-enterprise">
                        <option value="">All Departments</option>
                        <c:forEach var="dept" items="${departments}">
                            <option value="${dept.id}" ${selectedDept == dept.id ? 'selected' : ''}>${dept.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-2">
                    <select name="status" class="form-select-enterprise">
                        <option value="">All Statuses</option>
                        <option value="ACTIVE" ${selectedStatus == 'ACTIVE' ? 'selected' : ''}>Active</option>
                        <option value="ON_LEAVE" ${selectedStatus == 'ON_LEAVE' ? 'selected' : ''}>On Leave</option>
                        <option value="INACTIVE" ${selectedStatus == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                    </select>
                </div>
                <div class="col-md-2 d-flex gap-2">
                    <button type="submit" class="btn-enterprise btn-primary-enterprise w-100">Filter</button>
                    <a href="/employees" class="btn-enterprise btn-secondary-enterprise" title="Reset Filters"><i class="bi bi-arrow-counterclockwise"></i></a>
                </div>
            </form>
        </div>

        <!-- Employee Directory Table -->
        <div class="card-enterprise p-0 overflow-hidden">
            <div class="table-responsive-enterprise">
                <table class="table-enterprise">
                    <thead>
                        <tr>
                            <th>Employee ID</th>
                            <th>Full Name & Contact</th>
                            <th>Department</th>
                            <th>Designation</th>
                            <th>Employment Type</th>
                            <th>Joining Date</th>
                            <th>Status</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="emp" items="${employees}">
                            <tr>
                                <td>
                                    <span class="badge bg-light text-dark border font-monospace px-2 py-1">${emp.employeeCode}</span>
                                </td>
                                <td>
                                    <div class="d-flex align-items-center gap-3">
                                        <div class="user-avatar" style="width: 36px; height: 36px;">
                                            ${emp.firstName.substring(0, 1)}
                                        </div>
                                        <div>
                                            <a href="/employees/${emp.id}" class="text-decoration-none fw-bold text-dark d-block">
                                                ${emp.fullName}
                                            </a>
                                            <small class="text-muted">${emp.email} &middot; ${emp.phone}</small>
                                        </div>
                                    </div>
                                </td>
                                <td>${not empty emp.department ? emp.department.name : '<span class="text-muted">Unassigned</span>'}</td>
                                <td>${not empty emp.designation ? emp.designation.title : '<span class="text-muted">Staff</span>'}</td>
                                <td>
                                    <span class="badge bg-light text-secondary border px-2 py-1">${emp.employmentType}</span>
                                </td>
                                <td>${emp.dateOfJoining}</td>
                                <td>
                                    <span class="badge-status ${emp.status == 'ACTIVE' ? 'badge-active' : (emp.status == 'ON_LEAVE' ? 'badge-onleave' : 'badge-inactive')}">
                                        ${emp.status}
                                    </span>
                                </td>
                                <td class="text-end">
                                    <a href="/employees/${emp.id}" class="btn-enterprise btn-sm-enterprise btn-secondary-enterprise me-1">
                                        <i class="bi bi-eye"></i> View Profile
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty employees}">
                            <tr>
                                <td colspan="8">
                                    <div class="empty-state">
                                        <div class="empty-icon"><i class="bi bi-people"></i></div>
                                        <div class="empty-title">No employees found</div>
                                        <div class="empty-desc">Try clearing the search filters or add a new employee to your organization.</div>
                                        <a href="/employees/add" class="btn-enterprise btn-primary-enterprise">
                                            <i class="bi bi-plus-lg"></i> Add First Employee
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
