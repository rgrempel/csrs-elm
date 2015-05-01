package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.Contact;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.*;

/**
 * Spring Data JPA repository for the Contact entity.
 */
public interface ContactRepository extends FindsForLogin<Contact, Long> {

    @Query("SELECT DISTINCT c FROM Contact c JOIN c.contactEmails ce JOIN ce.email e JOIN e.userEmails ue JOIN ue.user u WHERE u.login = ?1")
/*  @EntityGraph(
        value = "Contact.WithAnnualsAndInterests",
        type = EntityGraph.EntityGraphType.LOAD
    ) */
    @Override
    Set<Contact> findAllForLogin (String login);

    @Query("SELECT DISTINCT c FROM Contact c JOIN c.contactEmails ce JOIN ce.email e JOIN e.userEmails ue JOIN ue.user u WHERE u.login = ?1 AND c.id = ?2")
    @Override
    Optional<Contact> findOneForLogin (String login, Long contactID);
   
    @Query("SELECT DISTINCT c FROM Contact c JOIN c.contactEmails ce JOIN ce.email e JOIN e.userEmails ue JOIN ue.user u WHERE u.login = ?1 AND c.id IN ?2")
    Set<Contact> findAllForLogin (String login, Set<Long> contactID);
    
    @Query("SELECT DISTINCT c FROM Contact c WHERE c.plainFirstName LIKE lower(unaccent(?1)) OR c.plainLastName LIKE lower(unaccent(?1))")
/*  @EntityGraph(
        value = "Contact.WithAnnuals",
        type = EntityGraph.EntityGraphType.LOAD
    )*/
    List<Contact> searchByFullNameLikeLower (String fullName);

    @Query("SELECT DISTINCT c FROM Contact c WHERE c.id = ?1")
/*  @EntityGraph(
        value = "Contact.WithAnnualsAndInterestsAndEmail",
        type = EntityGraph.EntityGraphType.LOAD
    ) */
    Contact findOneWithAnnualsAndInterestsAndEmail (Long id);
}
