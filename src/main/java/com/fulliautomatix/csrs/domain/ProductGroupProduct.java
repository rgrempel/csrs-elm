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
@Table(name = "T_PRODUCT_GROUP_PRODUCT")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id"})
public class ProductGroupProduct implements Serializable {
    // For JsonView
    public interface Scalar {};

    public interface WithProductGroup extends Scalar, ProductGroup.Scalar {};
    public interface WithProduct extends Scalar, Product.Scalar {};

    public interface WithEverything extends WithProductGroup, WithProduct {};

    @Id
    @SequenceGenerator(name="t_product_group_product_id_seq", sequenceName="t_product_group_product_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_product_group_product_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @Column(name="configuration")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String configuration;

    @ManyToOne
    @JoinColumn(name = "product_group_id")
    @lombok.Getter @lombok.Setter
    @JsonView(WithProductGroup.class)
    private ProductGroup productGroup;
    
    @ManyToOne
    @JoinColumn(name = "product_id")
    @lombok.Getter @lombok.Setter
    @JsonView(WithProduct.class)
    private Product product;

}
