package com.hrms.controller;

import com.hrms.security.SecurityUtil;
import com.hrms.service.AiInsightService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.Map;

@Controller
@RequestMapping("/insights")
public class AiInsightWebController {

    private final AiInsightService aiInsightService;
    private final SecurityUtil securityUtil;

    public AiInsightWebController(AiInsightService aiInsightService, SecurityUtil securityUtil) {
        this.aiInsightService = aiInsightService;
        this.securityUtil = securityUtil;
    }

    @GetMapping
    public String viewInsights(Model model) {
        Map<String, Object> insights = aiInsightService.generateExecutiveInsights();
        model.addAttribute("insights", insights);
        securityUtil.getCurrentUser().ifPresent(u -> model.addAttribute("currentUser", u));
        return "insights";
    }
}
