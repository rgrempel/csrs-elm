package com.fulliautomatix.csrs.domain;

import com.fasterxml.jackson.annotation.JsonIgnore;
import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import org.hibernate.validator.constraints.Email;

import javax.persistence.*;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;
import java.io.Serializable;
import java.util.HashSet;
import java.util.Set;

/**
 * A user.
 */
@Entity
@Table(name = "T_USER")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
public class User extends AbstractAuditingEntity implements Serializable {

    @Id
    @SequenceGenerator(name="t_user_id_seq", sequenceName="t_user_id_seq", allocationSize=1)
    @GeneratedValue(strategy=GenerationType.SEQUENCE, generator="t_user_id_seq")
    @lombok.Getter @lombok.Setter
    private Long id;

    @NotNull
    @Size(min = 1, max = 50)
    @Column(length = 50, unique = true, nullable = false)
    @lombok.Getter @lombok.Setter
    private String login;

    @JsonIgnore
    @NotNull
    @Size(min = 4, max = 100)
    @Column(length = 100)
    @lombok.Getter @lombok.Setter
    private String password;

    @OneToMany(mappedBy="user")
    @lombok.Getter @lombok.Setter
    private Set<UserEmail> userEmails = new HashSet<>();
    
    @Size(min = 2, max = 5)
    @Column(name = "lang_key", length = 5)
    @lombok.Getter @lombok.Setter
    private String langKey;

    @JsonIgnore
    @ManyToMany
    @JoinTable(
        name = "T_USER_AUTHORITY",
        joinColumns = {@JoinColumn(name = "user_id", referencedColumnName = "id")},
        inverseJoinColumns = {@JoinColumn(name = "authority_name", referencedColumnName = "name")}
    )
    @Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
    @lombok.Getter @lombok.Setter
    private Set<Authority> authorities = new HashSet<>();

    @JsonIgnore
    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true, mappedBy = "user")
    @Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
    @lombok.Getter @lombok.Setter
    private Set<PersistentToken> persistentTokens = new HashSet<>();

}
