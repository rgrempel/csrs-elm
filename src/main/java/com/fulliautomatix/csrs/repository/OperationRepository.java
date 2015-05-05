package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.Operation;
import org.springframework.data.jpa.repository.*;

import java.util.*;

/**
 * Spring Data JPA repository for the Operation entity.
 */
public interface OperationRepository extends JpaRepository<Operation, Long> {
    

}
