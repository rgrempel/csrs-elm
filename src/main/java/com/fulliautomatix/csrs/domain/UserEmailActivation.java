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

/**
 * An email address activation for a user.
 */
@Entity
@Table(name = "T_USER_EMAIL_ACTIVATION")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id", "activationKey", "dateSent", "dateUsed"})
@lombok.EqualsAndHashCode(of={"activationKey"})
public class UserEmailActivation implements Serializable {
    // For JsonView
    public interface Scalar {};

    public interface WithUserEmail extends Scalar, UserEmail.Scalar {};

    @Id
    @SequenceGenerator(name="t_user_email_activation_id_seq", sequenceName="t_user_email_activation_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_user_email_activation_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @lombok.Getter @lombok.Setter
    @ManyToOne
    @NotNull
    @JoinColumn(name = "user_email_id")
    @JsonView(WithUserEmail.class)
    private UserEmail userEmail;

    @lombok.Getter @lombok.Setter
    @NotNull
    @Column(name = "activation_key")
    @JsonView(Scalar.class)
    private String activationKey;

    @lombok.Getter @lombok.Setter
    @Type(type = "org.jadira.usertype.dateandtime.joda.PersistentDateTime")
    @Column(name = "date_sent")
    @JsonView(Scalar.class)
    private DateTime dateSent;
    
    @lombok.Getter @lombok.Setter
    @Type(type = "org.jadira.usertype.dateandtime.joda.PersistentDateTime")
    @Column(name = "date_used")
    @JsonView(Scalar.class)
    private DateTime dateUsed;
}
