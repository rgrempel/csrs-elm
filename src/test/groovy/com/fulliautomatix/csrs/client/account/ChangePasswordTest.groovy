package com.fulliautomatix.csrs.client.account

import org.junit.Test
import org.springframework.test.context.jdbc.Sql
import com.fulliautomatix.csrs.client.BaseTest
import com.fulliautomatix.csrs.client.HomePage

class ChangePasswordTest extends BaseTest {
    void doOldLogin () {
        fetch LoginPage
        tryLogin("testuser", "admin", HomePage)
        assert loggedInMessage.displayed
    }
    
    @Test
    @Sql(["/sql/mockUsers.sql"])
    void fails_with_wrong_current_password () {
        doOldLogin()
        
        fetch ChangePasswordPage
        assert oldPassword.displayed
        
        oldPassword.value "wrong"
        newPassword.value "andrew"
        confirmPassword.value "andrew"

        submitButton.click()
        assert loginFailed.displayed
    }

    @Test
    @Sql(["/sql/mockUsers.sql"])
    void succeeds_with_correct_password () {
        doOldLogin()

        fetch ChangePasswordPage
        assert oldPassword.displayed

        oldPassword.value "admin"
        newPassword.value "andrew"
        confirmPassword.value "andrew"

        submitButton.click()
        assert loginSuccess.displayed
        
        navbarMenuAccount.click()
        navbarMenuAccountLogout.click(HomePage)
        assert notLoggedInMessage.displayed

        fetch LoginPage
        tryLogin("testuser", "andrew", HomePage)
        assert loggedInMessage.displayed
    }
}
