package com.fulliautomatix.csrs.web.rest.dto;

import com.fulliautomatix.csrs.domain.Email;

import org.hibernate.validator.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;
import java.util.List;

@lombok.ToString
@lombok.EqualsAndHashCode
public class AccountCreationDTO {
    @org.hibernate.validator.constraints.Email
    @NotBlank
    private String email;

    @NotBlank
    @lombok.Getter @lombok.Setter
    private String langKey;

    public String getEmail () {
        if (email == null) {
            return null;
        } else {
            return email.trim().toLowerCase();
        }
    }

    public void setEmail (String address) {
        if (address == null) {
            this.email = null;
        } else {
            this.email = address.trim().toLowerCase();
        }
    }

    public Email createEmail () {
        Email created = new Email();
        created.setEmailAddress(email);
        return created;
    }
}
