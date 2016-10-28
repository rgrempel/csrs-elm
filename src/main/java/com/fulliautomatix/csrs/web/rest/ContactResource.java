package com.fulliautomatix.csrs.web.rest;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import javax.annotation.security.RolesAllowed;
import javax.inject.Inject;
import javax.validation.Valid;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.codahale.metrics.annotation.Timed;
import com.fasterxml.jackson.annotation.JsonView;
import com.fulliautomatix.csrs.domain.Contact;
import com.fulliautomatix.csrs.domain.User;
import com.fulliautomatix.csrs.domain.ContactEmail;
import com.fulliautomatix.csrs.domain.SentEmail;
import com.fulliautomatix.csrs.repository.ContactEmailRepository;
import com.fulliautomatix.csrs.repository.ContactRepository;
import com.fulliautomatix.csrs.repository.EmailRepository;
import com.fulliautomatix.csrs.repository.UserRepository;
import com.fulliautomatix.csrs.security.AuthoritiesConstants;
import com.fulliautomatix.csrs.security.OwnerService;
import com.fulliautomatix.csrs.security.SecurityUtils;
import com.fulliautomatix.csrs.service.LazyService;
import com.fulliautomatix.csrs.specification.ContactSpec;
import com.fulliautomatix.csrs.specification.Filter;

/**
 * REST controller for managing Contact.
 */
@RestController
@RequestMapping("/api")
@RolesAllowed(AuthoritiesConstants.ADMIN)
public class ContactResource {

    private final Logger log = LoggerFactory.getLogger(ContactResource.class);

    @Inject
    private ContactRepository contactRepository;

    @Inject
    private EmailRepository emailRepository;

    @Inject
    private ContactEmailRepository contactEmailRepository;

    @Inject
    private UserRepository userRepository;

    @Inject
    private OwnerService ownerService;

    @Inject
    private LazyService lazyService;

    @Inject
    private SecurityUtils securityUtils;

