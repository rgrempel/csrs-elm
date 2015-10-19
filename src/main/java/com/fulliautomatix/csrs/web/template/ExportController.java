package com.fulliautomatix.csrs.web.template;

import java.util.Collection;

import javax.annotation.security.RolesAllowed;
import javax.inject.Inject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.codahale.metrics.annotation.Timed;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fulliautomatix.csrs.domain.Contact;
import com.fulliautomatix.csrs.repository.ContactRepository;
import com.fulliautomatix.csrs.security.AuthoritiesConstants;
import com.fulliautomatix.csrs.service.LazyService;
import com.fulliautomatix.csrs.specification.Filter;
import com.fulliautomatix.csrs.web.view.ExcelContacts;

/**
 * Export to excel
 */
@Controller
@RolesAllowed(AuthoritiesConstants.ADMIN)
public class ExportController {
    private final Logger log = LoggerFactory.getLogger(ExportController.class);

    @Inject
    private ContactRepository contactRepository;

    @Inject
    private LazyService lazyService;

    @Inject
    private ObjectMapper objectMapper;

    /**
     * GET  /export/contacts.xls
     */
    @RequestMapping(
        value = "/export/contacts.xls",
        method = RequestMethod.GET
    )
    @Timed
    @Transactional(readOnly = true)
    public ModelAndView exportContacts (
        @RequestParam(value = "filter", required = false) String filterString
    ) throws Exception {
        Collection<Contact> contacts = contactRepository.findAll(
            objectMapper.readValue(filterString, Filter.class).getSpec()
        );
        lazyService.initializeForJsonView(contacts, Contact.WithAnnuals.class);

        return new ModelAndView(new ExcelContacts(), "contacts", contacts);
    }
}
