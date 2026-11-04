<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recruitment & Applicant Tracking System (ATS) | HRMS Operations</title>
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
                <h1 class="page-title">Recruitment & Applicant Tracking System</h1>
                <p class="page-subtitle">Visual candidate pipeline, job postings, interview scheduling, interviewer feedback, and 1-click hiring onboarding.</p>
            </div>
            <div class="header-actions">
                <button type="button" class="btn-enterprise btn-secondary-enterprise" data-bs-toggle="modal" data-bs-target="#newCandidateModal">
                    <i class="bi bi-person-plus"></i>
                    <span>Register Candidate</span>
                </button>
                <button type="button" class="btn-enterprise btn-secondary-enterprise" data-bs-toggle="modal" data-bs-target="#scheduleInterviewModal">
                    <i class="bi bi-calendar-event"></i>
                    <span>Schedule Interview</span>
                </button>
                <button type="button" class="btn-enterprise btn-primary-enterprise" data-bs-toggle="modal" data-bs-target="#newJobModal">
                    <i class="bi bi-plus-lg"></i>
                    <span>Post Job Opening</span>
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

        <!-- Recruitment KPI Metrics -->
        <div class="stats-grid-4 mb-4">
            <div class="stat-box">
                <div class="stat-box-top">
                    <span class="stat-label">Open Requisitions</span>
                    <div class="stat-icon indigo"><i class="bi bi-briefcase-fill"></i></div>
                </div>
                <div class="stat-value text-primary">${openJobsCount}</div>
                <div class="stat-footer text-muted">Active job listings</div>
            </div>
            <div class="stat-box">
                <div class="stat-box-top">
                    <span class="stat-label">Total Applicants</span>
                    <div class="stat-icon emerald"><i class="bi bi-person-lines-fill"></i></div>
                </div>
                <div class="stat-value text-success">${candidatesCount}</div>
                <div class="stat-footer text-muted">Across all recruitment funnels</div>
            </div>
            <div class="stat-box">
                <div class="stat-box-top">
                    <span class="stat-label">In Interview Stage</span>
                    <div class="stat-icon amber"><i class="bi bi-camera-video-fill"></i></div>
                </div>
                <div class="stat-value text-warning">${kanban['INTERVIEW'].size()}</div>
                <div class="stat-footer text-muted">Technical & HR rounds</div>
            </div>
            <div class="stat-box">
                <div class="stat-box-top">
                    <span class="stat-label">Offers / Hired</span>
                    <div class="stat-icon purple"><i class="bi bi-award-fill"></i></div>
                </div>
                <div class="stat-value text-purple">${kanban['OFFER'].size() + kanban['HIRED'].size()}</div>
                <div class="stat-footer text-muted">Ready for onboarding</div>
            </div>
        </div>

        <!-- Navigation Tabs -->
        <ul class="nav nav-pills tabs-enterprise" id="recruitmentTabs" role="tablist">
            <li class="nav-item">
                <a class="nav-link tab-btn ${activeView == 'kanban' ? 'active' : ''}" href="/recruitment?view=kanban">
                    <i class="bi bi-kanban me-1"></i> Visual Candidate Pipeline (Kanban)
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link tab-btn ${activeView == 'jobs' ? 'active' : ''}" href="/recruitment?view=jobs">
                    <i class="bi bi-card-list me-1"></i> Job Postings (${jobs.size()})
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link tab-btn ${activeView == 'interviews' ? 'active' : ''}" href="/recruitment?view=interviews">
                    <i class="bi bi-calendar2-range me-1"></i> Scheduled Interviews (${interviews.size()})
                </a>
            </li>
        </ul>

        <div class="tab-content">
            <!-- VIEW 1: KANBAN BOARD -->
            <c:if test="${activeView == 'kanban'}">
                <div class="kanban-board">
                    <c:forEach var="st" items="${stages}">
                        <div class="kanban-col">
                            <div class="kanban-col-header">
                                <span class="kanban-col-title">${st}</span>
                                <span class="kanban-count-pill">${kanban[st].size()}</span>
                            </div>

                            <c:forEach var="cand" items="${kanban[st]}">
                                <div class="kanban-card">
                                    <div class="fw-bold text-dark">${cand.fullName}</div>
                                    <small class="text-primary d-block mb-1">${cand.jobPosting.title}</small>
                                    <div class="text-muted small mb-2">
                                        <i class="bi bi-briefcase me-1"></i>${cand.experienceYears} yrs exp &middot; ${cand.currentCompany}
                                    </div>
                                    <div class="text-muted small mb-2">
                                        <i class="bi bi-envelope me-1"></i>${cand.email}
                                    </div>

                                    <!-- Kanban Stage Transition Selector -->
                                    <form method="post" action="/recruitment/candidates/stage" class="mb-2">
                                        <input type="hidden" name="candidateId" value="${cand.id}">
                                        <div class="input-group input-group-sm">
                                            <select name="stage" class="form-select form-select-sm" onchange="this.form.submit()">
                                                <c:forEach var="sOpt" items="${stages}">
                                                    <option value="${sOpt}" ${cand.stage == sOpt ? 'selected' : ''}>${sOpt}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                    </form>

                                    <!-- Quick Action: Convert to Employee if Offer or Selected -->
                                    <c:if test="${cand.stage == 'OFFER' || cand.stage == 'SELECTED'}">
                                        <button type="button" class="btn btn-sm btn-success w-100" data-bs-toggle="modal" data-bs-target="#hireModal${cand.id}">
                                            <i class="bi bi-person-check"></i> Convert to Employee
                                        </button>

                                        <!-- Hire Modal -->
                                        <div class="modal fade" id="hireModal${cand.id}" tabindex="-1">
                                            <div class="modal-dialog">
                                                <form method="post" action="/recruitment/candidates/hire" class="modal-content">
                                                    <div class="modal-header">
                                                        <h5 class="modal-title fw-bold text-dark">Hire & Onboard Candidate</h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <p class="small text-muted">
                                                            This will create an active <strong>Employee</strong> record for <strong>${cand.fullName}</strong>, generate onboarding tasks, and link their profile.
                                                        </p>
                                                        <input type="hidden" name="candidateId" value="${cand.id}">
                                                        <div class="mb-3">
                                                            <label class="form-label-enterprise">Department</label>
                                                            <select name="departmentId" class="form-select-enterprise" required>
                                                                <c:forEach var="d" items="${departments}">
                                                                    <option value="${d.id}" ${cand.jobPosting.department.id == d.id ? 'selected' : ''}>${d.name}</option>
                                                                </c:forEach>
                                                            </select>
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label-enterprise">Designation</label>
                                                            <select name="designationId" class="form-select-enterprise" required>
                                                                <c:forEach var="des" items="${designations}">
                                                                    <option value="${des.id}" ${cand.jobPosting.designation.id == des.id ? 'selected' : ''}>${des.title}</option>
                                                                </c:forEach>
                                                            </select>
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label-enterprise">Reporting Manager</label>
                                                            <select name="managerId" class="form-select-enterprise">
                                                                <option value="">-- None / Top Executive --</option>
                                                                <c:forEach var="m" items="${employees}">
                                                                    <option value="${m.id}">${m.fullName} (${m.employeeCode})</option>
                                                                </c:forEach>
                                                            </select>
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label-enterprise">Joining Date</label>
                                                            <input type="date" name="joiningDate" class="form-control-enterprise" required>
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label-enterprise">Base Monthly Salary (₹)</label>
                                                            <input type="number" name="basicSalary" class="form-control-enterprise" value="60000" required>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn-enterprise btn-secondary-enterprise" data-bs-dismiss="modal">Cancel</button>
                                                        <button type="submit" class="btn-enterprise btn-success-enterprise">Confirm Hire & Create Employee</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </c:if>

                                    <c:if test="${cand.stage == 'HIRED' && not empty cand.hiredEmployee}">
                                        <a href="/employees/${cand.hiredEmployee.id}" class="btn btn-sm btn-outline-success w-100">
                                            <i class="bi bi-check-circle-fill"></i> View Employee Profile
                                        </a>
                                    </c:if>
                                </div>
                            </c:forEach>

                            <c:if test="${empty kanban[st]}">
                                <div class="text-center text-muted small py-4">No candidates</div>
                            </c:if>
                        </div>
                    </c:forEach>
                </div>
            </c:if>

            <!-- VIEW 2: JOB REQUISITIONS -->
            <c:if test="${activeView == 'jobs'}">
                <div class="card-enterprise p-0 overflow-hidden">
                    <div class="table-responsive-enterprise">
                        <table class="table-enterprise">
                            <thead>
                                <tr>
                                    <th>Job Title</th>
                                    <th>Department</th>
                                    <th>Location</th>
                                    <th>Openings</th>
                                    <th>Hiring Manager</th>
                                    <th>Application Deadline</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="j" items="${jobs}">
                                    <tr>
                                        <td>
                                            <div class="fw-bold text-dark">${j.title}</div>
                                            <small class="text-muted">${j.employmentType}</small>
                                        </td>
                                        <td>${not empty j.department ? j.department.name : 'Unassigned'}</td>
                                        <td>${j.location}</td>
                                        <td><span class="badge bg-light text-dark border">${j.vacancies} Position(s)</span></td>
                                        <td>${not empty j.hiringManager ? j.hiringManager.fullName : 'Hiring Team'}</td>
                                        <td>${not empty j.deadline ? j.deadline : 'Open'}</td>
                                        <td>
                                            <span class="badge-status ${j.status == 'OPEN' ? 'badge-active' : 'badge-inactive'}">
                                                ${j.status}
                                            </span>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty jobs}">
                                    <tr><td colspan="7" class="text-center text-muted py-5">No job requisitions created yet.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:if>

            <!-- VIEW 3: SCHEDULED INTERVIEWS -->
            <c:if test="${activeView == 'interviews'}">
                <div class="card-enterprise p-0 overflow-hidden">
                    <div class="table-responsive-enterprise">
                        <table class="table-enterprise">
                            <thead>
                                <tr>
                                    <th>Candidate</th>
                                    <th>Applied Position</th>
                                    <th>Interviewer</th>
                                    <th>Scheduled Date & Time</th>
                                    <th>Round / Type</th>
                                    <th>Status</th>
                                    <th>Result / Rating</th>
                                    <th class="text-end">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="in" items="${interviews}">
                                    <tr>
                                        <td class="fw-bold">${in.candidate.fullName}</td>
                                        <td>${in.candidate.jobPosting.title}</td>
                                        <td>${not empty in.interviewer ? in.interviewer.fullName : 'Hiring Team'}</td>
                                        <td>${in.scheduledAt}</td>
                                        <td><span class="badge bg-light text-dark border">${in.interviewType}</span></td>
                                        <td><span class="badge-status badge-interview">${in.status}</span></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty in.rating}">
                                                    <strong>${in.rating} / 5 &middot; ${in.result}</strong>
                                                </c:when>
                                                <c:otherwise><span class="text-muted">Awaiting evaluation</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-end">
                                            <button type="button" class="btn-enterprise btn-sm-enterprise btn-secondary-enterprise" data-bs-toggle="modal" data-bs-target="#feedbackModal${in.id}">
                                                <i class="bi bi-star"></i> Evaluate
                                            </button>

                                            <!-- Feedback Modal -->
                                            <div class="modal fade text-start" id="feedbackModal${in.id}" tabindex="-1">
                                                <div class="modal-dialog">
                                                    <form method="post" action="/recruitment/interviews/feedback" class="modal-content">
                                                        <div class="modal-header">
                                                            <h5 class="modal-title fw-bold">Interview Evaluation: ${in.candidate.fullName}</h5>
                                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                        </div>
                                                        <div class="modal-body">
                                                            <input type="hidden" name="interviewId" value="${in.id}">
                                                            <div class="mb-3">
                                                                <label class="form-label-enterprise">Candidate Rating (1 to 5 Stars)</label>
                                                                <select name="rating" class="form-select-enterprise" required>
                                                                    <option value="5">5 - Exceptional Candidate</option>
                                                                    <option value="4" selected>4 - Strong Hire</option>
                                                                    <option value="3">3 - Acceptable / Meets Bar</option>
                                                                    <option value="2">2 - Below Expectations</option>
                                                                    <option value="1">1 - Definite Reject</option>
                                                                </select>
                                                            </div>
                                                            <div class="mb-3">
                                                                <label class="form-label-enterprise">Recommendation Decision</label>
                                                                <select name="result" class="form-select-enterprise">
                                                                    <option value="PASSED">Passed (Advance Stage)</option>
                                                                    <option value="FAILED">Failed</option>
                                                                </select>
                                                            </div>
                                                            <div class="mb-3">
                                                                <label class="form-label-enterprise">Interviewer Notes & Feedback</label>
                                                                <textarea name="feedback" class="form-control-enterprise" rows="3" required placeholder="Assessment of technical competency, culture fit, and communication..."></textarea>
                                                            </div>
                                                        </div>
                                                        <div class="modal-footer">
                                                            <button type="button" class="btn-enterprise btn-secondary-enterprise" data-bs-dismiss="modal">Cancel</button>
                                                            <button type="submit" class="btn-enterprise btn-primary-enterprise">Submit Evaluation</button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty interviews}">
                                    <tr><td colspan="8" class="text-center text-muted py-5">No interviews scheduled yet.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
