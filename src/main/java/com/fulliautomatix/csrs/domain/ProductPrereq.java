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
@Table(name = "T_PRODUCT_PREREQ")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id"})
public class ProductPrereq implements Serializable {
    // For JsonView
    public interface Scalar {};

    public interface WithProduct extends Scalar, Product.Scalar {};
 
    @Id
    @SequenceGenerator(name="t_product_prereq_id_seq", sequenceName="t_product_prereq_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_product_prereq_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @ManyToOne
    @lombok.Getter @lombok.Setter
    @JsonView(WithProduct.class)
    Product product;

    @ManyToOne
    @JoinColumn(name="requires_product_id")
    @lombok.Getter @lombok.Setter
    @JsonView(WithProduct.class)
    Product requiresProduct;
}
