package com.fulliautomatix.csrs.domain;

import com.fasterxml.jackson.annotation.JsonIgnore;
import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;

import javax.persistence.*;
import java.io.Serializable;
import java.util.HashSet;
import java.util.Set;

/**
 * A Annual.
 */
@Entity
@Table(name = "T_ANNUAL")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
public class Annual implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Column(name = "year")
    private Integer year;

    @Column(name = "membership")
    private Integer membership;

    @Column(name = "iter")
    private Boolean iter;

    @Column(name = "rr")
    private Integer rr;

    @ManyToOne
    private Contact contact;

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
