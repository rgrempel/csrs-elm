package com.fulliautomatix.csrs.repository;

import com.fulliautomatix.csrs.domain.ProductCategoryPrice;

import org.joda.time.DateTime;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.*;

/**
 * Spring Data JPA repository for the ProductCategoryPrice entity.
 */
public interface ProductCategoryPriceRepository extends JpaRepository<ProductCategoryPrice, Long> {

    @Query("SELECT DISTINCT pcp FROM ProductCategoryPrice pcp JOIN pcp.productCategory pc JOIN pc.product p WHERE p.code = 'membership' AND pc.code = ?1")
    public Optional<ProductCategoryPrice> membershipPriceForCode (Integer membership);

    @Query("SELECT DISTINCT pcp FROM ProductCategoryPrice pcp JOIN pcp.productCategory pc JOIN pc.productCategoriesImpliedBy i JOIN i.productCategory ipc JOIN pc.product p WHERE p.code = 'iter' AND ipc.id = ?1")
    public Optional<ProductCategoryPrice> iterPriceForMembershipCategory (Long membershipCategoryID);
    
    @Query("SELECT DISTINCT pcp FROM ProductCategoryPrice pcp JOIN pcp.productCategory pc JOIN pc.productCategoriesImpliedBy i JOIN i.productCategory ipc JOIN pc.product p WHERE p.code = 'rr' AND ipc.id = ?1")
    public Optional<ProductCategoryPrice> rrPriceForMembershipCategory (Long membershipCategoryID);
}
