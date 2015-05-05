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
 * A File.
 */
@Entity
@Table(name = "T_FILE")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id", "path", "size", "contentType"})
public class DataFile implements Serializable {
    // For JsonView
    public interface Scalar {};
    
    public interface WithDataFileBytes extends Scalar, DataFileBytes.Scalar {};

    @Id
    @SequenceGenerator(name="t_file_id_seq", sequenceName="t_file_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_file_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @Column(name="path", nullable=false)
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String path;
    
    @Column(name="content_type")
    @JsonView(Scalar.class)
    @lombok.Getter @lombok.Setter
    private String contentType;

    @Column(name="size")
    @JsonView(Scalar.class)
    @lombok.Getter @lombok.Setter
    private Long size;

    @OneToMany(mappedBy="dataFile")
    @OnDelete(action = OnDeleteAction.CASCADE)
    @lombok.Getter @lombok.Setter
    @BatchSize(size=50)
    @JsonView(WithDataFileBytes.class)
    private Set<DataFileBytes> dataFileBytes = new HashSet<>();
    
}
