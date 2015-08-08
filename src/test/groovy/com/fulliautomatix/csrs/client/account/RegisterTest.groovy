package com.fulliautomatix.csrs.client.account

import org.junit.Test
import com.fulliautomatix.csrs.client.BaseTest
import com.fulliautomatix.csrs.client.HomePage

class RegisterTest extends BaseTest {
    @Test
    void shows_error_for_unknown_key () {
        fetch RegisterPage
        
        key.value("bad key")
        keySubmit.click(InvitationPage)

        assert invitationNotFound.displayed
    }
}
