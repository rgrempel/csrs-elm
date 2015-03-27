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

import org.joda.time.DateTime;
import org.hibernate.validator.constraints.NotBlank;
import javax.persistence.*;
import javax.validation.constraints.*;
import java.io.Serializable;
import java.util.Set;

/**
 * An email address for a contact.
 */
@Entity
@Table(name = "T_CONTACT_EMAIL")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(
    generator = ObjectIdGenerators.PropertyGenerator.class, 
    property="id",
    scope = ContactEmail.class
)
@lombok.ToString(of={"id"})
public class ContactEmail implements Serializable {

    @Id
    @SequenceGenerator(name="t_contact_email_id_seq", sequenceName="t_contact_email_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_contact_email_id_seq")
    @lombok.Getter @lombok.Setter
    private Long id;

    @lombok.Getter @lombok.Setter
    @ManyToOne
    @NotNull
    private Email email;

    @lombok.Getter @lombok.Setter
    @ManyToOne
    @NotNull
    private Contact contact;
}
