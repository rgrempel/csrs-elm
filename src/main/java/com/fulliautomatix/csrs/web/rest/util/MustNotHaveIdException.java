package com.fulliautomatix.csrs.web.rest.util;

import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.http.HttpStatus;

@ResponseStatus(
    value=HttpStatus.UNPROCESSABLE_ENTITY,
    reason="Created object must not already have an ID"
)
public class MustNotHaveIdException extends RuntimeException {

}
