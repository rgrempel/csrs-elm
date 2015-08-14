package com.fulliautomatix.csrs.client

import geb.Page

class NavBarPage extends Page {
    static content = {
        navbarMenuAccountLogin { $("#navbar-account-login") }
        navbarMenuAccountLogout { $("#navbar-link-account-logout") }
        navbarMenuAccount { $("#navbar-account-menu") }
    }

    def clickLogout () {
        navbarMenuAccount.click()
        navbarMenuAccountLogout.click()
    }

    def clickLogin () {
        navbarMenuAccount.click()
        navbarMenuAccountLogin.click()
    }
}
