SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
-- ============================================================
-- Library Management System – Validation / Self-Test Queries
-- Version  : V1
-- Run AFTER V1__Seed_Data.sql
-- ============================================================

USE LibraryManagement;
GO

PRINT N'';
PRINT N'=== 1. Kiem tra co cau bang ===';
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO

PRINT N'';
PRINT N'=== 2. Ton kho: so ban co the muon theo dau sach ===';
SELECT BookId, ISBN, Title, TotalCopies, AvailableCopies, OnLoanCopies
FROM lib.vw_Inventory
ORDER BY AvailableCopies DESC;
GO

PRINT N'';
PRINT N'=== 3. Luot muon dang hoat dong (chua tra) ===';
SELECT LoanId, MemberCode, MemberName, BookTitle, CopyBarcode, DueDate, DaysOverdue
FROM lib.vw_ActiveLoans
ORDER BY DaysOverdue DESC;
GO

PRINT N'';
PRINT N'=== 4. Kiem tra kho a Foreign Key: thu xoa sach co ban sao ===';
BEGIN TRY
    DELETE FROM lib.Book WHERE BookId = 1;
    PRINT N'[FAIL] FK BookCopy->Book khong hoat dong!';
END TRY
BEGIN CATCH
    PRINT N'[PASS] FK BookCopy->Book ngan xoa sach co ban sao: ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT N'';
PRINT N'=== 5. Kiem tra UNIQUE barcode: thu them barcode trung ===';
BEGIN TRY
    INSERT INTO lib.BookCopy (BookId, Barcode, CopyStatus) VALUES (1, N'BC-00001', N'Available');
    PRINT N'[FAIL] UNIQUE Barcode khong hoat dong!';
END TRY
BEGIN CATCH
    PRINT N'[PASS] UNIQUE Barcode ngan trung lap: ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT N'';
PRINT N'=== 6. Kiem tra UNIQUE Username: thu them username trung ===';
BEGIN TRY
    INSERT INTO lib.Account (Username, PasswordHash, Email, RoleId) VALUES (N'admin', N'hash', N'new@x.vn', 1);
    PRINT N'[FAIL] UNIQUE Username khong hoat dong!';
END TRY
BEGIN CATCH
    PRINT N'[PASS] UNIQUE Username ngan trung lap: ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT N'';
PRINT N'=== 7. Kiem tra CHECK DueDate > LoanDate ===';
BEGIN TRY
    INSERT INTO lib.Loan (MemberId, LoanDate, DueDate, LoanStatus, CreatedByAccountId) VALUES (3, '2026-10-10', '2026-10-08', N'Active', 2);
    PRINT N'[FAIL] CHECK DueDate > LoanDate khong hoat dong!';
END TRY
BEGIN CATCH
    PRINT N'[PASS] CHECK DueDate ngan ngay tra < ngay muon: ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT N'';
PRINT N'=== 8. Kiem tra CHECK CopyStatus domain ===';
BEGIN TRY
    INSERT INTO lib.BookCopy (BookId, Barcode, CopyStatus) VALUES (1, N'BC-INVALID', N'Unknown');
    PRINT N'[FAIL] CHECK CopyStatus khong hoat dong!';
END TRY
BEGIN CATCH
    PRINT N'[PASS] CHECK CopyStatus ngan gia tri ngoai domain: ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT N'';
PRINT N'=== 9. Danh sach sach qua han (overdue items) ===';
SELECT al.MemberCode, al.MemberName, al.BookTitle, al.CopyBarcode,
       al.DueDate, al.DaysOverdue
FROM lib.vw_ActiveLoans al
WHERE al.DaysOverdue > 0
ORDER BY al.DaysOverdue DESC;
GO

PRINT N'';
PRINT N'=== 10. So sach tung the loai ===';
SELECT c.CategoryName,
       COUNT(DISTINCT b.BookId) AS TotalTitles,
       COUNT(bc.BookCopyId)     AS TotalCopies,
       SUM(CASE WHEN bc.CopyStatus = N'Available' THEN 1 ELSE 0 END) AS Available
FROM lib.Category c
LEFT JOIN lib.Book     b  ON b.CategoryId  = c.CategoryId AND b.IsActive = 1
LEFT JOIN lib.BookCopy bc ON bc.BookId     = b.BookId
WHERE c.ParentId IS NOT NULL
GROUP BY c.CategoryId, c.CategoryName
ORDER BY TotalTitles DESC;
GO

PRINT N'';
PRINT N'=== 11. Lich su muon theo thanh vien ===';
SELECT m.MemberCode, m.FullName,
       COUNT(DISTINCT l.LoanId)   AS TotalLoans,
       SUM(CASE WHEN l.LoanStatus = N'Active'   THEN 1 ELSE 0 END) AS Active,
       SUM(CASE WHEN l.LoanStatus = N'Overdue'  THEN 1 ELSE 0 END) AS Overdue,
       SUM(CASE WHEN l.LoanStatus = N'Returned' THEN 1 ELSE 0 END) AS Returned
FROM lib.Member m
LEFT JOIN lib.Loan l ON l.MemberId = m.MemberId
GROUP BY m.MemberId, m.MemberCode, m.FullName
ORDER BY TotalLoans DESC;
GO

PRINT N'';
PRINT N'=== Tu kiem tra hoan tat ===';
GO

