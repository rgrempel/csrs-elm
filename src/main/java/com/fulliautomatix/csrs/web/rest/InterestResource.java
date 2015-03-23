package com.fulliautomatix.csrs.web.rest;

import com.codahale.metrics.annotation.Timed;
import com.fulliautomatix.csrs.domain.Interest;
import com.fulliautomatix.csrs.repository.InterestRepository;
import com.fulliautomatix.csrs.security.AuthoritiesConstants;
import com.fulliautomatix.csrs.web.rest.util.PaginationUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.annotation.security.RolesAllowed;
import javax.inject.Inject;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.List;
import java.util.Optional;

/**
 * REST controller for managing Interest.
 */
@RestController
@RequestMapping("/api")
@RolesAllowed(AuthoritiesConstants.ADMIN)
public class InterestResource {

    private final Logger log = LoggerFactory.getLogger(InterestResource.class);

    @Inject
    private InterestRepository interestRepository;

    /**
     * POST  /interests -> Create a new interest.
     */
    @RequestMapping(value = "/interests",
            method = RequestMethod.POST,
            produces = MediaType.APPLICATION_JSON_VALUE)
    @Timed
    public ResponseEntity<Void> create(@RequestBody Interest interest) throws URISyntaxException {
        log.debug("REST request to save Interest : {}", interest);
        if (interest.getId() != null) {
            return ResponseEntity.badRequest().header("Failure", "A new interest cannot already have an ID").build();
        }
        interestRepository.save(interest);
        return ResponseEntity.created(new URI("/api/interests/" + interest.getId())).build();
    }

    /**
     * PUT  /interests -> Updates an existing interest.
     */
    @RequestMapping(value = "/interests",
        method = RequestMethod.PUT,
        produces = MediaType.APPLICATION_JSON_VALUE)
    @Timed
    public ResponseEntity<Void> update(@RequestBody Interest interest) throws URISyntaxException {
        log.debug("REST request to update Interest : {}", interest);
        if (interest.getId() == null) {
            return create(interest);
        }
        interestRepository.save(interest);
        return ResponseEntity.ok().build();
    }

    /**
     * GET  /interests -> get all the interests.
     */
    @RequestMapping(value = "/interests",
            method = RequestMethod.GET,
            produces = MediaType.APPLICATION_JSON_VALUE)
    @Timed
    public ResponseEntity<List<Interest>> getAll(@RequestParam(value = "page" , required = false) Integer offset,
                                  @RequestParam(value = "per_page", required = false) Integer limit)
        throws URISyntaxException {
        Page<Interest> page = interestRepository.findAll(PaginationUtil.generatePageRequest(offset, limit));
        HttpHeaders headers = PaginationUtil.generatePaginationHttpHeaders(page, "/api/interests", offset, limit);
        return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
    }

    /**
     * GET  /interests/:id -> get the "id" interest.
     */
    @RequestMapping(value = "/interests/{id}",
            method = RequestMethod.GET,
            produces = MediaType.APPLICATION_JSON_VALUE)
    @Timed
    public ResponseEntity<Interest> get(@PathVariable Long id) {
        log.debug("REST request to get Interest : {}", id);
        return Optional.ofNullable(interestRepository.findOne(id))
            .map(interest -> new ResponseEntity<>(
                interest,
                HttpStatus.OK))
            .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    /**
     * DELETE  /interests/:id -> delete the "id" interest.
     */
    @RequestMapping(value = "/interests/{id}",
            method = RequestMethod.DELETE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    @Timed
    public void delete(@PathVariable Long id) {
        log.debug("REST request to delete Interest : {}", id);
        interestRepository.delete(id);
    }
}
