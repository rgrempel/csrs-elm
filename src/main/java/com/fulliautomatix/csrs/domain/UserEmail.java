package com.fulliautomatix.csrs.domain;

import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import com.fasterxml.jackson.annotation.*;
import com.voodoodyne.jackson.jsog.JSOGGenerator;

import org.joda.time.DateTime;
import org.hibernate.validator.constraints.NotBlank;
import org.hibernate.annotations.Type;
import javax.persistence.*;
import javax.validation.constraints.*;
import java.io.Serializable;
import java.util.Set;
import java.util.HashSet;

/**
 * An email address for a user.
 */
@Entity
@Table(name = "T_USER_EMAIL")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id", "activated"})
public class UserEmail implements Serializable {
    // For JsonView
    public interface Scalar {};

    public interface WithEmail extends Scalar, Email.Scalar {};
    public interface WithUser extends Scalar, User.Scalar {};
    public interface WithUserEmailActivations extends Scalar, UserEmailActivation.Scalar {};

    public interface WithEverything extends WithEmail, WithUser, WithUserEmailActivations {};

    @Id
    @SequenceGenerator(name="t_user_email_id_seq", sequenceName="t_user_email_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_user_email_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @ManyToOne
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(WithEmail.class)
    private Email email;

    // Could be null in cases where we want to validate an email for a user
    // that doesn't exist yet.
    @ManyToOne
    @lombok.Getter @lombok.Setter
    @JsonView(WithUser.class)
    private User user;

    @Type(type = "org.jadira.usertype.dateandtime.joda.PersistentDateTime")
    @Column(name = "activated")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private DateTime activated;

    @OneToMany(mappedBy = "userEmail")
    @lombok.Getter @lombok.Setter
    @JsonView(WithUserEmailActivations.class)
    private Set<UserEmailActivation> userEmailActivations = new HashSet<>();
}
