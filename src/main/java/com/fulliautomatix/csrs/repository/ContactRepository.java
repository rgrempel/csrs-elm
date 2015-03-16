package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.Contact;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

/**
 * Spring Data JPA repository for the Contact entity.
 */
public interface ContactRepository extends JpaRepository<Contact,Long> {

    @Query("SELECT DISTINCT c FROM Contact c WHERE LOWER(c.firstName) LIKE ?1 OR LOWER(c.lastName) LIKE ?1")
    Page<Contact> searchByFullNameLikeLower (String fullName, Pageable page);

    @Query("SELECT DISTINCT c FROM Contact c WHERE LOWER(c.firstName) LIKE ?1 OR LOWER(c.lastName) LIKE ?1")
    @EntityGraph(
        value = "Contact.WithAnnuals",
        type = EntityGraph.EntityGraphType.LOAD
    )
    List<Contact> searchByFullNameLikeLower (String fullName);
}
