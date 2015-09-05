package com.fulliautomatix.csrs.client.account

import javax.inject.Inject
import org.junit.Test
import org.springframework.test.context.jdbc.Sql
import com.fulliautomatix.csrs.client.BaseTest
import com.fulliautomatix.csrs.client.HomePage
import com.fulliautomatix.csrs.repository.UserEmailActivationRepository
import com.fulliautomatix.csrs.repository.UserEmailRepository
import com.fulliautomatix.csrs.domain.UserEmailActivation

class ResetPasswordTest extends BaseTest {
    @Inject
    UserEmailActivationRepository userEmailActivationRepository

    @Test
    void shows_error_for_unknown_key () {
        fetch ResetPasswordPage
        
        key.value("bad key")
        keySubmit.click(InvitationPage)

        assert invitationNotFound.displayed
    }

    String sends_invitation () {
        userEmailActivationRepository.deleteAll()

        fetch ResetPasswordPage
       
        email.value "test@nowhere.com"
        emailSubmit.click()

        assert invitationSent.displayed
        
        UserEmailActivation uea = userEmailActivationRepository.findByEmailAddress("test@nowhere.com").get()
        uea.activationKey
    }
    
    void sends_and_finds_invitation () {
        String activationKey = sends_invitation()
        
        key.value(activationKey)
        keySubmit.click(InvitationResetPasswordPage)
       
        assert email.text() == "test@nowhere.com"
    }

    @Test
    @Sql(["/sql/mockUsers.sql"])
    void correct_invitation_url_goes_to_reset_password_page () {
        String activationKey = sends_invitation()
        via InvitationPage, activationKey
        refresh InvitationResetPasswordPage
    }

    @Test
    @Sql(["/sql/mockUsers.sql"])
    void wrong_invitation_url_stays_on_invitation_page () {
        String activationKey = sends_invitation()
        via InvitationPage, "wrongkey" 
        refresh InvitationPage
    }

    @Test
    @Sql(["/sql/mockUsers.sql"])
    void actually_resets_password () {
        sends_and_finds_invitation()

        password.value("password2")
        confirmPassword.value("password2")

        submitButton.click(HomePage)
        assert loggedInMessage.displayed
    }
}
