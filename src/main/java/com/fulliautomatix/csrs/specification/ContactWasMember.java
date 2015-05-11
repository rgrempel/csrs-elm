package com.fulliautomatix.csrs.specification;

import org.springframework.data.jpa.domain.Specification;

import com.fasterxml.jackson.annotation.*;
import com.voodoodyne.jackson.jsog.JSOGGenerator;

import com.fulliautomatix.csrs.domain.Contact;
import com.fulliautomatix.csrs.domain.Contact_;

import javax.persistence.criteria.*;
import java.util.*;

@lombok.Data
@lombok.NoArgsConstructor @lombok.AllArgsConstructor
@lombok.EqualsAndHashCode(callSuper=false)
@JsonTypeName("ContactWasMember")
public class ContactWasMember extends Spec<Contact> {
    @lombok.Getter @lombok.Setter
    private Set<Integer> yearsRequired;

    @lombok.Getter @lombok.Setter
    private Set<Integer> yearsForbidden;

    public ContactWasMember (Integer[] yr, Integer[] yf) {
        this(
            yr == null ? (Set<Integer>) null : new HashSet<Integer>(Arrays.asList(yr)), 
            yf == null ? (Set<Integer>) null : new HashSet<Integer>(Arrays.asList(yf))
        );
    }

    @Override
    public Predicate toPredicate (Root<Contact> contact, CriteriaQuery<?> query, CriteriaBuilder cb) {
        Predicate positive;
        
        if ((yearsRequired == null) || (yearsRequired.size() == 0)) {
            // No yearsRequired, so the positive aspect is ContactWasMember;
            positive = new ContactWasEverMember().toPredicate(contact, query, cb);
        } else {
            positive = new ContactWasMemberInAll(yearsRequired).toPredicate(contact, query, cb);
        }

        if ((yearsForbidden == null) || (yearsForbidden.size() == 0)) {
            // If nothing forbidden, just return the positive part
            return positive;
        } else {
            return cb.and(
                positive,
                new ContactWasMemberInNone(yearsForbidden).toPredicate(contact, query, cb)
            );
        }
    }
}
