package com.fulliautomatix.csrs.client.account

import com.fulliautomatix.csrs.client.NavBarPage

class ResetPasswordPage extends NavBarPage {
    static url = "#!/account/reset-password"
    
    static at = {
        $(".csrs-resetPassword")
    }
    
    static content = {
        email { $("input#email-input") }
        emailSubmit { $("#email-submit") }
        key { $("#key-input") }
        keySubmit { $("#key-submit") }
        invitationSent (wait: true) { $("#invitation-sent") }
    }
}
