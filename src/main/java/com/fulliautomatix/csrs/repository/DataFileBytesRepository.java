package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.DataFileBytes;
import org.springframework.data.jpa.repository.*;

import java.util.*;

/**
 * Spring Data JPA repository for the DataFile entity.
 */
public interface DataFileBytesRepository extends JpaRepository<DataFileBytes, Long> {
  
    @Query("SELECT b FROM DataFileBytes b JOIN b.dataFile df WHERE df.path = ?1")
    Optional<DataFileBytes> findByPath (String path);

}
