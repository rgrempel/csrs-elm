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
 * An Interest.
 */
@Entity
@Table(name = "T_INTEREST")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id", "interest"})
public class Interest implements Serializable {

    @Id
    @SequenceGenerator(name="t_interest_id_seq", sequenceName="t_interest_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_interest_id_seq")
    @lombok.Getter @lombok.Setter
    private Long id;

    @Column(name = "interest", nullable=false)
    @NotNull
    @lombok.Getter @lombok.Setter
    private String interest;

    @ManyToOne
    @lombok.Getter @lombok.Setter
    private Contact contact;

}
