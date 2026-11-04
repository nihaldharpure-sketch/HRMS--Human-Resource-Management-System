<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!-- App Sidebar (Dark Slate Theme) -->
<aside class="app-sidebar" id="appSidebar">
    <a class="brand-section" href="/dashboard">
        <div class="brand-icon">
            <i class="bi bi-layers-fill"></i>
        </div>
        <div class="brand-title">
            <span>HRMS</span>
            <span class="brand-subtitle">ENTERPRISE SAAS</span>
        </div>
    </a>

    <div class="sidebar-nav-container">
        <div class="nav-category">Main Workspace</div>
        <a class="sidebar-link ${pageContext.request.requestURI.contains('/dashboard') ? 'active' : ''}" href="/dashboard">
            <i class="bi bi-grid-1x2-fill"></i>
            <span>Dashboard</span>
        </a>
        <a class="sidebar-link ${pageContext.request.requestURI.contains('/portal') ? 'active' : ''}" href="/portal">
            <i class="bi bi-person-badge-fill"></i>
            <span>Self-Service Portal</span>
            <span class="sidebar-badge highlight">My Hub</span>
        </a>
        <a class="sidebar-link ${pageContext.request.requestURI.contains('/insights') ? 'active' : ''}" href="/insights">
            <i class="bi bi-stars"></i>
            <span>AI HR Insights</span>
            <span class="sidebar-badge">AI</span>
        </a>

        <div class="nav-category">Core Human Resources</div>
        <a class="sidebar-link ${pageContext.request.requestURI.contains('/employees') ? 'active' : ''}" href="/employees">
            <i class="bi bi-people-fill"></i>
            <span>Employees</span>
        </a>
        <a class="sidebar-link ${pageContext.request.requestURI.contains('/departments') ? 'active' : ''}" href="/departments">
            <i class="bi bi-diagram-3-fill"></i>
            <span>Organization</span>
        </a>
        <a class="sidebar-link ${pageContext.request.requestURI.contains('/attendance') ? 'active' : ''}" href="/attendance">
            <i class="bi bi-clock-history"></i>
            <span>Attendance & Shifts</span>
        </a>
        <a class="sidebar-link ${pageContext.request.requestURI.contains('/leave') ? 'active' : ''}" href="/leave">
            <i class="bi bi-calendar2-heart-fill"></i>
            <span>Leave Management</span>
        </a>

        <div class="nav-category">Operations & Talent</div>
        <a class="sidebar-link ${pageContext.request.requestURI.contains('/payroll') ? 'active' : ''}" href="/payroll">
            <i class="bi bi-wallet2"></i>
            <span>Payroll & Salary</span>
        </a>
        <a class="sidebar-link ${pageContext.request.requestURI.contains('/recruitment') ? 'active' : ''}" href="/recruitment">
            <i class="bi bi-briefcase-fill"></i>
            <span>Recruitment ATS</span>
        </a>
        <a class="sidebar-link ${pageContext.request.requestURI.contains('/performance') ? 'active' : ''}" href="/performance">
            <i class="bi bi-bar-chart-steps"></i>
            <span>Performance</span>
        </a>

        <div class="nav-category">Administration</div>
        <a class="sidebar-link ${pageContext.request.requestURI.contains('/reports') ? 'active' : ''}" href="/reports">
            <i class="bi bi-file-earmark-bar-graph-fill"></i>
            <span>Reports & Exports</span>
        </a>
        <a class="sidebar-link ${pageContext.request.requestURI.contains('/notifications') ? 'active' : ''}" href="/notifications">
            <i class="bi bi-bell-fill"></i>
            <span>Notifications</span>
            <c:if test="${not empty unreadCount && unreadCount > 0}">
                <span class="sidebar-badge highlight">${unreadCount}</span>
            </c:if>
        </a>
        <a class="sidebar-link ${pageContext.request.requestURI.contains('/settings') ? 'active' : ''}" href="/settings">
            <i class="bi bi-sliders"></i>
            <span>Settings</span>
        </a>
    </div>

    <div class="sidebar-footer">
        <div class="user-avatar">
            ${not empty currentUser ? currentUser.username.substring(0, 1).toUpperCase() : 'A'}
        </div>
        <div class="user-meta">
            <div class="user-name">${not empty currentUser ? currentUser.fullName : 'Admin User'}</div>
            <div class="user-role-badge">${not empty currentUser ? currentUser.primaryRoleName : 'Administrator'}</div>
        </div>
        <a href="/logout" class="logout-btn" title="Sign out">
            <i class="bi bi-box-arrow-right"></i>
        </a>
    </div>
</aside>

