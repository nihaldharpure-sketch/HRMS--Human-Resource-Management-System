package com.hrms.repository;

import com.hrms.entity.Interview;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface InterviewRepository extends JpaRepository<Interview, Long> {
    List<Interview> findByCandidateIdOrderByScheduledAtDesc(Long candidateId);
    List<Interview> findByInterviewerIdOrderByScheduledAtDesc(Long interviewerId);
    List<Interview> findAllByOrderByScheduledAtDesc();
    long countByStatus(String status);
}
