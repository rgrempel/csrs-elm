package com.fulliautomatix.csrs.domain;

import org.hibernate.annotations.Type;
import org.hibernate.annotations.BatchSize;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import org.joda.time.DateTime;

import com.fasterxml.jackson.annotation.*;
import com.voodoodyne.jackson.jsog.JSOGGenerator;

import org.hibernate.validator.constraints.*;
import javax.persistence.*;
import javax.validation.constraints.*;
import java.io.Serializable;
import java.util.*;
import java.util.stream.*;

/**
 * A sent email.
 */
@Entity
@Table(name = "T_SENT_EMAIL")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id", "emailFrom", "emailTo", "emailSubject"})
public class SentEmail extends AbstractAuditingEntity implements Serializable {
    // For JsonView
    public interface Scalar {};
    public interface WithContent extends Scalar {};
    
    @Id
    @SequenceGenerator(name="t_sent_email_id_seq", sequenceName="t_sent_email_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_sent_email_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @Column(name="email_to", nullable=false)
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String emailTo; 
    
    @Column(name="email_from", nullable=false)
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String emailFrom;

    @Column(name="email_subject", nullable=false)
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String emailSubject;

    @Column(name="email_content", nullable=false)
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(WithContent.class)
    private String emailContent;
    
    @Type(type="org.jadira.usertype.dateandtime.joda.PersistentDateTime")
    @Column(name="email_sent")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private DateTime emailSent;
}
