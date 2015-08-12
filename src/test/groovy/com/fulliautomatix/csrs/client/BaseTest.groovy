package com.fulliautomatix.csrs.client

import org.springframework.boot.test.SpringApplicationConfiguration
import org.springframework.boot.test.WebIntegrationTest
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner
import org.springframework.beans.factory.annotation.Value

import geb.junit4.GebReportingTest
import geb.Configuration
import org.junit.runner.RunWith
import com.fulliautomatix.csrs.Application

@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(classes = Application.class)
@WebIntegrationTest('server.port:0')
abstract class BaseTest extends GebReportingTest {
    @Value('${local.server.port}')
    int port

    Configuration createConf () {
        def configuration = super.createConf()
        configuration.baseUrl = "http://localhost:$port/"
        configuration
    }

    void refresh () {
        driver.navigate().refresh()
    }

    def getCookies () {
        driver.manage().getCookies()
    }

    def deleteCookieNamed (name) {
        driver.manage().deleteCookieNamed(name)
    }

    def fetch (page) {
        to page
        refresh()
    }
}
