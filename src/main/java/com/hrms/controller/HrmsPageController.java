package com.hrms.controller;

import com.hrms.security.SecurityUtil;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HrmsPageController {

    private final SecurityUtil securityUtil;

    public HrmsPageController(SecurityUtil securityUtil) {
        this.securityUtil = securityUtil;
    }

    @GetMapping("/settings")
    public String settings(Model model) {
        model.addAttribute("moduleTitle", "Organization Settings");
        model.addAttribute("moduleDescription", "Configure enterprise working hours, leave accrual policies, and notification rules.");
        securityUtil.getCurrentUser().ifPresent(u -> model.addAttribute("currentUser", u));
        return "settings";
    }
}