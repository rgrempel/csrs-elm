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
@Table(name = "T_PRODUCT")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id", "code", "order"})
@lombok.EqualsAndHashCode(of={"code"})
public class Product implements Serializable {
    // For JsonView
    public interface Scalar {};

    public interface WithProductVariants extends Scalar, ProductVariant.Scalar {};
    public interface WithProductPrereqs extends Scalar, ProductPrereq.WithProduct {};

    public interface WithEverything extends WithProductVariants, WithProductPrereqs {};
    public interface DeepTree extends WithEverything,
                                      ProductVariant.WithEverything, 
                                      ProductVariantValue.WithEverything,
                                      ProductValue.WithEverything,
                                      ProductValueImplies.WithProductValue,
                                      ProductVariable.WithProductValues,
                                      ProductVariantPrice.WithProductVariant {};

    @Id
    @SequenceGenerator(name="t_product_id_seq", sequenceName="t_product_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_product_id_seq")
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

    @OneToMany(mappedBy = "product")
    @lombok.Getter @lombok.Setter
    @BatchSize(size=50)
    @JsonView(WithProductVariants.class)
    private Set<ProductVariant> productVariants = new HashSet<>();

    @OneToMany(mappedBy="product")
    @lombok.Getter @lombok.Setter
    @BatchSize(size=50)
    @JsonView(WithProductPrereqs.class)
    private Set<ProductPrereq> productPrereqRequires = new HashSet<>();

    @OneToMany(mappedBy="requiresProduct")
    @lombok.Getter @lombok.Setter
    @BatchSize(size=50)
    @JsonView(WithProductPrereqs.class)
    private Set<ProductPrereq> productPrereqRequiredBy = new HashSet<>();

}
