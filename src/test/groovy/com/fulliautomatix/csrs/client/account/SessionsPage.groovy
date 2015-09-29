package com.fulliautomatix.csrs.client.account

import com.fulliautomatix.csrs.client.NavBarPage

class SessionsPage extends NavBarPage {
    static url = "#!/account/sessions"
    
    static at = {
        $(".csrs-account-sessions")
    }
    
    static content = {
        buttons (wait: 3, required: false) {
            $(".delete-session-button") 
        }
    }
}
