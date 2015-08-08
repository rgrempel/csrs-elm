package com.fulliautomatix.csrs.client

import org.junit.Test

class LoginTest extends BaseTest {
    @Test
    void clicking_on_navbar_link () {
        fetch HomePage
        navbarMenuAccount.click()
        navbarMenuAccountLogin.click(LoginPage)
    }

    @Test
    void can_login_as_admin () {
        fetch LoginPage
        tryLogin("admin", "admin", HomePage)
        assert loggedInMessage.displayed
    }

    @Test
    void can_login_as_user () {
        fetch LoginPage
        tryLogin("user", "user", HomePage)
        assert loggedInMessage.displayed
    }

    @Test
    void logging_in_with_wrong_password_fails () {
        fetch LoginPage
        tryLogin("admin", "wrong", LoginPage)
        assert loginFailed.displayed
    }
}
