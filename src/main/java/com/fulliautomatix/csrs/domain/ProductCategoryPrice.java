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
@Table(name = "T_PRODUCT_CATEGORY_PRICE")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id"})
public class ProductCategoryPrice implements Serializable {
    // For JsonView
    public interface Scalar {};
 
    public interface WithProductCategory extends Scalar, ProductCategory.Scalar {};

    @Id
    @SequenceGenerator(name="t_product_category_price_id_seq", sequenceName="t_product_category_price_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_product_category_price_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "product_category_id")
    @lombok.Getter @lombok.Setter
    @JsonView(WithProductCategory.class)
    private ProductCategory productCategory;
   
    @Column(name = "start_year", nullable=false)
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Integer startYear;
    
    @Column(name = "price_in_cents", nullable=false)
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Integer priceInCents;
    
    @Column(name = "three_year_reduction_in_cents", nullable=false)
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Integer threeYearReductionInCents;
}
