SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
-- ============================================================
-- Library Management System – SQL Server Schema
-- Version  : V1
-- Author   : DoAnQuanLyThuVien Team
-- Created  : 2026-10-16
-- Standard : 3rd Normal Form (3NF)
-- Target   : SQL Server 2019+ / Azure SQL
-- ============================================================
-- Assumptions
--   1. Book = bibliographic record (ISBN, title, ...).
--      BookCopy = physical copy that can be loaned.
--   2. A Book may have multiple Authors (M:N), belongs to
--      one Category and one Publisher.
--   3. A Member has exactly one Account (1:1) and one Role.
--   4. A Loan (header) belongs to one Member and contains one
--      or more LoanItems, each tracking one BookCopy.
--   5. LoanItem.ReturnedDate IS NULL  => copy still on loan.
--   6. BookCopy.CopyStatus domain:
--        Available | OnLoan | Reserved | Lost | Damaged | Withdrawn
--   7. Soft-delete via IsActive flag where noted.
-- ============================================================

USE master;
GO

-- Drop & recreate database (dev convenience)
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = N'LibraryManagement')
BEGIN
    ALTER DATABASE LibraryManagement SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE LibraryManagement;
END;
GO

CREATE DATABASE LibraryManagement
    COLLATE Vietnamese_CI_AS;
GO

USE LibraryManagement;
GO

CREATE SCHEMA lib AUTHORIZATION dbo;
GO

-- ==============================================================
-- 1. ROLE
-- ==============================================================
CREATE TABLE lib.Role (
    RoleId      TINYINT        NOT NULL IDENTITY(1,1),
    RoleName    NVARCHAR(50)   NOT NULL,
    Description NVARCHAR(255)  NULL,
    CONSTRAINT PK_Role         PRIMARY KEY (RoleId),
    CONSTRAINT UQ_Role_Name    UNIQUE (RoleName)
);
GO

-- ==============================================================
-- 2. ACCOUNT
-- ==============================================================
CREATE TABLE lib.Account (
    AccountId     INT           NOT NULL IDENTITY(1,1),
    Username      NVARCHAR(100) NOT NULL,
    PasswordHash  NVARCHAR(256) NOT NULL,
    Email         NVARCHAR(256) NOT NULL,
    RoleId        TINYINT       NOT NULL,
    IsActive      BIT           NOT NULL CONSTRAINT DF_Account_IsActive  DEFAULT 1,
    LastLoginAt   DATETIME2(0)  NULL,
    CreatedAt     DATETIME2(0)  NOT NULL CONSTRAINT DF_Account_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt     DATETIME2(0)  NOT NULL CONSTRAINT DF_Account_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Account        PRIMARY KEY (AccountId),
    CONSTRAINT UQ_Account_User   UNIQUE (Username),
    CONSTRAINT UQ_Account_Email  UNIQUE (Email),
    CONSTRAINT FK_Account_Role   FOREIGN KEY (RoleId) REFERENCES lib.Role (RoleId)
);
GO

-- ==============================================================
-- 3. MEMBER  (1:1 with Account via shared PK)
-- ==============================================================
CREATE TABLE lib.Member (
    MemberId       INT           NOT NULL,
    FullName       NVARCHAR(150) NOT NULL,
    DateOfBirth    DATE          NULL,
    Phone          NVARCHAR(20)  NULL,
    Address        NVARCHAR(300) NULL,
    MemberCode     NVARCHAR(20)  NOT NULL,
    CardIssuedDate DATE          NOT NULL CONSTRAINT DF_Member_Issued  DEFAULT CAST(SYSUTCDATETIME() AS DATE),
    CardExpiryDate DATE          NOT NULL,
    IsActive       BIT           NOT NULL CONSTRAINT DF_Member_Active  DEFAULT 1,
    CreatedAt      DATETIME2(0)  NOT NULL CONSTRAINT DF_Member_Created DEFAULT SYSUTCDATETIME(),
    UpdatedAt      DATETIME2(0)  NOT NULL CONSTRAINT DF_Member_Updated DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Member           PRIMARY KEY (MemberId),
    CONSTRAINT UQ_Member_Code      UNIQUE (MemberCode),
    CONSTRAINT FK_Member_Account   FOREIGN KEY (MemberId)  REFERENCES lib.Account (AccountId),
    CONSTRAINT CK_Member_Expiry    CHECK (CardExpiryDate > CardIssuedDate)
);
GO

