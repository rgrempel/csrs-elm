package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.Annual;
import org.springframework.data.jpa.repository.*;

import java.util.List;

/**
 * Spring Data JPA repository for the Annual entity.
 */
public interface AnnualRepository extends JpaRepository<Annual,Long> {

}
