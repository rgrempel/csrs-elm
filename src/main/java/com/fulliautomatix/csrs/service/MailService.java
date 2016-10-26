package com.fulliautomatix.csrs.service;

import com.fulliautomatix.csrs.domain.User;
import com.fulliautomatix.csrs.domain.Email;
import com.fulliautomatix.csrs.domain.Contact;
import com.fulliautomatix.csrs.domain.SentEmail;
import com.fulliautomatix.csrs.repository.SentEmailRepository;
import org.apache.commons.lang.CharEncoding;
import org.joda.time.DateTime;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.MessageSource;
import org.springframework.core.env.Environment;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.thymeleaf.context.Context;
import org.thymeleaf.spring4.SpringTemplateEngine;

import javax.annotation.PostConstruct;
import javax.inject.Inject;
import javax.mail.internet.MimeMessage;
import java.util.Locale;

/**
 * Service for sending e-mails.
 * <p/>
 * <p>
 * We use the @Async annotation to send e-mails asynchronously.
 * </p>
 */
@Service
public class MailService {

    private final Logger log = LoggerFactory.getLogger(MailService.class);

    @Inject
    private Environment env;

    @Inject
    private JavaMailSenderImpl javaMailSender;

    @Inject
    private MessageSource messageSource;
    
    @Inject
    private SentEmailRepository sentEmailRepository;
    
    @Inject
    private SpringTemplateEngine templateEngine;

    /**
     * System default email address that sends the e-mails.
     */
    private String from;

    @PostConstruct
    public void init() {
        this.from = env.getProperty("spring.mail.from");
    }

    @Async
    public void sendEmail(String to, String subject, String content, boolean isMultipart, boolean isHtml) {
        log.debug("Send e-mail[multipart '{}' and html '{}'] to '{}' with subject '{}' and content={}",
                isMultipart, isHtml, to, subject, content);

        // I suppose I should set this, and then create the MimeMessageHelper from it.
        SentEmail sentEmail = new SentEmail();
        sentEmail.setEmailTo(to);
        sentEmail.setEmailFrom(from);
        sentEmail.setEmailSubject(subject);
        sentEmail.setEmailContent(content);
            
        // Prepare message using a Spring helper
        MimeMessage mimeMessage = javaMailSender.createMimeMessage();
        try {
            MimeMessageHelper message = new MimeMessageHelper(mimeMessage, isMultipart, CharEncoding.UTF_8);
            message.setTo(to);
            message.setFrom(from);
            message.setSubject(subject);
            message.setText(content, isHtml);
            
            javaMailSender.send(mimeMessage);
            log.debug("Sent e-mail to User '{}'", to);

            // If we get this far, we appear to have sent it
            sentEmail.setEmailSent(DateTime.now());
        } catch (Exception e) {
            log.warn("E-mail could not be sent to user '{}', exception is: {}", to, e.getMessage());
        } finally {
            // We store the email in either case ... if not sent, the email_sent field will be null
            sentEmailRepository.save(sentEmail);
        }
    }

    /*
    @Async
    public void sendActivationEmail(User user, String baseUrl) {
        log.debug("Sending activation e-mail to '{}'", user.getEmail());
        Locale locale = Locale.forLanguageTag(user.getLangKey());
        Context context = new Context(locale);
        context.setVariable("user", user);
        context.setVariable("baseUrl", baseUrl);
        String content = templateEngine.process("activationEmail", context);
        String subject = messageSource.getMessage("email.activation.title", null, locale);
        sendEmail(user.getEmail(), subject, content, false, true);
    }
*/
    @Async
    public void sendAccountCreationEmail (Email email, String langKey, String baseUrl) {
        log.debug("Sending account creation email to '{}'", email.getEmailAddress());

        Locale locale = Locale.forLanguageTag(langKey);
        Context context = new Context(locale);
        context.setVariable("email", email);
        context.setVariable("baseUrl", baseUrl);

        String content = templateEngine.process("accountCreationEmail", context);
        String subject = messageSource.getMessage("email.accountCreation.title", null, locale);
        sendEmail(email.getEmailAddress(), subject, content, false, true);
    }
    
    @Async
    public void sendPasswordResetEmail (Email email, String langKey, String baseUrl) {
        log.debug("Sending password reset email to '{}'", email.getEmailAddress());

        Locale locale = Locale.forLanguageTag(langKey);
        Context context = new Context(locale);
        context.setVariable("email", email);
        context.setVariable("baseUrl", baseUrl);

        String content = templateEngine.process("passwordResetEmail", context);
        String subject = messageSource.getMessage("email.passwordReset.title", null, locale);
        sendEmail(email.getEmailAddress(), subject, content, false, true);
    }

    @Async
    public void sendExistingMemberEmail (Email email, Contact contact, String baseUrl) {
        log.debug("Sending existing member email to '{}'", email.getEmailAddress());

        Locale enLocale = Locale.forLanguageTag("en");
        Context enContext = new Context(enLocale);
        enContext.setVariable("email", email);
        enContext.setVariable("contact", contact);
        enContext.setVariable("baseUrl", baseUrl);

        String enContent = templateEngine.process("existingMemberEmail", enContext);
        String enSubject = messageSource.getMessage("email.existingMember.title", null, enLocale);

        Locale frLocale = Locale.forLanguageTag("fr");
        Context frContext = new Context(frLocale);
        frContext.setVariable("email", email);
        frContext.setVariable("contact", contact);
        frContext.setVariable("baseUrl", baseUrl);

        String frContent = templateEngine.process("existingMemberEmail", frContext);
        String frSubject = messageSource.getMessage("email.existingMember.title", null, frLocale);

        sendEmail(
            email.getEmailAddress(),
            enSubject + "/" + frSubject,
            enContent + frContent,
            false,
            true
        );
    }
    
    @Async
    public void sendSpecialOfferEmail (Email email) {
        log.debug("Sending special offer email to '{}'", email.getEmailAddress());

        Locale enLocale = Locale.forLanguageTag("en");
        Context enContext = new Context(enLocale);
        enContext.setVariable("email", email);

        String enContent = templateEngine.process("specialOfferEmail", enContext);
        String enSubject = messageSource.getMessage("email.specialOffer.title", null, enLocale);

        Locale frLocale = Locale.forLanguageTag("fr");
        Context frContext = new Context(frLocale);
        frContext.setVariable("email", email);

        String frContent = templateEngine.process("specialOfferEmail", frContext);
        String frSubject = messageSource.getMessage("email.specialOffer.title", null, frLocale);

        sendEmail(
            email.getEmailAddress(),
            enSubject + "/" + frSubject,
            enContent + frContent,
            false,
            true
        );
    }
}
