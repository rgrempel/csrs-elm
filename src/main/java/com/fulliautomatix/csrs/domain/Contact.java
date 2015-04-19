package com.fulliautomatix.csrs.domain;

import org.hibernate.annotations.BatchSize;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;

import com.fasterxml.jackson.annotation.*;
import com.voodoodyne.jackson.jsog.JSOGGenerator;

import org.hibernate.validator.constraints.*;
import javax.persistence.*;
import javax.validation.constraints.*;
import java.io.Serializable;
import java.util.*;
import java.util.stream.*;

/**
 * A Contact.
 */
@Entity
@Table(name = "T_CONTACT")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIgnoreProperties(ignoreUnknown = true)
@JsonIdentityInfo(generator=JSOGGenerator.class)
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
    ),
    @NamedEntityGraph(
        name = "Contact.WithAnnualsAndInterestsAndEmail",
        attributeNodes = {
            @NamedAttributeNode("annuals"),
            @NamedAttributeNode("interests"),
            @NamedAttributeNode("contactEmails")
        }
    )
})
@lombok.ToString(of={"id", "salutation", "firstName", "lastName", "department", "affiliation"})
public class Contact implements Serializable, HasOwner {
    // For JsonView
    public interface Scalar {};

    public interface WithAnnuals extends Scalar, Annual.Scalar {};
    public interface WithContactEmails extends Scalar, ContactEmail.WithEmail {};
    public interface WithInterests extends Scalar, Interest.Scalar {};
    public interface WithRenewals extends Scalar, Renewal.Scalar {};

    public interface WithEverything extends WithAnnuals, WithContactEmails, WithInterests, WithRenewals {};

    @Id
    @SequenceGenerator(name="t_contact_id_seq", sequenceName="t_contact_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_contact_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @Column(name = "code")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String code;

    @Column(name = "salutation")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String salutation;

    @Column(name = "first_name")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String firstName;

    @Column(name = "last_name", nullable=false)
    @NotBlank
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String lastName;

    @Column(name = "department")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String department;

    @Column(name = "affiliation")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String affiliation;

    @Column(name = "street")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String street;

    @Column(name = "city")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String city;

    @Column(name = "region")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String region;

    @Column(name = "country")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String country;

    @Column(name = "postal_code")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String postalCode;

    @Column(name = "email")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String email;

    @OneToMany(mappedBy = "contact")
    @lombok.Getter @lombok.Setter
    @BatchSize(size=50)
    @JsonView(WithContactEmails.class)
    private Set<ContactEmail> contactEmails = new HashSet<>();

    @ManyToOne
    @JoinColumn(name = "preferred_email_id")
    @lombok.Getter @lombok.Setter
    @BatchSize(size=50)
    @JsonIgnore
    private Email preferredEmail;

    @Column(name = "omit_name_from_directory", nullable=false)
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Boolean omitNameFromDirectory;

    @Column(name = "omit_email_from_directory", nullable=false)
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Boolean omitEmailFromDirectory;

    @OneToMany(mappedBy="contact")
    @OnDelete(action = OnDeleteAction.CASCADE)
    @lombok.Getter @lombok.Setter
    @BatchSize(size=50)
    @JsonView(WithAnnuals.class)
    private Set<Annual> annuals = new HashSet<>();

    @OneToMany(mappedBy="contact")
    @OnDelete(action = OnDeleteAction.CASCADE)
    @lombok.Getter @lombok.Setter
    @BatchSize(size=50)
    @JsonView(WithInterests.class)
    private Set<Interest> interests = new HashSet<>();
    
    @OneToMany(mappedBy="contact")
    @OnDelete(action = OnDeleteAction.CASCADE)
    @lombok.Getter @lombok.Setter
    @BatchSize(size=50)
    @JsonView(WithRenewals.class)
    private Set<Renewal> renewals = new HashSet<>();
    
    @Override
    public Set<Contact> findOwners () {
        return Stream.of(this).collect(Collectors.toSet());
    }

    public boolean empty (String s) {
        return (s == null) || (s.length() == 0);
    }

    public String fullName () {
        return Stream.of(salutation, firstName, lastName).filter(o -> 
            !empty(o)
        ).collect(Collectors.joining(" "));
    }

    public String fullAddress () {
        String cityState = Stream.of(city, region).filter(o ->
            !empty(o)
        ).collect(Collectors.joining(", "));

        return Stream.of(street, cityState, country, postalCode).filter(o ->
            !empty(o)
        ).collect(Collectors.joining("\n"));
    }

    @PrePersist 
    public void checkDefaults () {
        if (omitNameFromDirectory == null) omitNameFromDirectory = false;
        if (omitEmailFromDirectory == null) omitEmailFromDirectory = false;
    }
}
