package com.fulliautomatix.csrs.domain;

import org.hibernate.annotations.Type;
import org.hibernate.annotations.BatchSize;
import org.joda.time.LocalDateTime;
import javax.persistence.*;
import javax.validation.constraints.NotNull;
import java.util.HashMap;
import java.util.Map;

/**
 * Persist AuditEvent managed by the Spring Boot actuator
 * @see org.springframework.boot.actuate.audit.AuditEvent
 */
@Entity
@Table(name = "T_PERSISTENT_AUDIT_EVENT")
public class PersistentAuditEvent  {

    @Id
    @SequenceGenerator(name="t_persistent_audit_event_event_id_seq", sequenceName="t_persistent_audit_event_event_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_persistent_audit_event_event_id_seq")
    @Column(name = "event_id")
    @lombok.Getter @lombok.Setter
    private Long id;

    @NotNull
    @Column(nullable = false)
    @lombok.Getter @lombok.Setter
    private String principal;

    @Column(name = "event_date")
    @Type(type = "org.jadira.usertype.dateandtime.joda.PersistentLocalDateTime")
    @lombok.Getter @lombok.Setter
    private LocalDateTime auditEventDate;

    @Column(name = "event_type")
    @lombok.Getter @lombok.Setter
    private String auditEventType;

    @ElementCollection
    @MapKeyColumn(name="name")
    @Column(name="value")
    @CollectionTable(name="T_PERSISTENT_AUDIT_EVENT_DATA", joinColumns=@JoinColumn(name="event_id"))
    @lombok.Getter @lombok.Setter
    @BatchSize(size = 100)
    private Map<String, String> data = new HashMap<>();
}
