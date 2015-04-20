package com.fulliautomatix.csrs.domain;

import org.hibernate.annotations.BatchSize;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;

import com.fasterxml.jackson.annotation.*;
import com.voodoodyne.jackson.jsog.JSOGGenerator;

import org.hibernate.validator.constraints.*;
import javax.persistence.*;
import javax.validation.constraints.*;
import java.io.Serializable;
import java.util.*;
import java.util.stream.*;

/**
 * A Product Value.
 */
@Entity
@Table(name = "T_PRODUCT_VALUE")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id", "code", "order"})
@lombok.EqualsAndHashCode(of={"code"})
public class ProductValue implements Serializable {
    // For JsonView
    public interface Scalar {};

    public interface WithProductVariable extends Scalar, ProductVariable.Scalar {};
    public interface WithProductValueImplies extends Scalar, ProductValueImplies.Scalar {};

    public interface WithEverything extends WithProductVariable, WithProductValueImplies {};

    @Id
    @SequenceGenerator(name="t_product_value_id_seq", sequenceName="t_product_value_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_product_value_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @Column(name="code", nullable=false)
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String code;

    @Column(name="order")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Integer order;

    @ManyToOne
    @JoinColumn(name="product_variable_id")
    @lombok.Getter @lombok.Setter
    @JsonView(WithProductVariable.class)
    private ProductVariable productVariable;
    
    @OneToMany(mappedBy="productValue")
    @lombok.Getter @lombok.Setter
    @BatchSize(size=50)
    @JsonView(WithProductValueImplies.class)
    private Set<ProductValueImplies> productValueImplies = new HashSet<>();

    @OneToMany(mappedBy="impliesProductValue")
    @lombok.Getter @lombok.Setter
    @BatchSize(size=50)
    @JsonView(WithProductValueImplies.class)
    private Set<ProductValueImplies> productValueImpliedBy = new HashSet<>();
}
