package com.hrms.service;

import com.hrms.entity.OnboardingTask;
import com.hrms.repository.OnboardingTaskRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
public class OnboardingService {

    private final OnboardingTaskRepository onboardingTaskRepository;

    public OnboardingService(OnboardingTaskRepository onboardingTaskRepository) {
        this.onboardingTaskRepository = onboardingTaskRepository;
    }

    public List<OnboardingTask> getTasksForEmployee(Long employeeId) {
        return onboardingTaskRepository.findByEmployeeIdOrderByDueDateAsc(employeeId);
    }

    public List<OnboardingTask> getAllPendingTasks() {
        return onboardingTaskRepository.findByStatusOrderByDueDateAsc("PENDING");
    }

    public List<OnboardingTask> getAllTasks() {
        return onboardingTaskRepository.findAll();
    }

    @Transactional
    public void completeTask(Long taskId) {
        OnboardingTask task = onboardingTaskRepository.findById(taskId)
                .orElseThrow(() -> new IllegalArgumentException("Task not found with id: " + taskId));
        task.setStatus("COMPLETED");
        task.setCompletedDate(LocalDate.now());
        onboardingTaskRepository.save(task);
    }

    @Transactional
    public OnboardingTask createTask(OnboardingTask task) {
        return onboardingTaskRepository.save(task);
    }
}
