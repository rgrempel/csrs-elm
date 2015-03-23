package com.fulliautomatix.csrs.domain;

import com.fasterxml.jackson.annotation.JsonIgnore;
import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;

import javax.persistence.*;
import java.io.Serializable;
import java.util.HashSet;
import java.util.Set;

/**
 * An Interest.
 */
@Entity
@Table(name = "T_INTEREST")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(
    generator = ObjectIdGenerators.PropertyGenerator.class, 
    property="id",
    scope = Interest.class
)
public class Interest implements Serializable {

    @Id
    @SequenceGenerator(name="t_interest_id_seq", sequenceName="t_interest_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_interest_id_seq")
    private Long id;

    @Column(name = "interest")
    private String interest;

    @ManyToOne
    private Contact contact;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getInterest () {
        return this.interest;
    }

    public void setInterest (String interest) {
        this.interest = interest;
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

        Interest other = (Interest) o;

        if (id != null ? !id.equals(other.id) : other.id != null) return false;

        return true;
    }

    @Override
    public int hashCode() {
        return (int) (id ^ (id >>> 32));
    }

    @Override
    public String toString() {
        return "Interest{" +
                "id=" + id +
                ", interest='" + interest + "'" +
                '}';
    }
}
