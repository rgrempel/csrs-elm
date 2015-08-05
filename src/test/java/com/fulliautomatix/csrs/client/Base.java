package com.fulliautomatix.csrs.client;

import com.fulliautomatix.csrs.Application;

import org.junit.Test;
import org.junit.runner.RunWith;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.springframework.boot.test.WebIntegrationTest;
import org.springframework.boot.test.SpringApplicationConfiguration;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.beans.factory.annotation.Value;

import org.fluentlenium.adapter.util.SharedDriver;
import org.fluentlenium.adapter.FluentTest;
import static org.assertj.core.api.Assertions.assertThat;

@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(classes = Application.class)
@WebIntegrationTest("server.port:0")
@SharedDriver(type = SharedDriver.SharedType.ONCE)
public abstract class Base extends FluentTest {
    @Value("${local.server.port}")
    private int port;

    @Override
    public String getDefaultBaseUrl () {
        return "http://localhost:" + String.valueOf(port);
    }
}
