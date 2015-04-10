package com.fulliautomatix.csrs.web.rest;

import com.codahale.metrics.annotation.Timed;
import com.fasterxml.jackson.annotation.*;
import com.fulliautomatix.csrs.domain.User;
import com.fulliautomatix.csrs.repository.UserRepository;
import com.fulliautomatix.csrs.security.AuthoritiesConstants;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.security.RolesAllowed;
import javax.inject.Inject;
import java.util.List;

/**
 * REST controller for managing users.
 */
@RestController
@RequestMapping("/api")
public class UserResource {

    private final Logger log = LoggerFactory.getLogger(UserResource.class);

    @Inject
    private UserRepository userRepository;

    /**
     * GET  /users -> get all users.
     */
    @RequestMapping(
        value = "/users",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @RolesAllowed(AuthoritiesConstants.ADMIN)
    @JsonView(User.Scalar.class)
    public List<User> getAll () {
        log.debug("REST request to get all Users");

        return userRepository.findAll();
    }

    /**
     * GET  /users/:login -> get the "login" user.
     */
    @RequestMapping(
        value = "/users/{login}",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @RolesAllowed(AuthoritiesConstants.ADMIN)
    @JsonView(User.Scalar.class)
    public ResponseEntity<User> getUser (@PathVariable String login) {
        log.debug("REST request to get User : {}", login);

        return userRepository.findOneByLogin(login).map(user -> 
            new ResponseEntity<>(user, HttpStatus.OK)
        ).orElse(
            new ResponseEntity<>(HttpStatus.NOT_FOUND)
        );
    }

    /**
     * HEAD /users/:login -> check if "login" user exists ...
     */
    @RequestMapping(
        value = "/users/{login}",
        method = RequestMethod.HEAD,
        produces = MediaType.TEXT_PLAIN_VALUE
    )
    @Timed
    public ResponseEntity checkUser (@PathVariable String login) {
        log.debug("REST request to check user login : {}", login);

        return userRepository.findOneByLogin(login).map(user -> 
            new ResponseEntity<>(HttpStatus.OK)
        ).orElse(
            new ResponseEntity<>(HttpStatus.NOT_FOUND)
        );
    }
}
