package com.fulliautomatix.csrs.web.rest.dto;

import org.hibernate.validator.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;
import java.util.List;

@lombok.ToString
@lombok.EqualsAndHashCode
public class PasswordChangeDTO {
    @NotBlank
    @lombok.Getter @lombok.Setter
    private String oldPassword;

    @NotBlank
    @lombok.Getter @lombok.Setter
    private String newPassword;
}
