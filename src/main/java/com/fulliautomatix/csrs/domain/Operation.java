package com.fulliautomatix.csrs.domain;

import org.hibernate.annotations.BatchSize;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;

import com.fasterxml.jackson.annotation.*;
import com.voodoodyne.jackson.jsog.JSOGGenerator;

import org.hibernate.validator.constraints.*;
import javax.persistence.*;
import javax.validation.constraints.*;
import java.io.Serializable;
import java.util.*;
import java.util.stream.*;

/**
 * An Operation.
 */
@Entity
@Table(name = "T_OPERATION")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id", "operationType", "operationUrl"})
public class Operation extends AbstractAuditingEntity implements Serializable {
    // For JsonView
    public interface Scalar {};
    
    @Id
    @SequenceGenerator(name="t_operation_id_seq", sequenceName="t_operation_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_operation_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @Column(name="operation_type")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String operationType;

    @Column(name="operation_url")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String operationUrl;
    
    @Column(name="operation_body")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String operationBody;
    
    @Column(name="rollback_type")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String rollbackType;

    @Column(name="rollback_url")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String rollbackUrl;
    
    @Column(name="rollback_body")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String rollbackBody;
}