    /**
     * POST  /contacts -> Create a new contact.
     */
    @RequestMapping(
        value = "/contacts",
        method = RequestMethod.POST,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    public ResponseEntity<Void> create (@RequestBody @Valid Contact contact) throws URISyntaxException {
        log.debug("REST request to save Contact : {}", contact);

        if (contact.getId() != null) {
            return ResponseEntity.badRequest().header("Failure", "A new contact cannot already have an ID").build();
        }

        contact = contactRepository.save(contact);

        return ResponseEntity.created(new URI("/api/contacts/" + contact.getId())).build();
    }

    /**
     * POST  /account/contacts -> Create a new contact for tne current user
     */
    @RequestMapping(
        value = "/account/contacts",
        method = RequestMethod.POST,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @RolesAllowed(AuthoritiesConstants.USER)
    @Transactional
    public ResponseEntity<Void> createForUser (@RequestBody @Valid Contact contact) throws URISyntaxException {
        log.debug("REST request to save Contact for account : {}", contact);

        if (contact.getId() != null) {
            return ResponseEntity.badRequest().header("Failure", "A new contact cannot already have an ID").build();
        }

        final Contact saved = contactRepository.save(contact);

        // Hook up all the emails ...
        emailRepository.findAllForLogin(securityUtils.getCurrentLogin()).stream().forEach(e -> {
            ContactEmail ce = new ContactEmail();
            ce.setEmail(e);
            ce.setContact(saved);
            contactEmailRepository.save(ce);
        });

        return ResponseEntity.created(new URI("/api/contacts/" + contact.getId())).build();
    }

    /**
     * PUT  /contacts -> Updates an existing contact.
     */
    @RequestMapping(
        value = "/contacts",
        method = RequestMethod.PUT,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    public ResponseEntity<Void> update(@Valid @RequestBody Contact contact) throws URISyntaxException {
        log.debug("REST request to update Contact : {}", contact);

        if (contact.getId() == null) {
            return ResponseEntity.badRequest().header("Failure", "An existing must already have an ID").build();
        }

        contact = contactRepository.save(contact);
        return ResponseEntity.ok().build();
    }

    /**
     * PUT  /account/contacts -> Updates an existing contact for the user
     */
    @RequestMapping(
        value = "/account/contacts",
        method = RequestMethod.PUT,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @RolesAllowed(AuthoritiesConstants.USER)
    public ResponseEntity<Void> updateForUser (@Valid @RequestBody Contact contact) throws URISyntaxException {
        log.debug("REST request to update Contact : {}", contact);

        if (contact.getId() == null) {
            return ResponseEntity.badRequest().header("Failure", "An existing must already have an ID").build();
        }

        ownerService.checkOldOwner(contactRepository, contact.getId());
        ownerService.checkNewOwner(contact);

        contact = contactRepository.save(contact);

        return ResponseEntity.ok().build();
    }

    /**
     * PUT  /account/contacts/mark-verified/:id -> mark the "id" contact as verified.
     */
    @RequestMapping(
        value = "/account/contacts/mark-verified/{id:\\d+}",
        method = RequestMethod.PUT,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @RolesAllowed(AuthoritiesConstants.USER)
    public ResponseEntity<Void> markVerified(@PathVariable Long id) {
        log.debug("REST request to markVerified Contact : {}", id);

        return ownerService.findOneForLogin(
            contactRepository, id
        ).map((contact) -> {
            contact.markVerified();
            contactRepository.save(contact);
            return ResponseEntity.ok().build();
        }).orElse(
            new ResponseEntity<>(HttpStatus.NOT_FOUND)
        );
    }

    /**
     * GET  /contacts get all the contacts.
     */
    @RequestMapping(
        value = "/contacts",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @JsonView(Contact.WithAnnuals.class)
    @RolesAllowed(AuthoritiesConstants.ADMIN)
    @Transactional(readOnly=true)
    public ResponseEntity<Collection<Contact>> getAll (
        @RequestParam(value = "yr", required = false) Set<Integer> yearsRequired,
        @RequestParam(value = "yf", required = false) Set<Integer> yearsForbidden
    ) throws URISyntaxException {
        // TODO: This is actually now really members ...
        Collection<Contact> contacts = contactRepository.findAll(
            new ContactSpec.WasMember(yearsRequired, yearsForbidden)
        );

        lazyService.initializeForJsonView(contacts, Contact.WithAnnuals.class);
        return new ResponseEntity<>(contacts, HttpStatus.OK);
    }

    /**
     * Filter ...
     */
    @RequestMapping(
        value = "/contacts/filter",
        method = RequestMethod.POST,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @JsonView(Contact.WithAnnuals.class)
    @RolesAllowed(AuthoritiesConstants.ADMIN)
    @Transactional(readOnly=true)
    public ResponseEntity<Collection<Contact>> filter (@RequestBody Filter<Contact> filter) throws URISyntaxException {
        log.debug("REST filter request");

        Collection<Contact> contacts = contactRepository.findAll(filter.getSpec());
        lazyService.initializeForJsonView(contacts, Contact.WithAnnuals.class);
        return new ResponseEntity<>(contacts, HttpStatus.OK);
    }

    /**
     * GET  /account/contacts (all the contacts which this account is entitled to edit)
     */
    @RequestMapping(
        value = "/account/contacts",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @RolesAllowed(AuthoritiesConstants.USER)
    @JsonView(Contact.WithEverything.class)
    @Transactional(readOnly = true)
    public ResponseEntity<Set<Contact>> getAllForAccount () throws URISyntaxException {
        String login = securityUtils.getCurrentLogin();
        Set<Contact> contacts = contactRepository.findAllForLogin(login);
        lazyService.initializeForJsonView(contacts, Contact.WithEverything.class);

        return new ResponseEntity<>(contacts, HttpStatus.OK);
    }

    /**
     * GET  /contacts/:id/users
     *
     * All the users who are associated with this contact.
     */
    @RequestMapping(
        value = "/contacts/{id:\\d+}/users",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @RolesAllowed(AuthoritiesConstants.ADMIN)
    @JsonView(User.Scalar.class)
    @Transactional(readOnly = true)
    public ResponseEntity<Set<User>> getUsersForContact (@PathVariable Long id) throws URISyntaxException {
        log.debug("Users associated with contact");
        return new ResponseEntity<>(userRepository.usersForContact(id), HttpStatus.OK);
    }

    /**
     * GET  /contacts/:id/email
     *
     * All the email sent to an address associated with this contact.
     */
    @RequestMapping(
        value = "/contacts/{id:\\d+}/email",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @RolesAllowed(AuthoritiesConstants.ADMIN)
    @JsonView(SentEmail.Scalar.class)
    @Transactional(readOnly = true)
    public ResponseEntity<List<SentEmail>> getSentEmailForContact (@PathVariable Long id) throws URISyntaxException {
        log.debug("Sent Email associated with contact");
        return new ResponseEntity<>(contactRepository.emailSentToContact(id), HttpStatus.OK);
    }
    
    /**
     * GET  /contacts?fullNameSearch=bob -> do a fullNameSearch.
     */
    @RequestMapping(
        value = "/contacts",
        params = "fullNameSearch",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @JsonView(Contact.WithAnnuals.class)
    @Transactional(readOnly = true)
    public ResponseEntity<List<Contact>> getAll (@RequestParam(value = "fullNameSearch") String search) throws URISyntaxException {
        List<Contact> contacts = contactRepository.searchByFullNameLikeLower(("%" + search + "%"));
        lazyService.initializeForJsonView(contacts, Contact.WithAnnuals.class);

        return new ResponseEntity<>(contacts, HttpStatus.OK);
    }

    /**
     * GET  /contacts/:id -> get the "id" contact with annuals
     */
    @RequestMapping(
        value = "/contacts/{id:\\d+}",
        params = "withAnnualsAndInterests",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @JsonView(Contact.WithEverything.class)
    @Transactional(readOnly = true)
    public ResponseEntity<Contact> getWithAnnualsAndInterestsAndEmail (@PathVariable Long id) {
        log.debug("REST request to get Contact : {}", id);
        return Optional.ofNullable(
            contactRepository.findOneWithAnnualsAndInterestsAndEmail(id)
        ).map((contact) -> {
            lazyService.initializeForJsonView(contact, Contact.WithEverything.class);
            return new ResponseEntity<>(contact, HttpStatus.OK);
        }).orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }
    /**
     * GET  /contacts/:id -> get the "id" contact.
     */
    @RequestMapping(
        value = "/contacts/{id:\\d+}",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @JsonView(Contact.WithEverything.class)
    @Transactional(readOnly=true)
    public ResponseEntity<Contact> get(@PathVariable Long id) {
        log.debug("REST request to get Contact : {}", id);
        return Optional.ofNullable(
            contactRepository.findOne(id)
        ).map((contact) -> {
            lazyService.initializeForJsonView(contact, Contact.WithEverything.class);
            return new ResponseEntity<>(contact, HttpStatus.OK);
        }).orElse(
            new ResponseEntity<>(HttpStatus.NOT_FOUND)
        );
    }

    /**
     * DELETE  /contacts/:id -> delete the "id" contact.
     */
    @RequestMapping(
        value = "/contacts/{id:\\d+}",
        method = RequestMethod.DELETE,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    public void delete(@PathVariable Long id) {
        log.debug("REST request to delete Contact : {}", id);
        contactRepository.delete(id);
    }
}
