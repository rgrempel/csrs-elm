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
@Table(name = "T_PRODUCT_VALUE_IMPLIES")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id"})
public class ProductValueImplies implements Serializable {
    // For JsonView
    public interface Scalar {};

    public interface WithProductValue extends Scalar, ProductValue.Scalar {};

    @Id
    @SequenceGenerator(name="t_product_value_implies_id_seq", sequenceName="t_product_value_implies_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_product_value_implies_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "product_value_id")
    @lombok.Getter @lombok.Setter
    @JsonView(WithProductValue.class)
    private ProductValue productValue;
    
    @ManyToOne
    @JoinColumn(name = "implies_product_value_id")
    @lombok.Getter @lombok.Setter
    @JsonView(WithProductValue.class)
    private ProductValue impliesProductValue;
}
