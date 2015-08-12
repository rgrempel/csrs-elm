package com.fulliautomatix.csrs.client.account

import com.fulliautomatix.csrs.client.NavBarPage

class LoginPage extends NavBarPage {
    static url = "#!/account/login"
    
    static at = {
        $(".csrs-auth-login")
    }
    
    static content = {
        username { $("input#username") }
        password { $("input#password") }
        rememberMe { $("#rememberMe") }
        submitButton { $("#submitButton") }
        loginFailed (wait: true) { $("#loginFailed") }
    }

    void tryLogin (user, pass, page) {
        username.value user
        password.value pass
        rememberMe.value false
        submitButton.click(page)
    }

    void rememberLogin (user, pass, page) {
        username.value user
        password.value pass
        rememberMe.value true
        submitButton.click(page)
    }
}
