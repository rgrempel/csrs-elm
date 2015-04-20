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
@Table(name = "T_RENEWAL_ITEM")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id"})
public class RenewalItem implements Serializable {
    // For JsonView
    public interface Scalar {};

    public interface WithRenewal extends Scalar, Renewal.Scalar {};
    public interface WithProductVariantPrice extends Scalar, ProductVariantPrice.Scalar {};

    public interface WithEverything extends WithRenewal, WithProductVariantPrice {};

    @Id
    @SequenceGenerator(name="t_renewal_item_id_seq", sequenceName="t_renewal_item_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_renewal_item_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @ManyToOne
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(WithRenewal.class)
    private Renewal renewal;

    @ManyToOne
    @JoinColumn(name = "product_variant_price_id")
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(WithProductVariantPrice.class)
    private ProductVariantPrice productVariantPrice;

}
