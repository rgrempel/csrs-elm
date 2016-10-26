package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.Email;

import org.joda.time.DateTime;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Set;
import java.util.Optional;

/**
 * Spring Data JPA repository for the Email entity.
 */
public interface EmailRepository extends FindsForLogin<Email, Long> {

    Optional<Email> findOneByEmailAddress (String email);

    @Query("SELECT DISTINCT e FROM Email e JOIN e.userEmails ue JOIN ue.user u WHERE u.login = ?1")
    Set<Email> findAllForLogin (String login);

    @Query("SELECT DISTINCT e FROM Email e JOIN e.userEmails ue JOIN ue.user u WHERE u.login = ?1 AND e.id = ?2")
    @Override
    Optional<Email> findOneForLogin (String login, Long id);

    @Query("SELECT DISTINCT e FROM Email e JOIN e.contactEmails ce JOIN ce.contact c WHERE c.id in ?1 AND NOT EXISTS (SELECT u FROM e.userEmails ue JOIN ue.user u)")
    Set<Email> forExistingContactsWithoutUsers (Set<Long> contactIDs);

}
