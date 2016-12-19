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
import org.apache.avalon.framework.configuration.DefaultConfigurationBuilder;
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
        DefaultConfigurationBuilder cfgBuilder = new DefaultConfigurationBuilder();
        
        FopFactoryBuilder builder = new FopFactoryBuilder(
            new File(".").toURI(),
            graphicsResourceResolver
        );
        
        try {
            builder.setConfiguration(
                cfgBuilder.buildFromFile(
                    new File("/home/csrs/config/fop.xml")
                )
            );
        } catch (Exception ex) {
            log.error(ex.toString());
        }
   
        return builder.build();  
    }

    @Bean
    public TransformerFactory transformerFactory () {
        return TransformerFactory.newInstance();
    }
}
