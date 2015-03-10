package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.Contact;
import org.springframework.data.jpa.repository.*;

import java.util.List;

/**
 * Spring Data JPA repository for the Contact entity.
 */
public interface ContactRepository extends JpaRepository<Contact,Long> {

}
