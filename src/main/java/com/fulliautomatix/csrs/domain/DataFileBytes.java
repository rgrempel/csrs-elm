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
 * A File's Bytes.
 */
@Entity
@Table(name = "T_FILE_BYTES")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id", "originalFilename"})
public class DataFileBytes implements Serializable {
    // For JsonView
    public interface Scalar {};
    
    public interface WithBytes extends Scalar {};
    public interface WithDataFile extends Scalar, DataFile.Scalar {};

    public interface WithEverything extends WithBytes, WithDataFile {};

    @Id
    @SequenceGenerator(name="t_file_bytes_id_seq", sequenceName="t_file_bytes_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_file_bytes_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @Column(name="bytes")
    @JsonView(WithBytes.class)
    @lombok.Getter @lombok.Setter
    byte[] bytes;

    @ManyToOne
    @JoinColumn(name="file_id")
    @lombok.Getter @lombok.Setter
    @JsonView(WithDataFile.class)
    private DataFile dataFile;

    @Column(name="content_type")
    @JsonView(Scalar.class)
    @lombok.Getter @lombok.Setter
    private String contentType;

    @Column(name="size")
    @JsonView(Scalar.class)
    @lombok.Getter @lombok.Setter
    private Long size;

    @Column(name="original_filename")
    @JsonView(Scalar.class)
    @lombok.Getter @lombok.Setter
    private String originalFilename;
}
