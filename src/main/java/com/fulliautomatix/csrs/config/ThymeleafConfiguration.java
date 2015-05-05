package com.fulliautomatix.csrs.config;

import org.apache.commons.lang.CharEncoding;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.autoconfigure.thymeleaf.ThymeleafProperties;

import org.springframework.context.MessageSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Description;
import org.springframework.context.support.ReloadableResourceBundleMessageSource;

import org.thymeleaf.templateresolver.ClassLoaderTemplateResolver;
import org.thymeleaf.templatemode.StandardTemplateModeHandlers;

import com.fulliautomatix.csrs.repository.TemplateRepository;
import com.fulliautomatix.csrs.thymeleaf.DatabaseResourceResolver;
import com.fulliautomatix.csrs.thymeleaf.DatabaseTemplateResolver;

import javax.inject.Inject;

@Configuration
@EnableConfigurationProperties(ThymeleafProperties.class)
public class ThymeleafConfiguration {

    private final Logger log = LoggerFactory.getLogger(ThymeleafConfiguration.class);

    @Inject
    private ThymeleafProperties properties;

    @Inject
    private TemplateRepository templateRepository;

    @Bean
    @Description("Thymeleaf template resolver serving HTML 5 emails")
    public ClassLoaderTemplateResolver emailTemplateResolver() {
        ClassLoaderTemplateResolver emailTemplateResolver = new ClassLoaderTemplateResolver();
        emailTemplateResolver.setPrefix("mails/");
        emailTemplateResolver.setSuffix(".html");
        emailTemplateResolver.setTemplateMode("HTML5");
        emailTemplateResolver.setCharacterEncoding(CharEncoding.UTF_8);
        emailTemplateResolver.setCacheable(properties.isCache());
        emailTemplateResolver.setOrder(1);
        return emailTemplateResolver;
    }

    @Bean
    @Description("Spring mail message resolver")
    public MessageSource emailMessageSource() {
        log.info("loading non-reloadable mail messages resources");
        ReloadableResourceBundleMessageSource messageSource = new ReloadableResourceBundleMessageSource();
        messageSource.setBasename("classpath:/mails/messages/messages");
        messageSource.setDefaultEncoding(CharEncoding.UTF_8);
        return messageSource;
    }
    
    @Bean
    @Description("Thymeleaf template resolver serving XML for FOP")
    public ClassLoaderTemplateResolver fopTemplateResolver() {
        ClassLoaderTemplateResolver fopTemplateResolver = new ClassLoaderTemplateResolver();
        fopTemplateResolver.setPrefix("pdf/");
        fopTemplateResolver.setSuffix(".fop.xml");
        fopTemplateResolver.setTemplateMode("XML");
        fopTemplateResolver.setCharacterEncoding(CharEncoding.UTF_8);
        fopTemplateResolver.setCacheable(properties.isCache());
        fopTemplateResolver.setOrder(2);
        return fopTemplateResolver;
    }

    @Bean
    public DatabaseResourceResolver databaseResourceResolver () {
        return new DatabaseResourceResolver(templateRepository);
    }

    @Bean
    public DatabaseTemplateResolver databaseTemplateResolver () {
        return new DatabaseTemplateResolver(databaseResourceResolver());
    }
}
