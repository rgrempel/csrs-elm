package com.fulliautomatix.csrs.domain;

import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import com.fasterxml.jackson.annotation.JsonView;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;

import javax.persistence.*;
import javax.validation.constraints.*;
import java.io.Serializable;
import java.util.Set;

/**
 * A Contact.
 */
@Entity
@Table(name = "T_CONTACT")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIgnoreProperties(ignoreUnknown = true)
@JsonIdentityInfo(
    generator = ObjectIdGenerators.PropertyGenerator.class, 
    property="id",
    scope = Contact.class
)
@NamedEntityGraphs({
    @NamedEntityGraph(
        name = "Contact.WithAnnuals",
        attributeNodes = {
            @NamedAttributeNode("annuals")
        }
    ),
    @NamedEntityGraph(
        name = "Contact.WithAnnualsAndInterests",
        attributeNodes = {
            @NamedAttributeNode("annuals"),
            @NamedAttributeNode("interests")
        }
    )
})
public class Contact implements Serializable {

    @Id
    @SequenceGenerator(name="t_contact_id_seq", sequenceName="t_contact_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_contact_id_seq")
    private Long id;

    @Column(name = "code")
    private String code;

    @Column(name = "salutation")
    private String salutation;

    @Column(name = "first_name")
    private String firstName;

    @Column(name = "last_name", nullable=false)
    @NotNull
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

    @Column(name = "omit_name_from_directory", nullable=false)
    private Boolean omitNameFromDirectory;

    @Column(name = "omit_email_from_directory", nullable=false)
    private Boolean omitEmailFromDirectory;

    @OneToMany(mappedBy="contact")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Set<Annual> annuals;

    @OneToMany(mappedBy="contact")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Set<Interest> interests;
    
    @PrePersist 
    public void setDefaults () {
        if (omitNameFromDirectory == null) omitNameFromDirectory = false;
        if (omitEmailFromDirectory == null) omitEmailFromDirectory = false;
    }    
        
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

    public Boolean getOmitNameFromDirectory () {
        return omitNameFromDirectory;
    }

    public void setOmitNameFromDirectory (Boolean omitNameFromDirectory) {
        this.omitNameFromDirectory = omitNameFromDirectory;
    }

    public Boolean getOmitEmailFromDirectory () {
        return omitEmailFromDirectory;
    }

    public void setOmitEmailFromDirectory (Boolean omitEmailFromDirectory) {
        this.omitEmailFromDirectory = omitEmailFromDirectory;
    }

    public Set<Annual> getAnnuals () {
        return this.annuals;
    }

    public void setAnnuals (Set<Annual> annuals) {
        this.annuals = annuals;
    }

    public Set<Interest> getInterests () {
        return this.interests;
    }

    public void setInterests (Set<Interest> interests) {
        this.interests = interests;
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
