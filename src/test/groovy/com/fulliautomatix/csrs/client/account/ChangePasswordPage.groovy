package com.fulliautomatix.csrs.client.account

import com.fulliautomatix.csrs.client.NavBarPage

class ChangePasswordPage extends NavBarPage {
    static url = "#!/account/change-password"
    
    static at = {
        $(".csrs-auth-change-password")
    }
    
    static content = {
        oldPassword { $("#oldPassword") }
        newPassword { $("#newPassword") }
        confirmPassword { $("#confirmPassword") }
        submitButton { $("#submitButton") }
        loginFailed (wait: true) { $("#loginFailed") }
        loginSuccess (wait: true) { $("#loginSuccess") }
    }
}
