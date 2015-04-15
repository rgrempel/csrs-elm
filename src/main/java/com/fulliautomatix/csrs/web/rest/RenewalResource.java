package com.fulliautomatix.csrs.web.rest;

import com.codahale.metrics.annotation.Timed;
import com.fasterxml.jackson.annotation.*;
import com.fulliautomatix.csrs.domain.Renewal;
import com.fulliautomatix.csrs.repository.RenewalRepository;
import com.fulliautomatix.csrs.web.rest.util.PaginationUtil;
import com.fulliautomatix.csrs.security.AuthoritiesConstants;
import com.fulliautomatix.csrs.security.OwnerService;
import com.fulliautomatix.csrs.service.PriceService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.hibernate.Hibernate;
import org.springframework.data.domain.Page;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.transaction.annotation.Transactional;

import javax.inject.Inject;
import javax.validation.Valid;
import javax.annotation.security.RolesAllowed;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.*;

/**
 * REST controller for managing Renewal.
 */
@RestController
@RequestMapping("/api")
@RolesAllowed(AuthoritiesConstants.ADMIN)
public class RenewalResource {

    private final Logger log = LoggerFactory.getLogger(RenewalResource.class);

    @Inject
    private RenewalRepository renewalRepository;

    @Inject
    private OwnerService ownerService;

    @Inject
    private PriceService priceService;

    /**
     * POST  /renewals -> Create a new renewal.
     */
    @RequestMapping(
        value = "/renewals",
        method = RequestMethod.POST,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @RolesAllowed(AuthoritiesConstants.USER)
    @Transactional
    public ResponseEntity<Void> create (@Valid @RequestBody Renewal renewal) throws URISyntaxException {
        log.debug("REST request to save Renewal : {}", renewal);

        if (renewal.getId() != null) {
            return ResponseEntity.badRequest().header("Failure", "A new renewal cannot already have an ID").build();
        }

        ownerService.checkNewOwner(renewal);

        Integer calculatedPrice = priceService.priceInCentsForRenewal(renewal);
        if (!calculatedPrice.equals(renewal.getPriceInCents())) {
            throw new RuntimeException("Price calculated on server does not match submitted price.");
        }
        
        renewal = renewalRepository.save(renewal);

        return ResponseEntity.created(new URI("/api/renewals/" + renewal.getId())).build();
    }

    /**
     * PUT  /renewals -> Updates an existing renewal.
     */
    @RequestMapping(
        value = "/renewals",
        method = RequestMethod.PUT,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @RolesAllowed(AuthoritiesConstants.USER)
    @Transactional
    public ResponseEntity<Void> update (@RequestBody Renewal renewal) throws URISyntaxException {
        log.debug("REST request to update Renewal : {}", renewal);

        ownerService.checkOldOwner(renewalRepository, renewal.getId());
        ownerService.checkNewOwner(renewal);

        Integer calculatedPrice = priceService.priceInCentsForRenewal(renewal);
        if (!calculatedPrice.equals(renewal.getPriceInCents())) {
            throw new RuntimeException("Price calculated on server does not match submitted price.");
        }

        renewal = renewalRepository.save(renewal);
        
        return ResponseEntity.ok().build();
    }

    /**
     * GET  /renewals -> get all the renewals.
     */
    @RequestMapping(
        value = "/renewals",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @RolesAllowed(AuthoritiesConstants.USER)
    @JsonView(Renewal.WithContact.class)
    @Transactional(readOnly = true)
    public ResponseEntity<Collection<Renewal>> getAll () throws URISyntaxException {
        Collection<Renewal> renewals = ownerService.findAllForLogin(renewalRepository);

        renewals.stream().forEach((renewal) -> {
            Hibernate.initialize(renewal.getContact());
        });

        return new ResponseEntity<>(renewals, HttpStatus.OK);
    }

    /**
     * GET  /renewals/:id -> get the "id" renewal.
     */
    @RequestMapping(
        value = "/renewals/{id}",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @JsonView(Renewal.WithContact.class)
    @Transactional(readOnly = true)
    public ResponseEntity<Renewal> get (@PathVariable Long id) {
        log.debug("REST request to get Renewal : {}", id);

        return ownerService.findOneForLogin(renewalRepository, id).map((renewal) -> {
            Hibernate.initialize(renewal.getContact());
            return new ResponseEntity<>(renewal, HttpStatus.OK);
        }).orElse(
            new ResponseEntity<>(HttpStatus.NOT_FOUND)
        );
    }

    /**
     * DELETE  /renewals/:id -> delete the "id" renewal.
     */
    @RequestMapping(
        value = "/renewals/{id}",
        method = RequestMethod.DELETE,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    public void delete (@PathVariable Long id) {
        log.debug("REST request to delete Renewal : {}", id);

        ownerService.checkOldOwner(renewalRepository, id);

        renewalRepository.delete(id);
    }
}
