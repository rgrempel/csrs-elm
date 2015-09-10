package com.fulliautomatix.csrs.web.rest;

import java.util.List;

import javax.annotation.security.RolesAllowed;
import javax.inject.Inject;

import org.joda.time.LocalDateTime;
import org.springframework.boot.actuate.audit.AuditEvent;
import org.springframework.http.MediaType;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.fulliautomatix.csrs.domain.PersistentAuditEvent;
import com.fulliautomatix.csrs.security.AuthoritiesConstants;
import com.fulliautomatix.csrs.service.AuditEventService;
import com.fulliautomatix.csrs.web.propertyeditors.LocaleDateTimeEditor;

/**
 * REST controller for getting the audit events.
 */
@RestController
@RequestMapping("/api")
public class AuditResource {

    @Inject
    private AuditEventService auditEventService;

    @InitBinder
    public void initBinder(WebDataBinder binder) {
        binder.registerCustomEditor(
            LocalDateTime.class,
            new LocaleDateTimeEditor("yyyy-MM-dd", false)
        );
    }

    // These two are for spring-boot in particular
    @RequestMapping(
        value = "/audits/all",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @RolesAllowed(AuthoritiesConstants.ADMIN)
    public List<AuditEvent> findAll () {
        return auditEventService.findAll();
    }

    @RequestMapping(
        value = "/audits/byDates",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @RolesAllowed(AuthoritiesConstants.ADMIN)
    public List<AuditEvent> findByDates (
        @RequestParam(value = "fromDate") LocalDateTime fromDate,
        @RequestParam(value = "toDate") LocalDateTime toDate
    ) {
        return auditEventService.findByDates(fromDate, toDate);
    }
    
    // These two are what I consume in the app's UI
    @RequestMapping(
        value = "/audits/allNative",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @RolesAllowed(AuthoritiesConstants.ADMIN)
    public List<PersistentAuditEvent> findAllNative () {
        List<PersistentAuditEvent> events = auditEventService.findAllNative();
        return events;
    }

    @RequestMapping(
        value = "/audits/byDatesNative",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @RolesAllowed(AuthoritiesConstants.ADMIN)
    public List<PersistentAuditEvent> findByDatesNative (
        @RequestParam(value = "fromDate") LocalDateTime fromDate,
        @RequestParam(value = "toDate") LocalDateTime toDate
    ) {
        List<PersistentAuditEvent> events = auditEventService.findByDatesNative(fromDate, toDate);
        return events;
    }
}
