package com.fulliautomatix.csrs.client

import org.junit.Test
import com.fulliautomatix.csrs.client.account.LoginPage

class AdminTest extends BaseTest {
    @Test
    void no_admin_menu_if_not_logged_in () {
        fetch HomePage
        assert !navbarMenuAdmin.displayed
    }

    @Test
    void no_admin_menu_if_logged_in_as_user () {
        fetch LoginPage
        tryLogin "user", "user", HomePage
        assert loggedInMessage.displayed
        assert !navbarMenuAdmin.displayed
    }

    @Test
    void admin_menu_if_logged_in_as_admin () {
        fetch LoginPage
        tryLogin "admin", "admin", HomePage
        assert loggedInMessage.displayed
        assert navbarMenuAdmin.displayed
    }
}