<!-- Top Navigation Bar -->
<header class="app-topbar">
    <div class="topbar-left">
        <button class="mobile-nav-toggle" type="button" aria-label="Toggle navigation" onclick="document.getElementById('appSidebar').classList.toggle('show-mobile')">
            <i class="bi bi-list"></i>
        </button>
        <div class="breadcrumb-lockup">
            <span>HRMS Operations</span>
            <i class="bi bi-chevron-right text-muted" style="font-size: 0.7rem;"></i>
            <strong>${not empty pageTitle ? pageTitle : (not empty title ? title : 'Overview')}</strong>
        </div>
    </div>

    <div class="topbar-right">
        <!-- Self-Service Quick Punch Action -->
        <a href="/portal" class="quick-action-pill" title="Open Employee Self-Service Punch">
            <i class="bi bi-clock"></i>
            <span>Quick Punch</span>
        </a>

        <div class="topbar-search">
            <i class="bi bi-search"></i>
            <input type="text" placeholder="Search employees, jobs..." onkeydown="if(event.key==='Enter') window.location.href='/employees?search='+encodeURIComponent(this.value)">
        </div>

        <a href="/notifications" class="icon-btn-badge" id="topbarBellLink" title="Notifications">
            <i class="bi bi-bell"></i>
            <span class="badge-dot ${not empty unreadCount && unreadCount > 0 ? '' : 'd-none'}" id="topbarBellBadge"></span>
        </a>

        <div class="dropdown">
            <a href="#" class="d-flex align-items-center gap-2 text-decoration-none" data-bs-toggle="dropdown" aria-expanded="false">
                <div class="user-avatar" style="width: 34px; height: 34px; font-size: 0.75rem;">
                    ${not empty currentUser ? currentUser.username.substring(0, 1).toUpperCase() : 'A'}
                </div>
                <div class="d-none d-md-block text-start" style="line-height: 1.2;">
                    <div style="font-size: 0.8rem; font-weight: 700; color: var(--slate-900);">
                        ${not empty currentUser ? currentUser.fullName : 'Admin User'}
                    </div>
                    <div style="font-size: 0.68rem; color: var(--slate-500);">
                        ${not empty currentUser ? currentUser.primaryRoleName : 'Administrator'}
                    </div>
                </div>
                <i class="bi bi-chevron-down text-muted" style="font-size: 0.75rem;"></i>
            </a>
            <ul class="dropdown-menu dropdown-menu-end shadow-sm" style="border-radius: 10px; border-color: var(--slate-200); font-size: 0.82rem;">
                <li><a class="dropdown-item py-2" href="/portal"><i class="bi bi-person-circle me-2 text-primary"></i>My Self-Service Hub</a></li>
                <li><a class="dropdown-item py-2" href="/settings"><i class="bi bi-sliders me-2 text-muted"></i>Account Settings</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item py-2 text-danger" href="/logout"><i class="bi bi-box-arrow-right me-2"></i>Sign Out</a></li>
            </ul>
        </div>
    </div>
</header>

<!-- Floating Popup Notification Toast Container (Dashboard, Portal & System-wide) -->
<div id="notificationToastContainer" class="notification-toast-container" aria-live="polite" aria-atomic="true"></div>

<script>
    (function initNotificationPopup() {
        // Fetch unread notifications for current authenticated user
        fetch('/notifications/api/unread')
            .then(res => res.ok ? res.json() : [])
            .then(data => {
                if (!Array.isArray(data) || data.length === 0) return;
                
                const container = document.getElementById('notificationToastContainer');
                if (!container) return;

                const badge = document.getElementById('topbarBellBadge');
                if (badge) badge.classList.remove('d-none');

                // Render up to 3 popup cards on screen
                data.slice(0, 3).forEach(n => {
                    const card = document.createElement('div');
                    card.className = 'notification-popup-card type-' + (n.type || 'SYSTEM');
                    card.id = 'notif-toast-' + n.id;
                    
                    let icon = 'bi-bell-fill text-primary';
                    if (n.type === 'LEAVE') icon = 'bi-calendar2-heart-fill text-warning';
                    else if (n.type === 'RECRUITMENT') icon = 'bi-briefcase-fill text-purple';
                    else if (n.type === 'PAYROLL') icon = 'bi-wallet2 text-success';
                    else if (n.type === 'ATTENDANCE') icon = 'bi-clock-fill text-info';

                    var linkHtml = (n.link && n.link !== '#') ? '<a href="' + escapeHtml(n.link) + '" class="popup-btn-link" onclick="markToastRead(' + n.id + ')">Open</a>' : '';

                    card.innerHTML = 
                        '<div class="popup-header">' +
                            '<div class="popup-title-wrap">' +
                                '<i class="bi ' + icon + '"></i>' +
                                '<span class="popup-badge">' + escapeHtml(n.type || 'SYSTEM') + '</span>' +
                            '</div>' +
                            '<button type="button" class="popup-close-btn" title="Dismiss" onclick="dismissToast(' + n.id + ')">&times;</button>' +
                        '</div>' +
                        '<div class="popup-title">' + escapeHtml(n.title) + '</div>' +
                        '<div class="popup-message">' + escapeHtml(n.message) + '</div>' +
                        '<div class="popup-actions">' +
                            linkHtml +
                            '<button type="button" class="popup-btn-read" onclick="markToastRead(' + n.id + ')">' +
                                '<i class="bi bi-check2"></i> Mark as Read' +
                            '</button>' +
                        '</div>';
                    container.appendChild(card);
                });
            })
            .catch(err => console.debug('Notifications fetch silent fail:', err));
    })();

    function escapeHtml(str) {
        if (!str) return '';
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }

    function removeToastCard(id) {
        const card = document.getElementById('notif-toast-' + id);
        if (card) {
            card.classList.add('removing');
            setTimeout(() => {
                if (card.parentNode) card.parentNode.removeChild(card);
                const remaining = document.querySelectorAll('.notification-popup-card');
                if (remaining.length === 0) {
                    const badge = document.getElementById('topbarBellBadge');
                    if (badge) badge.classList.add('d-none');
                }
            }, 260);
        }
    }

    function dismissToast(id) {
        removeToastCard(id);
    }

    function markToastRead(id) {
        // Send async POST request to mark as read in database
        fetch('/notifications/api/read/' + id, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                removeToastCard(id);
            }
        })
        .catch(() => {
            removeToastCard(id);
        });
    }
</script>