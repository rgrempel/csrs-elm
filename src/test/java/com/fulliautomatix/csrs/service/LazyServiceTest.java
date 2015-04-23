package com.fulliautomatix.csrs.service;

import com.fulliautomatix.csrs.Application;
import com.fulliautomatix.csrs.domain.Product;
import com.fulliautomatix.csrs.domain.ProductVariantPrice;
import com.fulliautomatix.csrs.repository.ProductRepository;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.IntegrationTest;
import org.springframework.boot.test.SpringApplicationConfiguration;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;

import org.hibernate.Hibernate;

import javax.inject.Inject;
import java.util.*;

import static org.assertj.core.api.Assertions.*;

/**
 * Test class for the LazyService
 *
 * @see LazyService
 */
@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(classes=Application.class)
@WebAppConfiguration
@Transactional
public class LazyServiceTest {

    @Inject
    private LazyService lazyService;

    @Inject
    private ProductRepository productRepository;

    @Test
    public void testInitializeForJsonView () {
        Product product = productRepository.findOne(1L);

        lazyService.initializeForJsonView(product, Product.WithProductVariants.class);

        assertThat(Hibernate.isInitialized(product.getProductVariants())).isTrue();
        assertThat(Hibernate.isInitialized(product.getProductPrereqRequires())).isFalse();
    }
    
    @Test
    public void testDeepInitializeForJsonView () {
        Product product = productRepository.findOne(1L);

        lazyService.initializeForJsonView(product, Product.DeepTree.class);

        assertThat(Hibernate.isInitialized(product.getProductVariants())).isTrue();
        assertThat(Hibernate.isInitialized(product.getProductPrereqRequires())).isTrue();

        product.getProductVariants().stream().forEach((pv) -> {
            assertThat(Hibernate.isInitialized(pv.getProductVariantPrices())).isTrue();
        });
    }
}
