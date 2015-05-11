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

public class ContactSpec {

    @lombok.Data
    @lombok.EqualsAndHashCode(callSuper=false)
    @JsonTypeName("ContactWasEverMember")
    public static class WasEverMember extends Spec<Contact> {
        @Override
        public Predicate toPredicateFrom (From<?, Contact> contact, CriteriaQuery<?> query, CriteriaBuilder cb) {
            query.distinct(true);

            return new AnnualSpec.WasMember().toPredicateFrom(contact.join(Contact_.annuals), query, cb);
        }
    }

    @lombok.Data
    @lombok.NoArgsConstructor @lombok.AllArgsConstructor
    @lombok.EqualsAndHashCode(callSuper=false)
    @JsonTypeName("ContactWasMemberInAll")
    public static class WasMemberInAll extends Spec<Contact> {
        @lombok.NonNull
        private Set<Integer> yearsRequired;

        public WasMemberInAll (Integer... years) {
            this(new HashSet<>(Arrays.asList(years)));
        }

        @Override
        public Predicate toPredicateFrom (From<?, Contact> contact, CriteriaQuery<?> query, CriteriaBuilder cb) {    
            query.distinct(true);

            // The easiest way conceptually to do this is to just keep adding joins ...
            // the other way that makes some sense is a "group by" and "having" approach.
            return cb.and(
                yearsRequired.stream().map((year) ->
                    new AnnualSpec.WasMemberInYear(year).toPredicateFrom(
                        contact.join(Contact_.annuals),
                        query,
                        cb
                    )
                ).toArray(Predicate[]::new)
            );
        }
    }

    @lombok.Data
    @lombok.NoArgsConstructor @lombok.AllArgsConstructor
    @lombok.EqualsAndHashCode(callSuper=false)
    @JsonTypeName("ContactWasMemberInNone")
    public static class WasMemberInNone extends Spec<Contact> {
        @lombok.NonNull
        private Set<Integer> yearsForbidden;

        public WasMemberInNone (Integer... years) {
            this(new HashSet<>(Arrays.asList(years)));
        }

        @Override
        public Predicate toPredicateFrom (From<?, Contact> contact, CriteriaQuery<?> query, CriteriaBuilder cb) {    
            query.distinct(true);

            // This one is easier ... just use a subquery and check that nothing
            // exsists with the supplied years
            Subquery<Annual> sq = query.subquery(Annual.class);
            Root<Annual> sr = sq.from(Annual.class);
            sq.select(sr);

            sq.where(
                cb.and(
                    cb.equal(sr.get(Annual_.contact), contact),
                    new AnnualSpec.WasMember().toPredicateFrom(sr, query, cb),
                    sr.get(Annual_.year).in(yearsForbidden)
                )
            );

            return cb.exists(sq).not();
        }
    }
    
    @lombok.Data
    @lombok.NoArgsConstructor @lombok.AllArgsConstructor
    @lombok.EqualsAndHashCode(callSuper=false)
    @JsonTypeName("ContactWasMember")
    public static class WasMember extends Spec<Contact> {
        @lombok.Getter @lombok.Setter
        private Set<Integer> yearsRequired;

        @lombok.Getter @lombok.Setter
        private Set<Integer> yearsForbidden;

        public WasMember (Integer[] yr, Integer[] yf) {
            this(
                yr == null ? (Set<Integer>) null : new HashSet<Integer>(Arrays.asList(yr)), 
                yf == null ? (Set<Integer>) null : new HashSet<Integer>(Arrays.asList(yf))
            );
        }

        @Override
        public Predicate toPredicateFrom (From<?, Contact> contact, CriteriaQuery<?> query, CriteriaBuilder cb) {
            Predicate positive;
            
            if ((yearsRequired == null) || (yearsRequired.size() == 0)) {
                // No yearsRequired, so the positive aspect is ContactWasMember;
                positive = new WasEverMember().toPredicateFrom(contact, query, cb);
            } else {
                positive = new WasMemberInAll(yearsRequired).toPredicateFrom(contact, query, cb);
            }

            if ((yearsForbidden == null) || (yearsForbidden.size() == 0)) {
                // If nothing forbidden, just return the positive part
                return positive;
            } else {
                return cb.and(
                    positive,
                    new WasMemberInNone(yearsForbidden).toPredicateFrom(contact, query, cb)
                );
            }
        }
    }
}
