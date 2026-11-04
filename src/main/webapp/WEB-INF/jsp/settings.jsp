<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Organization Settings | HRMS Operations</title>
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
                <h1 class="page-title">Organization Settings & Policies</h1>
                <p class="page-subtitle">Configure enterprise working shifts, holiday calendars, automated leave accruals, and role permissions.</p>
            </div>
            <div class="header-actions">
                <button type="button" class="btn-enterprise btn-primary-enterprise" onclick="alert('Settings preferences updated successfully.')">
                    <i class="bi bi-save"></i>
                    <span>Save Preferences</span>
                </button>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-lg-6">
                <div class="card-enterprise h-100">
                    <h5 class="fw-bold mb-3 text-dark border-bottom pb-2">
                        <i class="bi bi-clock text-primary me-2"></i>Shift & Working Hour Policies
                    </h5>
                    <div class="mb-3">
                        <label class="form-label-enterprise">Standard Shift Start Time</label>
                        <input type="time" class="form-control-enterprise" value="09:30">
                        <small class="text-muted" style="font-size: 0.72rem;">Check-ins after this time are automatically marked as Late.</small>
                    </div>
                    <div class="mb-3">
                        <label class="form-label-enterprise">Standard Shift End Time</label>
                        <input type="time" class="form-control-enterprise" value="18:00">
                    </div>
                    <div class="mb-3">
                        <label class="form-label-enterprise">Standard Daily Working Hours</label>
                        <input type="number" class="form-control-enterprise" value="8.0" step="0.5">
                        <small class="text-muted" style="font-size: 0.72rem;">Hours beyond this threshold accrue as Overtime.</small>
                    </div>
                    <div class="mb-3">
                        <label class="form-label-enterprise">Weekly Off Days</label>
                        <div class="d-flex gap-3">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" checked id="satOff">
                                <label class="form-check-label small" for="satOff">Saturday</label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" checked id="sunOff">
                                <label class="form-check-label small" for="sunOff">Sunday</label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-lg-6">
                <div class="card-enterprise h-100">
                    <h5 class="fw-bold mb-3 text-dark border-bottom pb-2">
                        <i class="bi bi-calendar2-heart text-primary me-2"></i>Annual Leave Quota Allotments
                    </h5>
                    <div class="mb-3">
                        <label class="form-label-enterprise">Annual Paid Time Off (Days/Year)</label>
                        <input type="number" class="form-control-enterprise" value="18">
                    </div>
                    <div class="mb-3">
                        <label class="form-label-enterprise">Casual Leave Quota (Days/Year)</label>
                        <input type="number" class="form-control-enterprise" value="12">
                    </div>
                    <div class="mb-3">
                        <label class="form-label-enterprise">Medical / Sick Leave Quota (Days/Year)</label>
                        <input type="number" class="form-control-enterprise" value="10">
                    </div>
                    <div class="mb-3">
                        <label class="form-label-enterprise">Carry Forward Limit</label>
                        <input type="number" class="form-control-enterprise" value="5">
                        <small class="text-muted" style="font-size: 0.72rem;">Maximum unused annual days rolled into the following year.</small>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
