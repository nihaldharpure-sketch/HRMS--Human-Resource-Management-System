package com.hrms.repository;

import com.hrms.entity.Candidate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface CandidateRepository extends JpaRepository<Candidate, Long> {

    List<Candidate> findByJobPostingId(Long jobPostingId);

    List<Candidate> findByStage(String stage);

    Optional<Candidate> findByEmailAndJobPostingId(String email, Long jobPostingId);

    long countByStage(String stage);

    @Query("SELECT c.stage, COUNT(c) FROM Candidate c GROUP BY c.stage")
    List<Object[]> countCandidatesByStage();
}
