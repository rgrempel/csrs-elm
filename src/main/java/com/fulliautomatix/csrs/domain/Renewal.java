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

/**
 * A Renewal.
 */
@Entity
@Table(name = "T_RENEWAL")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id", "year", "duration", "membership", "iter", "rr", "priceInCents"})
public class Renewal extends AbstractAuditingEntity implements Serializable {
    // For JsonView
    public interface Scalar {};
    
    public interface WithAnnuals extends Scalar, Annual.Scalar {};
    public interface WithContact extends Scalar, Contact.Scalar {};

    public interface WithEverything extends WithAnnuals, WithContact {};

    @Id
    @SequenceGenerator(name="t_renewal_id_seq", sequenceName="t_renewal_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_renewal_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @Column(name = "price_in_cents", nullable=false)
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Integer priceInCents;
    
    @OneToMany(mappedBy="renewal")
    @OnDelete(action = OnDeleteAction.CASCADE)
    @lombok.Getter @lombok.Setter
    @BatchSize(size=50)
    @JsonView(WithAnnuals.class)
    private Set<Annual> annuals = new HashSet<>();
    
    @Column(name = "year", nullable=false)
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Integer year;

    @Column(name = "duration", nullable=false)
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Integer duration;

    @Column(name = "membership", nullable=false)
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Integer membership;

    @Column(name = "iter", nullable=false)
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Boolean iter;

    @Column(name = "rr", nullable=false)
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Integer rr;

    @ManyToOne
    @lombok.Getter @lombok.Setter
    @JsonView(WithContact.class)
    private Contact contact;
}
