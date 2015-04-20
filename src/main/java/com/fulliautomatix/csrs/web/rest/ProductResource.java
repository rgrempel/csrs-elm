package com.fulliautomatix.csrs.web.rest;

import com.codahale.metrics.annotation.Timed;
import com.fasterxml.jackson.annotation.*;

import com.fulliautomatix.csrs.domain.*;
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
 * REST controller for managing Products.
 */
@RestController
@RequestMapping("/api")
@RolesAllowed(AuthoritiesConstants.USER)
public class ProductResource {
    private final Logger log = LoggerFactory.getLogger(ProductResource.class);

    @Inject
    ProductRepository productRepository;

    /**
     * GET  /products -> get all the products.
     */
    @RequestMapping(
        value = "/products",
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
            Hibernate.initialize(product.getProductPrereqRequires());
            Hibernate.initialize(product.getProductPrereqRequiredBy());
            
            product.getProductVariants().stream().forEach((pv) -> {
                Hibernate.initialize(pv.getProductVariantPrices());

                pv.getProductVariantValues().stream().forEach((pvv) -> {
                    ProductValue productValue = pvv.getProductValue();

                    Hibernate.initialize(productValue.getProductValueImplies());
                    Hibernate.initialize(productValue.getProductValueImpliedBy());

                    ProductVariable productVariable = productValue.getProductVariable();
                    Hibernate.initialize(productVariable.getProductValues());
                });
            });
        });

        return new ResponseEntity<>(products, HttpStatus.OK);
    }
}
