package com.fulliautomatix.csrs.specification;

import org.springframework.data.jpa.domain.Specification;

import com.fasterxml.jackson.annotation.*;
import com.voodoodyne.jackson.jsog.JSOGGenerator;

import com.fulliautomatix.csrs.domain.Annual;
import com.fulliautomatix.csrs.domain.Annual_;

import javax.persistence.criteria.*;
import java.util.*;

public class AnnualSpec {

    @lombok.Data
    @lombok.EqualsAndHashCode(callSuper=false)
    @JsonTypeName("AnnualWasMember")
    public static class WasMember extends Spec<Annual> {

        @Override
        public Predicate toPredicateFrom (From<?, Annual> annual, CriteriaQuery<?> query, CriteriaBuilder cb) {
            return cb.notEqual(annual.get(Annual_.membership), 0);
        }
    }

    @lombok.Data
    @lombok.NoArgsConstructor @lombok.AllArgsConstructor
    @lombok.EqualsAndHashCode(callSuper=false)
    @JsonTypeName("AnnualWasMemberInYear")
    public static class WasMemberInYear extends Spec<Annual> {
        private Integer year;

        @Override
        public Predicate toPredicateFrom (From<?, Annual> annual, CriteriaQuery<?> query, CriteriaBuilder cb) {
            return cb.and(
                new WasMember().toPredicateFrom(annual, query, cb), 
                cb.equal(annual.get(Annual_.year), year)
            );
        }
    }
}
