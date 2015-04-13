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
@Table(name = "T_PRODUCT_CATEGORY")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id", "code"})
public class ProductCategory implements Serializable {
    // For JsonView
    public interface Scalar {};

    public interface WithProduct extends Scalar, Product.Scalar {};
    public interface WithProductCategoryImplies extends Scalar, ProductCategoryImplies.WithProductCategory {};
    public interface WithProductCategoryPrices extends Scalar, ProductCategoryPrice.Scalar {};
    
    public interface WithEverything extends WithProduct, WithProductCategoryImplies, WithProductCategoryPrices {};

    @Id
    @SequenceGenerator(name="t_product_category_id_seq", sequenceName="t_product_category_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_product_category_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @Column(name = "code", nullable=false)
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Integer code;
    
    @ManyToOne
    @lombok.Getter @lombok.Setter
    @JsonView(WithProduct.class)
    private Product product;

    @OneToMany(mappedBy = "productCategory")
    @lombok.Getter @lombok.Setter
    @BatchSize(size=50)
    @JsonView(WithProductCategoryImplies.class)
    private Set<ProductCategoryImplies> productCategoriesImplies = new HashSet<>();

    @OneToMany(mappedBy = "impliesProductCategory")
    @lombok.Getter @lombok.Setter
    @BatchSize(size=50)
    @JsonView(WithProductCategoryImplies.class)
    private Set<ProductCategoryImplies> productCategoriesImpliedBy = new HashSet<>();
    
    @OneToMany(mappedBy = "productCategory")
    @lombok.Getter @lombok.Setter
    @BatchSize(size=50)
    @JsonView(WithProductCategoryPrices.class)
    private Set<ProductCategoryPrice> productCategoryPrices = new HashSet<>();
}
