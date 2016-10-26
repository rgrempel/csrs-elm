package com.fulliautomatix.csrs.web.rest.dto;

import com.fulliautomatix.csrs.domain.Contact;

import org.hibernate.validator.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;
import java.util.Set;

@lombok.ToString
@lombok.EqualsAndHashCode
public class ExistingContactDTO {
    @lombok.Getter @lombok.Setter
    private Set<Long> contactIDs;

}
