package com.fulliautomatix.csrs.specification;

import org.springframework.data.jpa.domain.Specification;

import com.fasterxml.jackson.annotation.*;
import com.voodoodyne.jackson.jsog.JSOGGenerator;

import com.fulliautomatix.csrs.domain.Contact;
import com.fulliautomatix.csrs.domain.Contact_;
import com.fulliautomatix.csrs.domain.Annual;
import com.fulliautomatix.csrs.domain.Annual_;

import javax.persistence.criteria.*;
import java.util.*;

@JsonTypeInfo(
    use = JsonTypeInfo.Id.NAME,
    include = JsonTypeInfo.As.PROPERTY,
    property = "@type"
)
@JsonSubTypes({
    @JsonSubTypes.Type(ContactWasEverMember.class),
    @JsonSubTypes.Type(ContactWasMember.class),
    @JsonSubTypes.Type(ContactWasMemberInAll.class),
    @JsonSubTypes.Type(ContactWasMemberInNone.class)
})
public abstract class Spec<T> implements Specification<T> {
    
    @Override
    public abstract Predicate toPredicate (Root<T> contact, CriteriaQuery<?> query, CriteriaBuilder cb);
}
