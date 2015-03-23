package com.fulliautomatix.csrs.domain;

import com.fasterxml.jackson.annotation.JsonIgnore;
import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;

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
@JsonIdentityInfo(
    generator = ObjectIdGenerators.PropertyGenerator.class, 
    property="id",
    scope = Annual.class
)
public class Annual implements Serializable {

    @Id
    @SequenceGenerator(name="t_annual_id_seq", sequenceName="t_annual_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_annual_id_seq")
    private Long id;

    @Column(name = "year", nullable=false)
    @NotNull
    private Integer year;

    @Column(name = "membership", nullable=false)
    private Integer membership;

    @Column(name = "iter", nullable=false)
    private Boolean iter;

    @Column(name = "rr", nullable=false)
    private Integer rr;

    @ManyToOne
    private Contact contact;

    @PrePersist 
    public void setDefaults () {
        if (membership == null) membership = 0;
        if (iter == null) iter = false;
        if (rr == null) rr = 0;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Integer getYear() {
        return year;
    }

    public void setYear(Integer year) {
        this.year = year;
    }

    public Integer getMembership() {
        return membership;
    }

    public void setMembership(Integer membership) {
        this.membership = membership;
    }

    public Boolean getIter() {
        return iter;
    }

    public void setIter(Boolean iter) {
        this.iter = iter;
    }

    public Integer getRR() {
        return rr;
    }

    public void setRR(Integer rr) {
        this.rr = rr;
    }

    public Contact getContact() {
        return contact;
    }

    public void setContact(Contact contact) {
        this.contact = contact;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        Annual annual = (Annual) o;

        if (id != null ? !id.equals(annual.id) : annual.id != null) return false;

        return true;
    }

    @Override
    public int hashCode() {
        return (int) (id ^ (id >>> 32));
    }

    @Override
    public String toString() {
        return "Annual{" +
                "id=" + id +
                ", year='" + year + "'" +
                ", membership='" + membership + "'" +
                ", iter='" + iter + "'" +
                ", rr='" + rr + "'" +
                '}';
    }
}
