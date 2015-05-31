package com.fulliautomatix.csrs.web.template;

import java.io.OutputStream;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import javax.annotation.security.RolesAllowed;
import javax.inject.Inject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.JpaSort;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.thymeleaf.context.Context;

import com.codahale.metrics.annotation.Timed;
import com.fulliautomatix.csrs.domain.Contact;
import com.fulliautomatix.csrs.domain.Contact_;
import com.fulliautomatix.csrs.repository.ContactRepository;
import com.fulliautomatix.csrs.security.AuthoritiesConstants;
import com.fulliautomatix.csrs.service.LazyService;
import com.fulliautomatix.csrs.service.PDFService;
import com.fulliautomatix.csrs.service.UserService;
import com.fulliautomatix.csrs.specification.ContactSpec.InDirectoryForYear;
import com.fulliautomatix.csrs.specification.Spec;

/**
 * Directory.
 */
@Controller
@RolesAllowed(AuthoritiesConstants.USER)
public class DirectoryController {

    private final Logger log = LoggerFactory.getLogger(DirectoryController.class);

    @Inject
    private ContactRepository contactRepository;

    @Inject
    private LazyService lazyService;

    @Inject
    private UserService userService;

    @Inject
    private PDFService pdfService;

    /**
     * GET  /csrs-scer-directory-{year}.pdf get the directory
     */
    @RequestMapping(
        value = "/csrs-scer-directory-{year}.pdf",
        method = RequestMethod.GET,
        produces = "application/pdf" 
    )
    @Timed
    @RolesAllowed(AuthoritiesConstants.USER)
    @Transactional(readOnly = true)
    public void getInvoice (@PathVariable Integer year, OutputStream output) throws Exception {
        log.debug("REST request to get invoice for Directory : {}", year);

        String language = userService.getUser().map(user -> 
            user.getLangKey()
        ).orElse("en");

        Locale locale = Locale.forLanguageTag(language);
        Context context = new Context(locale);
        context.setVariable("year", year);

        Spec<Contact> spec = new InDirectoryForYear(year);
        Sort sort = new JpaSort(Contact_.lastName, Contact_.firstName);
        List<Contact> contacts = contactRepository.findAll(spec, sort);
        lazyService.initializeForJsonView(contacts, Contact.WithEmailAndInterests.class); 
        context.setVariable("contacts", contacts);

        context.setVariable("now", new Date());

        pdfService.createPDF(output, context, "directory");
    }
}
