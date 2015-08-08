package com.fulliautomatix.csrs.client

class HomePage extends NavBarPage {
    static url = ""
    
    static at = {
        $(".focus-home")
    }
    
    static content = {
        loggedInMessage { $("#loggedInMessage") }
        notLoggedInMessage { $("#notLoggedInMessage") }
        bigHeading { $("h1") }
    }
}
