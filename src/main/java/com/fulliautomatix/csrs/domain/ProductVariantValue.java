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

@Entity
@Table(name = "T_PRODUCT_VARIANT_VALUE")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id"})
public class ProductVariantValue implements Serializable {
    // For JsonView
    public interface Scalar {};

    public interface WithProductVariant extends Scalar, ProductVariant.Scalar {};
    public interface WithProductValue extends Scalar, ProductValue.Scalar {};

    public interface WithEverything extends WithProductVariant, WithProductValue {};

    @Id
    @SequenceGenerator(name="t_product_variant_value_id_seq", sequenceName="t_product_variant_value_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_product_variant_value_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @ManyToOne
    @JoinColumn(name="product_variant_id")
    @lombok.Getter @lombok.Setter
    @JsonView(WithProductVariant.class)
    private ProductVariant productVariant;

    @ManyToOne
    @JoinColumn(name="product_value_id")
    @lombok.Getter @lombok.Setter
    @JsonView(WithProductValue.class)
    private ProductValue productValue;

}
