package com.fulliautomatix.csrs.client;

import org.springframework.transaction.annotation.Transactional;
import org.fluentlenium.core.annotation.Page;
import org.junit.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.fluentlenium.assertj.FluentLeniumAssertions.assertThat;

public class HomeTest extends Base {
    @Page
    public HomePage homePage;

    @Test
    public void home_page_should_display () {
        goTo(homePage);
        assertThat(homePage.bigHeading()).hasText("Welcome");
    }
}
