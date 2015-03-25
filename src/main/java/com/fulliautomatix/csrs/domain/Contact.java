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

import org.hibernate.validator.constraints.NotBlank;
import javax.persistence.*;
import javax.validation.constraints.*;
import java.io.Serializable;
import java.util.Set;

import lombok.Getter;
import lombok.Setter;
import lombok.EqualsAndHashCode;
import lombok.ToString;

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
@ToString(of={"id", "salutation", "firstName", "lastName", "department", "affiliation"})
public class Contact implements Serializable {

    @Id
    @SequenceGenerator(name="t_contact_id_seq", sequenceName="t_contact_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_contact_id_seq")
    @Getter @Setter
    private Long id;

    @Getter @Setter
    @Column(name = "code")
    private String code;

    @Getter @Setter
    @Column(name = "salutation")
    private String salutation;

    @Getter @Setter
    @Column(name = "first_name")
    private String firstName;

    @Getter @Setter
    @Column(name = "last_name", nullable=false)
    @NotBlank
    private String lastName;

    @Getter @Setter
    @Column(name = "department")
    private String department;

    @Getter @Setter
    @Column(name = "affiliation")
    private String affiliation;

    @Getter @Setter
    @Column(name = "street")
    private String street;

    @Getter @Setter
    @Column(name = "city")
    private String city;

    @Getter @Setter
    @Column(name = "region")
    private String region;

    @Getter @Setter
    @Column(name = "country")
    private String country;

    @Getter @Setter
    @Column(name = "postal_code")
    private String postalCode;

    @Getter @Setter
    @Column(name = "email")
    private String email;

    @Getter @Setter
    @Column(name = "omit_name_from_directory", nullable=false)
    private Boolean omitNameFromDirectory;

    @Getter @Setter
    @Column(name = "omit_email_from_directory", nullable=false)
    private Boolean omitEmailFromDirectory;

    @Getter @Setter
    @OneToMany(mappedBy="contact")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Set<Annual> annuals;

    @Getter @Setter
    @OneToMany(mappedBy="contact")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Set<Interest> interests;
    
    @PrePersist 
    public void setDefaults () {
        if (omitNameFromDirectory == null) omitNameFromDirectory = false;
        if (omitEmailFromDirectory == null) omitEmailFromDirectory = false;
    }
}
