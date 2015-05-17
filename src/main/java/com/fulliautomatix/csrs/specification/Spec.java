package com.fulliautomatix.csrs.specification;

import java.util.Set;

import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.From;
import javax.persistence.criteria.Predicate;
import javax.persistence.criteria.Root;

import org.springframework.data.jpa.domain.Specification;

import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import com.fasterxml.jackson.annotation.JsonTypeName;

@JsonTypeInfo(
    use = JsonTypeInfo.Id.NAME,
    include = JsonTypeInfo.As.PROPERTY,
    property = "@type"
)
@JsonSubTypes({
    @JsonSubTypes.Type(AnnualSpec.WasMember.class),
    @JsonSubTypes.Type(AnnualSpec.HadMembershipTypeInYear.class),
    @JsonSubTypes.Type(ContactSpec.WasEverMember.class),
    @JsonSubTypes.Type(ContactSpec.WasMember.class),
    @JsonSubTypes.Type(ContactSpec.WasMemberInAll.class),
    @JsonSubTypes.Type(ContactSpec.WasMemberInNone.class),
    @JsonSubTypes.Type(ContactSpec.WasMemberInYear.class),
    @JsonSubTypes.Type(ContactSpec.HadMembershipTypeInYear.class),
    @JsonSubTypes.Type(Spec.NegatedSpec.class),
    @JsonSubTypes.Type(Spec.AndSpec.class),
    @JsonSubTypes.Type(Spec.OrSpec.class)
})
public abstract class Spec<T> implements Specification<T> {
    
    @Override
    public Predicate toPredicate (Root<T> contact, CriteriaQuery<?> query, CriteriaBuilder cb) {
        return toPredicateFrom(contact, query, cb);
    }

    public abstract Predicate toPredicateFrom (From<?,T> from, CriteriaQuery<?> query, CriteriaBuilder cb);

    @lombok.Data
    @lombok.EqualsAndHashCode(callSuper=false)
    @lombok.NoArgsConstructor @lombok.AllArgsConstructor
    @JsonTypeName("Spec.Not")
    public static class NegatedSpec<T> extends Spec<T> {
        @lombok.NonNull
        private Spec<T> spec;
        
        @Override
        public Predicate toPredicateFrom (From<?, T> from, CriteriaQuery<?> query, CriteriaBuilder cb) {    
            return spec.toPredicateFrom(from, query, cb).not();
        }
    }

    @lombok.Data
    @lombok.EqualsAndHashCode(callSuper=false)
    @lombok.NoArgsConstructor @lombok.AllArgsConstructor
    @JsonTypeName("Spec.And")
    public static class AndSpec<T> extends Spec<T> {
        @lombok.NonNull
        private Set<Spec<T>> specs;
        
        @Override
        public Predicate toPredicateFrom (From<?, T> from, CriteriaQuery<?> query, CriteriaBuilder cb) {    
            return cb.and(
                specs.stream().map(spec -> 
                    spec.toPredicateFrom(from, query, cb)
                ).toArray(size -> new Predicate[size])
            );
        }
    }
    
    @lombok.Data
    @lombok.EqualsAndHashCode(callSuper=false)
    @lombok.NoArgsConstructor @lombok.AllArgsConstructor
    @JsonTypeName("Spec.Or")
    public static class OrSpec<T> extends Spec<T> {
        @lombok.NonNull
        private Set<Spec<T>> specs;
        
        @Override
        public Predicate toPredicateFrom (From<?, T> from, CriteriaQuery<?> query, CriteriaBuilder cb) {    
            return cb.or(
                specs.stream().map(spec -> 
                    spec.toPredicateFrom(from, query, cb)
                ).toArray(size -> new Predicate[size])
            );
        }
    }
}
