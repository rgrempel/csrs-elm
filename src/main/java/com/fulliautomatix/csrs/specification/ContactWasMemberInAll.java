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
import java.util.stream.*;

@lombok.Data
@lombok.NoArgsConstructor
@lombok.AllArgsConstructor
public class ContactWasMemberInAll implements Specification<Contact> {
    @lombok.NonNull
    private Set<Integer> yearsRequired;

    public ContactWasMemberInAll (Integer... years) {
        this(new HashSet<>(Arrays.asList(years)));
    }

    @Override
    public Predicate toPredicate (Root<Contact> contact, CriteriaQuery<?> query, CriteriaBuilder cb) {    
        query.distinct(true);

        // The easiest way conceptually to do this is to just keep adding joins ...
        // the other way that makes some sense is a "group by" and "having" approach.
        Predicate[] yearPredicates = yearsRequired.stream().map((year) -> {
            Join<Contact, Annual> annuals = contact.join(Contact_.annuals);
            return cb.and(
                cb.notEqual(annuals.get(Annual_.membership), 0),
                cb.equal(annuals.get(Annual_.year), year)
            );
        }).toArray(Predicate[]::new);

        return cb.and(yearPredicates);
    }
}
