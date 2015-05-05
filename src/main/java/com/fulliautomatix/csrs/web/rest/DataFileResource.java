package com.fulliautomatix.csrs.web.rest;

import com.codahale.metrics.annotation.Timed;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.annotation.*;
import com.fasterxml.jackson.databind.ObjectMapper;

import com.fulliautomatix.csrs.security.AuthoritiesConstants;
import com.fulliautomatix.csrs.service.LazyService;
import com.fulliautomatix.csrs.domain.DataFile;
import com.fulliautomatix.csrs.domain.DataFileBytes;
import com.fulliautomatix.csrs.repository.DataFileRepository;
import com.fulliautomatix.csrs.repository.DataFileBytesRepository;

import com.fulliautomatix.csrs.web.rest.util.ResourceNotFoundException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import javax.inject.Inject;
import javax.validation.Valid;
import javax.annotation.security.RolesAllowed;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.*;
import java.io.*;

/**
 * REST controller for managing Files.
 */
@RestController
@RequestMapping("/api")
@RolesAllowed(AuthoritiesConstants.ADMIN)
public class DataFileResource {
    private final Logger log = LoggerFactory.getLogger(DataFileResource.class);

    @Inject
    DataFileRepository dataFileRepository;

    @Inject
    DataFileBytesRepository dataFileBytesRepository;

    @Inject
    private LazyService lazyService;
    
    /**
     * POST  /files  Create a new file.
     */
    @RequestMapping(
        value = "/files",
        method = RequestMethod.POST,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @Transactional
    @JsonView(DataFile.Scalar.class)
    public ResponseEntity<DataFile> create (
        @RequestParam("file") MultipartFile file
    ) throws URISyntaxException, IOException {
        log.debug("REST request to create file");

        if (file.isEmpty()) {
            throw new RuntimeException("empty file");
        }

        DataFile dataFile = new DataFile();
        dataFile.setPath(file.getOriginalFilename());
        dataFile.setContentType(file.getContentType());
        dataFile.setSize(file.getSize());

        dataFile = dataFileRepository.save(dataFile);

        DataFileBytes fileBytes = new DataFileBytes();
        fileBytes.setDataFile(dataFile);
        fileBytes.setContentType(file.getContentType());
        fileBytes.setSize(file.getSize());
        fileBytes.setOriginalFilename(file.getOriginalFilename());
        fileBytes.setBytes(file.getBytes());

        fileBytes = dataFileBytesRepository.save(fileBytes);

        return new ResponseEntity<>(dataFile, HttpStatus.OK);
    }

    /**
     * GET  /files get all the files.
     */
    @RequestMapping(
        value = "/files",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @JsonView(DataFile.Scalar.class)
    @Transactional(readOnly = true)
    public ResponseEntity<Collection<DataFile>> getAll () throws URISyntaxException {
        Collection<DataFile> dataFiles = dataFileRepository.findAll();
        lazyService.initializeForJsonView(dataFiles, DataFile.Scalar.class);

        return new ResponseEntity<>(dataFiles, HttpStatus.OK);
    }

    /**
     * GET  /files/:id  get the "id" file.
     */
    @RequestMapping(
        value = "/files/{id}",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    @JsonView(DataFile.Scalar.class)
    @Transactional(readOnly = true)
    public ResponseEntity<DataFile> get (@PathVariable Long id) {
        log.debug("REST request to get DataFile : {}", id);

        return Optional.ofNullable(
            dataFileRepository.findOne(id)
        ).map((file) -> {
            lazyService.initializeForJsonView(file, DataFile.Scalar.class);
            return new ResponseEntity<>(file, HttpStatus.OK);
        }).orElse(
            new ResponseEntity<>(HttpStatus.NOT_FOUND)
        );
    }

    /**
     * DELETE  /files/:id delete the "id" file.
     */
    @RequestMapping(
        value = "/files/{id}",
        method = RequestMethod.DELETE,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    @Timed
    public void delete (@PathVariable Long id) {
        log.debug("REST request to delete file : {}", id);

        dataFileRepository.delete(id);
    }
}
