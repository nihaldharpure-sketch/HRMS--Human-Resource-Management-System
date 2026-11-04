<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register New Employee | HRMS Operations</title>
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
                <a href="/employees" class="text-decoration-none small text-muted mb-2 d-inline-block">
                    <i class="bi bi-arrow-left"></i> Back to Employee Directory
                </a>
                <h1 class="page-title">Register New Employee</h1>
                <p class="page-subtitle">Create a complete personnel record with organizational assignment, initial salary, and portal access.</p>
            </div>
        </div>

        <c:if test="${not empty errorMessage}">
            <div class="alert-enterprise alert-danger-enterprise">
                <i class="bi bi-exclamation-triangle-fill fs-5"></i>
                <span>${errorMessage}</span>
            </div>
        </c:if>

        <form:form method="post" action="/employees/add" modelAttribute="employeeRequest" class="card-enterprise">
            <!-- Section 1: Basic Information -->
            <div class="mb-4">
                <h5 class="fw-bold mb-3 text-dark border-bottom pb-2">
                    <i class="bi bi-person-lines-fill text-primary me-2"></i>Personal & Contact Details
                </h5>
                <div class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label-enterprise">First Name *</label>
                        <form:input path="firstName" class="form-control-enterprise" required="true" placeholder="e.g. Liam" />
                        <form:errors path="firstName" cssClass="text-danger small" />
                    </div>
                    <div class="col-md-3">
                        <label class="form-label-enterprise">Last Name *</label>
                        <form:input path="lastName" class="form-control-enterprise" required="true" placeholder="e.g. Vance" />
                        <form:errors path="lastName" cssClass="text-danger small" />
                    </div>
                    <div class="col-md-3">
                        <label class="form-label-enterprise">Corporate Email *</label>
                        <form:input path="email" type="email" class="form-control-enterprise" required="true" placeholder="liam.vance@company.com" />
                        <form:errors path="email" cssClass="text-danger small" />
                    </div>
                    <div class="col-md-3">
                        <label class="form-label-enterprise">Mobile Phone</label>
                        <form:input path="phone" class="form-control-enterprise" placeholder="+1 (555) 000-0000" />
                    </div>

                    <div class="col-md-3">
                        <label class="form-label-enterprise">Date of Birth</label>
                        <form:input path="dateOfBirth" type="date" class="form-control-enterprise" />
                    </div>
                    <div class="col-md-3">
                        <label class="form-label-enterprise">Gender</label>
                        <form:select path="gender" class="form-select-enterprise">
                            <option value="">Select Gender</option>
                            <option value="Male">Male</option>
                            <option value="Female">Female</option>
                            <option value="Non-binary">Non-binary</option>
                            <option value="Prefer not to say">Prefer not to say</option>
                        </form:select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label-enterprise">Marital Status</label>
                        <form:select path="maritalStatus" class="form-select-enterprise">
                            <option value="Single">Single</option>
                            <option value="Married">Married</option>
                        </form:select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label-enterprise">Employee Code (Leave empty for auto)</label>
                        <form:input path="employeeCode" class="form-control-enterprise" placeholder="Auto-generated if blank" />
                    </div>
                </div>
            </div>

            <!-- Section 2: Organizational Placement -->
            <div class="mb-4">
                <h5 class="fw-bold mb-3 text-dark border-bottom pb-2">
                    <i class="bi bi-briefcase-fill text-primary me-2"></i>Employment & Department Assignment
                </h5>
                <div class="row g-3">
                    <div class="col-md-4">
                        <label class="form-label-enterprise">Department *</label>
                        <form:select path="departmentId" class="form-select-enterprise" required="true">
                            <form:option value="" label="-- Choose Department --" />
                            <form:options items="${departments}" itemValue="id" itemLabel="name" />
                        </form:select>
                        <form:errors path="departmentId" cssClass="text-danger small" />
                    </div>
                    <div class="col-md-4">
                        <label class="form-label-enterprise">Designation *</label>
                        <form:select path="designationId" class="form-select-enterprise" required="true">
                            <form:option value="" label="-- Choose Designation --" />
                            <form:options items="${designations}" itemValue="id" itemLabel="title" />
                        </form:select>
                        <form:errors path="designationId" cssClass="text-danger small" />
                    </div>
                    <div class="col-md-4">
                        <label class="form-label-enterprise">Reporting Manager</label>
                        <form:select path="managerId" class="form-select-enterprise">
                            <form:option value="" label="-- None / Top Executive --" />
                            <c:forEach var="mgr" items="${managers}">
                                <form:option value="${mgr.id}">${mgr.fullName} (${mgr.employeeCode})</form:option>
                            </c:forEach>
                        </form:select>
                    </div>

                    <div class="col-md-3">
                        <label class="form-label-enterprise">Joining Date</label>
                        <form:input path="dateOfJoining" type="date" class="form-control-enterprise" />
                    </div>
                    <div class="col-md-3">
                        <label class="form-label-enterprise">Employment Type</label>
                        <form:select path="employmentType" class="form-select-enterprise">
                            <form:option value="FULL_TIME">Full-time Regular</form:option>
                            <form:option value="PART_TIME">Part-time</form:option>
                            <form:option value="CONTRACT">Contractor</form:option>
                            <form:option value="INTERN">Intern</form:option>
                        </form:select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label-enterprise">Probation Period (Months)</label>
                        <form:input path="probationPeriodMonths" type="number" class="form-control-enterprise" min="0" max="12" />
                    </div>
                    <div class="col-md-3">
                        <label class="form-label-enterprise">Initial Status</label>
                        <form:select path="status" class="form-select-enterprise">
                            <form:option value="ACTIVE">Active</form:option>
                            <form:option value="ON_LEAVE">On Leave</form:option>
                            <form:option value="INACTIVE">Inactive</form:option>
                        </form:select>
                    </div>
                </div>
            </div>

            <!-- Section 3: Compensation & Bank Details -->
            <div class="mb-4">
                <h5 class="fw-bold mb-3 text-dark border-bottom pb-2">
                    <i class="bi bi-wallet2 text-primary me-2"></i>Compensation & Bank Information
                </h5>
                <div class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label-enterprise">Base Monthly Salary (₹ / $)</label>
                        <form:input path="basicSalary" type="number" step="1000" class="form-control-enterprise" placeholder="50000" />
                        <small class="text-muted" style="font-size: 0.72rem;">HRA, Conveyance, and PF will auto-calculate.</small>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label-enterprise">Bank Name</label>
                        <form:input path="bankName" class="form-control-enterprise" placeholder="e.g. HDFC / Chase" />
                    </div>
                    <div class="col-md-3">
                        <label class="form-label-enterprise">Bank Account Number</label>
                        <form:input path="bankAccountNumber" class="form-control-enterprise" placeholder="Account digits" />
                    </div>
                    <div class="col-md-3">
                        <label class="form-label-enterprise">IFSC / Routing Code</label>
                        <form:input path="bankIfsc" class="form-control-enterprise" placeholder="Branch code" />
                    </div>
                </div>
            </div>

            <!-- Section 4: Address & Emergency Details -->
            <div class="mb-4">
                <h5 class="fw-bold mb-3 text-dark border-bottom pb-2">
                    <i class="bi bi-geo-alt-fill text-primary me-2"></i>Address & Emergency Contacts
                </h5>
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label-enterprise">Street Address</label>
                        <form:input path="addressStreet" class="form-control-enterprise" placeholder="123 Corporate Way, Apt 4B" />
                    </div>
                    <div class="col-md-3">
                        <label class="form-label-enterprise">City</label>
                        <form:input path="addressCity" class="form-control-enterprise" placeholder="City" />
                    </div>
                    <div class="col-md-3">
                        <label class="form-label-enterprise">State / Zip</label>
                        <div class="d-flex gap-2">
                            <form:input path="addressState" class="form-control-enterprise" placeholder="State" />
                            <form:input path="addressZip" class="form-control-enterprise" placeholder="Zip" />
                        </div>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label-enterprise">Emergency Contact Name</label>
                        <form:input path="emergencyContactName" class="form-control-enterprise" placeholder="Contact person" />
                    </div>
                    <div class="col-md-4">
                        <label class="form-label-enterprise">Emergency Contact Phone</label>
                        <form:input path="emergencyContactPhone" class="form-control-enterprise" placeholder="+1 (555) 999-9999" />
                    </div>
                    <div class="col-md-4">
                        <label class="form-label-enterprise">Relationship</label>
                        <form:input path="emergencyContactRelation" class="form-control-enterprise" placeholder="Spouse / Parent / Sibling" />
                    </div>
                </div>
            </div>

            <!-- Form Actions -->
            <div class="d-flex align-items-center justify-content-end gap-3 pt-3 border-top">
                <a href="/employees" class="btn-enterprise btn-secondary-enterprise">Cancel</a>
                <button type="submit" class="btn-enterprise btn-primary-enterprise">
                    <i class="bi bi-check2-circle"></i>
                    <span>Register Employee & Provision Access</span>
                </button>
            </div>
        </form:form>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
