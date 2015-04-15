package com.fulliautomatix.csrs.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.fulliautomatix.csrs.domain.Renewal;
import com.fulliautomatix.csrs.domain.ProductCategoryPrice;
import com.fulliautomatix.csrs.repository.ProductCategoryPriceRepository;

import javax.inject.Inject;
import java.util.*;

/**
 * Service class for managing prices.
 */
@Service
public class PriceService {
    private final Logger log = LoggerFactory.getLogger(PriceService.class);

    @Inject
    private ProductCategoryPriceRepository priceRepository;

    public Integer priceInCentsForRenewal (Renewal renewal) {
        return priceRepository.membershipPriceForCode(
            renewal.getMembership()
        ).flatMap((membershipPrice) -> {
            return priceRepository.iterPriceForMembershipCategory(
                membershipPrice.getProductCategory().getId()
            ).flatMap((iterPrice) -> {
                return priceRepository.rrPriceForMembershipCategory(
                    membershipPrice.getProductCategory().getId()
                ).flatMap((rrPrice) -> {
                    int result = membershipPrice.getPriceInCents().intValue() * 
                                 renewal.getDuration().intValue();

                    if (renewal.getDuration().intValue() >= 3) {
                        result -= membershipPrice.getThreeYearReductionInCents();
                    }

                    if (!renewal.getRr().equals(0)) {
                        result += rrPrice.getPriceInCents().intValue() *
                                  renewal.getDuration().intValue();
                        
                        if (renewal.getDuration().intValue() >= 3) {
                            result -= rrPrice.getThreeYearReductionInCents();
                        } 
                    }

                    if (renewal.getIter().booleanValue()) {
                        result += iterPrice.getPriceInCents().intValue() *
                                  renewal.getDuration().intValue();
                        
                        if (renewal.getDuration().intValue() >= 3) {
                            result -= iterPrice.getThreeYearReductionInCents();
                        } 
                    }

                    return Optional.of(new Integer(result));
                });
            });
        }).orElseThrow(() -> {
            return new RuntimeException("Problem getting prices");
        });
    }
}
