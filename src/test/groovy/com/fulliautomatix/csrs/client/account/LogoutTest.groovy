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
        
        navbarMenuAccount.click()
        navbarMenuAccountLogout.click()
        assert notLoggedInMessage.displayed
    }
}
