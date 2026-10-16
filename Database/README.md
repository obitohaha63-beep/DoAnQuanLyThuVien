# Database – LibraryManagement V1

## Danh sach script

| File | Mo ta |
|------|-------|
| `V1__Create_Schema.sql` | Tao CSDL + toan bo bang, rang buoc, index, view |
| `V1__Seed_Data.sql`     | Du lieu demo (chay sau schema) |
| `V1__Validation.sql`    | Tu kiem tra FK, UNIQUE, CHECK va truy van ton kho |

## Cach su dung

```sql
-- 1. Tao schema
sqlcmd -S (localdb)\MSSQLLocalDB -i V1__Create_Schema.sql

-- 2. Nhap du lieu mau
sqlcmd -S (localdb)\MSSQLLocalDB -d LibraryManagement -i V1__Seed_Data.sql

-- 3. Chay tu kiem tra
sqlcmd -S (localdb)\MSSQLLocalDB -d LibraryManagement -i V1__Validation.sql
```

Hoac mo tung file trong SSMS va F5.

---

## So do ERD (3NF)

```
lib.Role (1) ──────────── (N) lib.Account
                                   │
                                   │ 1:1 (shared PK)
                                   ▼
                              lib.Member
                                   │
                                   │ 1:N
                                   ▼
                              lib.Loan ──── (N) lib.LoanItem ──── (1) lib.BookCopy
                                                                          │
                                                                          │ N:1
                                                                          ▼
lib.Category (1) ─────────────────────────── (N) lib.Book ──── (N) lib.BookAuthor ──── (1) lib.Author
lib.Publisher (1) ────────────────────────────────┘
```

---

## Mo ta bang

### lib.Role
| Cot | Kieu | Rang buoc | Mo ta |
|-----|------|-----------|-------|
| RoleId | TINYINT IDENTITY | PK | ID vai tro |
| RoleName | NVARCHAR(50) | NOT NULL, UNIQUE | Ten vai tro: Admin / Librarian / Member |
| Description | NVARCHAR(255) | NULL | Mo ta |

### lib.Account
| Cot | Kieu | Rang buoc | Mo ta |
|-----|------|-----------|-------|
| AccountId | INT IDENTITY | PK | ID tai khoan |
| Username | NVARCHAR(100) | NOT NULL, UNIQUE | Ten dang nhap |
| PasswordHash | NVARCHAR(256) | NOT NULL | Ma hoa bcrypt / PBKDF2 |
| Email | NVARCHAR(256) | NOT NULL, UNIQUE | Email dang nhap |
| RoleId | TINYINT | NOT NULL, FK -> Role | Vai tro |
| IsActive | BIT | NOT NULL, DEFAULT 1 | Trang thai hoat dong |
| LastLoginAt | DATETIME2(0) | NULL | Lan dang nhap cuoi |
| CreatedAt | DATETIME2(0) | NOT NULL, DEFAULT NOW | |
| UpdatedAt | DATETIME2(0) | NOT NULL, DEFAULT NOW | |

### lib.Member
| Cot | Kieu | Rang buoc | Mo ta |
|-----|------|-----------|-------|
| MemberId | INT | PK + FK -> Account (1:1) | ID thanh vien = ID tai khoan |
| FullName | NVARCHAR(150) | NOT NULL | Ho ten day du |
| DateOfBirth | DATE | NULL | Ngay sinh |
| Phone | NVARCHAR(20) | NULL | So dien thoai |
| Address | NVARCHAR(300) | NULL | Dia chi |
| MemberCode | NVARCHAR(20) | NOT NULL, UNIQUE | Ma the thu vien (LIB-xxxxx) |
| CardIssuedDate | DATE | NOT NULL | Ngay cap the |
| CardExpiryDate | DATE | NOT NULL, CHECK > Issued | Ngay het han |
| IsActive | BIT | NOT NULL, DEFAULT 1 | Con hoat dong |

### lib.Category
| Cot | Kieu | Rang buoc | Mo ta |
|-----|------|-----------|-------|
| CategoryId | SMALLINT IDENTITY | PK | |
| CategoryName | NVARCHAR(100) | NOT NULL, UNIQUE | Ten the loai |
| ParentId | SMALLINT | NULL, FK -> Category (tu tham chieu) | The loai cha |
| IsActive | BIT | NOT NULL, DEFAULT 1 | |

### lib.Publisher
| Cot | Kieu | Rang buoc | Mo ta |
|-----|------|-----------|-------|
| PublisherId | SMALLINT IDENTITY | PK | |
| PublisherName | NVARCHAR(200) | NOT NULL, UNIQUE | Ten nha xuat ban |
| Address / Phone / Email / Website | NVARCHAR | NULL | Thong tin lien he |
| IsActive | BIT | NOT NULL, DEFAULT 1 | |

### lib.Author
| Cot | Kieu | Rang buoc | Mo ta |
|-----|------|-----------|-------|
| AuthorId | INT IDENTITY | PK | |
| FullName | NVARCHAR(150) | NOT NULL | Ho ten that |
| PenName | NVARCHAR(150) | NULL | But danh |
| Nationality | NVARCHAR(100) | NULL | Quoc tich |
| Biography | NVARCHAR(MAX) | NULL | Tieu su |
| IsActive | BIT | NOT NULL, DEFAULT 1 | |

