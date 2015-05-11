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

@lombok.Data
@lombok.EqualsAndHashCode(callSuper=false)
@JsonTypeName("ContactWasEverMember")
public class ContactWasEverMember extends Spec<Contact> {
    @Override
    public Predicate toPredicate (Root<Contact> contact, CriteriaQuery<?> query, CriteriaBuilder cb) {
        query.distinct(true);

        return cb.notEqual(contact.join(Contact_.annuals).get(Annual_.membership), 0);
    }
}
