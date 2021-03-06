package com.fulliautomatix.csrs.service;

import java.util.HashSet;
import java.util.Optional;
import java.util.Set;

import javax.inject.Inject;

import org.joda.time.LocalDate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fulliautomatix.csrs.domain.Authority;
import com.fulliautomatix.csrs.domain.User;
import com.fulliautomatix.csrs.repository.AuthorityRepository;
import com.fulliautomatix.csrs.repository.PersistentTokenRepository;
import com.fulliautomatix.csrs.repository.UserRepository;
import com.fulliautomatix.csrs.security.SecurityUtils;

/**
 * Service class for managing users.
 */
@Service
@Transactional
public class UserService {

    private final Logger log = LoggerFactory.getLogger(UserService.class);

    @Inject
    private PasswordEncoder passwordEncoder;

    @Inject
    private UserRepository userRepository;

    @Inject
    private PersistentTokenRepository persistentTokenRepository;

    @Inject
    private AuthorityRepository authorityRepository;

    @Inject
    private SecurityUtils securityUtils;

    /*
    public Optional<User> activateRegistration(String key) {
        log.debug("Activating user for activation key {}", key);
        userRepository.findOneByActivationKey(key)
            .map(user -> {
                // activate given user for the registration key.
                user.setActivated(true);
                user.setActivationKey(null);
                userRepository.save(user);
                log.debug("Activated user: {}", user);
                return user;
            });
        return Optional.empty();
    }
    */

    public User createUserInformation (String login, String password, String langKey) {
        User newUser = new User();
        
        Authority authority = authorityRepository.findOne("ROLE_USER");
        Set<Authority> authorities = new HashSet<>();
        authorities.add(authority);
        newUser.setAuthorities(authorities);
        
        String encryptedPassword = passwordEncoder.encode(password);
        newUser.setPassword(encryptedPassword);
        
        newUser.setLogin(login);
        newUser.setLangKey(langKey);
        
        newUser = userRepository.save(newUser);
        
        log.debug("Created Information for User: {}", newUser);
        return newUser;
    }

    public void updateUserInformation (String languageKey) {
        getUser().ifPresent(u -> {
            u.setLangKey(languageKey);
            u = userRepository.save(u);
            log.debug("Changed Information for User: {}", u);
        });
    }

    public void changePassword (String password) {
        getUser().ifPresent(u -> {
            changePassword(u, password);
        });
    }
    
    public void changePassword (User user, String password) {
        String encryptedPassword = passwordEncoder.encode(password);
        user.setPassword(encryptedPassword);
        userRepository.save(user);
        log.debug("Changed password for User: {}", user);
    }

    public boolean checkPassword (String password) {
        return getUser().map(user -> {
            return this.passwordEncoder.matches(password, user.getPassword());
        }).orElseThrow(() -> 
            new RuntimeException("Could not find user")
        );
    }

    public Optional<User> getUser () {
        return userRepository.findOneByLogin(securityUtils.getCurrentLogin());
    }

    @Transactional(readOnly = true)
    public User getUserWithAuthorities() {
        User currentUser = getUser().get();
        currentUser.getAuthorities().size(); // eagerly load the association
        return currentUser;
    }

    /**
     * Persistent Token are used for providing automatic authentication, they should be automatically deleted after
     * 30 days.
     * <p/>
     * <p>
     * This is scheduled to get fired everyday, at midnight.
     * </p>
     */
    @Scheduled(cron = "0 0 0 * * ?")
    public void removeOldPersistentTokens() {
        LocalDate now = new LocalDate();
        persistentTokenRepository.findByTokenDateBefore(now.minusMonths(1)).stream().forEach(token ->{
            log.debug("Deleting token {}", token.getSeries());
            User user = token.getUser();
            user.getPersistentTokens().remove(token);
            persistentTokenRepository.delete(token);
        });
    }

    // Deal with unused activations ...

    /**
     * Not activated users should be automatically deleted after 3 days.
     * <p/>
     * <p>
     * This is scheduled to get fired everyday, at 01:00 (am).
     * </p>
     */
    /*
    @Scheduled(cron = "0 0 1 * * ?")
    public void removeNotActivatedUsers() {
        DateTime now = new DateTime();
        List<User> users = userRepository.findAllByActivatedIsFalseAndCreatedDateBefore(now.minusDays(3));
        for (User user : users) {
            log.debug("Deleting not activated user {}", user.getLogin());
            userRepository.delete(user);
        }
    }
    */
}
