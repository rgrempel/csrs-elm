package com.fulliautomatix.csrs.web.view;

import java.util.Date;
import java.util.Map;
import java.util.Collection;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFDataFormat;

import com.fulliautomatix.csrs.domain.Contact;

import org.springframework.web.servlet.view.document.AbstractExcelView;

public class ExcelContacts extends AbstractExcelView {
    protected void buildExcelDocument (
        Map<String, Object> model,
        HSSFWorkbook workbook,
        HttpServletRequest request,
        HttpServletResponse response
    ) {
        Collection<Contact> contacts = (Collection<Contact>) model.get("contacts");

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

        // Write contact names
        int rowIndex = 4;
        for (Contact c : contacts) {
            HSSFRow sheetRow = sheet.createRow(rowIndex++);
            sheetRow.createCell(1).setCellValue(c.fullName());
        }

        response.setHeader("Content-Disposition", "attachment; filename=\"csrs-contacts.xls\"");
    }
}
