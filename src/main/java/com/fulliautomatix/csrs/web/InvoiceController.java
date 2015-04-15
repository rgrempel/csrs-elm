package com.fulliautomatix.csrs.web;

import com.codahale.metrics.annotation.Timed;
import com.fasterxml.jackson.annotation.*;
import com.fulliautomatix.csrs.domain.Renewal;
import com.fulliautomatix.csrs.repository.RenewalRepository;
import com.fulliautomatix.csrs.web.rest.util.ResourceNotFoundException;
import com.fulliautomatix.csrs.security.AuthoritiesConstants;
import com.fulliautomatix.csrs.security.OwnerService;
import com.fulliautomatix.csrs.service.PriceService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.apache.fop.apps.*;
import org.xml.sax.helpers.DefaultHandler;
import org.hibernate.Hibernate;
import org.springframework.data.domain.Page;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.thymeleaf.context.Context;
import org.thymeleaf.spring4.SpringTemplateEngine;

import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.*;
import javax.xml.transform.stream.StreamSource;
import javax.inject.Inject;
import javax.validation.Valid;
import javax.annotation.security.RolesAllowed;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.*;
import java.io.*;

/**
 * Invoices.
 */
@Controller
@RolesAllowed(AuthoritiesConstants.USER)
public class InvoiceController {

    private final Logger log = LoggerFactory.getLogger(InvoiceController.class);

    @Inject
    private RenewalRepository renewalRepository;

    @Inject
    private OwnerService ownerService;

    @Inject
    private PriceService priceService;

    @Inject
    private SpringTemplateEngine templateEngine;

    @Inject
    private FopFactory fopFactory;
    
    @Inject
    private TransformerFactory transformerFactory;

    /**
     * GET  /renewals/:id/invoice.pdf -> get the "id" renewal.
     */
    @RequestMapping(
        value = "/renewals/{id}/invoice.pdf",
        method = RequestMethod.GET,
        produces = MimeConstants.MIME_PDF
    )
    @Timed
    @RolesAllowed(AuthoritiesConstants.USER)
    @Transactional(readOnly = true)
    public void getInvoice (@PathVariable Long id, OutputStream output) 
        throws FOPException, IOException, TransformerConfigurationException, TransformerException 
    {
        log.debug("REST request to get invoice for Renewal : {}", id);

        Renewal renewal = ownerService.findOneForLogin(renewalRepository, id).get();
        
        Hibernate.initialize(renewal.getContact());
        
        Locale locale = Locale.forLanguageTag("en");
        Context context = new Context(locale);
    //       context.setVariable("email", email);
    //       context.setVariable("baseUrl", baseUrl);

        Fop fop = fopFactory.newFop(MimeConstants.MIME_PDF, output);
        
        PipedReader reader = new PipedReader();
        PipedWriter writer = new PipedWriter(reader);
        
        new Thread(
            new Runnable() {
                public void run () {
                    templateEngine.process("invoice", context, writer);
                    try {
                        writer.close();
                    } catch (IOException e) {}
                }
            }
        ).start();

        Transformer transformer = transformerFactory.newTransformer();
        Source src = new StreamSource(reader);
        Result res = new SAXResult(fop.getDefaultHandler());
        transformer.transform(src, res);
        reader.close();
    }
}
