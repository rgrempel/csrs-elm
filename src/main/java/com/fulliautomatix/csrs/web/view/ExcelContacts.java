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
    protected HSSFCell createCell (HSSFRow row, HSSFCellStyle style, int pos) {
        HSSFCell cell = row.createCell(pos);
        if (style != null) cell.setCellStyle(style);
        return cell;
    }

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

        HSSFSheet sheet = workbook.createSheet("CSRS");
        sheet.setDefaultColumnWidth(12);

        // Write a text at A1.
        HSSFCell cell = getCell(sheet, 0, 0);
        setText(cell, "CSRS Database Export");

        // Write the current date at A2.
        HSSFCellStyle dateStyle = workbook.createCellStyle();
        HSSFDataFormat dataFormat = workbook.createDataFormat();
        dateStyle.setDataFormat(dataFormat.getFormat("yyyy-m-d"));

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

        // In 1/256 of a character width
        sheet.setColumnWidth(0, 24 * 256);
        sheet.setColumnWidth(1, 36 * 256);
        sheet.setColumnWidth(2, 10 * 256);
        sheet.setColumnWidth(3, 10 * 256);
        sheet.setColumnWidth(4, 12 * 256);
        sheet.setColumnWidth(5, 6 * 256);
        sheet.setColumnWidth(6, 6 * 256);
        sheet.setColumnWidth(7, 8 * 256);
        sheet.setColumnWidth(8, 6 * 256);
        sheet.setColumnWidth(9, 6 * 256);
        sheet.setColumnWidth(10, 24 * 256);
        sheet.setColumnWidth(11, 24 * 256);

        int headerCell = 12;
        HSSFRow headers2 = sheet.createRow(4);
        
        for (Integer year : years) {
            headers.createCell(headerCell + 1).setCellValue(year);
            
            headers2.createCell(headerCell++).setCellValue("Membership");
            headers2.createCell(headerCell++).setCellValue("Iter");
            headers2.createCell(headerCell++).setCellValue("R & R");
        }

        HSSFCellStyle dataStyle = workbook.createCellStyle();
        dataStyle.setVerticalAlignment(HSSFCellStyle.VERTICAL_TOP);
        dataStyle.setWrapText(true);

        // Write contact names
        int rowIndex = 5;
        for (Contact c : contacts) {
            HSSFRow sheetRow = sheet.createRow(rowIndex++);
            
            // In 1/20 of a pt
            sheetRow.setHeight((short) (48 * 20));
           
            createCell(sheetRow, dataStyle, 0).setCellValue(c.fullName());
            createCell(sheetRow, dataStyle, 1).setCellValue(c.abbreviatedAddress());
            createCell(sheetRow, dataStyle, 2).setCellValue(c.getFirstName());
            createCell(sheetRow, dataStyle, 3).setCellValue(c.getLastName());
            createCell(sheetRow, dataStyle, 4).setCellValue(c.getCity());
            createCell(sheetRow, dataStyle, 5).setCellValue(c.getRegion());
            createCell(sheetRow, dataStyle, 6).setCellValue(c.getCountry());
            createCell(sheetRow, dataStyle, 7).setCellValue(c.getPostalCode());
            createCell(sheetRow, dataStyle, 8).setCellValue(c.getOmitNameFromDirectory() ? "x" : "");
            createCell(sheetRow, dataStyle, 9).setCellValue(c.getOmitEmailFromDirectory() ? "x" : "");
            createCell(sheetRow, dataStyle, 10).setCellValue(c.formattedEmail("\n"));
            createCell(sheetRow, dataStyle, 11).setCellValue(c.formattedInterests("\n"));

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
