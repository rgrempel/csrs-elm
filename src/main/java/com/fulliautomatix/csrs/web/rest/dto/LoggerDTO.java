package com.fulliautomatix.csrs.web.rest.dto;

import ch.qos.logback.classic.Logger;
import com.fasterxml.jackson.annotation.JsonCreator;

@lombok.EqualsAndHashCode
@lombok.ToString
public class LoggerDTO {
    @lombok.Getter @lombok.Setter
    private String name;

    @lombok.Getter @lombok.Setter
    private String level;

    public LoggerDTO (Logger logger) {
        this.name = logger.getName();
        this.level = logger.getEffectiveLevel().toString();
    }

    @JsonCreator
    public LoggerDTO () {

    }
}
