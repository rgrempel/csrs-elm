package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.ContactEmail;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.*;

/**
 * Spring Data JPA repository for the ContactEmail entity.
 */
public interface ContactEmailRepository extends FindsForLogin<ContactEmail, Long> {

    @Query("SELECT DISTINCT ce FROM ContactEmail ce JOIN ce.email e JOIN e.userEmails ue JOIN ue.user u WHERE u.login = ?1 AND ce.id = ?2")
    @Override
    Optional<ContactEmail> findOneForLogin (String login, Long id);

    @Query("SELECT DISTINCT ce FROM ContactEmail ce JOIN ce.email e JOIN e.userEmails ue JOIN ue.user u WHERE u.login = ?1")
    @Override
    Set<ContactEmail> findAllForLogin (String login);
}
