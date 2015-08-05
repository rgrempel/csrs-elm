package com.fulliautomatix.csrs.web.rest;

import com.fulliautomatix.csrs.Application;
import com.fulliautomatix.csrs.domain.Contact;
import com.fulliautomatix.csrs.service.LazyService;
import com.fulliautomatix.csrs.repository.ContactRepository;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.MockitoAnnotations;
import org.springframework.boot.test.IntegrationTest;
import org.springframework.boot.test.SpringApplicationConfiguration;
import org.springframework.http.MediaType;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.*;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.PostConstruct;
import javax.inject.Inject;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Test class for the ContactResource REST controller.
 *
 * @see ContactResource
 */
@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(classes = Application.class)
@WebAppConfiguration
@IntegrationTest
public class ContactResourceTest {

    private static final String DEFAULT_CODE = "SAMPLE_TEXT";
    private static final String UPDATED_CODE = "UPDATED_TEXT";
    private static final String DEFAULT_FIRST_NAME = "SAMPLE_TEXT";
    private static final String UPDATED_FIRST_NAME = "UPDATED_TEXT";
    private static final String DEFAULT_LAST_NAME = "SAMPLE_TEXT";
    private static final String UPDATED_LAST_NAME = "UPDATED_TEXT";
    private static final String DEFAULT_SALUTATION = "SAMPLE_TEXT";
    private static final String UPDATED_SALUTATION = "UPDATED_TEXT";
    private static final String DEFAULT_STREET = "SAMPLE_TEXT";
    private static final String UPDATED_STREET = "UPDATED_TEXT";
    private static final String DEFAULT_CITY = "SAMPLE_TEXT";
    private static final String UPDATED_CITY = "UPDATED_TEXT";
    private static final String DEFAULT_REGION = "SAMPLE_TEXT";
    private static final String UPDATED_REGION = "UPDATED_TEXT";
    private static final String DEFAULT_COUNTRY = "SAMPLE_TEXT";
    private static final String UPDATED_COUNTRY = "UPDATED_TEXT";
    private static final String DEFAULT_POSTAL_CODE = "SAMPLE_TEXT";
    private static final String UPDATED_POSTAL_CODE = "UPDATED_TEXT";
 //   private static final String DEFAULT_EMAIL = "SAMPLE_TEXT";
 //   private static final String UPDATED_EMAIL = "UPDATED_TEXT";

    @Inject
    private ContactRepository contactRepository;

    @Inject
    private LazyService lazyService;

    private MockMvc restContactMockMvc;

    private Contact contact;

    @PostConstruct
    public void setup() {
        MockitoAnnotations.initMocks(this);
        ContactResource contactResource = new ContactResource();
        ReflectionTestUtils.setField(contactResource, "contactRepository", contactRepository);
        ReflectionTestUtils.setField(contactResource, "lazyService", lazyService);
        this.restContactMockMvc = MockMvcBuilders.standaloneSetup(contactResource).build();
    }

    @Before
    public void initTest() {
        contact = new Contact();
        contact.setCode(DEFAULT_CODE);
        contact.setFirstName(DEFAULT_FIRST_NAME);
        contact.setLastName(DEFAULT_LAST_NAME);
        contact.setSalutation(DEFAULT_SALUTATION);
        contact.setStreet(DEFAULT_STREET);
        contact.setCity(DEFAULT_CITY);
        contact.setRegion(DEFAULT_REGION);
        contact.setCountry(DEFAULT_COUNTRY);
        contact.setPostalCode(DEFAULT_POSTAL_CODE);
//        contact.setEmail(DEFAULT_EMAIL);
    }

    @Test
    @Transactional
    public void createContact() throws Exception {
        // Validate the database is empty
        assertThat(contactRepository.findAll()).hasSize(0);

        // Create the Contact
        restContactMockMvc.perform(post("/api/contacts")
                .contentType(TestUtil.APPLICATION_JSON_UTF8)
                .content(TestUtil.convertObjectToJsonBytes(contact)))
                .andExpect(status().isCreated());

        // Validate the Contact in the database
        List<Contact> contacts = contactRepository.findAll();
        assertThat(contacts).hasSize(1);
        Contact testContact = contacts.iterator().next();
        assertThat(testContact.getCode()).isEqualTo(DEFAULT_CODE);
        assertThat(testContact.getFirstName()).isEqualTo(DEFAULT_FIRST_NAME);
        assertThat(testContact.getLastName()).isEqualTo(DEFAULT_LAST_NAME);
        assertThat(testContact.getSalutation()).isEqualTo(DEFAULT_SALUTATION);
        assertThat(testContact.getStreet()).isEqualTo(DEFAULT_STREET);
        assertThat(testContact.getCity()).isEqualTo(DEFAULT_CITY);
        assertThat(testContact.getRegion()).isEqualTo(DEFAULT_REGION);
        assertThat(testContact.getCountry()).isEqualTo(DEFAULT_COUNTRY);
        assertThat(testContact.getPostalCode()).isEqualTo(DEFAULT_POSTAL_CODE);
 //       assertThat(testContact.getEmail()).isEqualTo(DEFAULT_EMAIL);
    }

