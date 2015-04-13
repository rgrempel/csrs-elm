package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.Product;

import org.joda.time.DateTime;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.*;

/**
 * Spring Data JPA repository for the Product entity.
 */
public interface ProductRepository extends JpaRepository<Product, Long> {

}
