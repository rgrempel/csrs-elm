package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.User;

import org.joda.time.DateTime;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import org.springframework.data.jpa.repository.Query;

import java.util.Set;
import java.util.Optional;

/**
 * Spring Data JPA repository for the User entity.
 */
public interface UserRepository extends JpaRepository<User, Long> {

//    Optional<User> findOneByActivationKey(String activationKey);

//    List<User> findAllByActivatedIsFalseAndCreatedDateBefore(DateTime dateTime);

//    Optional<User> findOneByEmail(String email);

    Optional<User> findOneByLogin(String login);

    @Query("SELECT DISTINCT u from User u JOIN u.userEmails ue JOIN ue.email e JOIN e.contactEmails ce JOIN ce.contact c WHERE c.id = ?1")
    Set<User> usersForContact (Long id);

    void delete(User t);

}
