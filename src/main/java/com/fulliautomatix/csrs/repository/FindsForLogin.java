package com.fulliautomatix.csrs.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.NoRepositoryBean;
import java.io.Serializable;
import java.util.*;

@NoRepositoryBean
public interface FindsForLogin<T, PK extends Serializable> extends JpaRepository<T, PK> {
    Optional<T> findOneForLogin (String login, PK id);

    Set<T> findAllForLogin (String login);
}
