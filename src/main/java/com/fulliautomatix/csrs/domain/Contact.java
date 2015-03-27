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
@lombok.ToString(of={"id", "salutation", "firstName", "lastName", "department", "affiliation"})
public class Contact implements Serializable {

    @Id
    @SequenceGenerator(name="t_contact_id_seq", sequenceName="t_contact_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_contact_id_seq")
    @lombok.Getter @lombok.Setter
    private Long id;

    @Column(name = "code")
    @lombok.Getter @lombok.Setter
    private String code;

    @Column(name = "salutation")
    @lombok.Getter @lombok.Setter
    private String salutation;

    @Column(name = "first_name")
    @lombok.Getter @lombok.Setter
    private String firstName;

    @Column(name = "last_name", nullable=false)
    @NotBlank
    @lombok.Getter @lombok.Setter
    private String lastName;

    @Column(name = "department")
    @lombok.Getter @lombok.Setter
    private String department;

    @Column(name = "affiliation")
    @lombok.Getter @lombok.Setter
    private String affiliation;

    @Column(name = "street")
    @lombok.Getter @lombok.Setter
    private String street;

    @Column(name = "city")
    @lombok.Getter @lombok.Setter
    private String city;

    @Column(name = "region")
    @lombok.Getter @lombok.Setter
    private String region;

    @Column(name = "country")
    @lombok.Getter @lombok.Setter
    private String country;

    @Column(name = "postal_code")
    @lombok.Getter @lombok.Setter
    private String postalCode;

    @Column(name = "email")
    @lombok.Getter @lombok.Setter
    private String email;

    @OneToMany(mappedBy = "contact")
    @lombok.Getter @lombok.Setter
    private Set<ContactEmail> contactEmails;

    @ManyToOne
    @JoinColumn(name = "preferred_email_id")
    @lombok.Getter @lombok.Setter
    private Email preferredEmail;

    @Column(name = "omit_name_from_directory", nullable=false)
    @lombok.Getter @lombok.Setter
    private Boolean omitNameFromDirectory;

    @Column(name = "omit_email_from_directory", nullable=false)
    @lombok.Getter @lombok.Setter
    private Boolean omitEmailFromDirectory;

    @OneToMany(mappedBy="contact")
    @OnDelete(action = OnDeleteAction.CASCADE)
    @lombok.Getter @lombok.Setter
    private Set<Annual> annuals;

    @OneToMany(mappedBy="contact")
    @OnDelete(action = OnDeleteAction.CASCADE)
    @lombok.Getter @lombok.Setter
    private Set<Interest> interests;
    
    @PrePersist 
    public void checkDefaults () {
        if (omitNameFromDirectory == null) omitNameFromDirectory = false;
        if (omitEmailFromDirectory == null) omitEmailFromDirectory = false;
    }
}
