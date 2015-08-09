package com.fulliautomatix.csrs.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.fulliautomatix.csrs.domain.UserEmailActivation;

/**
 * Spring Data JPA repository for the UserEmailActivation entity.
 */
public interface UserEmailActivationRepository extends JpaRepository<UserEmailActivation, Long> {
    
    Optional<UserEmailActivation> findByActivationKey (String key);

    @Query("SELECT DISTINCT uea FROM UserEmailActivation uea JOIN uea.userEmail ue JOIN ue.email e WHERE e.emailAddress = ?1")
    Optional<UserEmailActivation> findByEmailAddress (String address);
}
