package com.fulliautomatix.csrs.service;

import org.apache.commons.lang.CharEncoding;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.MessageSource;
import org.springframework.core.env.Environment;
import org.springframework.scheduling.annotation.*;
import org.springframework.stereotype.Service;
import org.thymeleaf.context.Context;
import org.thymeleaf.spring4.SpringTemplateEngine;
import org.apache.fop.apps.*;
import org.xml.sax.helpers.DefaultHandler;
import com.fulliautomatix.csrs.thymeleaf.DatabaseURIResolver;

import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.*;
import javax.xml.transform.stream.StreamSource;
import javax.inject.Inject;
import java.util.concurrent.*;
import java.util.*;
import java.io.*;

/**
 * Service for creating PDFs.
 */
@Service
public class PDFService {
    private final Logger log = LoggerFactory.getLogger(PDFService.class);

    @Inject
    DatabaseURIResolver databaseURIResolver;

    /**
     * Inner class for Async purposes
     */
    @Service
    public static class TemplateRunner { 

        @Inject
        private SpringTemplateEngine templateEngine;

        @Async
        public Future<Boolean> processTemplate(String template, Context context, PipedWriter writer) throws IOException {
            try {
                templateEngine.process(template, context, writer);
            } finally {
                writer.close();
            }

            return new AsyncResult<Boolean>(true);
        } 
    }

    @Inject 
    private TemplateRunner templateRunner;

    @Inject
    private FopFactory fopFactory;
   
    @Inject
    private TransformerFactory transformerFactory;

    public void createPDF (OutputStream output, Context context, String template) throws Exception {
        FOUserAgent ua = fopFactory.newFOUserAgent();
        ua.setURIResolver(databaseURIResolver);

        Fop fop = fopFactory.newFop(MimeConstants.MIME_PDF, ua, output);

        PipedReader reader = new PipedReader();
        PipedWriter writer = new PipedWriter(reader);
    
        // Get the templateEngine to start streaming the XML
        Future<Boolean> result = templateRunner.processTemplate(template, context, writer);

        // Get FOP to consume the XML
        Transformer transformer = transformerFactory.newTransformer();
        Source src = new StreamSource(reader);
        Result res = new SAXResult(fop.getDefaultHandler());
        transformer.transform(src, res);
        reader.close();

        result.get();
    }
}
