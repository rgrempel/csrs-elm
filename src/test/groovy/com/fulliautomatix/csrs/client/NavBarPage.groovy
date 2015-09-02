package com.fulliautomatix.csrs.client

import geb.Page

class NavBarPage extends Page {
    static content = {
        navbarMenuAccountLogin (wait: true, required: false) {
            $("#navbar-account-login")
        }
        
        navbarMenuAccountLogout (wait: true, required: false) {
            $("#navbar-link-account-logout")
        }
        
        navbarMenuAccount {
            $("#navbar-account-menu")
        }

        navbarMenuAdmin (wait: true, required: false) {
            $("#navbar-admin-menu")
        }
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
