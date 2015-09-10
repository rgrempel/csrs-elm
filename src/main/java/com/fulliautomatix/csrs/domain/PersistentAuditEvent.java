package com.fulliautomatix.csrs.domain;

import java.util.HashMap;
import java.util.Map;

import javax.persistence.CollectionTable;
import javax.persistence.Column;
import javax.persistence.ElementCollection;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.MapKeyColumn;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.validation.constraints.NotNull;

import org.hibernate.annotations.BatchSize;
import org.hibernate.annotations.Type;
import org.joda.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonView;

/**
 * Persist AuditEvent managed by the Spring Boot actuator
 * @see org.springframework.boot.actuate.audit.AuditEvent
 */
@Entity
@Table(name = "T_PERSISTENT_AUDIT_EVENT")
public class PersistentAuditEvent  {
    public interface Scalar {};
    public interface WithData extends Scalar {};

    @Id
    @SequenceGenerator(name="t_persistent_audit_event_event_id_seq", sequenceName="t_persistent_audit_event_event_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_persistent_audit_event_event_id_seq")
    @Column(name = "event_id")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @NotNull
    @Column(nullable = false)
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String principal;

    @Column(name = "event_date")
    @Type(type = "org.jadira.usertype.dateandtime.joda.PersistentLocalDateTime")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private LocalDateTime auditEventDate;

    @Column(name = "event_type")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String auditEventType;

    @ElementCollection
    @MapKeyColumn(name="name")
    @Column(name="value")
    @CollectionTable(name="T_PERSISTENT_AUDIT_EVENT_DATA", joinColumns=@JoinColumn(name="event_id"))
    @lombok.Getter @lombok.Setter
    @BatchSize(size = 100)
    @JsonView(WithData.class)
    private Map<String, String> data = new HashMap<>();
}
