package com.fulliautomatix.csrs.domain;

import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import com.fasterxml.jackson.annotation.JsonView;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import javax.persistence.*;
import java.io.Serializable;
import java.util.List;

/**
 * A Contact.
 */
@Entity
@Table(name = "T_CONTACT")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIgnoreProperties(ignoreUnknown = true)
@NamedEntityGraph(
    name = "Contact.WithAnnuals",
    attributeNodes = {
        @NamedAttributeNode("annuals")
    }
)
public class Contact implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Column(name = "code")
    private String code;

    @Column(name = "salutation")
    private String salutation;

    @Column(name = "first_name")
    private String firstName;

    @Column(name = "last_name")
    private String lastName;

    @Column(name = "department")
    private String department;

    @Column(name = "affiliation")
    private String affiliation;

    @Column(name = "street")
    private String street;

    @Column(name = "city")
    private String city;

    @Column(name = "region")
    private String region;

    @Column(name = "country")
    private String country;

    @Column(name = "postal_code")
    private String postalCode;

    @Column(name = "email")
    private String email;

    @JsonIgnore
    @OneToMany(mappedBy="contact")
    private List<Annual> annuals;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getDepartment () {
        return department;
    }

    public void setDepartment (String department) {
        this.department = department;
    }

    public String getAffiliation () {
        return affiliation;
    }

    public void setAffiliation (String affiliation) {
        this.affiliation = affiliation;
    }

    public String getSalutation() {
        return salutation;
    }

    public void setSalutation(String salutation) {
        this.salutation = salutation;
    }

    public String getStreet() {
        return street;
    }

    public void setStreet(String street) {
        this.street = street;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getRegion() {
        return region;
    }

    public void setRegion(String region) {
        this.region = region;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getPostalCode() {
        return postalCode;
    }

    public void setPostalCode(String postalCode) {
        this.postalCode = postalCode;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    @JsonProperty
    @JsonManagedReference("contact-annuals")
    public List<Annual> getAnnuals () {
        return this.annuals;
    }

    @JsonIgnore
    public void setAnnuals (List<Annual> annuals) {
        this.annuals = annuals;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        Contact contact = (Contact) o;

        if (id != null ? !id.equals(contact.id) : contact.id != null) return false;

        return true;
    }

    @Override
    public int hashCode() {
        return (int) (id ^ (id >>> 32));
    }

    @Override
    public String toString() {
        return "Contact{" +
                "id=" + id +
                ", code='" + code + "'" +
                ", firstName='" + firstName + "'" +
                ", lastName='" + lastName + "'" +
                ", salutation='" + salutation + "'" +
                ", street='" + street + "'" +
                ", city='" + city + "'" +
                ", region='" + region + "'" +
                ", country='" + country + "'" +
                ", postalCode='" + postalCode + "'" +
                ", email='" + email + "'" +
                '}';
    }
}
