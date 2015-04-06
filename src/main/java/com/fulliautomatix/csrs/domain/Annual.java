package com.fulliautomatix.csrs.domain;

import com.fasterxml.jackson.annotation.JsonIgnore;
import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;
import com.voodoodyne.jackson.jsog.JSOGGenerator;

import javax.persistence.*;
import javax.validation.constraints.*;
import java.io.Serializable;
import java.util.HashSet;
import java.util.Set;

/**
 * A Annual.
 */
@Entity
@Table(name = "T_ANNUAL")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id", "year", "membership", "iter", "rr"})
public class Annual implements Serializable {

    @Id
    @SequenceGenerator(name="t_annual_id_seq", sequenceName="t_annual_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_annual_id_seq")
    @lombok.Getter @lombok.Setter
    private Long id;

    @Column(name = "year", nullable=false)
    @NotNull
    @lombok.Getter @lombok.Setter
    private Integer year;

    @Column(name = "membership", nullable=false)
    @lombok.Getter @lombok.Setter
    private Integer membership;

    @Column(name = "iter", nullable=false)
    @lombok.Getter @lombok.Setter
    private Boolean iter;

    @Column(name = "rr", nullable=false)
    @lombok.Getter @lombok.Setter
    private Integer rr;

    @ManyToOne
    @lombok.Getter @lombok.Setter
    private Contact contact;

    @PrePersist 
    public void checkDefaults () {
        if (membership == null) membership = 0;
        if (iter == null) iter = false;
        if (rr == null) rr = 0;
    }
}
