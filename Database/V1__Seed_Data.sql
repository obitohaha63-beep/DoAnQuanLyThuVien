SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
-- ============================================================
-- Library Management System – Seed / Demo Data
-- Version  : V1
-- Run AFTER V1__Create_Schema.sql
-- ============================================================

USE LibraryManagement;
GO

SET NOCOUNT ON;

-- ==============================================================
-- 1. Roles
-- ==============================================================
INSERT INTO lib.Role (RoleName, Description) VALUES
    (N'Admin',     N'Quan tri vien he thong'),
    (N'Librarian', N'Thu thu'),
    (N'Member',    N'Doc gia / Thanh vien thu vien');
GO

-- ==============================================================
-- 2. Accounts  (password = "Password@123" hashed – placeholder)
-- ==============================================================
INSERT INTO lib.Account (Username, PasswordHash, Email, RoleId) VALUES
    (N'admin',    N'$2a$12$PLACEHOLDER_ADMIN_HASH',    N'admin@library.vn',    1),  -- Admin
    (N'librarian1', N'$2a$12$PLACEHOLDER_LIB1_HASH',  N'lib1@library.vn',     2),  -- Librarian
    (N'nguyen.van.an',  N'$2a$12$PLACEHOLDER_MBR1',   N'an.nguyen@mail.vn',   3),  -- Member
    (N'tran.thi.bich',  N'$2a$12$PLACEHOLDER_MBR2',   N'bich.tran@mail.vn',   3),  -- Member
    (N'le.van.cuong',   N'$2a$12$PLACEHOLDER_MBR3',   N'cuong.le@mail.vn',    3);  -- Member
GO

-- ==============================================================
-- 3. Members  (AccountId 3-5 = member accounts)
-- ==============================================================
INSERT INTO lib.Member (MemberId, FullName, DateOfBirth, Phone, Address, MemberCode, CardIssuedDate, CardExpiryDate) VALUES
    (3, N'Nguyen Van An',  '2000-05-15', N'0901234567', N'123 Nguyen Hue, Q1, TP.HCM', N'LIB-00001', '2025-01-10', '2027-01-10'),
    (4, N'Tran Thi Bich',  '1998-11-20', N'0912345678', N'456 Le Loi, Q3, TP.HCM',     N'LIB-00002', '2025-03-01', '2027-03-01'),
    (5, N'Le Van Cuong',   '2002-07-30', N'0923456789', N'789 CMT8, Q10, TP.HCM',      N'LIB-00003', '2025-06-15', '2027-06-15');
GO

-- ==============================================================
-- 4. Categories  (with sub-categories)
-- ==============================================================
INSERT INTO lib.Category (CategoryName, ParentId, Description) VALUES
    (N'Van hoc',           NULL, N'Sach van hoc trong va ngoai nuoc'),
    (N'Khoa hoc ky thuat', NULL, N'Cong nghe, ky thuat, tin hoc'),
    (N'Kinh te',           NULL, N'Kinh doanh, tai chinh, quan tri');
-- Sub-categories
INSERT INTO lib.Category (CategoryName, ParentId, Description) VALUES
    (N'Tieu thuyet',       1, N'Tieu thuyet Viet Nam va dich'),
    (N'Tho ca',            1, N'Tho, ca dao, van hoc dan gian'),
    (N'Lap trinh',         2, N'Ngon ngu lap trinh, thuat toan'),
    (N'Co so du lieu',     2, N'RDBMS, NoSQL, data warehouse'),
    (N'Quan tri kinh doanh', 3, N'MBA, quan tri, lanh dao');
GO

-- ==============================================================
-- 5. Publishers
-- ==============================================================
INSERT INTO lib.Publisher (PublisherName, Address, Phone, Email, Website) VALUES
    (N'NXB Kim Dong',         N'55 Quang Trung, Ha Noi',         N'024-39433448', N'contact@kimdong.vn',   N'https://kimdong.vn'),
    (N'NXB Tre',              N'161B Ly Chinh Thang, Q3, HCM',   N'028-39316289', N'contact@nxbtre.vn',    N'https://nxbtre.vn'),
    (N'NXB Giao Duc Viet Nam',N'81 Tran Hung Dao, Ha Noi',       N'024-38222143', N'contact@nxbgd.vn',     N'https://nxbgiaoduc.edu.vn'),
    (N'O''Reilly Media',      N'1005 Gravenstein Hwy N, CA',     NULL,            N'info@oreilly.com',     N'https://oreilly.com');
GO

-- ==============================================================
-- 6. Authors
-- ==============================================================
INSERT INTO lib.Author (FullName, PenName, Nationality, Biography) VALUES
    (N'Nam Cao',              N'Nam Cao',            N'Viet Nam', N'Nha van hien thuc Viet Nam, tac gia Chi Pheo, Lao Hac...'),
    (N'Nguyen Du',            N'To Nhu',             N'Viet Nam', N'Dai thi hao, tac gia Truyen Kieu'),
    (N'Robert C. Martin',     N'Uncle Bob',          N'USA',      N'Software engineer, author of Clean Code'),
    (N'Martin Fowler',        NULL,                  N'UK',       N'Software architect, author of Refactoring'),
    (N'C.J. Date',            NULL,                  N'UK',       N'Database theorist, author of An Introduction to Database Systems'),
    (N'Nguyen Nhat Anh',      NULL,                  N'Viet Nam', N'Nha van Viet Nam noi tieng voi tieu thuyet thieu nhi');
