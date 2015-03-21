package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.Interest;
import org.springframework.data.jpa.repository.*;

import java.util.List;

/**
 * Spring Data JPA repository for the Interest entity.
 */
public interface InterestRepository extends JpaRepository<Interest,Long> {

}
