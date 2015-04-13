package com.fulliautomatix.csrs.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.fulliautomatix.csrs.domain.Renewal;

import javax.inject.Inject;
import java.util.*;

/**
 * Service class for managing prices.
 */
@Service
public class PriceService {
    private final Logger log = LoggerFactory.getLogger(PriceService.class);

    public Integer priceInCentsForRenewal (Renewal renewal) {
        return new Integer(0);
    }
}
