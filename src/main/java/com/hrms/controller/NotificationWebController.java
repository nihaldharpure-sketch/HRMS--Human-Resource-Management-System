package com.hrms.controller;

import com.hrms.entity.Employee;
import com.hrms.entity.Notification;
import com.hrms.entity.UserAccount;
import com.hrms.security.SecurityUtil;
import com.hrms.service.NotificationService;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.*;

@Controller
@RequestMapping("/notifications")
public class NotificationWebController {

    private final NotificationService notificationService;
    private final SecurityUtil securityUtil;

    public NotificationWebController(NotificationService notificationService, SecurityUtil securityUtil) {
        this.notificationService = notificationService;
        this.securityUtil = securityUtil;
    }

    @GetMapping
    public String notificationsCenter(Model model) {
        Optional<UserAccount> currentUser = securityUtil.getCurrentUser();
        List<Notification> notifications;
        if (currentUser.isPresent()) {
            notifications = notificationService.getNotificationsForUser(currentUser.get().getId());
            if (notifications.isEmpty()) {
                notifications = notificationService.getAllNotifications();
            }
        } else {
            notifications = notificationService.getAllNotifications();
        }

        model.addAttribute("notifications", notifications);
        currentUser.ifPresent(u -> model.addAttribute("currentUser", u));
        return "notifications";
    }

    @PostMapping("/read/{id}")
    public String markRead(@PathVariable Long id) {
        notificationService.markAsRead(id);
        return "redirect:/notifications";
    }

    @PostMapping("/read-all")
    public String markAllRead(RedirectAttributes redirectAttributes) {
        Optional<UserAccount> currentUser = securityUtil.getCurrentUser();
        if (currentUser.isPresent()) {
            Long uid = currentUser.get().getId();
            Long empId = currentUser.get().getEmployee() != null ? currentUser.get().getEmployee().getId() : null;
            notificationService.markAllAsReadForUser(uid, empId);
        }
        redirectAttributes.addFlashAttribute("successMessage", "All notifications marked as read.");
        return "redirect:/notifications";
    }

    // JSON API Endpoints for Dashboard / Portal real-time popups
    @GetMapping("/api/unread")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getUnreadNotificationsApi() {
        Optional<UserAccount> currentUser = securityUtil.getCurrentUser();
        if (currentUser.isEmpty()) {
            return ResponseEntity.ok(Collections.emptyList());
        }

        Long uid = currentUser.get().getId();
        Long empId = currentUser.get().getEmployee() != null ? currentUser.get().getEmployee().getId() : null;
        List<Notification> unread = notificationService.getUnreadNotificationsForUser(uid, empId);

        List<Map<String, Object>> response = new ArrayList<>();
        for (Notification n : unread) {
            Map<String, Object> map = new HashMap<>();
            map.put("id", n.getId());
            map.put("title", n.getTitle() != null ? n.getTitle() : "Notification");
            map.put("message", n.getMessage() != null ? n.getMessage() : "");
            map.put("type", n.getType() != null ? n.getType() : "SYSTEM");
            map.put("link", n.getLink() != null && !n.getLink().isBlank() ? n.getLink() : "#");
            map.put("createdAt", n.getCreatedAt() != null ? n.getCreatedAt().toString() : "");
            response.add(map);
        }

        return ResponseEntity.ok(response);
    }

    @PostMapping("/api/read/{id}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> markReadApi(@PathVariable Long id) {
        notificationService.markAsRead(id);
        Map<String, Object> resp = new HashMap<>();
        resp.put("success", true);
        resp.put("id", id);
        return ResponseEntity.ok(resp);
    }

    @PostMapping("/api/read-all")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> markAllReadApi() {
        Optional<UserAccount> currentUser = securityUtil.getCurrentUser();
        if (currentUser.isPresent()) {
            Long uid = currentUser.get().getId();
            Long empId = currentUser.get().getEmployee() != null ? currentUser.get().getEmployee().getId() : null;
            notificationService.markAllAsReadForUser(uid, empId);
        }
        Map<String, Object> resp = new HashMap<>();
        resp.put("success", true);
        return ResponseEntity.ok(resp);
    }
}
