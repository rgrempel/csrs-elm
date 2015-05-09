package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.Annual;
import com.fulliautomatix.csrs.web.rest.dto.MemberByYearDTO;
import org.springframework.data.jpa.repository.*;

import java.util.List;

/**
 * Spring Data JPA repository for the Annual entity.
 */
public interface AnnualRepository extends JpaRepository<Annual,Long> {

    @Query("SELECT new com.fulliautomatix.csrs.web.rest.dto.MemberByYearDTO(a.year, a.membership, count(*)) FROM Annual a GROUP BY a.year, a.membership")
    List<MemberByYearDTO> countByYearAndMembership();

}
