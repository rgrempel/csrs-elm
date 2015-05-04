package com.fulliautomatix.csrs.web.rest.util;

import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.http.HttpStatus;

@ResponseStatus(
    value=HttpStatus.UNPROCESSABLE_ENTITY,
    reason="Updated object must already have an ID"
)
public class MustHaveIdException extends RuntimeException {

}
