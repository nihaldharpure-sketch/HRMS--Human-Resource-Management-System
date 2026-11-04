package com.hrms.repository;

import com.hrms.entity.JobPosting;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface JobPostingRepository extends JpaRepository<JobPosting, Long> {
    List<JobPosting> findByStatusOrderByPostedDateDesc(String status);
    List<JobPosting> findAllByOrderByPostedDateDesc();
    long countByStatus(String status);
}
