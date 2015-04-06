package com.fulliautomatix.csrs.domain;

import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import com.fasterxml.jackson.annotation.JsonView;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;
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

    @Id
    @SequenceGenerator(name="t_email_id_seq", sequenceName="t_email_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_email_id_seq")
    @lombok.Getter @lombok.Setter
    private Long id;

    @Column(name = "email_address", nullable=false)
    @NotBlank
    private String emailAddress;

    @OneToMany(mappedBy="email")
    @JsonIgnore
    @lombok.Getter @lombok.Setter
    private Set<UserEmail> userEmails = new HashSet<>(); 
    
    @OneToMany(mappedBy="email")
    @JsonIgnore
    @lombok.Getter @lombok.Setter
    private Set<ContactEmail> contactEmails = new HashSet<>();

    @OneToMany(mappedBy="preferredEmail")
    @JsonIgnore
    @lombok.Getter @lombok.Setter
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
