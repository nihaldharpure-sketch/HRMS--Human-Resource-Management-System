package com.hrms.repository;

import com.hrms.entity.AttendanceCorrection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface AttendanceCorrectionRepository extends JpaRepository<AttendanceCorrection, Long> {

    List<AttendanceCorrection> findAllByOrderBySubmittedAtDesc();

    List<AttendanceCorrection> findByEmployeeIdOrderBySubmittedAtDesc(Long employeeId);

    List<AttendanceCorrection> findByStatusOrderBySubmittedAtDesc(String status);

    @Query("SELECT ac FROM AttendanceCorrection ac WHERE ac.employee.manager.id = :managerId ORDER BY ac.submittedAt DESC")
    List<AttendanceCorrection> findByManagerIdOrderBySubmittedAtDesc(@Param("managerId") Long managerId);

    long countByStatus(String status);
}
