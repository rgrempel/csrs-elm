package com.fulliautomatix.csrs.domain;

import org.hibernate.annotations.BatchSize;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import org.hibernate.annotations.Type;

import com.fasterxml.jackson.annotation.*;
import com.voodoodyne.jackson.jsog.JSOGGenerator;

import org.joda.time.DateTime;
import org.hibernate.validator.constraints.*;
import javax.persistence.*;
import javax.validation.constraints.*;
import java.io.Serializable;
import java.util.*;
import java.util.stream.*;

@Entity
@Table(name = "T_PRODUCT_VARIANT_PRICE")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id"})
public class ProductVariantPrice implements Serializable {
    // For JsonView
    public interface Scalar {};
 
    public interface WithProductVariant extends Scalar, ProductVariant.Scalar {};
    public interface WithRenewalItems extends Scalar, RenewalItem.Scalar {};

    public interface WithEverything extends WithProductVariant, WithRenewalItems {};

    @Id
    @SequenceGenerator(name="t_product_variant_price_id_seq", sequenceName="t_product_variant_price_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_product_variant_price_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @ManyToOne
    @JoinColumn(name="product_variant_id")
    @lombok.Getter @lombok.Setter
    @JsonView(WithProductVariant.class)
    private ProductVariant productVariant;
   
    @OneToMany(mappedBy="productVariantPrice")
    @OnDelete(action=OnDeleteAction.CASCADE)
    @lombok.Getter @lombok.Setter
    @BatchSize(size=50)
    @JsonView(WithRenewalItems.class)
    private Set<RenewalItem> renewalItems = new HashSet<>();

    @Column(name="valid_from", nullable=false)
    @NotNull
    @Type(type="org.jadira.usertype.dateandtime.joda.PersistentDateTime")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private DateTime validFrom;
    
    @Column(name="price_in_cents", nullable=false)
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Integer priceInCents;
    
    @Column(name="three_year_reduction_in_cents", nullable=false)
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Integer threeYearReductionInCents;
}
