package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.ContactEmail;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Set;

/**
 * Spring Data JPA repository for the ContactEmail entity.
 */
public interface ContactEmailRepository extends JpaRepository<ContactEmail,Long> {

}
