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
 * A Product Variant.
 */
@Entity
@Table(name = "T_PRODUCT_VARIANT")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id", "code"})
public class ProductVariant implements Serializable {
    // For JsonView
    public interface Scalar {};

    public interface WithProduct extends Scalar, Product.Scalar {};
    public interface WithProductVariantPrices extends Scalar, ProductVariantPrice.Scalar {};
    public interface WithProductVariantValues extends Scalar, ProductVariantValue.WithEverything {};

    public interface WithEverything extends WithProduct, WithProductVariantPrices, WithProductVariantValues {};
    
    @Id
    @SequenceGenerator(name="t_product_variant_id_seq", sequenceName="t_product_variant_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_product_variant_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @ManyToOne
    @lombok.Getter @lombok.Setter
    @JsonView(WithProduct.class)
    private Product product;

    @Column(name="code", nullable=false)
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String code;

    @OneToMany(mappedBy="productVariant")
    @OnDelete(action = OnDeleteAction.CASCADE)
    @lombok.Getter @lombok.Setter
    @BatchSize(size=50)
    @JsonView(WithProductVariantPrices.class)
    private Set<ProductVariantPrice> productVariantPrices = new HashSet<>();

    @OneToMany(mappedBy="productVariant")
    @OnDelete(action = OnDeleteAction.CASCADE)
    @lombok.Getter @lombok.Setter
    @BatchSize(size=50)
    @JsonView(WithProductVariantValues.class)
    private Set<ProductVariantValue> productVariantValues = new HashSet<>();
}
