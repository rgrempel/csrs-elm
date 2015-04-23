package com.fulliautomatix.csrs.security;

import com.fulliautomatix.csrs.Application;
import org.junit.Test;
import org.junit.runner.RunWith;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;

import org.springframework.boot.test.IntegrationTest;
import org.springframework.boot.test.SpringApplicationConfiguration;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;

import java.util.*;

import javax.inject.Inject;

import static org.assertj.core.api.Assertions.assertThat;

/**
* Test class for the SecurityUtils utility class.
*
* @see SecurityUtils
*/
@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(classes = Application.class)
@WebAppConfiguration
@IntegrationTest
@Transactional
public class SecurityUtilsTest {
    @Inject
    private SecurityUtils securityUtils;

    @Test
    public void testGetCurrentLogin() {
        SecurityContext securityContext = SecurityContextHolder.createEmptyContext();
        securityContext.setAuthentication(new UsernamePasswordAuthenticationToken("admin", "admin"));
        SecurityContextHolder.setContext(securityContext);
        String login = securityUtils.getCurrentLogin();
        assertThat(login).isEqualTo("admin");
    }

    @Test
    public void testIsAuthenticated() {
        SecurityContext securityContext = SecurityContextHolder.createEmptyContext();
        securityContext.setAuthentication(new UsernamePasswordAuthenticationToken("admin", "admin"));
        SecurityContextHolder.setContext(securityContext);
        boolean isAuthenticated = securityUtils.isAuthenticated();
        assertThat(isAuthenticated).isTrue();
    }

    @Test
    public void testAnonymousIsNotAuthenticated() {
        SecurityContext securityContext = SecurityContextHolder.createEmptyContext();
        Collection<GrantedAuthority> authorities = new ArrayList<>();
        authorities.add(new SimpleGrantedAuthority(AuthoritiesConstants.ANONYMOUS));
        securityContext.setAuthentication(new UsernamePasswordAuthenticationToken("anonymous", "anonymous", authorities));
        SecurityContextHolder.setContext(securityContext);
        boolean isAuthenticated = securityUtils.isAuthenticated();
        assertThat(isAuthenticated).isFalse();
    }
}
