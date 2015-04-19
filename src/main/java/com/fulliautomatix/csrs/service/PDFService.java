package com.fulliautomatix.csrs.service;

import org.apache.commons.lang.CharEncoding;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.MessageSource;
import org.springframework.core.env.Environment;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.thymeleaf.context.Context;
import org.thymeleaf.spring4.SpringTemplateEngine;
import org.apache.fop.apps.*;
import org.xml.sax.helpers.DefaultHandler;

import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.*;
import javax.xml.transform.stream.StreamSource;
import javax.inject.Inject;
import java.util.*;
import java.io.*;

/**
 * Service for creating PDFs.
 */
@Service
public class PDFService {

    private final Logger log = LoggerFactory.getLogger(PDFService.class);

    @Inject
    private SpringTemplateEngine templateEngine;

    @Inject
    private FopFactory fopFactory;
    
    @Inject
    private TransformerFactory transformerFactory;

    public void createPDF (OutputStream output, Context context, String template) {
        try {
            Fop fop = fopFactory.newFop(MimeConstants.MIME_PDF, output);
            
            PipedReader reader = new PipedReader();
            PipedWriter writer = new PipedWriter(reader);
        
            // Get the templateEngine to start streaming the XML
            new Thread(() -> {
                templateEngine.process(template, context, writer);
                try {
                    writer.close();
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            }).start();

            // Get FOP to consume the XML
            Transformer transformer = transformerFactory.newTransformer();
            Source src = new StreamSource(reader);
            Result res = new SAXResult(fop.getDefaultHandler());
            transformer.transform(src, res);
            reader.close();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
