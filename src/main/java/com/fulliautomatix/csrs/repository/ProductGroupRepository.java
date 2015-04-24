package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.ProductGroup;

import org.joda.time.DateTime;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.*;

/**
 * Spring Data JPA repository for the ProductGroup entity.
 */
public interface ProductGroupRepository extends JpaRepository<ProductGroup, Long> {

}
