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
 * A Template language.
 */
@Entity
@Table(name = "T_TEMPLATE_LANGUAGE")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id", "language"})
public class TemplateLanguage implements Serializable {
    // For JsonView
    public interface Scalar {};

    public interface WithTemplate extends Scalar, Template.Scalar {};
    
    @Id
    @SequenceGenerator(name="t_template_language_id_seq", sequenceName="t_template_language_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_template_language_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;
 
    @ManyToOne
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(WithTemplate.class)
    private Template template;
   
    @Column(name="language")
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String language;

    @Column(name="text")
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String text;
}
