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
import org.apache.poi.hssf.usermodel.HSSFFont;

import org.apache.poi.hssf.util.CellRangeAddress;

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
        // Massage our data ...
        Collection<Contact> contacts = 
            (Collection<Contact>) model.get("contacts");
        
        List<Integer> years =
            (List<Integer>) model.get("years");

        Collections.sort
            ( years
            , Collections.reverseOrder()
            );

        // Create some style stuff
        HSSFFont boldFont = workbook.createFont();
        boldFont.setBold(true);

        HSSFCellStyle boldStyle = workbook.createCellStyle();
        boldStyle.setFont(boldFont);

        HSSFCellStyle headerStyle = workbook.createCellStyle();
        headerStyle.setAlignment(HSSFCellStyle.ALIGN_CENTER);
        headerStyle.setFont(boldFont);

        HSSFCellStyle centeredStyle = workbook.createCellStyle();
        centeredStyle.setAlignment(HSSFCellStyle.ALIGN_CENTER);

        HSSFCellStyle dataStyle = workbook.createCellStyle();
        dataStyle.setVerticalAlignment(HSSFCellStyle.VERTICAL_TOP);
        dataStyle.setWrapText(true);

        HSSFCellStyle centeredDataStyle = workbook.createCellStyle();
        centeredDataStyle.cloneStyleFrom(dataStyle);
        centeredDataStyle.setAlignment(HSSFCellStyle.ALIGN_CENTER);

        HSSFCellStyle yearStyle = workbook.createCellStyle();
        yearStyle.cloneStyleFrom(headerStyle);
        yearStyle.setBorderLeft(HSSFCellStyle.BORDER_THICK);
        yearStyle.setBorderRight(HSSFCellStyle.BORDER_THICK);

        HSSFCellStyle leftHeaderStyle = workbook.createCellStyle();
        leftHeaderStyle.cloneStyleFrom(headerStyle);
        leftHeaderStyle.setBorderLeft(HSSFCellStyle.BORDER_THICK);
        leftHeaderStyle.setBorderBottom(HSSFCellStyle.BORDER_THICK);
        
        HSSFCellStyle middleHeaderStyle = workbook.createCellStyle();
        middleHeaderStyle.cloneStyleFrom(headerStyle);
        middleHeaderStyle.setBorderBottom(HSSFCellStyle.BORDER_THICK);
        
        HSSFCellStyle rightHeaderStyle = workbook.createCellStyle();
        rightHeaderStyle.cloneStyleFrom(headerStyle);
        rightHeaderStyle.setBorderRight(HSSFCellStyle.BORDER_THICK);
        rightHeaderStyle.setBorderBottom(HSSFCellStyle.BORDER_THICK);
        
        HSSFCellStyle leftDataStyle = workbook.createCellStyle();
        leftDataStyle.cloneStyleFrom(dataStyle);
        leftDataStyle.setBorderLeft(HSSFCellStyle.BORDER_MEDIUM);
        
        HSSFCellStyle middleDataStyle = workbook.createCellStyle();
        middleDataStyle.cloneStyleFrom(dataStyle);
        middleDataStyle.setAlignment(HSSFCellStyle.ALIGN_CENTER);

        HSSFCellStyle rightDataStyle = workbook.createCellStyle();
        rightDataStyle.cloneStyleFrom(dataStyle);
        rightDataStyle.setBorderRight(HSSFCellStyle.BORDER_MEDIUM);
        
        // Create the sheet
        HSSFSheet sheet = workbook.createSheet("CSRS");
        sheet.setDefaultColumnWidth(12);
        sheet.setZoom(3, 2);

        // Default line height
        int oneLineHeight = sheet.getDefaultRowHeight();

        // Write a title
        HSSFCell cell = getCell(sheet, 0, 0);
        setText(cell, "CSRS Database Export");
        cell.setCellStyle(boldStyle);

        // Write the current date.
        HSSFCellStyle dateStyle = workbook.createCellStyle();
        HSSFDataFormat dataFormat = workbook.createDataFormat();
        dateStyle.setDataFormat(dataFormat.getFormat("yyyy-m-d"));
        dateStyle.setFont(boldFont);

        cell = getCell(sheet, 0, 1);
        cell.setCellValue(new Date());
        cell.setCellStyle(dateStyle);

        // TODO: This should all be localized ...

        // Write headers ...
        HSSFRow headers = sheet.createRow(2);

        createCell(headers, headerStyle, 0).setCellValue("Full Name");
        createCell(headers, headerStyle, 1).setCellValue("Full Address");
        createCell(headers, headerStyle, 2).setCellValue("First Name");
        createCell(headers, headerStyle, 3).setCellValue("Last Name");
        createCell(headers, headerStyle, 4).setCellValue("City");
        createCell(headers, headerStyle, 5).setCellValue("Province");
        createCell(headers, headerStyle, 6).setCellValue("Country");
        createCell(headers, headerStyle, 7).setCellValue("Postal Code");
        createCell(headers, headerStyle, 8).setCellValue("Omit name");
        createCell(headers, headerStyle, 9).setCellValue("Omit email");
        createCell(headers, headerStyle, 10).setCellValue("Email");
        createCell(headers, headerStyle, 11).setCellValue("Interests");

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
        HSSFRow headers2 = sheet.createRow(1);
        
        for (Integer year : years) {
            createCell(headers2, yearStyle, headerCell).setCellValue(year);
            sheet.addMergedRegion(new CellRangeAddress(1, 1, headerCell, headerCell + 2));

            sheet.setColumnWidth(headerCell, 12 * 256);
            sheet.setColumnWidth(headerCell + 1, 6 * 256);
            sheet.setColumnWidth(headerCell + 2, 10 * 256);

            createCell(headers, leftHeaderStyle, headerCell++).setCellValue("Membership");
            createCell(headers, middleHeaderStyle, headerCell++).setCellValue("Iter");
            createCell(headers, rightHeaderStyle, headerCell++).setCellValue("R & R");
        }

        // Write contact names
        int rowIndex = 3;
        int rowCell = 12;
        
        for (Contact c : contacts) {
            HSSFRow sheetRow = sheet.createRow(rowIndex++);
            
            sheetRow.setHeight((short) (4 * oneLineHeight));
           
            createCell(sheetRow, dataStyle, 0).setCellValue(c.fullName());
            createCell(sheetRow, dataStyle, 1).setCellValue(c.abbreviatedAddress());
            createCell(sheetRow, dataStyle, 2).setCellValue(c.getFirstName());
            createCell(sheetRow, dataStyle, 3).setCellValue(c.getLastName());
            createCell(sheetRow, dataStyle, 4).setCellValue(c.getCity());
            createCell(sheetRow, dataStyle, 5).setCellValue(c.getRegion());
            createCell(sheetRow, dataStyle, 6).setCellValue(c.getCountry());
            createCell(sheetRow, dataStyle, 7).setCellValue(c.getPostalCode());
            createCell(sheetRow, centeredDataStyle, 8).setCellValue(c.getOmitNameFromDirectory() ? "x" : "");
            createCell(sheetRow, centeredDataStyle, 9).setCellValue(c.getOmitEmailFromDirectory() ? "x" : "");
            createCell(sheetRow, dataStyle, 10).setCellValue(c.formattedEmail("\n"));
            createCell(sheetRow, dataStyle, 11).setCellValue(c.formattedInterests("\n"));

            rowCell = 12;
            for (Integer year : years) {
                Optional<Annual> annual = c.annualForYear(year);
               
                final int cellNumber = rowCell;

                String membership = "";    
                switch (annual.map(Annual::getMembership).orElse(0)) {
                    case 1:
                        membership = "Patron";
                        break;

                    case 2:
                        membership = "Regular";
                        break;

                    case 3:
                        membership = "Unemployed";
                        break;

                    case 4:
                        membership = "Retired";
                        break;

                    case 5:
                        membership = "Student";
                        break;
                }
                createCell(sheetRow, leftDataStyle, cellNumber).setCellValue(membership);

                String iter = annual.map(Annual::getIter).orElse(false) ? "x" : "";
                createCell(sheetRow, middleDataStyle, cellNumber + 1).setCellValue(iter);
                
                String rr = "";
                switch (annual.map(Annual::getRr).orElse(0)) {
                    case 1:
                        rr = "Print";
                        break;

                    case 2:
                        rr = "Electronic";
                        break;
                }
                createCell(sheetRow, rightDataStyle, cellNumber + 2).setCellValue(rr);

                rowCell += 3;
            }
        }

        sheet.createFreezePane(1, 3);
        sheet.setAutoFilter(new CellRangeAddress(2, rowIndex - 1, 0, rowCell - 1));

        response.setHeader("Content-Disposition", "attachment; filename=\"csrs-contacts.xls\"");
    }
}
