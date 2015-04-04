package com.fulliautomatix.csrs.web.rest;

import com.codahale.metrics.annotation.Timed;
import com.fulliautomatix.csrs.domain.Authority;
import com.fulliautomatix.csrs.domain.PersistentToken;
import com.fulliautomatix.csrs.domain.User;
import com.fulliautomatix.csrs.domain.UserEmail;
import com.fulliautomatix.csrs.domain.UserEmailActivation;
import com.fulliautomatix.csrs.repository.PersistentTokenRepository;
import com.fulliautomatix.csrs.repository.UserEmailRepository;
import com.fulliautomatix.csrs.repository.UserEmailActivationRepository;
import com.fulliautomatix.csrs.repository.UserRepository;
import com.fulliautomatix.csrs.security.SecurityUtils;
import com.fulliautomatix.csrs.service.MailService;
import com.fulliautomatix.csrs.service.UserService;
import com.fulliautomatix.csrs.web.rest.dto.UserDTO;
import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.transaction.annotation.Transactional;

import javax.inject.Inject;
import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.*;
import java.util.stream.Collectors;

/**
 * REST controller for managing the current user's account.
 */
@RestController
@RequestMapping("/api")
public class AccountResource {

    private final Logger log = LoggerFactory.getLogger(AccountResource.class);

    @Inject
    private UserRepository userRepository;

    @Inject
    private UserService userService;

    @Inject
    private PersistentTokenRepository persistentTokenRepository;

    @Inject
    private MailService mailService;

    @Inject 
    private UserEmailActivationRepository userEmailActivationRepository;

    @Inject
    private UserEmailRepository userEmailRepository;

    /**
     * POST  /register -> register the user.
     */
    @RequestMapping(
        value = "/register",
        params = {"key"},
        method = RequestMethod.POST,
        produces = MediaType.TEXT_PLAIN_VALUE
    )
    @Timed
    @Transactional
    public ResponseEntity<?> registerAccount(@Valid @RequestBody UserDTO userDTO, @RequestParam("key") String key, HttpServletRequest request) {
        log.debug("REST request to register account");
        // First retrieve the key ...
        return userEmailActivationRepository.findByActivationKey(key).map((activation) -> {
            // Check if it's already been used ...
            UserEmail userEmail = activation.getUserEmail();
            if (userEmail.getUser() != null) {
                log.debug("Activation key already used");
                return new ResponseEntity<>("Activation key already used", HttpStatus.BAD_REQUEST);
            } else {
                return userRepository.findOneByLogin(userDTO.getLogin()).map(
                    user -> new ResponseEntity<>("login already in use", HttpStatus.BAD_REQUEST)
                ).orElseGet(() -> {
                    User user = userService.createUserInformation(userDTO.getLogin(), userDTO.getPassword(), userDTO.getLangKey());
                    userEmail.setUser(user);
                    userEmailRepository.save(userEmail);

                    // And delete the activation key, since it's now been used
                    userEmailActivationRepository.delete(activation);

                    return new ResponseEntity<>(HttpStatus.CREATED);
                });
            }
        }).orElseGet(() -> { 
            log.debug("Activation key not found");
            return new ResponseEntity<>("Activation key not found", HttpStatus.BAD_REQUEST);
        });
    }

    /**
     * GET  /authenticate -> check if the user is authenticated, and return its login.
     */
    @RequestMapping(value = "/authenticate",
            method = RequestMethod.GET,
            produces = MediaType.APPLICATION_JSON_VALUE)
    @Timed
    public String isAuthenticated(HttpServletRequest request) {
        log.debug("REST request to check if the current user is authenticated");
        return request.getRemoteUser();
    }

    /**
     * GET  /account -> get the current user.
     */
    @RequestMapping(value = "/account",
            method = RequestMethod.GET,
            produces = MediaType.APPLICATION_JSON_VALUE)
    @Timed
    public ResponseEntity<UserDTO> getAccount() {
        return Optional.ofNullable(userService.getUserWithAuthorities())
            .map(user -> new ResponseEntity<>(
                new UserDTO(
                    user.getLogin(),
                    null,
                    user.getLangKey(),
                    user.getAuthorities().stream().map(Authority::getName).collect(Collectors.toList())),
                HttpStatus.OK))
            .orElse(new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR));
    }

    /**
     * POST  /account -> update the current user information.
     */
    @RequestMapping(value = "/account",
            method = RequestMethod.POST,
            produces = MediaType.APPLICATION_JSON_VALUE)
    @Timed
    @Transactional
    public ResponseEntity<String> saveAccount(@RequestBody UserDTO userDTO) {
        return userRepository
            .findOneByLogin(userDTO.getLogin())
            .filter(u -> u.getLogin().equals(SecurityUtils.getCurrentLogin()))
            .map(u -> {
                userService.updateUserInformation(userDTO.getLangKey());
                return new ResponseEntity<String>(HttpStatus.OK);
            })
            .orElseGet(() -> new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR));
    }

    /**
     * POST  /change_password -> changes the current user's password
     */
    @RequestMapping(value = "/account/change_password",
            method = RequestMethod.POST,
            produces = MediaType.APPLICATION_JSON_VALUE)
    @Timed
    public ResponseEntity<?> changePassword(@RequestBody String password) {
        if (StringUtils.isEmpty(password)) {
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
        userService.changePassword(password);
        return new ResponseEntity<>(HttpStatus.OK);
    }

    /**
     * GET  /account/sessions -> get the current open sessions.
     */
    @RequestMapping(value = "/account/sessions",
            method = RequestMethod.GET,
            produces = MediaType.APPLICATION_JSON_VALUE)
    @Timed
    public ResponseEntity<List<PersistentToken>> getCurrentSessions() {
        return userRepository.findOneByLogin(SecurityUtils.getCurrentLogin())
            .map(user -> new ResponseEntity<>(
                persistentTokenRepository.findByUser(user),
                HttpStatus.OK))
            .orElse(new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR));
    }

    /**
     * DELETE  /account/sessions?series={series} -> invalidate an existing session.
     *
     * - You can only delete your own sessions, not any other user's session
     * - If you delete one of your existing sessions, and that you are currently logged in on that session, you will
     *   still be able to use that session, until you quit your browser: it does not work in real time (there is
     *   no API for that), it only removes the "remember me" cookie
     * - This is also true if you invalidate your current session: you will still be able to use it until you close
     *   your browser or that the session times out. But automatic login (the "remember me" cookie) will not work
     *   anymore.
     *   There is an API to invalidate the current session, but there is no API to check which session uses which
     *   cookie.
     */
    @RequestMapping(value = "/account/sessions/{series}",
            method = RequestMethod.DELETE)
    @Timed
    public void invalidateSession(@PathVariable String series) throws UnsupportedEncodingException {
        String decodedSeries = URLDecoder.decode(series, "UTF-8");
        userRepository.findOneByLogin(SecurityUtils.getCurrentLogin()).ifPresent(u -> {
            persistentTokenRepository.findByUser(u).stream()
                .filter(persistentToken -> StringUtils.equals(persistentToken.getSeries(), decodedSeries))
                .findAny().ifPresent(t -> persistentTokenRepository.delete(decodedSeries));
        });
    }
}
