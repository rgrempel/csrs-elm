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
import com.fulliautomatix.csrs.web.rest.dto.AccountCreationDTO;
import com.fulliautomatix.csrs.web.rest.dto.ExistingContactDTO;
import com.fulliautomatix.csrs.service.util.RandomUtil;
import com.fulliautomatix.csrs.service.MailService;
import com.fulliautomatix.csrs.service.LazyService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.transaction.annotation.Transactional;

import org.joda.time.DateTime;
import javax.validation.Valid;
import javax.servlet.http.HttpServletRequest;
import javax.annotation.security.RolesAllowed;
import javax.inject.Inject;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.*;

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

    @Inject
    private LazyService lazyService;
    
    /**
     * GET   /invitation/key -> Verify an invitation that exists
     */
    @RequestMapping(
        value = "/invitation/{key}",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @JsonView(UserEmailActivation.WithUser.class)
    @Transactional(readOnly = true)
    public ResponseEntity<UserEmailActivation> getInvitation (@PathVariable String key) throws URISyntaxException {
        return userEmailActivationRepository.findByActivationKey(key).map((activation) -> {
            lazyService.initializeForJsonView(activation, UserEmailActivation.WithUserEmail.class); 
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
    public ResponseEntity<Void> sendCreateAccountInvitation (
        @RequestParam(value="passwordReset") boolean passwordReset,
        @RequestBody @Valid AccountCreationDTO request,
        HttpServletRequest servletRequest
    ) throws URISyntaxException {
        log.debug("REST request to send account creation invitation : {}", request);

        // Get the existing email address, or create a new one
        Email email = emailRepository.findOneByEmailAddress(request.getEmail()).orElseGet(() -> {
            Email created = request.createEmail();
            created = emailRepository.save(created);
            return created;
        });

        // Get the existing UserEmail addresses for this email (possibly none)
        Set<UserEmail> userEmails = email.getUserEmails();

        // Make sure the user is fetched, so the template can use it.
        userEmails.stream().forEach(userEmail -> userEmail.getUser());
       
        // See if there is a null one, for a new user ... if not, add it
        // We do this only if we were *asked* to create a new account, or, if asked for
        // passwordReset, we didn't find an existing account to reset
        if (!passwordReset || userEmails.size() == 0) {
            userEmails.stream().filter((userEmail) -> userEmail.getUser() == null).findFirst().orElseGet(() -> {
                UserEmail created = new UserEmail();
                created.setEmail(email);
                created = userEmailRepository.save(created);
                userEmails.add(created);
                return created;
            });
        }

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
        if (passwordReset) {
            mailService.sendPasswordResetEmail(email, request.getLangKey(), baseUrl);
        } else {
            mailService.sendAccountCreationEmail(email, request.getLangKey(), baseUrl);
        }

        // And, if we had no exceptions, we'll get here and just return OK
        return ResponseEntity.ok().build();
    }
    
    /**
     * POST  /invitation/contacts -> Send an invitation for existing contacts 
     */
    @RequestMapping(
        value = "/invitation/contacts",
        method = RequestMethod.POST,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @Transactional
    @RolesAllowed(AuthoritiesConstants.ADMIN)
    public ResponseEntity<Void> sendExistingContactInvitation (
        @RequestBody @Valid ExistingContactDTO request,
        HttpServletRequest servletRequest
    ) throws URISyntaxException {
        log.debug("REST request to send invitations to existing contacts : {}", request);

        // Given the conteactIDs, get all the email addresses for which there are no users yet
        Set<Email> emails = emailRepository.forExistingContactsWithoutUsers(request.getContactIDs());

        // Now, we iterate over the emails.
        for (Email email : emails) {
            // Given the query used above, we'll only have emails that have no userEmail, or a userEmail
            // without a user (i.e. an activation was already created). So, either get the userEmail without
            // a user, or create one.
            UserEmail userEmail = email.getUserEmails().stream().findFirst().orElseGet(() -> {
                UserEmail created = new UserEmail();
                created.setEmail(email);
                created = userEmailRepository.save(created);
                email.getUserEmails().add(created);
                return created;
            });
            
            // Now, create an activation for the userEmail, unless it has one already ... in that case,
            // just update the dateSent.
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

            // Now, find an owner contact, so we can say their name
            Contact owner = email.findOwners().stream().findFirst().orElseGet(() -> {
                Contact unknown = new Contact();
                unknown.setFirstName("Colleague");
                unknown.setLastName("");
                return unknown;
            });

            String baseUrl = servletRequest.getScheme() + // "http"
            "://" +                                // "://"
            servletRequest.getServerName() +              // "myhost"
            ":" +                                  // ":"
            servletRequest.getServerPort();               // "80"
            
            // OK, now we've done all the work ... time to send the email!
            mailService.sendExistingMemberEmail(email, owner, baseUrl);
        }

        // And, if we had no exceptions, we'll get here and just return OK
        return ResponseEntity.ok().build();
    }
}
