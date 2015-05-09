package com.fulliautomatix.csrs.web.rest.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fulliautomatix.csrs.web.rest.util.ValidationException;

import org.springframework.web.bind.MethodArgumentNotValidException;

import java.util.*;
import java.util.stream.*;

@lombok.Data
@lombok.AllArgsConstructor
public class MemberByYearDTO {
    private Integer year;
    private Integer membership;
    private Long count;
}
