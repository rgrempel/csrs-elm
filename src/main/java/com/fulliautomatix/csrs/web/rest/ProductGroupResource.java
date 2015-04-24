package com.fulliautomatix.csrs.web.rest;

import com.codahale.metrics.annotation.Timed;
import com.fasterxml.jackson.annotation.*;

import com.fulliautomatix.csrs.domain.*;
import com.fulliautomatix.csrs.repository.ProductGroupRepository;
import com.fulliautomatix.csrs.security.AuthoritiesConstants;
import com.fulliautomatix.csrs.service.LazyService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

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
 * REST controller for managing ProductGroups.
 */
@RestController
@RequestMapping("/api")
@RolesAllowed(AuthoritiesConstants.USER)
public class ProductGroupResource {
    private final Logger log = LoggerFactory.getLogger(ProductGroupResource.class);

    @Inject
    ProductGroupRepository productGroupRepository;

    @Inject
    private LazyService lazyService;
    
    /**
     * GET  /product-groups -> get all the products.
     */
    @RequestMapping(
        value = "/product-groups",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @RolesAllowed(AuthoritiesConstants.USER)
    @Transactional(readOnly=true)
    @JsonView(ProductGroup.DeepTree.class)
    public ResponseEntity<List<ProductGroup>> getAll () throws URISyntaxException {
        List<ProductGroup> productGroups = productGroupRepository.findAll();
        lazyService.initializeForJsonView(productGroups, ProductGroup.DeepTree.class);

        return new ResponseEntity<>(productGroups, HttpStatus.OK);
    }
    
    /**
     * GET  /product-groups/{id}
     */
    @RequestMapping(
        value = "/product-groups/{id}",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @RolesAllowed(AuthoritiesConstants.USER)
    @Transactional(readOnly=true)
    @JsonView(ProductGroup.DeepTree.class)
    public ResponseEntity<ProductGroup> get (@PathVariable Long id) throws URISyntaxException {
        log.debug("REST request to get ProductGroup : {}", id);

        return Optional.ofNullable(
            productGroupRepository.findOne(id)
        ).map((productGroup) -> {
            lazyService.initializeForJsonView(productGroup, ProductGroup.DeepTree.class);
            return new ResponseEntity<>(productGroup, HttpStatus.OK);
        }).orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }
}
