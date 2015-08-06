package com.fulliautomatix.csrs.client;

import org.fluentlenium.core.annotation.Page;
import org.junit.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.fluentlenium.assertj.FluentLeniumAssertions.assertThat;

public class LoginTest extends Base {
    @Page
    public LoginPage loginPage;

    @Page
    public HomePage homePage;

    @Test
    public void can_login_as_admin () {
        goTo(loginPage);
        loginPage.tryLogin("admin", "admin"); 
        assertThat(homePage.loggedInMessage).isDisplayed();
    }

    @Test
    public void logging_in_with_wrong_password_fails () {
        goTo(loginPage);
        loginPage.tryLogin("admin", "wrong");
        assertThat(loginPage.loginFailed).isDisplayed();
    }
}
