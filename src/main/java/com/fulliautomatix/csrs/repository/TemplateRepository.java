package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.Template;

import org.joda.time.DateTime;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.*;

/**
 * Spring Data JPA repository for the Template entity.
 */
public interface TemplateRepository extends JpaRepository<Template, Long> {
    Optional<Template> findOneById (Long id);
}
