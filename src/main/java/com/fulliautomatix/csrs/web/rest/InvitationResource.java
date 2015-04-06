package com.fulliautomatix.csrs.web.rest;

import com.codahale.metrics.annotation.Timed;
import com.fasterxml.jackson.annotation.*;
import com.fulliautomatix.csrs.domain.Contact;
import com.fulliautomatix.csrs.domain.Email;
import com.fulliautomatix.csrs.domain.UserEmail;
import com.fulliautomatix.csrs.domain.UserEmailActivation;
import com.fulliautomatix.csrs.repository.EmailRepository;
import com.fulliautomatix.csrs.repository.UserEmailRepository;
import com.fulliautomatix.csrs.repository.UserEmailActivationRepository;
import com.fulliautomatix.csrs.security.AuthoritiesConstants;
import com.fulliautomatix.csrs.web.rest.util.PaginationUtil;
import com.fulliautomatix.csrs.web.rest.util.ValidationException;
import com.fulliautomatix.csrs.web.rest.dto.AccountCreationDTO;
import com.fulliautomatix.csrs.service.util.RandomUtil;
import com.fulliautomatix.csrs.service.MailService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.Errors;

import org.joda.time.DateTime;
import javax.validation.Valid;
import javax.servlet.http.HttpServletRequest;
import javax.annotation.security.RolesAllowed;
import javax.inject.Inject;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.List;
import java.util.Set;
import java.util.Optional;

/**
 * REST controller for managing Invitations.
 */
@RestController
@RequestMapping("/api")
public class InvitationResource {

    private final Logger log = LoggerFactory.getLogger(InvitationResource.class);

    @Inject
    private MailService mailService;

    @Inject
    private EmailRepository emailRepository;
    
    @Inject
    private UserEmailRepository userEmailRepository;

    @Inject
    private UserEmailActivationRepository userEmailActivationRepository;

    /**
     * GET   /invitation/key -> Verify an invitation that exists
     */
    @RequestMapping(
        value = "/invitation/{key}",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @JsonView(UserEmailActivation.WithUserEmail.class)
    public ResponseEntity<UserEmailActivation> getInvitation (@PathVariable String key) throws URISyntaxException {
        return userEmailActivationRepository.findByActivationKey(key).map((activation) -> {
            return new ResponseEntity<UserEmailActivation>(activation, HttpStatus.OK);
        }).orElse(
            new ResponseEntity<UserEmailActivation>(HttpStatus.NOT_FOUND)
        );    
    }

    /**
     * POST  /invitation/account -> Send an invitation to create an account 
     */
    @RequestMapping(
        value = "/invitation/account",
        method = RequestMethod.POST,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @Transactional
    public ResponseEntity<Void> sendCreateAccountInvitation (@RequestBody @Valid AccountCreationDTO request, Errors errors, HttpServletRequest servletRequest) throws URISyntaxException {
        log.debug("REST request to send account creation invitation : {}", request);

        if (errors.hasErrors()) {
            throw new ValidationException("Request failed validation", errors);
        }

        // Get the existing email address, or create a new one
        Email email = emailRepository.findOneByEmailAddress(request.getEmail()).orElseGet(() -> {
            Email created = request.createEmail();
            created = emailRepository.save(created);
            return created;
        });

        // Get the existing UserEmail addresses for this email (possibly none)
        Set<UserEmail> userEmails = email.getUserEmails();
       
        // See if there is a null one, for a new user ... if not, add it
        userEmails.stream().filter((userEmail) -> userEmail.getUser() == null).findFirst().orElseGet(() -> {
            UserEmail created = new UserEmail();
            created.setEmail(email);
            created = userEmailRepository.save(created);
            userEmails.add(created);
            return created;
        });

        // Now, create activations for *all* the user emails, unless they have one already ... in that case,
        // just update the dateSent.
        for (UserEmail userEmail : userEmails) {
            UserEmailActivation activation = userEmail.getUserEmailActivations().stream().findFirst().orElseGet(() -> {
                UserEmailActivation created = new UserEmailActivation();
                created.setUserEmail(userEmail);
                created.setActivationKey(RandomUtil.generateActivationKey());
                userEmail.getUserEmailActivations().add(created);
                return created;
            });

            // This updates whether we've just created it or not
            activation.setDateSent(new DateTime());
            
            activation = userEmailActivationRepository.save(activation);
        };

        String baseUrl = servletRequest.getScheme() + // "http"
        "://" +                                // "://"
        servletRequest.getServerName() +              // "myhost"
        ":" +                                  // ":"
        servletRequest.getServerPort();               // "80"
        
        // OK, now we've done all the work ... time to send the email!
        mailService.sendAccountCreationEmail(email, request.getLangKey(), baseUrl);

        // And, if we had no exceptions, we'll get here and just return OK
        return ResponseEntity.ok().build();
    }
}
