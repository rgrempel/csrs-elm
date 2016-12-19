package com.fulliautomatix.csrs.thymeleaf;

import org.springframework.stereotype.Service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fulliautomatix.csrs.repository.DataFileBytesRepository;
import com.fulliautomatix.csrs.domain.DataFileBytes;
import org.apache.xmlgraphics.io.ResourceResolver;
import org.apache.xmlgraphics.io.Resource;

import javax.xml.transform.*;
import javax.xml.transform.stream.StreamSource;

import java.net.URI;
import javax.inject.Inject;
import java.io.*;

@Service
public class GraphicsResourceResolver implements ResourceResolver {
    private final Logger log = LoggerFactory.getLogger(ResourceResolver.class);

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
    
    public Resource getResource (URI uri) {
        String filename = new File(uri.getPath()).getName();
        return dataFileBytesRepository.findByPath(filename).map((dataFile) -> {
            return new Resource(
                new ByteArrayInputStream(
                    dataFile.getBytes()
                )
            );
        }).orElse(null);
    }
    
    public OutputStream getOutputStream (URI uri) {
        return null;
    } 
}
