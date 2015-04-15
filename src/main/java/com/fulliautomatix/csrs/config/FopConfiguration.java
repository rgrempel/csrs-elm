package com.fulliautomatix.csrs.config;

import org.apache.commons.lang.CharEncoding;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.MessageSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Description;
import org.springframework.context.support.ReloadableResourceBundleMessageSource;
import org.apache.fop.apps.FopFactory;
import javax.xml.transform.TransformerFactory;

@Configuration
public class FopConfiguration {

    private final Logger log = LoggerFactory.getLogger(FopConfiguration.class);

    @Bean
    @Description("FopFactory")
    public FopFactory fopFactory () {
        return FopFactory.newInstance();
    }

    @Bean
    public TransformerFactory transformerFactory () {
        return TransformerFactory.newInstance();
    }
}
