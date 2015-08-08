package com.fulliautomatix.csrs.client.account

import com.fulliautomatix.csrs.client.NavBarPage

class RegisterPage extends NavBarPage {
    static url = "#!/account/register"
    
    static at = {
        $(".csrs-register")
    }
    
    static content = {
        email { $("input#email-input") }
        emailSubmit { $("#email-submit") }
        key { $("#key-input") }
        keySubmit { $("#key-submit") }
        invitationSent (wait: true) { $("#invitation-sent") }
    }
}
