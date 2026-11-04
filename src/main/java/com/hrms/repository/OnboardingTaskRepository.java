package com.hrms.repository;

import com.hrms.entity.OnboardingTask;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OnboardingTaskRepository extends JpaRepository<OnboardingTask, Long> {
    List<OnboardingTask> findByEmployeeIdOrderByDueDateAsc(Long employeeId);
    List<OnboardingTask> findByStatusOrderByDueDateAsc(String status);
    long countByStatus(String status);
}
