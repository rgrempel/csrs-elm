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
import org.apache.fop.apps.FopFactoryBuilder;
import org.xml.sax.SAXException;
import java.io.File;
import javax.inject.Inject;
import javax.xml.transform.TransformerFactory;
import com.fulliautomatix.csrs.thymeleaf.GraphicsResourceResolver;

@Configuration
public class FopConfiguration {

    private final Logger log = LoggerFactory.getLogger(FopConfiguration.class);

    @Inject
    private GraphicsResourceResolver graphicsResourceResolver;

    @Bean
    @Description("FopFactory")
    public FopFactory fopFactory () {
        FopFactoryBuilder builder = new FopFactoryBuilder(
            new File("/home/csrs/config/fop.xml").toURI(),
            graphicsResourceResolver
        );
        
        return builder.build();  
    }

    @Bean
    public TransformerFactory transformerFactory () {
        return TransformerFactory.newInstance();
    }
}
