package com.fulliautomatix.csrs.specification;

@lombok.Data
@lombok.NoArgsConstructor
@lombok.AllArgsConstructor
public class Filter<T> {
    private Spec<T> spec;

}
