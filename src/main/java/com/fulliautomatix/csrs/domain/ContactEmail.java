package com.fulliautomatix.csrs.domain;

import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import com.fasterxml.jackson.annotation.*;
import com.voodoodyne.jackson.jsog.JSOGGenerator;

import org.joda.time.DateTime;
import org.hibernate.validator.constraints.NotBlank;
import javax.persistence.*;
import javax.validation.constraints.*;
import java.io.Serializable;
import java.util.*;
import java.util.stream.*;

/**
 * An email address for a contact.
 */
@Entity
@Table(name = "T_CONTACT_EMAIL")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id"})
public class ContactEmail implements Serializable, HasOwner {
    // For JsonView
    public interface Scalar {};

    public interface WithEmail extends Scalar, Email.Scalar {};
    public interface WithContact extends Scalar, Contact.Scalar {};

    public interface WithEverything extends WithEmail, WithContact {};

    @Id
    @SequenceGenerator(name="t_contact_email_id_seq", sequenceName="t_contact_email_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_contact_email_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @lombok.Getter @lombok.Setter
    @ManyToOne
    @NotNull
    @JsonView(WithEmail.class)
    private Email email;

    @lombok.Getter @lombok.Setter
    @ManyToOne
    @NotNull
    @JsonView(WithContact.class)
    private Contact contact;
    
    @Override
    public Set<Contact> findOwners () {
        return Stream.of(contact).collect(Collectors.toSet());
    }
}
