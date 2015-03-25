package com.fulliautomatix.csrs.web.rest.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import org.springframework.validation.FieldError;

@lombok.Data
@lombok.AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class FieldValidationDTO {
    private String resource;
    private String field;
    private String code;
    private String message;

    public FieldValidationDTO (FieldError error) {
        this(error.getObjectName(), error.getField(), error.getCode(), error.getDefaultMessage());
    }
}

