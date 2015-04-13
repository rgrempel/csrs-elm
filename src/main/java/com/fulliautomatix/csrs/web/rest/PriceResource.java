package com.fulliautomatix.csrs.web.rest;

import com.codahale.metrics.annotation.Timed;
import com.fasterxml.jackson.annotation.*;

import com.fulliautomatix.csrs.domain.Product;
import com.fulliautomatix.csrs.repository.ProductRepository;
import com.fulliautomatix.csrs.security.AuthoritiesConstants;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.http.*;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.annotation.*;
import org.springframework.transaction.annotation.Transactional;

import org.hibernate.Hibernate;

import javax.validation.Valid;
import javax.annotation.security.RolesAllowed;
import javax.inject.Inject;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.*;

/**
 * REST controller for managing Prices.
 */
@RestController
@RequestMapping("/api")
public class PriceResource {
    private final Logger log = LoggerFactory.getLogger(PriceResource.class);

    @Inject
    ProductRepository productRepository;

    /**
     * GET  /prices -> get all the prices.
     */
    @RequestMapping(
        value = "/prices",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @RolesAllowed(AuthoritiesConstants.USER)
    @Transactional(readOnly = true)
    @JsonView(Product.DeepTree.class)
    public ResponseEntity<List<Product>> getAll () throws URISyntaxException {
        List<Product> products = productRepository.findAll();

        products.stream().forEach((product) -> {
            product.getProductCategories().stream().forEach((productCategory) -> {
                Hibernate.initialize(productCategory.getProductCategoriesImplies());
                Hibernate.initialize(productCategory.getProductCategoriesImpliedBy());
                Hibernate.initialize(productCategory.getProductCategoryPrices());
            });
        });

        return new ResponseEntity<>(products, HttpStatus.OK);
    }
}
