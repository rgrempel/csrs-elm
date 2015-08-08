package com.fulliautomatix.csrs.client.account

import com.fulliautomatix.csrs.client.NavBarPage

class LogoutPage extends NavBarPage {
    static url = "#!/account/logout"
    
    static at = {
        $(".csrs-auth-logout")
    }
    
    static content = {
    }
}
