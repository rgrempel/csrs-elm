package com.fulliautomatix.csrs.thymeleaf;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.thymeleaf.templateresolver.TemplateResolver;

import java.io.ByteArrayInputStream;
import java.io.UnsupportedEncodingException;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import javax.xml.transform.stream.StreamSource;

import javax.inject.Inject;

public class DatabaseURIResolver extends TemplateResolver {
    private final Logger log = LoggerFactory.getLogger(DatabaseURIResolver.class);

    public Source resolve (String href, String base) throws TransformerException {
        if (href.startsWith("db:")) {
            return null;
        } else {
            return null;
        }
    }
}
