package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.Renewal;
import org.springframework.data.jpa.repository.*;

import java.util.List;

/**
 * Spring Data JPA repository for the Renewal entity.
 */
public interface RenewalRepository extends JpaRepository<Renewal,Long> {

}
