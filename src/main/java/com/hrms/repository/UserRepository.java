package com.hrms.repository;

import com.hrms.entity.UserAccount;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<UserAccount, Long> {
    Optional<UserAccount> findByUsername(String username);

    @Query("SELECT u FROM UserAccount u LEFT JOIN u.employee e WHERE LOWER(u.username) = LOWER(:identifier) OR (e IS NOT NULL AND (LOWER(e.email) = LOWER(:identifier) OR UPPER(e.employeeCode) = UPPER(:identifier)))")
    Optional<UserAccount> findByIdentifier(@Param("identifier") String identifier);

    Optional<UserAccount> findByEmployeeId(Long employeeId);
}
