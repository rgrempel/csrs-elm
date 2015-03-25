package com.fulliautomatix.csrs.web.rest.util;

import org.springframework.validation.Errors;

public class ValidationException extends RuntimeException {
    private Errors errors;

    public ValidationException (String message, Errors errors) {
        super(message);
        this.errors = errors;
    }

    public Errors getErrors() {
        return errors;
    }
}

