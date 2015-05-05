package com.fulliautomatix.csrs.thymeleaf;

import org.springframework.stereotype.Service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.thymeleaf.resourceresolver.IResourceResolver;
import org.thymeleaf.TemplateProcessingParameters;

import com.fulliautomatix.csrs.domain.Template;
import com.fulliautomatix.csrs.repository.TemplateRepository;

import java.io.*;
import java.nio.charset.StandardCharsets;
import javax.inject.Inject;

public class DatabaseResourceResolver implements IResourceResolver {
    private final Logger log = LoggerFactory.getLogger(DatabaseResourceResolver.class);

    private TemplateRepository templateRepository; 
   
    public DatabaseResourceResolver (TemplateRepository templateRepository) {
        this.templateRepository = templateRepository;
    }

    public String getName () {
        return "DatabaseResourceResolver";
    }

    public InputStream getResourceAsStream (TemplateProcessingParameters templateProcessingParameters, String resourceName) {
        return templateRepository.findByCode(resourceName).map((template) -> {
            return new ByteArrayInputStream(template.getText().getBytes(StandardCharsets.UTF_8));
        }).orElse(null);
    }
}