### lib.Book
| Cot | Kieu | Rang buoc | Mo ta |
|-----|------|-----------|-------|
| BookId | INT IDENTITY | PK | |
| ISBN | NVARCHAR(20) | NOT NULL, UNIQUE | Ma ISBN (13/10 chu so) |
| Title | NVARCHAR(300) | NOT NULL | Tieu de |
| SubTitle | NVARCHAR(300) | NULL | Phu tieu de |
| CategoryId | SMALLINT | NOT NULL, FK -> Category | The loai |
| PublisherId | SMALLINT | NOT NULL, FK -> Publisher | Nha xuat ban |
| PublishYear | SMALLINT | NULL, CHECK 1000-2100 | Nam xuat ban |
| Edition | TINYINT | NULL | Lan xuat ban |
| Language | NVARCHAR(50) | NULL, DEFAULT 'Tieng Viet' | Ngon ngu |
| PageCount | SMALLINT | NULL, CHECK > 0 | So trang |
| Description | NVARCHAR(MAX) | NULL | Mo ta sach |
| CoverImageUrl | NVARCHAR(500) | NULL | Duong dan anh bia |
| IsActive | BIT | NOT NULL, DEFAULT 1 | |

### lib.BookAuthor  (bang trung gian N:N)
| Cot | Kieu | Rang buoc | Mo ta |
|-----|------|-----------|-------|
| BookId | INT | PK(1/2) + FK -> Book | |
| AuthorId | INT | PK(2/2) + FK -> Author | |
| AuthorRole | NVARCHAR(50) | NOT NULL, DEFAULT 'Main' | Main / Co-author / Translator / Editor |

### lib.BookCopy
| Cot | Kieu | Rang buoc | Mo ta |
|-----|------|-----------|-------|
| BookCopyId | INT IDENTITY | PK | |
| BookId | INT | NOT NULL, FK -> Book | Dau sach thuoc ve |
| Barcode | NVARCHAR(50) | NOT NULL, UNIQUE | Ma vach dan vat ly |
| AcquiredDate | DATE | NOT NULL | Ngay nhap kho |
| Price | DECIMAL(12,2) | NULL, CHECK >= 0 | Gia tri thay the |
| CopyStatus | NVARCHAR(20) | NOT NULL, CHECK domain | Available / OnLoan / Reserved / Lost / Damaged / Withdrawn |
| Shelf | NVARCHAR(50) | NULL | Vi tri ke sach |
| Notes | NVARCHAR(500) | NULL | Ghi chu |

### lib.Loan
| Cot | Kieu | Rang buoc | Mo ta |
|-----|------|-----------|-------|
| LoanId | INT IDENTITY | PK | |
| MemberId | INT | NOT NULL, FK -> Member | Thanh vien muon |
| LoanDate | DATE | NOT NULL, DEFAULT TODAY | Ngay muon |
| DueDate | DATE | NOT NULL, CHECK > LoanDate | Han tra |
| LoanStatus | NVARCHAR(20) | NOT NULL, CHECK domain | Active / Returned / Overdue / Cancelled |
| Notes | NVARCHAR(500) | NULL | Ghi chu |
| CreatedByAccountId | INT | NOT NULL, FK -> Account | Thu thu xu ly |

### lib.LoanItem
| Cot | Kieu | Rang buoc | Mo ta |
|-----|------|-----------|-------|
| LoanItemId | INT IDENTITY | PK | |
| LoanId | INT | NOT NULL, FK -> Loan | Phieu muon |
| BookCopyId | INT | NOT NULL, FK -> BookCopy | Ban sach cu the |
| DueDate | DATE | NOT NULL | Han tra (co the gia han) |
| ReturnedDate | DATE | NULL | NULL = chua tra |
| OverdueFine | DECIMAL(10,2) | NULL, CHECK >= 0 | Phi phat (neu co) |
| ConditionOnReturn | NVARCHAR(50) | NULL | Tinh trang khi tra |
| ReturnedByAccountId | INT | NULL, FK -> Account | Thu thu nhan tra |

---

## Index
| Index | Bang | Cot | Muc dich |
|-------|------|-----|----------|
| IX_BookCopy_BookId | BookCopy | BookId INCLUDE (CopyStatus, Barcode) | Truy van ton kho |
| IX_Loan_Member_Status | Loan | MemberId, LoanStatus | Luot muon theo thanh vien |
| IX_LoanItem_DueDate | LoanItem | DueDate WHERE ReturnedDate IS NULL | Phat hien qua han |
| IX_Book_Title | Book | Title | Tim kiem sach |
| IX_BookAuthor_AuthorId | BookAuthor | AuthorId | Sach cua tac gia |

---

## View
| View | Mo ta |
|------|-------|
| `lib.vw_Inventory` | So ban co san / dang muon / tong so theo tieu de sach |
| `lib.vw_ActiveLoans` | Tat ca luot muon chua tra, kem so ngay qua han |

---

## Gia dinh thiet ke
1. **Book vs BookCopy**: Book la ban ghi thu muc; BookCopy la ban vat ly co the muon duoc.
2. **Account – Member 1:1**: Thu tu va Admin co Account nhung khong co Member. Chi doc gia moi co ca hai.
3. **DueDate tren LoanItem**: Co the khac voi DueDate tren Loan header (cho phep gia han tung cuon rieng le).
4. **Ton kho**: `AvailableCopies = COUNT(*) WHERE CopyStatus = 'Available'`. Khi muon sach phai cap nhat CopyStatus -> 'OnLoan' dong thoi.
5. **Mat khau**: Luu hash (bcrypt/PBKDF2); khong bao gio luu plain-text.
6. **Xoa mem**: Dung IsActive = 0, khong DELETE thuc su (ngoai script dev).
7. **Collation**: Vietnamese_CI_AS dam bao sort/search tieng Viet chinh xac.
