package com.fulliautomatix.csrs.web.template;

import java.io.OutputStream;
import java.util.Collection;
import java.util.Locale;

import javax.annotation.security.RolesAllowed;
import javax.inject.Inject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.thymeleaf.context.Context;

import com.codahale.metrics.annotation.Timed;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fulliautomatix.csrs.domain.Contact;
import com.fulliautomatix.csrs.repository.ContactRepository;
import com.fulliautomatix.csrs.security.AuthoritiesConstants;
import com.fulliautomatix.csrs.service.LazyService;
import com.fulliautomatix.csrs.service.PDFService;
import com.fulliautomatix.csrs.specification.Filter;

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

    @Inject
    private ObjectMapper objectMapper;

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
        @RequestParam(value = "filter", required = false) String filterString,
        OutputStream output
    ) throws Exception {
        Collection<Contact> contacts = contactRepository.findAll(
            objectMapper.readValue(filterString, Filter.class).getSpec()
        );
        lazyService.initializeForJsonView(contacts, Contact.WithAnnuals.class);

        Locale locale = Locale.forLanguageTag("en");
        Context context = new Context();
        context.setVariable("contacts", contacts); 

        pdfService.createPDF(output, context, template);
    }
}
