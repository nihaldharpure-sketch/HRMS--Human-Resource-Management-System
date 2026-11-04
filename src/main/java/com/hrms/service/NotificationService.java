package com.hrms.service;

import com.hrms.entity.Notification;
import com.hrms.entity.Role;
import com.hrms.entity.UserAccount;
import com.hrms.repository.NotificationRepository;
import com.hrms.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    public NotificationService(NotificationRepository notificationRepository, UserRepository userRepository) {
        this.notificationRepository = notificationRepository;
        this.userRepository = userRepository;
    }

    public List<Notification> getAllNotifications() {
        return notificationRepository.findAllByOrderByCreatedAtDesc();
    }

    public List<Notification> getNotificationsForUser(Long userId) {
        return notificationRepository.findByRecipientIdOrderByCreatedAtDesc(userId);
    }

    public List<Notification> getUnreadNotificationsForUser(Long userId, Long employeeId) {
        return notificationRepository.findUnreadForUser(userId, employeeId);
    }

    @Transactional
    public Notification sendNotification(UserAccount recipient, String title, String message, String type, String link) {
        Notification notification = new Notification(recipient, title, message, type, link);
        return notificationRepository.save(notification);
    }

    @Transactional
    public void notifyAdminsAndHR(String title, String message, String link) {
        List<UserAccount> users = userRepository.findAll();
        for (UserAccount u : users) {
            if (u.hasRole(Role.ADMIN) || u.hasRole(Role.HR_MANAGER) || u.hasRole(Role.HR)) {
                sendNotification(u, title, message, "APPROVAL", link);
            }
        }
    }

    @Transactional
    public void markAsRead(Long id) {
        notificationRepository.findById(id).ifPresent(n -> {
            n.setIsRead(true);
            notificationRepository.save(n);
        });
    }

    @Transactional
    public void markAllAsReadForUser(Long userId) {
        List<Notification> list = notificationRepository.findByRecipientIdOrderByCreatedAtDesc(userId);
        for (Notification n : list) {
            n.setIsRead(true);
        }
        notificationRepository.saveAll(list);
    }

    @Transactional
    public void markAllAsReadForUser(Long userId, Long employeeId) {
        List<Notification> list = notificationRepository.findUnreadForUser(userId, employeeId);
        for (Notification n : list) {
            n.setIsRead(true);
        }
        notificationRepository.saveAll(list);
    }

    public long getUnreadCount(Long userId) {
        if (userId != null) {
            return notificationRepository.countByRecipientIdAndIsReadFalse(userId);
        }
        return notificationRepository.countByIsReadFalse();
    }

    public long getUnreadCount(Long userId, Long employeeId) {
        if (userId != null) {
            return notificationRepository.countUnreadForUser(userId, employeeId);
        }
        return notificationRepository.countByIsReadFalse();
    }
}
