package com.fulliautomatix.csrs.web.rest.dto;

import org.hibernate.validator.constraints.Email;

import javax.validation.constraints.NotNull;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;
import java.util.List;

@lombok.ToString(of={"login", "langKey"})
public class UserDTO {

    @Pattern(regexp = "^[a-z0-9]*$")
    @NotNull
    @Size(min = 1, max = 50)
    @lombok.Getter
    private String login;

    @NotNull
    @Size(min = 5, max = 100)
    @lombok.Getter
    private String password;

    @Size(min = 2, max = 5)
    @lombok.Getter
    private String langKey;

    @lombok.Getter
    private List<String> roles;

    public UserDTO () {

    }

    public UserDTO (String login, String password, String langKey, List<String> roles) {
        this.login = login;
        this.password = password;
        this.langKey = langKey;
        this.roles = roles;
    }
}
