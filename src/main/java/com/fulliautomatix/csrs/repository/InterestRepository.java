package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.Interest;
import org.springframework.data.jpa.repository.*;

import java.util.*;

/**
 * Spring Data JPA repository for the Interest entity.
 */
public interface InterestRepository extends FindsForLogin<Interest,Long> {

    @Query("SELECT DISTINCT i FROM Interest i JOIN i.contact c JOIN c.contactEmails ce JOIN ce.email e JOIN e.userEmails ue JOIN ue.user u WHERE u.login = ?1 AND i.id = ?2")
    @Override
    Optional<Interest> findOneForLogin (String login, Long id);

    @Query("SELECT DISTINCT i FROM Interest i JOIN i.contact c JOIN c.contactEmails ce JOIN ce.email e JOIN e.userEmails ue JOIN ue.user u WHERE u.login = ?1")
    @Override
    Set<Interest> findAllForLogin (String login);

}
