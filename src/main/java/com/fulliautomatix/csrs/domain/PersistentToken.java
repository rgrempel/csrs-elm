package com.fulliautomatix.csrs.domain;

import com.fasterxml.jackson.annotation.*;
import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;
import org.hibernate.annotations.Type;
import org.joda.time.LocalDate;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;

import javax.persistence.*;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import java.io.Serializable;

/**
 * Persistent tokens are used by Spring Security to automatically log in users.
 *
 * @see com.fulliautomatix.csrs.security.CustomPersistentRememberMeServices
 */
@Entity
@Table(name = "T_PERSISTENT_TOKEN")
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
@lombok.EqualsAndHashCode(of={"series"})
@lombok.ToString(of={"series","tokenValue","tokenDate","ipAddress","userAgent"})
public class PersistentToken implements Serializable {

    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormat.forPattern("d MMMM yyyy");

    private static final int MAX_USER_AGENT_LEN = 255;

    @Id
    @lombok.Getter @lombok.Setter
    private String series;

    @JsonIgnore
    @NotNull
    @Column(name = "token_value", nullable = false)
    @lombok.Getter @lombok.Setter
    private String tokenValue;

    @JsonIgnore
    @Column(name = "token_date")
    @Type(type = "org.jadira.usertype.dateandtime.joda.PersistentLocalDate")
    @lombok.Getter @lombok.Setter
    private LocalDate tokenDate;

    //an IPV6 address max length is 39 characters
    @Size(min = 0, max = 39)
    @Column(name = "ip_address", length = 39)
    @lombok.Getter @lombok.Setter
    private String ipAddress;

    @Column(name = "user_agent")
    private String userAgent;

    @JsonIgnore
    @ManyToOne
    @lombok.Getter @lombok.Setter
    private User user;

    @JsonGetter
    public String getFormattedTokenDate() {
        return DATE_TIME_FORMATTER.print(this.tokenDate);
    }

    public String getUserAgent() {
        return userAgent;
    }

    public void setUserAgent(String userAgent) {
        if (userAgent.length() >= MAX_USER_AGENT_LEN) {
            this.userAgent = userAgent.substring(0, MAX_USER_AGENT_LEN - 1);
        } else {
            this.userAgent = userAgent;
        }
    }
}
