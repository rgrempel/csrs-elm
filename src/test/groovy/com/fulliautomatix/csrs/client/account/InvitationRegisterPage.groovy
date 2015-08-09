package com.fulliautomatix.csrs.client.account

import com.fulliautomatix.csrs.client.NavBarPage

class InvitationRegisterPage extends NavBarPage {
    static at = {
        $(".csrs-invitation-register")
    }

    static content = {
        username { $("#username") }
        email { $("#email") }
        password { $("#password") }
        confirmPassword { $("#confirmPassword") }
        submitButton { $("#submitButton") }
    }
}