-- ==============================================================
-- 4. CATEGORY (hierarchical via ParentId)
-- ==============================================================
CREATE TABLE lib.Category (
    CategoryId   SMALLINT        NOT NULL IDENTITY(1,1),
    CategoryName NVARCHAR(100)   NOT NULL,
    ParentId     SMALLINT        NULL,
    Description  NVARCHAR(500)   NULL,
    IsActive     BIT             NOT NULL CONSTRAINT DF_Category_Active DEFAULT 1,
    CONSTRAINT PK_Category        PRIMARY KEY (CategoryId),
    CONSTRAINT UQ_Category_Name   UNIQUE (CategoryName),
    CONSTRAINT FK_Category_Parent FOREIGN KEY (ParentId) REFERENCES lib.Category (CategoryId)
);
GO

-- ==============================================================
-- 5. PUBLISHER
-- ==============================================================
CREATE TABLE lib.Publisher (
    PublisherId   SMALLINT        NOT NULL IDENTITY(1,1),
    PublisherName NVARCHAR(200)   NOT NULL,
    Address       NVARCHAR(300)   NULL,
    Phone         NVARCHAR(20)    NULL,
    Email         NVARCHAR(256)   NULL,
    Website       NVARCHAR(256)   NULL,
    IsActive      BIT             NOT NULL CONSTRAINT DF_Publisher_Active DEFAULT 1,
    CONSTRAINT PK_Publisher       PRIMARY KEY (PublisherId),
    CONSTRAINT UQ_Publisher_Name  UNIQUE (PublisherName)
);
GO

-- ==============================================================
-- 6. AUTHOR
-- ==============================================================
CREATE TABLE lib.Author (
    AuthorId    INT           NOT NULL IDENTITY(1,1),
    FullName    NVARCHAR(150) NOT NULL,
    PenName     NVARCHAR(150) NULL,
    Nationality NVARCHAR(100) NULL,
    Biography   NVARCHAR(MAX) NULL,
    IsActive    BIT           NOT NULL CONSTRAINT DF_Author_Active DEFAULT 1,
    CONSTRAINT PK_Author PRIMARY KEY (AuthorId)
);
GO

-- ==============================================================
-- 7. BOOK
-- ==============================================================
CREATE TABLE lib.Book (
    BookId        INT           NOT NULL IDENTITY(1,1),
    ISBN          NVARCHAR(20)  NOT NULL,
    Title         NVARCHAR(300) NOT NULL,
    SubTitle      NVARCHAR(300) NULL,
    CategoryId    SMALLINT      NOT NULL,
    PublisherId   SMALLINT      NOT NULL,
    PublishYear   SMALLINT      NULL,
    Edition       TINYINT       NULL,
    Language      NVARCHAR(50)  NULL CONSTRAINT DF_Book_Language DEFAULT N'Tieng Viet',
    PageCount     SMALLINT      NULL,
    Description   NVARCHAR(MAX) NULL,
    CoverImageUrl NVARCHAR(500) NULL,
    IsActive      BIT           NOT NULL CONSTRAINT DF_Book_Active   DEFAULT 1,
    CreatedAt     DATETIME2(0)  NOT NULL CONSTRAINT DF_Book_Created  DEFAULT SYSUTCDATETIME(),
    UpdatedAt     DATETIME2(0)  NOT NULL CONSTRAINT DF_Book_Updated  DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Book           PRIMARY KEY (BookId),
    CONSTRAINT UQ_Book_ISBN      UNIQUE (ISBN),
    CONSTRAINT FK_Book_Category  FOREIGN KEY (CategoryId)  REFERENCES lib.Category  (CategoryId),
    CONSTRAINT FK_Book_Publisher FOREIGN KEY (PublisherId) REFERENCES lib.Publisher (PublisherId),
    CONSTRAINT CK_Book_Year      CHECK (PublishYear IS NULL OR (PublishYear >= 1000 AND PublishYear <= 2100)),
    CONSTRAINT CK_Book_Pages     CHECK (PageCount IS NULL OR PageCount > 0)
);
GO

