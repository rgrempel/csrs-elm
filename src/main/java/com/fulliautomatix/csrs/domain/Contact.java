package com.fulliautomatix.csrs.domain;

import java.io.Serializable;
import java.util.HashSet;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.NamedAttributeNode;
import javax.persistence.NamedEntityGraph;
import javax.persistence.NamedEntityGraphs;
import javax.persistence.OneToMany;
import javax.persistence.PrePersist;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.apache.commons.lang.StringUtils;
import org.joda.time.DateTime;
import org.hibernate.annotations.BatchSize;
import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import org.hibernate.annotations.Type;
import org.hibernate.validator.constraints.NotBlank;

import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonView;
import com.voodoodyne.jackson.jsog.JSOGGenerator;

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
@lombok.ToString(of={"id", "salutation", "firstName", "lastName", "department", "affiliation", "lastVerified"})
public class Contact implements Serializable, HasOwner {
    private static final long serialVersionUID = 1L;

    // For JsonView
    public interface Scalar {};

    public interface WithAnnuals extends Scalar, Annual.Scalar {};
    public interface WithContactEmails extends Scalar, ContactEmail.WithEmail {};
    public interface WithInterests extends Scalar, Interest.Scalar {};
    public interface WithEmailAndInterests extends WithContactEmails, WithInterests {};
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

    @Column(
        name = "plain_first_name",
        insertable = false,
        updatable = false
    )
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String plainFirstName;

    @Column(
        name = "plain_last_name",
        insertable = false,
        updatable = false
    )
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String plainLastName;

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

    @lombok.Getter @lombok.Setter
    @Type(type = "org.jadira.usertype.dateandtime.joda.PersistentDateTime")
    @Column(name = "last_verified")
    @JsonView(Scalar.class)
    private DateTime lastVerified;

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

    public Optional<Annual> annualForYear (Integer year) {
        return annuals.stream().filter(annual ->
            year.equals(annual.getYear())
        ).findFirst();
    }

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

    public void markVerified () {
        setLastVerified(new DateTime());
    }

    public String formattedEmail (String delimiter) {
        return contactEmails.stream().map(ce ->
            ce.getEmail().getEmailAddress()
        ).collect(Collectors.joining(delimiter));
    }

    public String formattedInterests (String delimiter) {
        return interests.stream().map(interest ->
            interest.getInterest()
        ).collect(Collectors.joining(delimiter));
    }

    public String fullName () {
        return Stream.of(salutation, firstName, lastName).filter(o -> 
            !StringUtils.isBlank(o)
        ).collect(Collectors.joining(" "));
    }

    public String abbreviatedStreet () {
        // If more than 2 lines, replace first LF with a comma
        if (StringUtils.countMatches(street, "\n") > 1) {
            return StringUtils.replace(street, "\n", ", ", 1);
        } else {
            return street;
        }
    }

    public String[] plainStreet () {
        return Stream.of(StringUtils.split(street, "\n")).filter(s ->
            !s.equals(affiliation) && !s.equals(department)
        ).toArray(String[]::new);
    }

    public String abbreviatedAddress () {
        StringBuilder sb = new StringBuilder();
       
        String street = abbreviatedStreet();
        if (!StringUtils.isBlank(street)) {
            sb.append(street);
            sb.append("\n");
        }

        String cityState = Stream.of(city, region).filter(o ->
            !StringUtils.isBlank(o)
        ).collect(Collectors.joining(", "));

        if (!StringUtils.isBlank(cityState)) {
            sb.append(cityState);
        }

        if (!StringUtils.isBlank(country)) {
            // If country is not blank, then start a new line with it
            sb.append("\n");
            sb.append(country);
        }

        String delim = "    ";
        if (StringUtils.countMatches(sb.toString(), "\n") < 2) {
            // If we don't have 4 lines already, then put postalCode on own line
            delim = "\n";
        }

        if (!StringUtils.isBlank(postalCode)) {
            // In either event, if the postalCode is present, add it with some spaces
            sb.append(delim);
            sb.append(postalCode);
        }

        return sb.toString();
    }

    public String fullAddress () {
        String cityState = Stream.of(city, region).filter(o ->
            !StringUtils.isBlank(o)
        ).collect(Collectors.joining(", "));

        return Stream.of(street, cityState, country, postalCode).filter(o ->
            !StringUtils.isBlank(o)
        ).collect(Collectors.joining("\n"));
    }

    @PrePersist 
    public void checkDefaults () {
        if (omitNameFromDirectory == null) omitNameFromDirectory = false;
        if (omitEmailFromDirectory == null) omitEmailFromDirectory = false;
    }
}
