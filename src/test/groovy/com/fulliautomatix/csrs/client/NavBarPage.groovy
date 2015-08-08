package com.fulliautomatix.csrs.client

import geb.Page

class NavBarPage extends Page {
    static content = {
        navbarMenuAccountLogin { $("#navbar-account-login") }
        navbarMenuAccount { $("#navbar-account-menu") }
    }
}
