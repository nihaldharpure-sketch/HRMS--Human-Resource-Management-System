package com.hrms.repository;

import com.hrms.entity.CompanyHoliday;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface CompanyHolidayRepository extends JpaRepository<CompanyHoliday, Long> {
    Optional<CompanyHoliday> findByHolidayDate(LocalDate holidayDate);
    List<CompanyHoliday> findAllByOrderByHolidayDateAsc();
    List<CompanyHoliday> findByHolidayDateBetweenOrderByHolidayDateAsc(LocalDate start, LocalDate end);
}
