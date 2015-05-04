package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.TemplateLanguage;

import org.joda.time.DateTime;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.*;

/**
 * Spring Data JPA repository for the TemplateLanguage entity.
 */
public interface TemplateLanguageRepository extends JpaRepository<TemplateLanguage, Long> {

}