-- ==============================================================
-- 8. BOOKAUTHOR  (M:N junction)
-- ==============================================================
CREATE TABLE lib.BookAuthor (
    BookId     INT          NOT NULL,
    AuthorId   INT          NOT NULL,
    AuthorRole NVARCHAR(50) NOT NULL CONSTRAINT DF_BookAuthor_Role DEFAULT N'Main',
    CONSTRAINT PK_BookAuthor        PRIMARY KEY (BookId, AuthorId),
    CONSTRAINT FK_BookAuthor_Book   FOREIGN KEY (BookId)   REFERENCES lib.Book   (BookId),
    CONSTRAINT FK_BookAuthor_Author FOREIGN KEY (AuthorId) REFERENCES lib.Author (AuthorId)
);
GO

-- ==============================================================
-- 9. BOOKCOPY  (physical copy / inventory item)
-- ==============================================================
CREATE TABLE lib.BookCopy (
    BookCopyId   INT            NOT NULL IDENTITY(1,1),
    BookId       INT            NOT NULL,
    Barcode      NVARCHAR(50)   NOT NULL,
    AcquiredDate DATE           NOT NULL CONSTRAINT DF_Copy_Acquired DEFAULT CAST(SYSUTCDATETIME() AS DATE),
    Price        DECIMAL(12,2)  NULL,
    CopyStatus   NVARCHAR(20)   NOT NULL CONSTRAINT DF_Copy_Status  DEFAULT N'Available',
    Shelf        NVARCHAR(50)   NULL,
    Notes        NVARCHAR(500)  NULL,
    CreatedAt    DATETIME2(0)   NOT NULL CONSTRAINT DF_Copy_Created  DEFAULT SYSUTCDATETIME(),
    UpdatedAt    DATETIME2(0)   NOT NULL CONSTRAINT DF_Copy_Updated  DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_BookCopy        PRIMARY KEY (BookCopyId),
    CONSTRAINT UQ_BookCopy_Barcode UNIQUE (Barcode),
    CONSTRAINT FK_BookCopy_Book   FOREIGN KEY (BookId) REFERENCES lib.Book (BookId),
    CONSTRAINT CK_BookCopy_Status CHECK (CopyStatus IN (N'Available',N'OnLoan',N'Reserved',N'Lost',N'Damaged',N'Withdrawn')),
    CONSTRAINT CK_BookCopy_Price  CHECK (Price IS NULL OR Price >= 0)
);
GO

-- ==============================================================
-- 10. LOAN  (header)
-- ==============================================================
CREATE TABLE lib.Loan (
    LoanId             INT           NOT NULL IDENTITY(1,1),
    MemberId           INT           NOT NULL,
    LoanDate           DATE          NOT NULL CONSTRAINT DF_Loan_Date    DEFAULT CAST(SYSUTCDATETIME() AS DATE),
    DueDate            DATE          NOT NULL,
    LoanStatus         NVARCHAR(20)  NOT NULL CONSTRAINT DF_Loan_Status  DEFAULT N'Active',
    Notes              NVARCHAR(500) NULL,
    CreatedByAccountId INT           NOT NULL,
    CreatedAt          DATETIME2(0)  NOT NULL CONSTRAINT DF_Loan_Created DEFAULT SYSUTCDATETIME(),
    UpdatedAt          DATETIME2(0)  NOT NULL CONSTRAINT DF_Loan_Updated DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Loan           PRIMARY KEY (LoanId),
    CONSTRAINT FK_Loan_Member    FOREIGN KEY (MemberId)           REFERENCES lib.Member  (MemberId),
    CONSTRAINT FK_Loan_CreatedBy FOREIGN KEY (CreatedByAccountId) REFERENCES lib.Account (AccountId),
    CONSTRAINT CK_Loan_DueDate   CHECK (DueDate > LoanDate),
    CONSTRAINT CK_Loan_Status    CHECK (LoanStatus IN (N'Active',N'Returned',N'Overdue',N'Cancelled'))
);
GO

