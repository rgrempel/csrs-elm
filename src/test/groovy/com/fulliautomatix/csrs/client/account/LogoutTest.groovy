package com.fulliautomatix.csrs.client.account

import org.junit.Test
import com.fulliautomatix.csrs.client.BaseTest
import com.fulliautomatix.csrs.client.HomePage

class LogoutTest extends BaseTest {
    @Test
    void clicking_on_navbar_link () {
        fetch LoginPage
        tryLogin("admin", "admin", HomePage)
        assert loggedInMessage.displayed
        
        clickLogout()
        assert notLoggedInMessage.displayed
    }

    @Test
    void logging_out_takes_you_to_home_page () {
        fetch LoginPage
        tryLogin("admin", "admin", HomePage)

        to LoginPage
        clickLogout()
        at HomePage
        assert notLoggedInMessage.displayed
    }
}
