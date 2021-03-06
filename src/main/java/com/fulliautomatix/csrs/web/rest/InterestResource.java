package com.fulliautomatix.csrs.web.rest;

import com.codahale.metrics.annotation.Timed;
import com.fasterxml.jackson.annotation.*;
import com.fulliautomatix.csrs.domain.Interest;
import com.fulliautomatix.csrs.domain.Contact;
import com.fulliautomatix.csrs.repository.InterestRepository;
import com.fulliautomatix.csrs.repository.ContactRepository;
import com.fulliautomatix.csrs.security.AuthoritiesConstants;
import com.fulliautomatix.csrs.security.OwnerService;
import com.fulliautomatix.csrs.web.rest.util.PaginationUtil;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.data.domain.Page;
import org.springframework.http.*;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.annotation.*;
import org.springframework.transaction.annotation.Transactional;

import javax.validation.Valid;
import javax.annotation.security.RolesAllowed;
import javax.inject.Inject;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.*;

/**
 * REST controller for managing Interest.
 */
@RestController
@RequestMapping("/api")
@RolesAllowed(AuthoritiesConstants.USER)
public class InterestResource {

    private final Logger log = LoggerFactory.getLogger(InterestResource.class);

    @Inject
    private InterestRepository interestRepository;

    @Inject
    private ContactRepository contactRepository;

    @Inject
    private OwnerService ownerService;

    /**
     * POST  /interests -> Create a new interest.
     */
    @RequestMapping(
        value = "/interests",
        method = RequestMethod.POST,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @Transactional
    public ResponseEntity<Void> create (@Valid @RequestBody Interest interest) throws URISyntaxException {
        log.debug("REST request to save Interest : {}", interest);

        if (interest.getId() != null) {
            return ResponseEntity.badRequest().header("Failure", "A new interest cannot already have an ID").build();
        }

        ownerService.checkNewOwner(interest);

        interest = interestRepository.save(interest);
        return ResponseEntity.created(new URI("/api/interests/" + interest.getId())).build();
    }

    /**
     * PUT  /interests -> Updates an existing interest.
     */
    @RequestMapping(
        value = "/interests",
        method = RequestMethod.PUT,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @Transactional
    public ResponseEntity<Void> update (@Valid @RequestBody Interest interest) throws URISyntaxException {
        log.debug("REST request to update Interest : {}", interest);
        
        if (interest.getId() == null) {
            return ResponseEntity.badRequest().header("Failure", "An updated interest must already have an ID").build();
        }

        ownerService.checkOldOwner(interestRepository, interest.getId());
        ownerService.checkNewOwner(interest);

        interest = interestRepository.save(interest);
        return ResponseEntity.ok().build();
    }

    /**
     * GET  /interests -> get all the interests.
     */
    @RequestMapping(
        value = "/interests",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE)
    @Timed
    @RolesAllowed(AuthoritiesConstants.ADMIN)
    @JsonView(Interest.WithContact.class)
    @Transactional(readOnly = true)
    public ResponseEntity<List<Interest>> getAll () throws URISyntaxException {
        List<Interest> interests = interestRepository.findAll();
        return new ResponseEntity<>(interests, HttpStatus.OK);
    }

    /**
     * GET  /interests/:id -> get the "id" interest.
     */
    @RequestMapping(
        value = "/interests/{id}",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @JsonView(Interest.WithContact.class)
    @Transactional(readOnly = true)
    public ResponseEntity<Interest> get (@PathVariable Long id) {
        log.debug("REST request to get Interest : {}", id);
        
        return ownerService.findOneForLogin(interestRepository, id).map(interest ->
            new ResponseEntity<>(interest, HttpStatus.OK)
        ).orElse(
            new ResponseEntity<>(HttpStatus.NOT_FOUND)
        );
    }

    /**
     * DELETE  /interests/:id -> delete the "id" interest.
     */
    @RequestMapping(
        value = "/interests/{id}",
        method = RequestMethod.DELETE,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    public void delete (@PathVariable Long id) {
        log.debug("REST request to delete Interest : {}", id);

        ownerService.checkOldOwner(interestRepository, id);

        interestRepository.delete(id);
    }
}
