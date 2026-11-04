<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In | HRMS Operations Enterprise Platform</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        :root {
            --primary: #4f46e5;
            --primary-hover: #4338ca;
            --slate-900: #0f172a;
            --slate-800: #1e293b;
        }
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #0f172a 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
            color: #0f172a;
        }
        .login-card {
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.45);
            max-width: 440px;
            width: 100%;
            padding: 40px;
            position: relative;
        }
        .brand-badge {
            width: 48px;
            height: 48px;
            background: linear-gradient(135deg, #4f46e5, #7c3aed);
            color: #ffffff;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            margin: 0 auto 16px;
            box-shadow: 0 8px 16px rgba(79, 70, 229, 0.35);
        }
        .role-chip {
            cursor: pointer;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            border: 1px solid #e2e8f0;
            background: #f8fafc;
            color: #475569;
            transition: all 0.18s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .role-chip:hover {
            border-color: #4f46e5;
            color: #4f46e5;
            background: #eef2ff;
        }
        .form-control:focus {
            border-color: #4f46e5;
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.15);
        }
    </style>
</head>
<body>

<div class="login-card">
    <div class="text-center mb-4">
        <div class="brand-badge">
            <i class="bi bi-layers-fill"></i>
        </div>
        <h3 class="fw-bold mb-1" style="color: #0f172a; letter-spacing: -0.02em;">HRMS Operations</h3>
        <p class="text-muted small">Enterprise Human Resource Management System</p>
    </div>

    <c:if test="${param.error != null}">
        <div class="alert alert-danger py-2 px-3 small d-flex align-items-center gap-2 mb-3">
            <i class="bi bi-exclamation-circle-fill"></i>
            <span>Invalid username or password. Please try again.</span>
        </div>
    </c:if>
    <c:if test="${param.logout != null}">
        <div class="alert alert-success py-2 px-3 small d-flex align-items-center gap-2 mb-3">
            <i class="bi bi-check-circle-fill"></i>
            <span>You have been safely signed out.</span>
        </div>
    </c:if>

    <form method="post" action="/login" id="loginForm">
        <div class="mb-3">
            <label class="form-label small fw-bold text-secondary">Username or Corporate Email</label>
            <div class="input-group">
                <span class="input-group-text bg-light text-muted border-end-0"><i class="bi bi-person"></i></span>
                <input type="text" class="form-control border-start-0 ps-0" id="usernameInput" name="username" required placeholder="username" autofocus>
            </div>
        </div>

        <div class="mb-3">
            <label class="form-label small fw-bold text-secondary">Password</label>
            <div class="input-group">
                <span class="input-group-text bg-light text-muted border-end-0"><i class="bi bi-key"></i></span>
                <input type="password" class="form-control border-start-0 ps-0" id="passwordInput" name="password" required placeholder="••••••••">
            </div>
        </div>

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div class="form-check">
                <input class="form-check-input" type="checkbox" id="rememberMe">
                <label class="form-check-label small text-muted" for="rememberMe">Remember me</label>
            </div>
            <a href="#" class="small text-decoration-none" style="color: #4f46e5;">Forgot password?</a>
        </div>

        <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold" style="background: #4f46e5; border-color: #4f46e5; border-radius: 8px;">
            Sign In to Workspace
        </button>
    </form>

    <!-- Quick Role Autofill Test Credentials -->
    <div class="mt-4 pt-3 border-top text-center">
        <div class="small text-muted mb-2 fw-semibold" style="font-size: 0.72rem; letter-spacing: 0.05em; text-transform: uppercase;">
            One-Click Demo Credentials
        </div>
        <div class="d-flex flex-wrap gap-2 justify-content-center">
            <button type="button" class="role-chip" onclick="fillCreds('admin', 'admin123')">
                <i class="bi bi-shield-lock text-primary"></i> Admin
            </button>
            <button type="button" class="role-chip" onclick="fillCreds('hrmanager', 'hr123')">
                <i class="bi bi-person-badge text-success"></i> HR Manager
            </button>
            <button type="button" class="role-chip" onclick="fillCreds('payroll', 'payroll123')">
                <i class="bi bi-wallet2" style="color: #9333ea;"></i> Payroll
            </button>
            <button type="button" class="role-chip" onclick="fillCreds('david', 'user123')">
                <i class="bi bi-person-gear text-warning"></i> Lead (David)
            </button>
            <button type="button" class="role-chip" onclick="fillCreds('priya', 'user123')">
                <i class="bi bi-person text-info"></i> Employee (Priya)
            </button>
        </div>
    </div>
</div>

<script>
    function fillCreds(u, p) {
        document.getElementById('usernameInput').value = u;
        document.getElementById('passwordInput').value = p;
    }
</script>
</body>
</html>
