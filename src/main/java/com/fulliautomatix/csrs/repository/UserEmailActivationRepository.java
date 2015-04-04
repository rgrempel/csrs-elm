package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.UserEmailActivation;

import org.joda.time.DateTime;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

/**
 * Spring Data JPA repository for the UserEmailActivation entity.
 */
public interface UserEmailActivationRepository extends JpaRepository<UserEmailActivation, Long> {
    
    Optional<UserEmailActivation> findByActivationKey (String key);

}