GO

-- ==============================================================
-- 7. Books
-- ==============================================================
INSERT INTO lib.Book (ISBN, Title, CategoryId, PublisherId, PublishYear, Edition, Language, PageCount) VALUES
    (N'978-604-2-27401-3', N'Chi Pheo',                         4, 2, 2020, 5, N'Tieng Viet', 180),
    (N'978-604-1-19350-6', N'Truyen Kieu',                      5, 3, 2019, 3, N'Tieng Viet', 350),
    (N'978-0-13-468599-1', N'Clean Code',                       6, 4, 2008, 1, N'English',    431),
    (N'978-0-20-148567-7', N'Refactoring: Improving Design',    6, 4, 2018, 2, N'English',    448),
    (N'978-0-20-170022-3', N'An Introduction to Database Systems', 7, 4, 2004, 8, N'English', 1024),
    (N'978-604-2-23101-5', N'Mat Biec',                         4, 2, 2021, 10, N'Tieng Viet', 248);
GO

-- ==============================================================
-- 8. BookAuthor  (junction)
-- ==============================================================
INSERT INTO lib.BookAuthor (BookId, AuthorId, AuthorRole) VALUES
    (1, 1, N'Main'),   -- Chi Pheo -> Nam Cao
    (2, 2, N'Main'),   -- Truyen Kieu -> Nguyen Du
    (3, 3, N'Main'),   -- Clean Code -> Uncle Bob
    (4, 4, N'Main'),   -- Refactoring -> Martin Fowler
    (5, 5, N'Main'),   -- DB Systems -> C.J. Date
    (6, 6, N'Main');   -- Mat Biec -> Nguyen Nhat Anh
GO

-- ==============================================================
-- 9. BookCopies  (multiple copies per book)
-- ==============================================================
INSERT INTO lib.BookCopy (BookId, Barcode, AcquiredDate, Price, CopyStatus, Shelf) VALUES
-- Chi Pheo: 3 copies
    (1, N'BC-00001', '2023-01-10', 55000,  N'Available', N'A1-001'),
    (1, N'BC-00002', '2023-01-10', 55000,  N'OnLoan',    N'A1-001'),
    (1, N'BC-00003', '2024-06-01', 55000,  N'Available', N'A1-001'),
-- Truyen Kieu: 2 copies
    (2, N'BC-00004', '2023-02-15', 72000,  N'Available', N'A1-002'),
    (2, N'BC-00005', '2023-02-15', 72000,  N'Damaged',   N'A1-002'),
-- Clean Code: 3 copies
    (3, N'BC-00006', '2022-09-01', 280000, N'Available', N'B2-001'),
    (3, N'BC-00007', '2022-09-01', 280000, N'OnLoan',    N'B2-001'),
    (3, N'BC-00008', '2024-03-20', 290000, N'Available', N'B2-001'),
-- Refactoring: 2 copies
    (4, N'BC-00009', '2023-07-11', 310000, N'Available', N'B2-002'),
    (4, N'BC-00010', '2023-07-11', 310000, N'Reserved',  N'B2-002'),
-- DB Systems: 1 copy
    (5, N'BC-00011', '2021-05-20', 450000, N'OnLoan',    N'B3-001'),
-- Mat Biec: 2 copies
    (6, N'BC-00012', '2024-01-05', 88000,  N'Available', N'A1-003'),
    (6, N'BC-00013', '2024-01-05', 88000,  N'Available', N'A1-003');
GO

-- ==============================================================
-- 10. Loans
-- ==============================================================
INSERT INTO lib.Loan (MemberId, LoanDate, DueDate, LoanStatus, CreatedByAccountId, Notes) VALUES
    (3, '2026-09-01', '2026-09-15', N'Returned', 2, N'Tra dung han'),
    (4, '2026-09-10', '2026-09-24', N'Overdue',  2, NULL),
    (5, '2026-10-01', '2026-10-15', N'Active',   2, NULL),
    (3, '2026-10-05', '2026-10-19', N'Active',   2, NULL);
GO

-- ==============================================================
-- 11. LoanItems
-- ==============================================================
INSERT INTO lib.LoanItem (LoanId, BookCopyId, DueDate, ReturnedDate, OverdueFine, ReturnedByAccountId) VALUES
-- Loan 1 (Returned) – BC-00001 Chi Pheo
    (1, 1, '2026-09-15', '2026-09-13', 0,    2),
-- Loan 2 (Overdue) – BC-00002 Chi Pheo, BC-00007 Clean Code, BC-00011 DB Systems
    (2, 2,  '2026-09-24', NULL, 0, NULL),
    (2, 7,  '2026-09-24', NULL, 0, NULL),
    (2, 11, '2026-09-24', NULL, 0, NULL),
-- Loan 3 (Active) – BC-00008 Clean Code
    (3, 8,  '2026-10-15', NULL, 0, NULL),
-- Loan 4 (Active) – BC-00012 Mat Biec
    (4, 12, '2026-10-19', NULL, 0, NULL);
GO

PRINT N'V1 seed data inserted successfully.';
GO

