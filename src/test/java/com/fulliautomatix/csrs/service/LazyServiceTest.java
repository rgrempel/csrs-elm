package com.fulliautomatix.csrs.service;

import com.fulliautomatix.csrs.Application;
import com.fulliautomatix.csrs.domain.Product;
import com.fulliautomatix.csrs.domain.ProductGroup;
import com.fulliautomatix.csrs.domain.ProductGroupProduct;
import com.fulliautomatix.csrs.domain.Contact;
import com.fulliautomatix.csrs.domain.ProductVariantPrice;
import com.fulliautomatix.csrs.repository.ProductRepository;
import com.fulliautomatix.csrs.repository.ProductGroupRepository;
import com.fulliautomatix.csrs.repository.ContactRepository;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.IntegrationTest;
import org.springframework.boot.test.SpringApplicationConfiguration;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.context.jdbc.Sql;

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
    private ContactRepository contactRepository;

    @Inject
    private ProductRepository productRepository;

    @Inject
    private ProductGroupRepository productGroupRepository;

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
    
    @Test
    @Transactional
    @Sql({"/sql/contact.sql"})
    public void testContactEmails () {
        Contact contact = contactRepository.findOne(1L);
        assertThat(contact).isNotNull();
        lazyService.initializeForJsonView(contact, Contact.WithEverything.class);
        assertThat(Hibernate.isInitialized(contact.getContactEmails())).isTrue();
    }
    
    @Test
    @Transactional
    @Sql({"/sql/contact.sql"})
    public void testContactEmailsCollection () {
        List<Contact> contacts = contactRepository.findAll();
        assertThat(contacts).isNotNull();
        assertThat(contacts).hasSize(1);

        lazyService.initializeForJsonView(contacts, Contact.WithEverything.class);

        for (Contact contact : contacts) {
            assertThat(Hibernate.isInitialized(contact.getContactEmails())).isTrue();
        }
    }
    
    @Test
    @Transactional
    public void testProductGroup () {
        ProductGroup pg = productGroupRepository.findOne(1L);
        assertThat(pg).isNotNull();

        lazyService.initializeForJsonView(pg, ProductGroup.DeepTree.class);

        assertThat(Hibernate.isInitialized(pg.getProductGroupProducts())).isTrue();

        for (ProductGroupProduct pgp : pg.getProductGroupProducts()) {
            assertThat(Hibernate.isInitialized(pgp.getProduct())).isTrue();
            assertThat(Hibernate.isInitialized(pgp.getProduct().getProductVariants())).isTrue();
        }
    }
}
