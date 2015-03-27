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
import org.hibernate.annotations.Type;
import javax.persistence.*;
import javax.validation.constraints.*;
import java.io.Serializable;
import java.util.Set;

/**
 * An email address for a user.
 */
@Entity
@Table(name = "T_USER_EMAIL")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(
    generator = ObjectIdGenerators.PropertyGenerator.class, 
    property="id",
    scope = UserEmail.class
)
@lombok.ToString(of={"id", "activated"})
public class UserEmail implements Serializable {

    @Id
    @SequenceGenerator(name="t_user_email_id_seq", sequenceName="t_user_email_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_user_email_id_seq")
    @lombok.Getter @lombok.Setter
    private Long id;

    @ManyToOne
    @NotNull
    @lombok.Getter @lombok.Setter
    private Email email;

    // Could be null in cases where we want to validate an email for a user
    // that doesn't exist yet.
    @ManyToOne
    @lombok.Getter @lombok.Setter
    private User user;

    @Type(type = "org.jadira.usertype.dateandtime.joda.PersistentDateTime")
    @Column(name = "activated")
    @lombok.Getter @lombok.Setter
    private DateTime activated;
}
