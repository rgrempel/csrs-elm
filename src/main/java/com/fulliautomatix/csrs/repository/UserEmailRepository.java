package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.UserEmail;

import org.joda.time.DateTime;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

/**
 * Spring Data JPA repository for the Email entity.
 */
public interface UserEmailRepository extends JpaRepository<UserEmail, Long> {

}
