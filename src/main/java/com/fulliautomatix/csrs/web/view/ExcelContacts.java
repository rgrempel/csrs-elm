package com.fulliautomatix.csrs.web.view;

import java.util.Date;
import java.util.Map;
import java.util.List;
import java.util.Optional;
import java.util.Collection;
import java.util.Collections;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFDataFormat;

import com.fulliautomatix.csrs.domain.Contact;
import com.fulliautomatix.csrs.domain.Annual;

import org.springframework.web.servlet.view.document.AbstractExcelView;

public class ExcelContacts extends AbstractExcelView {
    protected void buildExcelDocument (
        Map<String, Object> model,
        HSSFWorkbook workbook,
        HttpServletRequest request,
        HttpServletResponse response
    ) {
        Collection<Contact> contacts = 
            (Collection<Contact>) model.get("contacts");
        
        List<Integer> years =
            (List<Integer>) model.get("years");

        Collections.sort
            ( years
            , Collections.reverseOrder()
            );

        HSSFSheet sheet = workbook.createSheet("Spring");
        sheet.setDefaultColumnWidth(12);

        // Write a text at A1.
        HSSFCell cell = getCell(sheet, 0, 0);
        setText(cell, "CSRS Database Export");

        // Write the current date at A2.
        HSSFCellStyle dateStyle = workbook.createCellStyle();
        dateStyle.setDataFormat(HSSFDataFormat.getBuiltinFormat("m/d/yy"));
        cell = getCell(sheet, 1, 0);
        cell.setCellValue(new Date());
        cell.setCellStyle(dateStyle);

        // TODO: This should all be localized ...

        // Write headers ...
        HSSFRow headers = sheet.createRow(3);
        headers.createCell(0).setCellValue("Full Name");
        headers.createCell(1).setCellValue("Full Address");
        headers.createCell(2).setCellValue("First Name");
        headers.createCell(3).setCellValue("Last Name");
        headers.createCell(4).setCellValue("City");
        headers.createCell(5).setCellValue("Province");
        headers.createCell(6).setCellValue("Country");
        headers.createCell(7).setCellValue("Postal Code");
        headers.createCell(8).setCellValue("Omit name");
        headers.createCell(9).setCellValue("Omit email");
        headers.createCell(10).setCellValue("Email");
        headers.createCell(11).setCellValue("Interests");

        int headerCell = 12;
        HSSFRow headers2 = sheet.createRow(4);
        
        for (Integer year : years) {
            headers.createCell(headerCell + 1).setCellValue(year);
            
            headers2.createCell(headerCell++).setCellValue("Membership");
            headers2.createCell(headerCell++).setCellValue("Iter");
            headers2.createCell(headerCell++).setCellValue("R & R");
        }

        // Write contact names
        int rowIndex = 5;
        for (Contact c : contacts) {
            HSSFRow sheetRow = sheet.createRow(rowIndex++);
            sheetRow.createCell(0).setCellValue(c.fullName());
            sheetRow.createCell(1).setCellValue(c.abbreviatedAddress());
            sheetRow.createCell(2).setCellValue(c.getFirstName());
            sheetRow.createCell(3).setCellValue(c.getLastName());
            sheetRow.createCell(4).setCellValue(c.getCity());
            sheetRow.createCell(5).setCellValue(c.getRegion());
            sheetRow.createCell(6).setCellValue(c.getCountry());
            sheetRow.createCell(7).setCellValue(c.getPostalCode());
            sheetRow.createCell(8).setCellValue(c.getOmitNameFromDirectory());
            sheetRow.createCell(9).setCellValue(c.getOmitEmailFromDirectory());
            sheetRow.createCell(10).setCellValue(c.formattedEmail("\n"));
            sheetRow.createCell(11).setCellValue(c.formattedInterests("\n"));

            int rowCell = 12;
            for (Integer year : years) {
                Optional<Annual> annual = c.annualForYear(year);
               
                final int cellNumber = rowCell;

                annual.ifPresent(a -> {
                    sheetRow.createCell(cellNumber).setCellValue(a.getMembership());
                    sheetRow.createCell(cellNumber + 1).setCellValue(a.getIter());
                    sheetRow.createCell(cellNumber + 2).setCellValue(a.getRr());
                });

                rowCell += 3;
            }
        }

        response.setHeader("Content-Disposition", "attachment; filename=\"csrs-contacts.xls\"");
    }
}
