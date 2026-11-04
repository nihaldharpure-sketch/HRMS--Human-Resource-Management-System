package com.hrms.service;

import com.hrms.entity.Employee;
import com.hrms.entity.PerformanceReview;
import com.hrms.repository.PerformanceReviewRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class PerformanceService {

    private final PerformanceReviewRepository reviewRepository;

    public PerformanceService(PerformanceReviewRepository reviewRepository) {
        this.reviewRepository = reviewRepository;
    }

    public List<PerformanceReview> getAllReviews() {
        return reviewRepository.findAllByOrderByReviewDateDesc();
    }

    public List<PerformanceReview> getReviewsForEmployee(Long employeeId) {
        return reviewRepository.findByEmployeeIdOrderByReviewDateDesc(employeeId);
    }

    public PerformanceReview getReviewById(Long id) {
        return reviewRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Performance review not found with id: " + id));
    }

    @Transactional
    public PerformanceReview createReview(PerformanceReview review) {
        return reviewRepository.save(review);
    }

    @Transactional
    public PerformanceReview submitSelfAssessment(Long id, String selfAssessment, Integer selfRating) {
        PerformanceReview review = getReviewById(id);
        review.setSelfAssessment(selfAssessment);
        review.setSelfRating(selfRating);
        review.setStatus("SUBMITTED");
        return reviewRepository.save(review);
    }

    @Transactional
    public PerformanceReview submitManagerReview(Long id, Employee manager, String feedback, Integer managerRating) {
        PerformanceReview review = getReviewById(id);
        review.setReviewer(manager);
        review.setManagerFeedback(feedback);
        review.setManagerRating(managerRating);
        review.setStatus("COMPLETED");
        return reviewRepository.save(review);
    }
}
