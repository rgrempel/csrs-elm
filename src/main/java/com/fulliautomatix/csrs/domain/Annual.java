package com.fulliautomatix.csrs.domain;

import com.fasterxml.jackson.annotation.*;
import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import com.voodoodyne.jackson.jsog.JSOGGenerator;

import javax.persistence.*;
import javax.validation.constraints.*;
import java.io.Serializable;
import java.util.*;
import java.util.stream.*;

/**
 * A Annual.
 */
@Entity
@Table(name = "T_ANNUAL")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id", "year", "membership", "iter", "rr"})
public class Annual implements Serializable, HasOwner {
    // For JsonView
    public interface Scalar {};

    public interface WithContact extends Scalar, Contact.Scalar {};
    public interface WithRenewal extends Scalar, Renewal.Scalar {};
    
    public interface WithEverything extends WithContact, WithRenewal {};

    @Id
    @SequenceGenerator(name="t_annual_id_seq", sequenceName="t_annual_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_annual_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @Column(name = "year", nullable=false)
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Integer year;

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

    @ManyToOne
    @lombok.Getter @lombok.Setter
    @JsonView(WithRenewal.class)
    private Renewal renewal;

    @Override
    public Set<Contact> findOwners () {
        return Stream.of(contact).collect(Collectors.toSet());
    }

    @PrePersist 
    public void checkDefaults () {
        if (membership == null) membership = 0;
        if (iter == null) iter = false;
        if (rr == null) rr = 0;
    }
}
