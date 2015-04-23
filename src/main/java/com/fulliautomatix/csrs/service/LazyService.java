package com.fulliautomatix.csrs.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.stereotype.Service;
import org.springframework.util.ReflectionUtils;

import com.fasterxml.jackson.annotation.JsonView;

import javax.inject.Inject;
import javax.persistence.OneToMany;

import java.util.*;
import java.io.*;

/**
 * Service for doing things lazily.
 */
@Service
public class LazyService {

    private final Logger log = LoggerFactory.getLogger(LazyService.class);

    public void initializeForJsonView (final Object bean, final Class desiredJsonView) {
        initializeForJsonView(bean, desiredJsonView, new HashSet<Object>());
    }

    public void initializeForJsonView (final Collection<Object> beanCollection, final Class desiredJsonView) {
        initializeForJsonView(beanCollection, desiredJsonView, new HashSet<Object>());
    }

    private void initializeForJsonView (final Collection<Object> beanCollection, final Class desiredJsonView, final Set<Object> beans) {
        if (beanCollection == null) return;
        
        if (beans.contains(beanCollection)) return;
        beans.add(beanCollection);

        beanCollection.stream().forEach((bean) -> {
            initializeForJsonView(bean, desiredJsonView, beans);
        });
    }
        
    // Note that we could (perhaps should) cache which fields for which classes are needed for which desiredJsonViews
    private void initializeForJsonView (final Object bean, final Class desiredJsonView, final Set<Object> beans) {
        if (bean == null) return;
        
        // Return if we've already considered this one.
        if (beans.contains(bean)) return;
        beans.add(bean);

        ReflectionUtils.doWithFields(bean.getClass(), (field) -> {
            Optional.ofNullable(field.getAnnotation(OneToMany.class)).ifPresent((oneToMany) -> {
                Optional.ofNullable(field.getAnnotation(JsonView.class)).ifPresent((fieldJsonView) -> {
                    Arrays.stream(fieldJsonView.value()).forEach((jsonView) -> {
                        if (jsonView.isAssignableFrom(desiredJsonView)) {
                            // We have a hit. We iterate over the collection, which will
                            // force it to be loaded, and we check whether it has anything
                            // that needs to be loaded.
                            try {
                                if (!field.isAccessible()) {
                                    field.setAccessible(true);
                                }

                                Object fieldValue = field.get(bean);
                                
                                if (fieldValue instanceof Collection) {
                                    initializeForJsonView((Collection) fieldValue, desiredJsonView, beans);
                                }
                            } catch (Exception ex) {
                                throw new RuntimeException(ex);
                            } 
                        }
                    });
                });
            });
        });
    }
}