</main>

<!-- Modal: Post Job Requisition -->
<div class="modal fade" id="newJobModal" tabindex="-1">
    <div class="modal-dialog">
        <form method="post" action="/recruitment/jobs/create" class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold">Post New Job Requisition</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label-enterprise">Job Title *</label>
                    <input type="text" name="title" class="form-control-enterprise" required placeholder="e.g. Lead Platform Engineer">
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Department *</label>
                    <select name="departmentId" class="form-select-enterprise" required>
                        <c:forEach var="d" items="${departments}">
                            <option value="${d.id}">${d.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Designation *</label>
                    <select name="designationId" class="form-select-enterprise" required>
                        <c:forEach var="des" items="${designations}">
                            <option value="${des.id}">${des.title}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Hiring Manager</label>
                    <select name="hiringManagerId" class="form-select-enterprise">
                        <option value="">-- Select Hiring Manager --</option>
                        <c:forEach var="m" items="${employees}">
                            <option value="${m.id}">${m.fullName}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="row g-2 mb-3">
                    <div class="col-6">
                        <label class="form-label-enterprise">Vacancies</label>
                        <input type="number" name="vacancies" class="form-control-enterprise" value="1" min="1">
                    </div>
                    <div class="col-6">
                        <label class="form-label-enterprise">Deadline</label>
                        <input type="date" name="deadline" class="form-control-enterprise">
                    </div>
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Work Location</label>
                    <input type="text" name="location" class="form-control-enterprise" placeholder="Headquarters / Remote">
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Role Description</label>
                    <textarea name="description" class="form-control-enterprise" rows="3" placeholder="Overview of team objectives and responsibilities..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-enterprise btn-secondary-enterprise" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" class="btn-enterprise btn-primary-enterprise">Publish Job Requisition</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal: Register Candidate -->
<div class="modal fade" id="newCandidateModal" tabindex="-1">
    <div class="modal-dialog">
        <form method="post" action="/recruitment/candidates/create" class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold">Register Candidate Application</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label-enterprise">Job Opening *</label>
                    <select name="jobPostingId" class="form-select-enterprise" required>
                        <c:forEach var="j" items="${jobs}">
                            <option value="${j.id}">${j.title} (${j.department.name})</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Candidate Full Name *</label>
                    <input type="text" name="fullName" class="form-control-enterprise" required placeholder="Full Name">
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Email Address *</label>
                    <input type="email" name="email" class="form-control-enterprise" required placeholder="candidate@example.com">
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Phone</label>
                    <input type="text" name="phone" class="form-control-enterprise" placeholder="+1 (555) 000-0000">
                </div>
                <div class="row g-2 mb-3">
                    <div class="col-6">
                        <label class="form-label-enterprise">Experience (Years)</label>
                        <input type="number" step="0.5" name="experienceYears" class="form-control-enterprise" value="3.0">
                    </div>
                    <div class="col-6">
                        <label class="form-label-enterprise">Expected Salary</label>
                        <input type="text" name="expectedSalary" class="form-control-enterprise" placeholder="e.g. $110,000">
                    </div>
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Current Organization</label>
                    <input type="text" name="currentCompany" class="form-control-enterprise" placeholder="Company Name">
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Recruiter Notes</label>
                    <textarea name="notes" class="form-control-enterprise" rows="2" placeholder="Initial screening notes..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-enterprise btn-secondary-enterprise" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" class="btn-enterprise btn-primary-enterprise">Register Candidate</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal: Schedule Interview -->
<div class="modal fade" id="scheduleInterviewModal" tabindex="-1">
    <div class="modal-dialog">
        <form method="post" action="/recruitment/interviews/schedule" class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold">Schedule Candidate Interview</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label-enterprise">Candidate *</label>
                    <select name="candidateId" class="form-select-enterprise" required>
                        <c:forEach var="c" items="${allCandidates}">
                            <option value="${c.id}">${c.fullName} - ${c.jobPosting.title}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Interviewer *</label>
                    <select name="interviewerId" class="form-select-enterprise" required>
                        <c:forEach var="m" items="${employees}">
                            <option value="${m.id}">${m.fullName} (${not empty m.designation ? m.designation.title : 'Staff'})</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Interview Type</label>
                    <select name="interviewType" class="form-select-enterprise">
                        <option value="TECHNICAL">Technical Round</option>
                        <option value="HR">HR Behavioral Round</option>
                        <option value="EXECUTIVE">Executive Leadership Round</option>
                        <option value="SCREENING">Initial Recruiter Screen</option>
                    </select>
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Date & Time *</label>
                    <input type="datetime-local" name="scheduledAt" class="form-control-enterprise" required>
                </div>
                <div class="mb-3">
                    <label class="form-label-enterprise">Meeting Link (Google Meet / Zoom)</label>
                    <input type="text" name="meetingLink" class="form-control-enterprise" placeholder="https://meet.google.com/...">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-enterprise btn-secondary-enterprise" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" class="btn-enterprise btn-primary-enterprise">Schedule Interview</button>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
