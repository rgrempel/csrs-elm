package com.fulliautomatix.csrs.client;

import org.fluentlenium.core.FluentPage;
import org.fluentlenium.core.annotation.AjaxElement;
import org.fluentlenium.core.domain.FluentWebElement;

public class HomePage extends FluentPage {
    @AjaxElement
    public FluentWebElement loggedInMessage;

    @AjaxElement
    public FluentWebElement notLoggedInMessage;

    @Override
    public String getUrl() {
        return "";
    }
   
    public FluentWebElement bigHeading () {
        return findFirst("h1");
    }
}
