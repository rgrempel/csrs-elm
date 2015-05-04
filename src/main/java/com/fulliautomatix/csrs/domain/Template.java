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
 * A Template.
 */
@Entity
@Table(name = "T_TEMPLATE")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@JsonIdentityInfo(generator=JSOGGenerator.class)
@lombok.ToString(of={"id", "code"})
@lombok.EqualsAndHashCode(of={"code"})
public class Template implements Serializable {
    // For JsonView
    public interface Scalar {};

    public interface WithTemplateLanguages extends Scalar, TemplateLanguage.Scalar {};
    
    @Id
    @SequenceGenerator(name="t_template_id_seq", sequenceName="t_template_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_template_id_seq")
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private Long id;

    @Column(name="code", nullable=false)
    @NotNull
    @lombok.Getter @lombok.Setter
    @JsonView(Scalar.class)
    private String code;
    
    @OneToMany(mappedBy="template")
    @OnDelete(action=OnDeleteAction.CASCADE)
    @lombok.Getter @lombok.Setter
    @BatchSize(size=50)
    @JsonView(WithTemplateLanguages.class)
    private Set<TemplateLanguage> templateLanguages = new HashSet<>();
    
}
