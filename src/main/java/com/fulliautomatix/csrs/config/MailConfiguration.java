package com.fulliautomatix.csrs.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.bind.RelaxedPropertyResolver;
import org.springframework.context.EnvironmentAware;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.mail.javamail.JavaMailSenderImpl;

import java.util.Properties;

@Configuration
public class MailConfiguration implements EnvironmentAware {

    private static final String ENV_SPRING_MAIL = "spring.mail.";
    private static final String DEFAULT_HOST = "127.0.0.1";
    private static final String PROP_HOST = "host";
    private static final String DEFAULT_PROP_HOST = "localhost";
    private static final String PROP_PORT = "port";
    private static final String PROP_USER = "username";
    private static final String PROP_PASSWORD = "password";
    private static final String PROP_PROTO = "protocol";
    private static final String PROP_TLS = "tls";
    private static final String PROP_AUTH = "auth";
    private static final String PROP_SMTPS_AUTH = "mail.smtps.auth";
    private static final String PROP_STARTTLS = "mail.smtp.starttls.enable";
    private static final String PROP_TRANSPORT_PROTO = "mail.transport.protocol";
    private static final String PROP_SSL_ENABLE = "mail.smtp.ssl.enable";
    private static final String PROP_SSL_TRUST = "mail.smtp.ssl.trust";
    private static final String PROP_SSL_CHECK_IDENTITY = "mail.smtp.ssl.checkserveridentity";

    private final Logger log = LoggerFactory.getLogger(MailConfiguration.class);

    private RelaxedPropertyResolver propertyResolver;

    @Override
    public void setEnvironment(Environment environment) {
        this.propertyResolver = new RelaxedPropertyResolver(environment, ENV_SPRING_MAIL);
    }

    @Bean
    public JavaMailSenderImpl javaMailSender() {
        log.debug("Configuring mail server");
        String host = propertyResolver.getProperty(PROP_HOST, DEFAULT_PROP_HOST);
        int port = propertyResolver.getProperty(PROP_PORT, Integer.class, 0);
        String user = propertyResolver.getProperty(PROP_USER);
        String password = propertyResolver.getProperty(PROP_PASSWORD);
        String protocol = propertyResolver.getProperty(PROP_PROTO);
        Boolean tls = propertyResolver.getProperty(PROP_TLS, Boolean.class, false);
        Boolean auth = propertyResolver.getProperty(PROP_AUTH, Boolean.class, false);

        JavaMailSenderImpl sender = new JavaMailSenderImpl();
        if (host != null && !host.isEmpty()) {
            sender.setHost(host);
            log.warn("Host is: " + host);
        } else {
            log.warn("Warning! Your SMTP server is not configured. We will try to use one on localhost.");
            log.debug("Did you configure your SMTP settings in your application.yml?");
            sender.setHost(DEFAULT_HOST);
        }
        sender.setPort(port);
        sender.setUsername(user);
        sender.setPassword(password);
        sender.setProtocol(protocol);

        Properties sendProperties = new Properties();
        sendProperties.setProperty(PROP_SMTPS_AUTH, auth.toString());
        sendProperties.setProperty(PROP_SSL_ENABLE, "true");
        sendProperties.setProperty(PROP_TRANSPORT_PROTO, protocol);
        // sendProperties.setProperty("mail.debug", "true");
        sender.setJavaMailProperties(sendProperties);
        return sender;
    }
}
