package com.fulliautomatix.csrs.thymeleaf;

import org.springframework.stereotype.Service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fulliautomatix.csrs.repository.DataFileBytesRepository;
import com.fulliautomatix.csrs.domain.DataFileBytes;

import javax.xml.transform.*;
import javax.xml.transform.stream.StreamSource;

import javax.inject.Inject;
import java.io.*;

@Service
public class DatabaseURIResolver implements URIResolver {
    private final Logger log = LoggerFactory.getLogger(DatabaseURIResolver.class);

    @Inject
    private DataFileBytesRepository dataFileBytesRepository;

    public Source resolve (String href, String base) throws TransformerException {
        return dataFileBytesRepository.findByPath(href).map((dataFile) -> {
            return new StreamSource(
                new ByteArrayInputStream(
                    dataFile.getBytes()
                )
            ); 
        }).orElse(null);
    }
}
