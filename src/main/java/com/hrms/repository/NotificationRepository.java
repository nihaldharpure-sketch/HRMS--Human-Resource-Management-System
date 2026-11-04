package com.hrms.repository;

import com.hrms.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findByRecipientIdOrderByCreatedAtDesc(Long recipientId);
    List<Notification> findByEmployeeIdOrderByCreatedAtDesc(Long employeeId);
    List<Notification> findAllByOrderByCreatedAtDesc();
    long countByRecipientIdAndIsReadFalse(Long recipientId);
    long countByIsReadFalse();

    @Query("SELECT n FROM Notification n WHERE (n.recipient.id = :userId OR (n.employee IS NOT NULL AND n.employee.id = :employeeId) OR (n.recipient IS NULL AND n.employee IS NULL)) AND (n.isRead IS NULL OR n.isRead = false) ORDER BY n.createdAt DESC")
    List<Notification> findUnreadForUser(@Param("userId") Long userId, @Param("employeeId") Long employeeId);

    @Query("SELECT COUNT(n) FROM Notification n WHERE (n.recipient.id = :userId OR (n.employee IS NOT NULL AND n.employee.id = :employeeId) OR (n.recipient IS NULL AND n.employee IS NULL)) AND (n.isRead IS NULL OR n.isRead = false)")
    long countUnreadForUser(@Param("userId") Long userId, @Param("employeeId") Long employeeId);
}
