package com.fulliautomatix.csrs.security;

import com.fulliautomatix.csrs.config.Constants;

import org.springframework.data.domain.AuditorAware;
import org.springframework.stereotype.Component;

import javax.inject.Inject;

/**
 * Implementation of AuditorAware based on Spring Security.
 */
@Component
public class SpringSecurityAuditorAware implements AuditorAware<String> {
    @Inject
    private SecurityUtils securityUtils;

    public String getCurrentAuditor() {
        String userName = securityUtils.getCurrentLogin();
        return (userName != null ? userName : Constants.SYSTEM_ACCOUNT);
    }
}
