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
@lombok.NoArgsConstructor @lombok.AllArgsConstructor
@lombok.EqualsAndHashCode(callSuper=false)
@JsonTypeName("ContactWasMemberInNone")
public class ContactWasMemberInNone extends Spec<Contact> {
    @lombok.NonNull
    private Set<Integer> yearsForbidden;

    public ContactWasMemberInNone (Integer... years) {
        this(new HashSet<>(Arrays.asList(years)));
    }

    @Override
    public Predicate toPredicate (Root<Contact> contact, CriteriaQuery<?> query, CriteriaBuilder cb) {    
        query.distinct(true);

        // This one is easier ... just use a subquery and check that nothing
        // exsists with the supplied years
        Subquery<Annual> sq = query.subquery(Annual.class);
        Root<Annual> sr = sq.from(Annual.class);
        sq.select(sr);

        sq.where(
            cb.and(
                cb.equal(sr.get(Annual_.contact), contact),
                cb.notEqual(sr.get(Annual_.membership), 0),
                sr.get(Annual_.year).in(yearsForbidden)
            )
        );

        return cb.exists(sq).not();
    }
}
