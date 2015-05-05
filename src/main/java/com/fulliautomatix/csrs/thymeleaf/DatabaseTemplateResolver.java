package com.fulliautomatix.csrs.thymeleaf;

import org.springframework.stereotype.Service;

import org.thymeleaf.TemplateProcessingParameters;
import org.thymeleaf.exceptions.ConfigurationException;
import org.thymeleaf.resourceresolver.IResourceResolver;
import org.thymeleaf.templateresolver.TemplateResolver;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.inject.Inject;

public class DatabaseTemplateResolver extends TemplateResolver {
    private final Logger log = LoggerFactory.getLogger(DatabaseTemplateResolver.class);

    public DatabaseTemplateResolver (DatabaseResourceResolver resolver) {
        super();
        super.setResourceResolver(resolver);
    }
    
    @Override
    public void setResourceResolver (final IResourceResolver resourceResolver) {
        throw new ConfigurationException(
            "Cannot set a resource resolver on " + this.getClass().getName() + ". If " +
            "you want to set your own resource resolver, use " + TemplateResolver.class.getName() + 
            "instead."
        );
    }
}
