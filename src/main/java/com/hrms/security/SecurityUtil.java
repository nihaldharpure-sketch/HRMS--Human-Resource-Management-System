package com.hrms.security;

import com.hrms.entity.Employee;
import com.hrms.entity.Role;
import com.hrms.entity.UserAccount;
import com.hrms.repository.UserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
public class SecurityUtil {

    private final UserRepository userRepository;

    public SecurityUtil(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public Optional<UserAccount> getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getPrincipal())) {
            return Optional.empty();
        }
        return userRepository.findByIdentifier(auth.getName());
    }

    public Optional<Employee> getCurrentEmployee() {
        return getCurrentUser().map(UserAccount::getEmployee);
    }

    public boolean hasRole(Role role) {
        return getCurrentUser().map(u -> u.hasRole(role)).orElse(false);
    }

    public boolean isAdminOrHr() {
        return getCurrentUser().map(u -> u.hasRole(Role.ADMIN) || u.hasRole(Role.HR_MANAGER) || u.hasRole(Role.HR)).orElse(false);
    }

    public boolean isPayrollManager() {
        return getCurrentUser().map(u -> u.hasRole(Role.ADMIN) || u.hasRole(Role.PAYROLL_MANAGER)).orElse(false);
    }

    public boolean isManager() {
        return getCurrentUser().map(u -> u.hasRole(Role.ADMIN) || u.hasRole(Role.HR_MANAGER) || u.hasRole(Role.MANAGER)).orElse(false);
    }
}
