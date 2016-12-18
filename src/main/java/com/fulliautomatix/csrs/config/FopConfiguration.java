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
import org.xml.sax.SAXException;
import java.io.File;
import javax.xml.transform.TransformerFactory;

@Configuration
public class FopConfiguration {

    private final Logger log = LoggerFactory.getLogger(FopConfiguration.class);

    @Bean
    @Description("FopFactory")
    public FopFactory fopFactory () {
        FopFactory factory = FopFactory.newInstance();
        try {
            factory.setUserConfig(new File("/home/csrs/config/fop.xml"));
        } catch (Exception e) {
        }
        return factory;
    }

    @Bean
    public TransformerFactory transformerFactory () {
        return TransformerFactory.newInstance();
    }
}
