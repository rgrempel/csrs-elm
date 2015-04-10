package com.fulliautomatix.csrs.web.rest;

import com.codahale.metrics.annotation.Timed;
import com.fasterxml.jackson.annotation.*;
import com.fulliautomatix.csrs.domain.Annual;
import com.fulliautomatix.csrs.repository.AnnualRepository;
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
import javax.annotation.security.RolesAllowed;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.List;
import java.util.Optional;

/**
 * REST controller for managing Annual.
 */
@RestController
@RequestMapping("/api")
@RolesAllowed(AuthoritiesConstants.ADMIN)
public class AnnualResource {

    private final Logger log = LoggerFactory.getLogger(AnnualResource.class);

    @Inject
    private AnnualRepository annualRepository;

    /**
     * POST  /annuals -> Create a new annual.
     */
    @RequestMapping(
        value = "/annuals",
        method = RequestMethod.POST,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    public ResponseEntity<Void> create (@RequestBody Annual annual) throws URISyntaxException {
        log.debug("REST request to save Annual : {}", annual);
        if (annual.getId() != null) {
            return ResponseEntity.badRequest().header("Failure", "A new annual cannot already have an ID").build();
        }
        annual = annualRepository.save(annual);
        return ResponseEntity.created(new URI("/api/annuals/" + annual.getId())).build();
    }

    /**
     * PUT  /annuals -> Updates an existing annual.
     */
    @RequestMapping(
        value = "/annuals",
        method = RequestMethod.PUT,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    public ResponseEntity<Void> update(@RequestBody Annual annual) throws URISyntaxException {
        log.debug("REST request to update Annual : {}", annual);
        if (annual.getId() == null) {
            return create(annual);
        }
        annual = annualRepository.save(annual);
        return ResponseEntity.ok().build();
    }

    /**
     * GET  /annuals -> get all the annuals.
     */
    @RequestMapping(
        value = "/annuals",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @JsonView(Annual.WithContact.class)
    public ResponseEntity<List<Annual>> getAll(@RequestParam(value = "page" , required = false) Integer offset,
                                  @RequestParam(value = "per_page", required = false) Integer limit)
        throws URISyntaxException {
        Page<Annual> page = annualRepository.findAll(PaginationUtil.generatePageRequest(offset, limit));
        HttpHeaders headers = PaginationUtil.generatePaginationHttpHeaders(page, "/api/annuals", offset, limit);
        return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
    }

    /**
     * GET  /annuals/:id -> get the "id" annual.
     */
    @RequestMapping(
        value = "/annuals/{id}",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @JsonView(Annual.WithContact.class)
    public ResponseEntity<Annual> get (@PathVariable Long id) {
        log.debug("REST request to get Annual : {}", id);

        return Optional.ofNullable(
            annualRepository.findOne(id)
        ).map(annual -> 
            new ResponseEntity<>(annual, HttpStatus.OK)
        ).orElse(
            new ResponseEntity<>(HttpStatus.NOT_FOUND)
        );
    }

    /**
     * DELETE  /annuals/:id -> delete the "id" annual.
     */
    @RequestMapping(
        value = "/annuals/{id}",
        method = RequestMethod.DELETE,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    public void delete (@PathVariable Long id) {
        log.debug("REST request to delete Annual : {}", id);
        annualRepository.delete(id);
    }
}
