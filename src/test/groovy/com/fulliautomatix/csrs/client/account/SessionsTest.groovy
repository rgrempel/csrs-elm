package com.fulliautomatix.csrs.client.account

import org.junit.Test
import org.springframework.test.context.jdbc.Sql
import com.fulliautomatix.csrs.client.BaseTest
import com.fulliautomatix.csrs.client.HomePage

class SessionsTest extends BaseTest {
    @Test
    @Sql(["/sql/deletePersistentTokens.sql"])
    void no_persistent_tokens_if_no_remember_me () {
        fetch LoginPage
        tryLogin("user", "user", HomePage)
        assert loggedInMessage.displayed

        to SessionsPage
        assert buttons.size() == 0 
    }
    
    @Test
    @Sql(["/sql/deletePersistentTokens.sql"])
    void one_persistent_token_if_remember_me () {
        fetch LoginPage
        rememberLogin("user", "user", HomePage)
        assert loggedInMessage.displayed

        to SessionsPage
        assert buttons.size() == 1

        buttons.click()
        waitFor {
            buttons.size() == 0
        }

        to HomePage
        deleteCookieNamed "JSESSIONID"
        refresh HomePage
        assert notLoggedInMessage.displayed
    }
}