    /*
    @Test
    @Transactional
    public void getAllContacts() throws Exception {
        // Initialize the database
        contactRepository.saveAndFlush(contact);

        // Get all the contacts
        restContactMockMvc.perform(get("/api/contacts"))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.[0].id").value(contact.getId().intValue()))
                .andExpect(jsonPath("$.[0].code").value(DEFAULT_CODE.toString()))
                .andExpect(jsonPath("$.[0].firstName").value(DEFAULT_FIRST_NAME.toString()))
                .andExpect(jsonPath("$.[0].lastName").value(DEFAULT_LAST_NAME.toString()))
                .andExpect(jsonPath("$.[0].salutation").value(DEFAULT_SALUTATION.toString()))
                .andExpect(jsonPath("$.[0].street").value(DEFAULT_STREET.toString()))
                .andExpect(jsonPath("$.[0].city").value(DEFAULT_CITY.toString()))
                .andExpect(jsonPath("$.[0].region").value(DEFAULT_REGION.toString()))
                .andExpect(jsonPath("$.[0].country").value(DEFAULT_COUNTRY.toString()))
                .andExpect(jsonPath("$.[0].postalCode").value(DEFAULT_POSTAL_CODE.toString()));
    }
*/

    @Test
    @Transactional
    public void getContact() throws Exception {
        // Initialize the database
        contactRepository.saveAndFlush(contact);

        assertThat(contact).isNotNull();
        assertThat(contact.getId()).isNotNull();
        assertThat(restContactMockMvc).isNotNull();

        // Get the contact
        restContactMockMvc.perform(get("/api/contacts/{id}", contact.getId()))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON))
            .andExpect(jsonPath("$.id").value(contact.getId().intValue()))
            .andExpect(jsonPath("$.code").value(DEFAULT_CODE.toString()))
            .andExpect(jsonPath("$.firstName").value(DEFAULT_FIRST_NAME.toString()))
            .andExpect(jsonPath("$.lastName").value(DEFAULT_LAST_NAME.toString()))
            .andExpect(jsonPath("$.salutation").value(DEFAULT_SALUTATION.toString()))
            .andExpect(jsonPath("$.street").value(DEFAULT_STREET.toString()))
            .andExpect(jsonPath("$.city").value(DEFAULT_CITY.toString()))
            .andExpect(jsonPath("$.region").value(DEFAULT_REGION.toString()))
            .andExpect(jsonPath("$.country").value(DEFAULT_COUNTRY.toString()))
            .andExpect(jsonPath("$.postalCode").value(DEFAULT_POSTAL_CODE.toString()));
    }

    @Test
    @Transactional
    public void getNonExistingContact() throws Exception {
        // Get the contact
        restContactMockMvc.perform(get("/api/contacts/{id}", 1L))
                .andExpect(status().isNotFound());
    }

    @Test
    @Transactional
    public void updateContact() throws Exception {
        // Initialize the database
        contactRepository.saveAndFlush(contact);

        // Update the contact
        contact.setCode(UPDATED_CODE);
        contact.setFirstName(UPDATED_FIRST_NAME);
        contact.setLastName(UPDATED_LAST_NAME);
        contact.setSalutation(UPDATED_SALUTATION);
        contact.setStreet(UPDATED_STREET);
        contact.setCity(UPDATED_CITY);
        contact.setRegion(UPDATED_REGION);
        contact.setCountry(UPDATED_COUNTRY);
        contact.setPostalCode(UPDATED_POSTAL_CODE);
     //   contact.setEmail(UPDATED_EMAIL);
        restContactMockMvc.perform(put("/api/contacts")
                .contentType(TestUtil.APPLICATION_JSON_UTF8)
                .content(TestUtil.convertObjectToJsonBytes(contact)))
                .andExpect(status().isOk());

        // Validate the Contact in the database
        List<Contact> contacts = contactRepository.findAll();
        assertThat(contacts).hasSize(1);
        Contact testContact = contacts.iterator().next();
        assertThat(testContact.getCode()).isEqualTo(UPDATED_CODE);
        assertThat(testContact.getFirstName()).isEqualTo(UPDATED_FIRST_NAME);
        assertThat(testContact.getLastName()).isEqualTo(UPDATED_LAST_NAME);
        assertThat(testContact.getSalutation()).isEqualTo(UPDATED_SALUTATION);
        assertThat(testContact.getStreet()).isEqualTo(UPDATED_STREET);
        assertThat(testContact.getCity()).isEqualTo(UPDATED_CITY);
        assertThat(testContact.getRegion()).isEqualTo(UPDATED_REGION);
        assertThat(testContact.getCountry()).isEqualTo(UPDATED_COUNTRY);
        assertThat(testContact.getPostalCode()).isEqualTo(UPDATED_POSTAL_CODE);
   //     assertThat(testContact.getEmail()).isEqualTo(UPDATED_EMAIL);
    }

    @Test
    @Transactional
    public void deleteContact() throws Exception {
        // Initialize the database
        contactRepository.saveAndFlush(contact);

        // Get the contact
        restContactMockMvc.perform(delete("/api/contacts/{id}", contact.getId())
                .accept(TestUtil.APPLICATION_JSON_UTF8))
                .andExpect(status().isOk());

        // Validate the database is empty
        List<Contact> contacts = contactRepository.findAll();
        assertThat(contacts).hasSize(0);
    }
}
