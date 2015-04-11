package com.fulliautomatix.csrs.web.rest.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fulliautomatix.csrs.web.rest.util.ValidationException;

import org.springframework.web.bind.MethodArgumentNotValidException;

import java.util.List;
import java.util.stream.Collectors;

@lombok.Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class ValidationDTO {
    private String error;
    private String message;
    private List<FieldValidationDTO> fieldErrors;
        
    public ValidationDTO (ValidationException ex) {
        this.error = "Validation Error";
        this.message = ex.getMessage();

        this.fieldErrors = ex.getErrors().getFieldErrors().stream().map(e -> {
            return new FieldValidationDTO(e);
        }).collect(Collectors.toList());
    }

    public ValidationDTO (MethodArgumentNotValidException ex) {
        this.error = "Validation Error";
        this.message = ex.getMessage();

        this.fieldErrors = ex.getBindingResult().getFieldErrors().stream().map(e -> {
            return new FieldValidationDTO(e);
        }).collect(Collectors.toList());
    }
}
