package com.fulliautomatix.csrs.web.template;

import com.codahale.metrics.annotation.Timed;
import com.fasterxml.jackson.annotation.*;
import com.fulliautomatix.csrs.domain.Contact;
import com.fulliautomatix.csrs.specification.ContactWasMember;
import com.fulliautomatix.csrs.repository.ContactRepository;
import com.fulliautomatix.csrs.web.rest.util.ResourceNotFoundException;
import com.fulliautomatix.csrs.security.AuthoritiesConstants;
import com.fulliautomatix.csrs.security.OwnerService;
import com.fulliautomatix.csrs.service.LazyService;
import com.fulliautomatix.csrs.service.PDFService;
import com.fulliautomatix.csrs.service.UserService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.hibernate.Hibernate;
import org.springframework.data.domain.Page;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.thymeleaf.context.Context;
import org.thymeleaf.spring4.SpringTemplateEngine;

import javax.inject.Inject;
import javax.validation.Valid;
import javax.annotation.security.RolesAllowed;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.*;
import java.io.*;

/**
 * Letters
 */
@Controller
@RolesAllowed(AuthoritiesConstants.ADMIN)
public class LetterController {
    private final Logger log = LoggerFactory.getLogger(LetterController.class);

    @Inject
    private PDFService pdfService;

    @Inject
    private ContactRepository contactRepository;

    @Inject
    private LazyService lazyService;

    /**
     * GET  /letters/{template}.pdf 
     */
    @RequestMapping(
        value = "/letters/{template}.pdf",
        method = RequestMethod.GET,
        produces = "application/pdf" 
    )
    @Timed
    @Transactional(readOnly = true)
    public void getLetter (
        @PathVariable String template,
        @RequestParam(value = "yr", required = false) Set<Integer> yearsRequired,
        @RequestParam(value = "yf", required = false) Set<Integer> yearsForbidden,
        OutputStream output
    ) throws Exception {
        log.debug("Request to produce PDF letter for : {} with yr = {} and yf = {}", template, yearsRequired, yearsForbidden);

        Collection<Contact> contacts = contactRepository.findAll(
            new ContactWasMember(yearsRequired, yearsForbidden)
        );
        lazyService.initializeForJsonView(contacts, Contact.WithAnnuals.class);

        Locale locale = Locale.forLanguageTag("en");
        Context context = new Context();
        context.setVariable("contacts", contacts); 

        pdfService.createPDF(output, context, template);
    }
}
