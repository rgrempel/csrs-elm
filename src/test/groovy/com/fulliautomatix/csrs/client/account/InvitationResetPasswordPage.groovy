package com.fulliautomatix.csrs.client.account

import com.fulliautomatix.csrs.client.NavBarPage

class InvitationResetPasswordPage extends NavBarPage {
    static at = {
        $(".csrs-invitation-reset-password")
    }

    static content = {
        username { $("#username") }
        email { $("#email") }
        password { $("#password") }
        confirmPassword { $("#confirmPassword") }
        submitButton { $("#submitButton") }
    }
}
