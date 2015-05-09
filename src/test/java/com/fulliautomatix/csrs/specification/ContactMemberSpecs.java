package com.fulliautomatix.csrs.specification;

import com.fulliautomatix.csrs.Application;
import com.fulliautomatix.csrs.domain.Contact;
import com.fulliautomatix.csrs.repository.ContactRepository;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.IntegrationTest;
import org.springframework.boot.test.SpringApplicationConfiguration;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.context.jdbc.Sql;

import javax.inject.Inject;
import java.util.*;

import static org.assertj.core.api.Assertions.*;

/**
 * Test class for ContactWasEverMember
 *
 * @see ContactWasEverMember
 */
@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(classes=Application.class)
@WebAppConfiguration
@Transactional
public class ContactMemberSpecs {

    @Inject
    private ContactRepository contactRepository;
 
    @Test
    @Transactional
    @Sql({"/sql/contactSpecification.sql"})
    public void testContactWasEverMember () {
        List<Contact> contact = contactRepository.findAll(
            new ContactWasEverMember()
        );
        assertThat(contact.size()).isEqualTo(2);
    }
    
    // Should be same as above ...
    @Test
    @Transactional
    @Sql({"/sql/contactSpecification.sql"})
    public void testContactWasMemberNoArgs () {
        List<Contact> contact = contactRepository.findAll(
            new ContactWasMember()
        );
        assertThat(contact.size()).isEqualTo(2);
    }
    
    // Should be same as above ...
    @Test
    @Transactional
    @Sql({"/sql/contactSpecification.sql"})
    public void testContactWasMemberNullArgs () {
        List<Contact> contact = contactRepository.findAll(
            new ContactWasMember((Set<Integer>) null, (Set<Integer>) null)
        );
        assertThat(contact.size()).isEqualTo(2);
    }
    
    // Should be same as above ...
    @Test
    @Transactional
    @Sql({"/sql/contactSpecification.sql"})
    public void testContactWasMemberEmptyArgs () {
        List<Contact> contact = contactRepository.findAll(
            new ContactWasMember(new HashSet<Integer>(), new HashSet<Integer>())
        );
        assertThat(contact.size()).isEqualTo(2);
    }
    
    @Test
    @Transactional
    @Sql({"/sql/contactSpecification.sql"})
    public void testContactWasMemberInAllSingleTrue () {
        List<Contact> contact = contactRepository.findAll(
            new ContactWasMemberInAll(2001)
        );
        assertThat(contact.size()).isEqualTo(2);
    }
    
    // Should be same as above ...
    @Test
    @Transactional
    @Sql({"/sql/contactSpecification.sql"})
    public void testContactWasMemberSingleTrueNull () {
        List<Contact> contact = contactRepository.findAll(
            new ContactWasMember(new Integer[] {2001}, null)
        );
        assertThat(contact.size()).isEqualTo(2);
    }
    
    // Should be same as above ...
    @Test
    @Transactional
    @Sql({"/sql/contactSpecification.sql"})
    public void testContactWasMemberSingleTrueEmpty () {
        List<Contact> contact = contactRepository.findAll(
            new ContactWasMember(new Integer[] {2001}, new Integer[0])
        );
        assertThat(contact.size()).isEqualTo(2);
    }

    @Test
    @Transactional
    @Sql({"/sql/contactSpecification.sql"})
    public void testContactWasMemberInAllSingleFalse () {
        List<Contact> contact = contactRepository.findAll(
            new ContactWasMemberInAll(2002)
        );
        assertThat(contact.size()).isEqualTo(0);
    }
    
    // Should be same as above ...
    @Test
    @Transactional
    @Sql({"/sql/contactSpecification.sql"})
    public void testContactWasMemberSingleFalseNull () {
        List<Contact> contact = contactRepository.findAll(
            new ContactWasMember(new Integer[] {2002}, null)
        );
        assertThat(contact.size()).isEqualTo(0);
    }
    
    @Test
    @Transactional
    @Sql({"/sql/contactSpecification.sql"})
    public void testContactWasMemberInAllSingleNotPresent () {
        List<Contact> contact = contactRepository.findAll(
            new ContactWasMemberInAll(1958)
        );
        assertThat(contact.size()).isEqualTo(0);
    }
    
    // Same
    @Test
    @Transactional
    @Sql({"/sql/contactSpecification.sql"})
    public void testContactWasMemberSingleNotPresent () {
        List<Contact> contact = contactRepository.findAll(
            new ContactWasMember(new Integer[] {1958}, null)
        );
        assertThat(contact.size()).isEqualTo(0);
    }
    
    @Test
    @Transactional
    @Sql({"/sql/contactSpecification.sql"})
    public void testContactWasMemberInAllDualOnePresent () {
        List<Contact> contact = contactRepository.findAll(
            new ContactWasMemberInAll(1958, 2001)
        );
        assertThat(contact.size()).isEqualTo(0);
    }
    
    @Test
    @Transactional
    @Sql({"/sql/contactSpecification.sql"})
    public void testContactWasMemberInAllDualBothPresent () {
        List<Contact> contact = contactRepository.findAll(
            new ContactWasMemberInAll(2001, 2003)
        );
        assertThat(contact.size()).isEqualTo(1);
    }
    
    @Test
    @Transactional
    @Sql({"/sql/contactSpecification.sql"})
    public void testContactWasMemberInNoneTrue () {
        List<Contact> contact = contactRepository.findAll(
            new ContactWasMemberInNone(1958)
        );
        assertThat(contact.size()).isEqualTo(4);
    }
    
    @Test
    @Transactional
    @Sql({"/sql/contactSpecification.sql"})
    public void testContactWasMemberInNoneSingle () {
        List<Contact> contact = contactRepository.findAll(
            new ContactWasMemberInNone(2001)
        );
        assertThat(contact.size()).isEqualTo(2);
    }
    
    @Test
    @Transactional
    @Sql({"/sql/contactSpecification.sql"})
    public void testContactWasMemberInNoneDual () {
        List<Contact> contact = contactRepository.findAll(
            new ContactWasMemberInNone(2001, 2002, 2003)
        );
        assertThat(contact.size()).isEqualTo(2);
    }
    
    @Test
    @Transactional
    @Sql({"/sql/contactSpecification.sql"})
    public void testContactWasMemberIncludeExclude () {
        List<Contact> contact = contactRepository.findAll(
            new ContactWasMember(new Integer[] {2001}, new Integer[] {2003})
        );
        assertThat(contact.size()).isEqualTo(1);
    } 
}
