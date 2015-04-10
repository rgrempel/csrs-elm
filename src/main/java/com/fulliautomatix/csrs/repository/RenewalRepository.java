package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.Renewal;
import org.springframework.data.jpa.repository.*;

import java.util.*;

/**
 * Spring Data JPA repository for the Renewal entity.
 */
public interface RenewalRepository extends FindsForLogin<Renewal, Long> {
    
    @Query("SELECT DISTINCT r FROM Renewal r JOIN r.contact c JOIN c.contactEmails ce JOIN ce.email e JOIN e.userEmails ue JOIN ue.user u WHERE u.login = ?1 AND r.id = ?2")
    @Override
    Optional<Renewal> findOneForLogin (String login, Long id);

    @Query("SELECT DISTINCT r FROM Renewal r JOIN r.contact c JOIN c.contactEmails ce JOIN ce.email e JOIN e.userEmails ue JOIN ue.user u WHERE u.login = ?1")
    @Override
    Set<Renewal> findAllForLogin (String login);

}
