package com.fulliautomatix.csrs.web.rest;

import com.codahale.metrics.annotation.Timed;
import com.fulliautomatix.csrs.domain.Contact;
import com.fulliautomatix.csrs.repository.ContactRepository;
import com.fulliautomatix.csrs.security.AuthoritiesConstants;
import com.fulliautomatix.csrs.web.rest.util.PaginationUtil;
import com.fulliautomatix.csrs.web.rest.util.ValidationException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.validation.Errors;

import javax.validation.Valid;
import javax.annotation.security.RolesAllowed;
import javax.inject.Inject;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.List;
import java.util.Optional;

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

    /**
     * POST  /contacts -> Create a new contact.
     */
    @RequestMapping(
        value = "/contacts",
        method = RequestMethod.POST,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    public ResponseEntity<Void> create (@RequestBody @Valid Contact contact, Errors errors) throws URISyntaxException {
        log.debug("REST request to save Contact : {}", contact);

        if (contact.getId() != null) {
            return ResponseEntity.badRequest().header("Failure", "A new contact cannot already have an ID").build();
        }

        if (errors.hasErrors()) {
            throw new ValidationException("Contact failed validation", errors);
        }

        contactRepository.save(contact);
        
        return ResponseEntity.created(new URI("/api/contacts/" + contact.getId())).build();
    }

    /**
     * PUT  /contacts -> Updates an existing contact.
     */
    @RequestMapping(value = "/contacts",
        method = RequestMethod.PUT,
        produces = MediaType.APPLICATION_JSON_VALUE)
    @Timed
    public ResponseEntity<Void> update(@RequestBody Contact contact) throws URISyntaxException {
        log.debug("REST request to update Contact : {}", contact);
        if (contact.getId() == null) {
            return ResponseEntity.badRequest().header("Failure", "An existing must already have an ID").build();
        }
        contactRepository.save(contact);
        return ResponseEntity.ok().build();
    }

    /**
     * GET  /contacts -> get all the contacts.
     */
    @RequestMapping(value = "/contacts",
            method = RequestMethod.GET,
            produces = MediaType.APPLICATION_JSON_VALUE)
    @Timed
    public ResponseEntity<List<Contact>> getAll(@RequestParam(value = "page" , required = false) Integer offset,
                                  @RequestParam(value = "per_page", required = false) Integer limit)
        throws URISyntaxException {
        Page<Contact> page = contactRepository.findAll(PaginationUtil.generatePageRequest(offset, limit));
        HttpHeaders headers = PaginationUtil.generatePaginationHttpHeaders(page, "/api/contacts", offset, limit);
        return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);
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
    public ResponseEntity<List<Contact>> getAll (
        @RequestParam(value = "page" , required = false) Integer offset,
        @RequestParam(value = "per_page", required = false) Integer limit,
        @RequestParam(value = "fullNameSearch") String search
    ) throws URISyntaxException {
//      Page<Contact> page = contactRepository.searchByFullName(search.toLowerCase(), PaginationUtil.generatePageRequest(offset, limit));
//      HttpHeaders headers = PaginationUtil.generatePaginationHttpHeaders(page, "/api/contacts", offset, limit);
//      return new ResponseEntity<>(page.getContent(), headers, HttpStatus.OK);

        List<Contact> contacts = contactRepository.searchByFullNameLikeLower((search + "%").toLowerCase());
        return new ResponseEntity<List<Contact>>(contacts, HttpStatus.OK);
    }
    
    /**
     * GET  /contacts/:id -> get the "id" contact with annuals
     */
    @RequestMapping(value = "/contacts/{id}",
            params = "withAnnualsAndInterests",
            method = RequestMethod.GET,
            produces = MediaType.APPLICATION_JSON_VALUE)
    @Timed
    public ResponseEntity<Contact> getWithAnnuals(@PathVariable Long id) {
        log.debug("REST request to get Contact : {}", id);
        return Optional.ofNullable(contactRepository.findOneWithAnnualsAndInterests(id))
            .map(contact -> new ResponseEntity<>(
                contact,
                HttpStatus.OK))
            .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }
    /**
     * GET  /contacts/:id -> get the "id" contact.
     */
    @RequestMapping(value = "/contacts/{id}",
            method = RequestMethod.GET,
            produces = MediaType.APPLICATION_JSON_VALUE)
    @Timed
    public ResponseEntity<Contact> get(@PathVariable Long id) {
        log.debug("REST request to get Contact : {}", id);
        return Optional.ofNullable(contactRepository.findOne(id))
            .map(contact -> new ResponseEntity<>(
                contact,
                HttpStatus.OK))
            .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    /**
     * DELETE  /contacts/:id -> delete the "id" contact.
     */
    @RequestMapping(value = "/contacts/{id}",
            method = RequestMethod.DELETE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    @Timed
    public void delete(@PathVariable Long id) {
        log.debug("REST request to delete Contact : {}", id);
        contactRepository.delete(id);
    }
}
