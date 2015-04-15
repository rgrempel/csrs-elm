package com.fulliautomatix.csrs.web.rest;

import com.codahale.metrics.annotation.Timed;
import com.fasterxml.jackson.annotation.*;
import com.fulliautomatix.csrs.domain.ContactEmail;
import com.fulliautomatix.csrs.domain.Contact;
import com.fulliautomatix.csrs.domain.Email;
import com.fulliautomatix.csrs.repository.ContactEmailRepository;
import com.fulliautomatix.csrs.repository.EmailRepository;
import com.fulliautomatix.csrs.repository.ContactRepository;
import com.fulliautomatix.csrs.security.AuthoritiesConstants;
import com.fulliautomatix.csrs.security.OwnerService;
import com.fulliautomatix.csrs.web.rest.util.PaginationUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.http.*;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import javax.annotation.security.RolesAllowed;
import javax.inject.Inject;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.*;

/**
 * REST controller for managing ContactEmail.
 */
@RestController
@RequestMapping("/api")
@RolesAllowed(AuthoritiesConstants.USER)
public class ContactEmailResource {

    private final Logger log = LoggerFactory.getLogger(ContactEmailResource.class);

    @Inject
    private ContactEmailRepository contactEmailRepository;

    @Inject
    private ContactRepository contactRepository;

    @Inject
    private EmailRepository emailRepository;

    @Inject
    private OwnerService ownerService;

    public Email findOrSaveEmail (Email email) {
        // We only need to check if it doesn't have one already
        if (email.getId() != null) return email;

        return emailRepository.findOneByEmailAddress(email.getEmailAddress()).orElseGet(() -> {
            // We just have to save it ... 
            Email saved = emailRepository.save(email);
            return saved;
        });
    }

    /**
     * POST  /contactEmails -> Create a new contactEmail.
     */
    @RequestMapping(
        value = "/contactEmails",
        method = RequestMethod.POST,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @Transactional
    public ResponseEntity<Void> create (@Valid @RequestBody ContactEmail contactEmail) throws URISyntaxException {
        log.debug("REST request to save ContactEmail : {}", contactEmail);

        if (contactEmail.getId() != null) {
            return ResponseEntity.badRequest().header("Failure", "A new contactEmail cannot already have an ID").build();
        }

        ownerService.checkNewOwner(contactEmail);

        // Make sure that the email is de-duped
        contactEmail.setEmail(findOrSaveEmail(contactEmail.getEmail()));
        contactEmail = contactEmailRepository.save(contactEmail);

        // Now, let's assume that the new email is also the preferred one ...
        // need to actually manage this yet.
        Contact contact = contactRepository.findOne(contactEmail.getContact().getId());
        contact.setPreferredEmail(contactEmail.getEmail());
        contact = contactRepository.save(contact);

        return ResponseEntity.created(new URI("/api/contactEmails/" + contactEmail.getId())).build();
    }

    /**
     * GET  /contactEmails -> get all the contactEmails.
     */
    @RequestMapping(
        value = "/contactEmails",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @RolesAllowed(AuthoritiesConstants.ADMIN)
    @JsonView(ContactEmail.WithEverything.class)
    public ResponseEntity<List<ContactEmail>> getAll () throws URISyntaxException {
        List<ContactEmail> contactEmails = contactEmailRepository.findAll();
        return new ResponseEntity<>(contactEmails, HttpStatus.OK);
    }

    /**
     * GET  /contactEmails/:id -> get the "id" contactEmail.
     */
    @RequestMapping(
        value = "/contactEmails/{id}",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @JsonView(ContactEmail.WithEverything.class)
    @Transactional(readOnly = true)
    public ResponseEntity<ContactEmail> get (@PathVariable Long id) {
        log.debug("REST request to get ContactEmail : {}", id);
        
        return ownerService.findOneForLogin(contactEmailRepository, id).map(contactEmail ->
            new ResponseEntity<>(contactEmail, HttpStatus.OK)
        ).orElse(
            new ResponseEntity<>(HttpStatus.NOT_FOUND)
        );
    }

    /**
     * DELETE  /contactEmails/:id -> delete the "id" contactEmail.
     */
    @RequestMapping(
        value = "/contactEmails/{id}",
        method = RequestMethod.DELETE,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @Transactional
    public void delete (@PathVariable Long id) {
        log.debug("REST request to delete ContactEmail : {}", id);

        ownerService.checkOldOwner(contactEmailRepository, id);

        // Need to deal with preferred email id issue when deleting ...

        contactEmailRepository.delete(id);
    }
}
