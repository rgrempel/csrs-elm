package com.fulliautomatix.csrs.domain;

import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import com.fasterxml.jackson.annotation.*;
import com.voodoodyne.jackson.jsog.JSOGGenerator;

import org.hibernate.validator.constraints.NotBlank;
import javax.persistence.*;
import javax.validation.constraints.*;
import java.io.Serializable;
import java.util.Set;
import java.util.HashSet;

/**
 * An email address.
 */
@Entity
@Table(name = "T_EMAIL")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id", "emailAddress"})
@lombok.EqualsAndHashCode(of={"emailAddress"})
@lombok.NoArgsConstructor
public class Email implements Serializable {
    // For JsonView
    public interface Scalar {};

    public interface WithUserEmails extends Scalar, UserEmail.Scalar {};
    public interface WithContactEmails extends Scalar, ContactEmail.Scalar {};

    public interface WithEverything extends WithUserEmails, WithContactEmails {};

    @Id
    @SequenceGenerator(name="t_email_id_seq", sequenceName="t_email_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_email_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @Column(name = "email_address", nullable=false)
    @NotBlank
    @JsonView(Scalar.class)
    private String emailAddress;

    @OneToMany(mappedBy="email")
    @lombok.Getter @lombok.Setter
    @JsonView(WithUserEmails.class)
    private Set<UserEmail> userEmails = new HashSet<>(); 
    
    @OneToMany(mappedBy="email")
    @lombok.Getter @lombok.Setter
    @JsonView(WithContactEmails.class)
    private Set<ContactEmail> contactEmails = new HashSet<>();

    @OneToMany(mappedBy="preferredEmail")
    @lombok.Getter @lombok.Setter
    @JsonIgnore
    private Set<Contact> preferredByContacts = new HashSet<>();

    public String getEmailAddress () {
        if (emailAddress == null) {
            return null;
        } else {
            return emailAddress.trim().toLowerCase();
        }
    }

    public void setEmailAddress (String address) {
        if (address == null) {
            this.emailAddress = null;
        } else {
            this.emailAddress = address.trim().toLowerCase();
        }
    }
}
