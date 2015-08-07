package com.fulliautomatix.csrs.client;

import org.fluentlenium.adapter.FluentTest;
import org.fluentlenium.adapter.util.SharedDriver;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.SpringApplicationConfiguration;
import org.springframework.boot.test.WebIntegrationTest;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.fulliautomatix.csrs.Application;

@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(classes = Application.class)
@WebIntegrationTest("server.port:0")
@SharedDriver(
    type = SharedDriver.SharedType.ONCE,
    deleteCookies = false
)
public abstract class Base extends FluentTest {
    @Value("${local.server.port}")
    private int port;

    @Override
    public String getDefaultBaseUrl () {
        return "http://localhost:" + String.valueOf(port);
    }
}
