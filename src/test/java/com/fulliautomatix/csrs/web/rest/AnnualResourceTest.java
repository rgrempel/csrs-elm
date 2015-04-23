package com.fulliautomatix.csrs.web.rest;

import com.fulliautomatix.csrs.Application;
import com.fulliautomatix.csrs.domain.Annual;
import com.fulliautomatix.csrs.domain.Contact;
import com.fulliautomatix.csrs.repository.AnnualRepository;
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
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.PostConstruct;
import javax.inject.Inject;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Test class for the AnnualResource REST controller.
 *
 * @see AnnualResource
 */
@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(classes = Application.class)
@WebAppConfiguration
@IntegrationTest
public class AnnualResourceTest {


    private static final Integer DEFAULT_YEAR = 0;
    private static final Integer UPDATED_YEAR = 1;

    private static final Integer DEFAULT_MEMBERSHIP = 0;
    private static final Integer UPDATED_MEMBERSHIP = 1;

    private static final Boolean DEFAULT_ITER = false;
    private static final Boolean UPDATED_ITER = true;

    private static final Integer DEFAULT_RR = 0;
    private static final Integer UPDATED_RR = 1;

    @Inject
    private AnnualRepository annualRepository;

    @Inject
    private ContactRepository contactRepository;

    private MockMvc restAnnualMockMvc;

    private Annual annual;
    private Contact contact;

    @PostConstruct
    public void setup() {
        MockitoAnnotations.initMocks(this);
        AnnualResource annualResource = new AnnualResource();
        ReflectionTestUtils.setField(annualResource, "annualRepository", annualRepository);
        this.restAnnualMockMvc = MockMvcBuilders.standaloneSetup(annualResource).build();
    }

    @Before
    public void initTest() {
        annual = new Annual();
        annual.setYear(DEFAULT_YEAR);
        annual.setMembership(DEFAULT_MEMBERSHIP);
        annual.setIter(DEFAULT_ITER);
        annual.setRr(DEFAULT_RR);
        
        contact = new Contact();
        contact.setLastName("LAST_NAME");
    }

    @Test
    @Transactional
    public void createAnnual() throws Exception {
        // Validate the database is empty
        assertThat(annualRepository.findAll()).hasSize(0);

        contactRepository.saveAndFlush(contact);
        annual.setContact(contact);

        // Create the Annual
        restAnnualMockMvc.perform(post("/api/annuals")
                .contentType(TestUtil.APPLICATION_JSON_UTF8)
                .content(TestUtil.convertObjectToJsonBytes(annual)))
                .andExpect(status().isCreated());

        // Validate the Annual in the database
        List<Annual> annuals = annualRepository.findAll();
        assertThat(annuals).hasSize(1);
        Annual testAnnual = annuals.iterator().next();
        assertThat(testAnnual.getYear()).isEqualTo(DEFAULT_YEAR);
        assertThat(testAnnual.getMembership()).isEqualTo(DEFAULT_MEMBERSHIP);
        assertThat(testAnnual.getIter()).isEqualTo(DEFAULT_ITER);
        assertThat(testAnnual.getRr()).isEqualTo(DEFAULT_RR);
    }

    @Test
    @Transactional
    public void getAllAnnuals() throws Exception {
        contactRepository.saveAndFlush(contact);
        annual.setContact(contact);
        
        // Initialize the database
        annualRepository.saveAndFlush(annual);

        // Get all the annuals
        restAnnualMockMvc.perform(get("/api/annuals"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.[0].id").value(annual.getId().intValue()))
                .andExpect(jsonPath("$.[0].year").value(DEFAULT_YEAR))
                .andExpect(jsonPath("$.[0].membership").value(DEFAULT_MEMBERSHIP))
                .andExpect(jsonPath("$.[0].iter").value(DEFAULT_ITER.booleanValue()))
                .andExpect(jsonPath("$.[0].rr").value(DEFAULT_RR));
    }

    @Test
    @Transactional
    public void getAnnual() throws Exception {
        contactRepository.saveAndFlush(contact);
        annual.setContact(contact);
        
        // Initialize the database
        annualRepository.saveAndFlush(annual);

        // Get the annual
        restAnnualMockMvc.perform(get("/api/annuals/{id}", annual.getId()))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON))
            .andExpect(jsonPath("$.id").value(annual.getId().intValue()))
            .andExpect(jsonPath("$.year").value(DEFAULT_YEAR))
            .andExpect(jsonPath("$.membership").value(DEFAULT_MEMBERSHIP))
            .andExpect(jsonPath("$.iter").value(DEFAULT_ITER.booleanValue()))
            .andExpect(jsonPath("$.rr").value(DEFAULT_RR));
    }

    @Test
    @Transactional
    public void getNonExistingAnnual() throws Exception {
        // Get the annual
        restAnnualMockMvc.perform(get("/api/annuals/{id}", 1L))
                .andExpect(status().isNotFound());
    }

    @Test
    @Transactional
    public void updateAnnual() throws Exception {
        contactRepository.saveAndFlush(contact);
        annual.setContact(contact);
        
        // Initialize the database
        annualRepository.saveAndFlush(annual);

        // Update the annual
        annual.setYear(UPDATED_YEAR);
        annual.setMembership(UPDATED_MEMBERSHIP);
        annual.setIter(UPDATED_ITER);
        annual.setRr(UPDATED_RR);
        restAnnualMockMvc.perform(put("/api/annuals")
                .contentType(TestUtil.APPLICATION_JSON_UTF8)
                .content(TestUtil.convertObjectToJsonBytes(annual)))
                .andExpect(status().isOk());

        // Validate the Annual in the database
        List<Annual> annuals = annualRepository.findAll();
        assertThat(annuals).hasSize(1);
        Annual testAnnual = annuals.iterator().next();
        assertThat(testAnnual.getYear()).isEqualTo(UPDATED_YEAR);
        assertThat(testAnnual.getMembership()).isEqualTo(UPDATED_MEMBERSHIP);
        assertThat(testAnnual.getIter()).isEqualTo(UPDATED_ITER);
        assertThat(testAnnual.getRr()).isEqualTo(UPDATED_RR);
    }

    @Test
    @Transactional
    public void deleteAnnual() throws Exception {
        contactRepository.saveAndFlush(contact);
        annual.setContact(contact);
        
        // Initialize the database
        annualRepository.saveAndFlush(annual);

        // Get the annual
        restAnnualMockMvc.perform(delete("/api/annuals/{id}", annual.getId())
                .accept(TestUtil.APPLICATION_JSON_UTF8))
                .andExpect(status().isOk());

        // Validate the database is empty
        List<Annual> annuals = annualRepository.findAll();
        assertThat(annuals).hasSize(0);
    }
}
