package com.fulliautomatix.csrs.client.account

import javax.inject.Inject
import org.junit.Test
import org.springframework.test.context.jdbc.Sql
import com.fulliautomatix.csrs.client.BaseTest
import com.fulliautomatix.csrs.client.HomePage
import com.fulliautomatix.csrs.repository.UserEmailActivationRepository
import com.fulliautomatix.csrs.repository.UserEmailRepository
import com.fulliautomatix.csrs.domain.UserEmailActivation

class RegisterTest extends BaseTest {
    @Inject
    UserEmailActivationRepository userEmailActivationRepository

    @Inject
    UserEmailRepository userEmailRepository

    @Test
    void shows_error_for_unknown_key () {
        fetch RegisterPage
        
        key.value("bad key")
        keySubmit.click(InvitationPage)

        assert invitationNotFound.displayed
    }

    String sends_invitation () {
        userEmailActivationRepository.deleteAll()
        userEmailRepository.deleteAll()

        fetch RegisterPage
       
        email.value "test@nowhere.com"
        emailSubmit.click()

        assert invitationSent.displayed
        
        UserEmailActivation uea = userEmailActivationRepository.findByEmailAddress("test@nowhere.com").get()
        uea.activationKey
    }

    void sends_and_finds_invitation () {
        String activationKey = sends_invitation()
        
        key.value(activationKey)
        keySubmit.click(InvitationRegisterPage)
        
        assert email.text() == "test@nowhere.com"
    }

    @Test
    void correct_invitation_url_goes_to_registration_page () {
        String activationKey = sends_invitation()
        via InvitationPage, activationKey
        refresh InvitationRegisterPage
    }

    @Test
    void wrong_invitation_url_stays_on_invitation_page () {
        String activationKey = sends_invitation()
        via InvitationPage, "wrongkey" 
        refresh InvitationPage
    }

    @Test
    @Sql(["/sql/deleteCustomUsers.sql"])
    void actually_creates_new_user () {
        sends_and_finds_invitation()

        username.value("testuser")
        password.value("password")
        confirmPassword.value("password")

        submitButton.click(HomePage)
        assert loggedInMessage.displayed
    }
}
