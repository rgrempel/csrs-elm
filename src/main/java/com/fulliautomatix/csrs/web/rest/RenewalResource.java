package com.fulliautomatix.csrs.web.rest;

import com.codahale.metrics.annotation.Timed;
import com.fasterxml.jackson.annotation.*;
import com.fulliautomatix.csrs.domain.Renewal;
import com.fulliautomatix.csrs.repository.RenewalRepository;
import com.fulliautomatix.csrs.web.rest.util.PaginationUtil;
import com.fulliautomatix.csrs.security.AuthoritiesConstants;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.inject.Inject;
import javax.validation.Valid;
import javax.annotation.security.RolesAllowed;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.List;
import java.util.Optional;

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

    /**
     * POST  /renewals -> Create a new renewal.
     */
    @RequestMapping(
        value = "/renewals",
        method = RequestMethod.POST,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    public ResponseEntity<Void> create (@Valid @RequestBody Renewal renewal) throws URISyntaxException {
        log.debug("REST request to save Renewal : {}", renewal);

        if (renewal.getId() != null) {
            return ResponseEntity.badRequest().header("Failure", "A new renewal cannot already have an ID").build();
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
    public ResponseEntity<Void> update (@RequestBody Renewal renewal) throws URISyntaxException {
        log.debug("REST request to update Renewal : {}", renewal);

        if (renewal.getId() == null) {
            return create(renewal);
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
    @JsonView(Renewal.WithContact.class)
    public ResponseEntity<List<Renewal>> getAll(@RequestParam(value = "page" , required = false) Integer offset,
                                  @RequestParam(value = "per_page", required = false) Integer limit)
        throws URISyntaxException {
        Page<Renewal> page = renewalRepository.findAll(PaginationUtil.generatePageRequest(offset, limit));
        HttpHeaders headers = PaginationUtil.generatePaginationHttpHeaders(page, "/api/renewals", offset, limit);
        return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
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
    public ResponseEntity<Renewal> get (@PathVariable Long id) {
        log.debug("REST request to get Renewal : {}", id);

        return Optional.ofNullable(
            renewalRepository.findOne(id)
        ).map(
            renewal -> new ResponseEntity<>(renewal, HttpStatus.OK)
        ).orElse(
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
        renewalRepository.delete(id);
    }
}
