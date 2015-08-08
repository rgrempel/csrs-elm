package com.fulliautomatix.csrs.client

import org.junit.Test

class ErrorTest extends BaseTest {
    @Test
    void going_to_nonexistent_page_should_show_error () {
        go "#!/nonexistantpage"
        at ErrorPage
    }
}