-- ==============================================================
-- 11. LOANITEM  (line item per copy)
-- ==============================================================
CREATE TABLE lib.LoanItem (
    LoanItemId          INT           NOT NULL IDENTITY(1,1),
    LoanId              INT           NOT NULL,
    BookCopyId          INT           NOT NULL,
    DueDate             DATE          NOT NULL,
    ReturnedDate        DATE          NULL,
    OverdueFine         DECIMAL(10,2) NULL CONSTRAINT DF_LoanItem_Fine DEFAULT 0,
    ConditionOnReturn   NVARCHAR(50)  NULL,
    Notes               NVARCHAR(500) NULL,
    ReturnedByAccountId INT           NULL,
    CONSTRAINT PK_LoanItem            PRIMARY KEY (LoanItemId),
    CONSTRAINT UQ_LoanItem_CopyLoan   UNIQUE (BookCopyId, LoanId),
    CONSTRAINT FK_LoanItem_Loan       FOREIGN KEY (LoanId)              REFERENCES lib.Loan     (LoanId),
    CONSTRAINT FK_LoanItem_Copy       FOREIGN KEY (BookCopyId)          REFERENCES lib.BookCopy (BookCopyId),
    CONSTRAINT FK_LoanItem_ReturnedBy FOREIGN KEY (ReturnedByAccountId) REFERENCES lib.Account  (AccountId),
    CONSTRAINT CK_LoanItem_Fine       CHECK (OverdueFine IS NULL OR OverdueFine >= 0)
);
GO

-- ==============================================================
-- INDEXES
-- ==============================================================
CREATE NONCLUSTERED INDEX IX_BookCopy_BookId      ON lib.BookCopy  (BookId)            INCLUDE (CopyStatus, Barcode);
CREATE NONCLUSTERED INDEX IX_Loan_Member_Status   ON lib.Loan      (MemberId, LoanStatus);
CREATE NONCLUSTERED INDEX IX_LoanItem_DueDate     ON lib.LoanItem  (DueDate)           WHERE ReturnedDate IS NULL;
CREATE NONCLUSTERED INDEX IX_Book_Title           ON lib.Book      (Title);
CREATE NONCLUSTERED INDEX IX_BookAuthor_AuthorId  ON lib.BookAuthor (AuthorId);
GO

-- ==============================================================
-- VIEW: vw_Inventory
-- ==============================================================
CREATE OR ALTER VIEW lib.vw_Inventory AS
SELECT
    b.BookId, b.ISBN, b.Title,
    c.CategoryName, p.PublisherName,
    COUNT(bc.BookCopyId) AS TotalCopies,
    SUM(CASE WHEN bc.CopyStatus = N'Available' THEN 1 ELSE 0 END) AS AvailableCopies,
    SUM(CASE WHEN bc.CopyStatus = N'OnLoan'    THEN 1 ELSE 0 END) AS OnLoanCopies
FROM lib.Book b
JOIN lib.Category  c  ON c.CategoryId  = b.CategoryId
JOIN lib.Publisher p  ON p.PublisherId = b.PublisherId
LEFT JOIN lib.BookCopy bc ON bc.BookId = b.BookId
WHERE b.IsActive = 1
GROUP BY b.BookId, b.ISBN, b.Title, c.CategoryName, p.PublisherName;
GO

-- ==============================================================
-- VIEW: vw_ActiveLoans
-- ==============================================================
CREATE OR ALTER VIEW lib.vw_ActiveLoans AS
SELECT
    li.LoanItemId, l.LoanId, l.LoanDate, li.DueDate,
    m.MemberCode, m.FullName AS MemberName,
    b.ISBN, b.Title AS BookTitle,
    bc.Barcode AS CopyBarcode, bc.CopyStatus,
    DATEDIFF(DAY, li.DueDate, CAST(SYSUTCDATETIME() AS DATE)) AS DaysOverdue
FROM lib.LoanItem li
JOIN lib.Loan     l  ON l.LoanId      = li.LoanId
JOIN lib.Member   m  ON m.MemberId    = l.MemberId
JOIN lib.BookCopy bc ON bc.BookCopyId = li.BookCopyId
JOIN lib.Book     b  ON b.BookId      = bc.BookId
WHERE li.ReturnedDate IS NULL
  AND l.LoanStatus IN (N'Active', N'Overdue');
GO

PRINT N'V1 schema created successfully.';
GO

