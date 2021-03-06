package com.fulliautomatix.csrs.web.rest;

import com.codahale.metrics.annotation.Timed;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.annotation.*;
import com.fasterxml.jackson.databind.ObjectMapper;

import com.fulliautomatix.csrs.domain.Template;
import com.fulliautomatix.csrs.domain.Operation;
import com.fulliautomatix.csrs.repository.OperationRepository;
import com.fulliautomatix.csrs.repository.TemplateRepository;
import com.fulliautomatix.csrs.security.AuthoritiesConstants;
import com.fulliautomatix.csrs.service.LazyService;

import com.fulliautomatix.csrs.web.rest.util.ResourceNotFoundException;
import com.fulliautomatix.csrs.web.rest.util.MustNotHaveIdException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

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
 * REST controller for managing Template.
 */
@RestController
@RequestMapping("/api")
@RolesAllowed(AuthoritiesConstants.ADMIN)
public class TemplateResource {

    private final Logger log = LoggerFactory.getLogger(TemplateResource.class);

    @Inject
    private ObjectMapper mapper;

    @Inject
    private TemplateRepository templateRepository;

    @Inject
    private OperationRepository operationRepository;

    @Inject
    private LazyService lazyService;
    
    /**
     * POST  /templates  Create a new template.
     */
    @RequestMapping(
        value = "/templates",
        method = RequestMethod.POST,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @Transactional
    @JsonView(Template.WithText.class)
    public ResponseEntity<Template> create (@Valid @RequestBody Template template) throws URISyntaxException, JsonProcessingException {
        log.debug("REST request to save Template : {}", template);

        if (template.getId() != null) {
            throw new MustNotHaveIdException();
        }

        Operation operation = new Operation();
        operation.setOperationType("POST");
        operation.setOperationUrl("/api/templates");
        operation.setOperationBody(
            mapper.writerWithView(
                Template.WithText.class
            ).writeValueAsString(template)
        );
        
        template = templateRepository.save(template);

        operation.setRollbackType("DELETE");
        operation.setRollbackUrl("/api/templates/" + template.getId().toString());
        operationRepository.save(operation);

        // Note that this won't deal with any database-updated stuff aside from
        // the id. So, in some cases, we might have to do something different.
        return new ResponseEntity<>(template, HttpStatus.OK);
    }

    /**
     * PUT  /templates - Updates an existing template.
     */
    @RequestMapping(
        value = "/templates/{id}",
        method = RequestMethod.PUT,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @Transactional
    @JsonView(Template.WithText.class)
    public ResponseEntity<Template> update (@RequestBody Template template, @PathVariable Long id) throws URISyntaxException, JsonProcessingException {
        log.debug("REST request to update Template : {}", template);

        template.setId(id);

        Operation operation = new Operation();
        operation.setOperationType("PUT");
        operation.setOperationUrl("/api/templates/" + id.toString());
        operation.setOperationBody(
            mapper.writerWithView(
                Template.WithText.class
            ).writeValueAsString(template)
        );
        
        Optional.ofNullable(templateRepository.findOne(id)).map((old) -> {
            lazyService.initializeForJsonView(old, Template.WithText.class);
            
            operation.setRollbackType("PUT");
            operation.setRollbackUrl("/api/templates/" + id.toString());
            try {
                operation.setRollbackBody(
                    mapper.writerWithView(
                        Template.WithText.class
                    ).writeValueAsString(old)
                );
            } catch (Exception ex) {
                throw new RuntimeException(ex);
            }

            operationRepository.save(operation);

            return operation;
        }).orElseThrow(() -> new ResourceNotFoundException("template not found"));

        template = templateRepository.save(template);
         
        return new ResponseEntity<>(template, HttpStatus.OK);
    }

    /**
     * GET  /templates get all the templates.
     */
    @RequestMapping(
        value = "/templates",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @JsonView(Template.Scalar.class)
    @Transactional(readOnly = true)
    public ResponseEntity<Collection<Template>> getAll () throws URISyntaxException {
        Collection<Template> templates = templateRepository.findAll();
        lazyService.initializeForJsonView(templates, Template.Scalar.class);

        return new ResponseEntity<>(templates, HttpStatus.OK);
    }

    /**
     * GET  /templates/:id -> get the "id" template.
     */
    @RequestMapping(
        value = "/templates/{id}",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @JsonView(Template.WithText.class)
    @Transactional(readOnly = true)
    public ResponseEntity<Template> get (@PathVariable Long id) {
        log.debug("REST request to get Template : {}", id);

        return templateRepository.findOneById(id).map((template) -> {
            lazyService.initializeForJsonView(template, Template.WithText.class);
            return new ResponseEntity<>(template, HttpStatus.OK);
        }).orElse(
            new ResponseEntity<>(HttpStatus.NOT_FOUND)
        );
    }

    /**
     * DELETE  /templates/:id -> delete the "id" template.
     */
    @RequestMapping(
        value = "/templates/{id}",
        method = RequestMethod.DELETE,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    public void delete (@PathVariable Long id) {
        log.debug("REST request to delete template : {}", id);

        templateRepository.delete(id);
    }
}
