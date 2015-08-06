package com.fulliautomatix.csrs.client;

import org.fluentlenium.core.FluentPage;
import org.fluentlenium.core.annotation.AjaxElement;
import org.fluentlenium.core.domain.FluentWebElement;

public class LoginPage extends FluentPage {
    @AjaxElement
    public FluentWebElement username;
    
    @AjaxElement
    public FluentWebElement password;
    
    @AjaxElement
    public FluentWebElement rememberMe;
    
    @AjaxElement
    public FluentWebElement submitButton;

    @AjaxElement
    public FluentWebElement loginFailed;

    @Override
    public String getUrl() {
        return "#!/account/login";
    }
   
    public LoginPage tryLogin (String user, String pass) {
        fill(username).with(user);
        fill(password).with(pass);
        click(submitButton);

        return this;
    }
}
