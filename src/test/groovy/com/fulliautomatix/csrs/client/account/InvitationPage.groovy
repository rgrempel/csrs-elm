package com.fulliautomatix.csrs.client.account

import com.fulliautomatix.csrs.client.NavBarPage

class InvitationPage extends NavBarPage {
    static url = "#!/account/invitation"
    
    static at = {
        $(".csrs-invitation")
    }
    
    static content = {
        invitationNotFound (wait: true) { $(".invitation-not-found") }
    }
}
