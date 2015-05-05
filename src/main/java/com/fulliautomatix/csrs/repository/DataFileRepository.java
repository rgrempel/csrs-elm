package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.DataFile;
import org.springframework.data.jpa.repository.*;

import java.util.*;

/**
 * Spring Data JPA repository for the DataFile entity.
 */
public interface DataFileRepository extends JpaRepository<DataFile, Long> {
    

}
