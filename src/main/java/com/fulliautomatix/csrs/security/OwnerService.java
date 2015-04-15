package com.fulliautomatix.csrs.security;

import org.springframework.stereotype.Service;
import org.springframework.security.access.AccessDeniedException;

import com.fulliautomatix.csrs.domain.HasOwner;
import com.fulliautomatix.csrs.domain.Contact;
import com.fulliautomatix.csrs.repository.ContactRepository;
import com.fulliautomatix.csrs.repository.FindsForLogin;

import javax.inject.Inject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.Serializable;
import java.util.*;
import java.util.stream.*;

@Service
public class OwnerService {
    private final Logger log = LoggerFactory.getLogger(OwnerService.class);

    @Inject
    private ContactRepository contactRepository;

    @Inject
    private SecurityUtils securityUtils;

    public void checkNewOwner (HasOwner object) {
        if (securityUtils.isUserInRole(AuthoritiesConstants.ADMIN)) return;

        Set<Long> contactIds = object.findOwners().stream().map(Contact::getId).collect(Collectors.toSet());
        if (contactIds.isEmpty()) {
            throw new AccessDeniedException("Not permitted for this user.");
        }

        Set<Contact> authorized = contactRepository.findAllForLogin(securityUtils.getCurrentLogin(), contactIds);
        if (authorized.isEmpty()) {
            throw new AccessDeniedException("Not permitted for this user.");
        }
    }

    public <T, PK extends Serializable> void checkOldOwner (FindsForLogin<T, PK> repository, PK key) {
        if (securityUtils.isUserInRole(AuthoritiesConstants.ADMIN)) return;
        
        findOneForLogin(repository, key).orElseThrow(() -> {
            return new AccessDeniedException("Not allowed for this user.");
        });
    }

    public <T, PK extends Serializable> Optional<T> findOneForLogin (FindsForLogin<T, PK> repository, PK key) {
        if (securityUtils.isUserInRole(AuthoritiesConstants.ADMIN)) {
            return Optional.ofNullable(repository.findOne(key));
        } else {
            return repository.findOneForLogin(securityUtils.getCurrentLogin(), key);
        }
    }

    public <T, PK extends Serializable> Collection<T> findAllForLogin (FindsForLogin<T, PK> repository) {
        if (securityUtils.isUserInRole(AuthoritiesConstants.ADMIN)) {
            return repository.findAll();
        } else {
            return repository.findAllForLogin(securityUtils.getCurrentLogin());
        }
    }
}
