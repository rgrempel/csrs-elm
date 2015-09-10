package com.fulliautomatix.csrs.service;

import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.Optional;
import java.util.Set;

import javax.persistence.ElementCollection;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.util.ReflectionUtils;

import com.fasterxml.jackson.annotation.JsonView;

/**
 * Service for doing things lazily.
 */
@Service
public class LazyService {

    private final Logger log = LoggerFactory.getLogger(LazyService.class);

    public void initializeForJsonView (final Object bean, final Class<?> desiredJsonView) {
        initializeForJsonView(bean, desiredJsonView, new HashSet<Object>());
    }

    // Note that we could (perhaps should) cache which fields for which classes are needed for which desiredJsonViews
    private void initializeForJsonView (final Object bean, final Class<?> desiredJsonView, final Set<Object> beans) {
        if (bean == null) return;

        // Return if we've already considered this one.
        if (beans.contains(bean)) return;
        beans.add(bean);
        
        if (bean instanceof Collection) {
            for (Object value : (Collection<?>) bean) {
                initializeForJsonView(value, desiredJsonView, beans);
            }
        } else {
            ReflectionUtils.doWithFields(bean.getClass(), (field) -> {
                // We need to check both OneToMany and ManyToOne, because there may
                // be something on the other side of a ManyToOne that should be
                // loaded.
                if (
                    field.getAnnotation(OneToMany.class) != null ||
                    field.getAnnotation(ManyToOne.class) != null ||
                    field.getAnnotation(ElementCollection.class) != null
                ) {
                    Optional.ofNullable(field.getAnnotation(JsonView.class)).ifPresent((fieldJsonView) -> {
                        Arrays.stream(fieldJsonView.value()).forEach((jsonView) -> {
                            if (jsonView.isAssignableFrom(desiredJsonView)) {
                                try {
                                    if (!field.isAccessible()) field.setAccessible(true);
                                    initializeForJsonView(field.get(bean), desiredJsonView, beans);
                                } catch (Exception ex) {
                                    throw new RuntimeException(ex);
                                } 
                            }
                        });
                    });
                }
            });
        }
    }
}
