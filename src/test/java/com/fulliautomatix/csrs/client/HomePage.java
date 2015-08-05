package com.fulliautomatix.csrs.client;

import org.fluentlenium.core.FluentPage;
import org.fluentlenium.core.domain.FluentWebElement;

public class HomePage extends FluentPage {
    @Override
    public String getUrl() {
        return "";
    }
   
    public FluentWebElement bigHeading () {
        return findFirst("h1");
    }    
}
