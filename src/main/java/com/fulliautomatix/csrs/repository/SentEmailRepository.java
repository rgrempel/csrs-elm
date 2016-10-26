package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.SentEmail;
import org.springframework.data.jpa.repository.*;

import java.util.*;

/**
 * Spring Data JPA repository for the SentEmail entity.
 */
public interface SentEmailRepository extends JpaRepository<SentEmail, Long> {

}
