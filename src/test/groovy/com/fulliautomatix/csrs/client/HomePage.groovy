package com.fulliautomatix.csrs.client

class HomePage extends NavBarPage {
    static url = ""
    
    static at = {
        $(".focus-home")
    }
    
    static content = {
        loggedInMessage (wait: true) { $("#loggedInMessage") }
        notLoggedInMessage (wait: true) { $("#notLoggedInMessage") }
        bigHeading { $("h1") }
    }
}
