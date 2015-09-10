package com.fulliautomatix.csrs.service;

import java.util.List;

import javax.inject.Inject;

import org.joda.time.LocalDateTime;
import org.springframework.boot.actuate.audit.AuditEvent;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fulliautomatix.csrs.config.audit.AuditEventConverter;
import com.fulliautomatix.csrs.domain.PersistentAuditEvent;
import com.fulliautomatix.csrs.repository.PersistenceAuditEventRepository;

/**
 * Service for managing audit events.
 * <p/>
 * <p>
 * This is the default implementation to support SpringBoot Actuator AuditEventRepository
 * </p>
 */
@Service
@Transactional
public class AuditEventService {

    @Inject
    private PersistenceAuditEventRepository persistenceAuditEventRepository;

    @Inject
    private AuditEventConverter auditEventConverter;

    @Inject
    private LazyService lazyService;
    
    public List<AuditEvent> findAll() {
        return auditEventConverter.convertToAuditEvent(persistenceAuditEventRepository.findAll());
    }

    public List<AuditEvent> findByDates(LocalDateTime fromDate, LocalDateTime toDate) {
        List<PersistentAuditEvent> persistentAuditEvents =
            persistenceAuditEventRepository.findAllByAuditEventDateBetween(fromDate, toDate);

        return auditEventConverter.convertToAuditEvent(persistentAuditEvents);
    }
    
    public List<PersistentAuditEvent> findAllNative () {
        List<PersistentAuditEvent> events = persistenceAuditEventRepository.findAll();
        lazyService.initializeForJsonView(events, PersistentAuditEvent.WithData.class);
        return events;
    }

    public List<PersistentAuditEvent> findByDatesNative (LocalDateTime fromDate, LocalDateTime toDate) {
        List<PersistentAuditEvent> events =
            persistenceAuditEventRepository.findAllByAuditEventDateBetween(fromDate, toDate);

        lazyService.initializeForJsonView(events, PersistentAuditEvent.WithData.class);
        return events;
    }
}
