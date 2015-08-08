package com.fulliautomatix.csrs.client

import org.junit.Test

class HomeTest extends BaseTest {
    @Test
    void home_page_should_display () {
        to HomePage

        assert bigHeading.text().contains("Welcome")
    }
}
