# 01 – Phân tích yêu cầu

**Dự án:** Đồ án Quản lý Thư viện
**Phiên bản tài liệu:** 1.0
**Ngày:** 2026-10-16
**Nhóm:** Đinh Công Thành · Trần Huỳnh Phát
**Trạng thái:** Bản nháp – chờ xác nhận giảng viên

> **Quy ước mã yêu cầu**
> `FR-xxx` = Chức năng bắt buộc (Functional Requirement)
> `NFR-xxx` = Yêu cầu phi chức năng (Non-Functional Requirement)
> `OPEN-xxx` = Điểm còn mở, cần nhóm / giảng viên xác nhận
> Cột **Nơi thực hiện** ghi `Web` (Library.Web · ASP.NET Core MVC), `Desktop` (Library.Admin · WinForms) hoặc `DB` (SQL Server / Library.Data).

---

## 1. Mục tiêu

Xây dựng hệ thống quản lý thư viện gồm hai giao diện dùng chung một SQL Server:

| Ứng dụng | Mô tả |
|----------|-------|
| **Library.Web** (ASP.NET Core MVC) | Cổng dành cho độc giả: tìm kiếm sách, xem tình trạng, đăng nhập xem lịch sử mượn |
| **Library.Admin** (WinForms) | Màn hình nội bộ cho nhân viên và quản trị viên: quản lý danh mục, lập phiếu mượn/trả |

Cả hai ứng dụng đều đọc/ghi vào **cùng một database** `LibraryManagement` thông qua tầng `Library.Data` (ADO.NET hoặc EF Core – xem `OPEN-01`).

---

## 2. Phạm vi hệ thống

### 2.1 Trong phạm vi (In-scope)

| # | Đối tượng / Chức năng | Ghi chú |
|---|----------------------|---------|
| 1 | Quản lý **Sách** (Book) | ISBN, tên, năm xuất bản, ảnh bìa |
| 2 | Quản lý **Thể loại** (Category) | Có phân cấp cha–con |
| 3 | Quản lý **Tác giả** (Author) | Bút danh, quốc tịch |
| 4 | Quản lý **Nhà xuất bản** (Publisher) | |
| 5 | Quản lý **Bản sao vật lý** (BookCopy) | Mã vạch, vị trí kệ, trạng thái |
| 6 | Quản lý **Độc giả** (Member) | Mã thẻ, ngày hết hạn thẻ |
| 7 | Quản lý **Nhân viên / Tài khoản** (Account + Role) | Admin, Librarian, Member |
| 8 | **Tìm kiếm sách** | Theo tên, tác giả, thể loại, ISBN |
| 9 | **Lập phiếu mượn** (Loan + LoanItem) | Chọn độc giả, chọn bản sao |
| 10 | **Lập phiếu trả** | Ghi ngày trả, tình trạng, phí phạt nếu quá hạn |

### 2.2 Ngoài phạm vi (Out-of-scope) – V1

- Thanh toán trực tuyến phí phạt
- Ứng dụng di động
- Gửi email/SMS thông báo quá hạn tự động (`OPEN-02`)
- Quản lý mua sách / nhập kho nâng cao

---

## 3. Khảo sát hệ thống tương tự

| Hệ thống | Điểm tham khảo | Điểm khác biệt so với đồ án |
|----------|---------------|------------------------------|
| **Koha** (mã nguồn mở) | Phân biệt bản ghi thư mục (biblioitem) và bản sao vật lý (item) – đây là mô hình mà đồ án áp dụng (Book / BookCopy) | Koha hỗ trợ MARC21, đồ án đơn giản hóa |
| **OpenBiblio** | Mượn/trả theo barcode, theo dõi quá hạn | Không có tầng web riêng cho độc giả |
| **Hệ thống thư viện ĐHBK HCM** | Tìm kiếm online, lịch sử mượn cho sinh viên | Tích hợp SSO trường học – đồ án dùng auth nội bộ |

**Kết luận:** Mô hình Book ↔ BookCopy là thực tiễn phổ biến; tầng Web dành cho độc giả giúp tự tra cứu mà không cần đến quầy.

---

## 4. Vai trò và quyền hạn

| Vai trò | Mô tả | Ứng dụng truy cập |
|---------|-------|-------------------|
| **Admin** | Quản trị toàn hệ thống: tạo/xóa tài khoản, cấu hình danh mục, xem báo cáo | Desktop (Admin) |
| **Librarian** (Nhân viên) | Lập phiếu mượn/trả, quản lý bản sao, tìm kiếm độc giả | Desktop (Admin) |
| **Member** (Độc giả) | Tìm sách, xem tình trạng còn sách, xem lịch sử mượn cá nhân | Web |

> `OPEN-03`: Độc giả có thể **đặt trước** sách trực tuyến (trạng thái `Reserved`) hay chỉ đặt qua quầy? → Cần xác nhận.

---

## 5. Yêu cầu chức năng

### 5.1 Nhóm: Quản lý danh mục (Admin / Librarian – Desktop)

| Mã | Yêu cầu | Nơi thực hiện |
|----|---------|--------------|
| FR-01 | Thêm, sửa, ẩn (soft-delete) Thể loại; hỗ trợ phân cấp cha–con | Desktop · DB |
| FR-02 | Thêm, sửa, ẩn Tác giả (bút danh, quốc tịch) | Desktop · DB |
| FR-03 | Thêm, sửa, ẩn Nhà xuất bản | Desktop · DB |
| FR-04 | Thêm, sửa, ẩn đầu sách (ISBN, tên, thể loại, tác giả, năm XB) | Desktop · DB |
| FR-05 | Thêm bản sao vật lý (barcode, kệ, giá trị) cho một đầu sách | Desktop · DB |
| FR-06 | Cập nhật trạng thái bản sao (Available / Damaged / Lost / Withdrawn) | Desktop · DB |

### 5.2 Nhóm: Quản lý tài khoản (Admin – Desktop)

| Mã | Yêu cầu | Nơi thực hiện |
|----|---------|--------------|
| FR-07 | Tạo tài khoản nhân viên (Admin, Librarian) | Desktop · DB |
| FR-08 | Tạo hồ sơ độc giả + tài khoản đăng nhập Web; sinh mã thẻ tự động (LIB-xxxxx) | Desktop · DB |
| FR-09 | Gia hạn / vô hiệu hóa thẻ độc giả | Desktop · DB |
| FR-10 | Đổi mật khẩu (tự đổi hoặc Admin reset) | Desktop · Web · DB |

### 5.3 Nhóm: Tìm kiếm sách (Tất cả vai trò)

| Mã | Yêu cầu | Nơi thực hiện |
|----|---------|--------------|
| FR-11 | Tìm sách theo tên (LIKE), ISBN, tác giả, thể loại | Web · Desktop · DB |
| FR-12 | Kết quả tìm kiếm hiển thị **số bản còn có thể mượn** (`AvailableCopies`) | Web · Desktop |
| FR-13 | Xem chi tiết đầu sách: thông tin, danh sách bản sao và trạng thái từng bản | Web · Desktop |

### 5.4 Nhóm: Mượn sách (Librarian – Desktop)

| Mã | Yêu cầu | Nơi thực hiện |
|----|---------|--------------|
| FR-14 | Lập phiếu mượn: chọn độc giả (quét mã thẻ hoặc tìm tên), chọn ≥1 bản sao (quét barcode) | Desktop · DB |
| FR-15 | Hệ thống tự xác nhận: bản sao phải có trạng thái `Available` | Desktop · DB |
| FR-16 | Hệ thống tự xác nhận: thẻ độc giả còn hiệu lực (`CardExpiryDate` ≥ hôm nay) | Desktop · DB |
| FR-17 | Sau khi lập phiếu, tự động cập nhật `BookCopy.CopyStatus = 'OnLoan'` | DB |
| FR-18 | Hạn trả mặc định = ngày mượn + N ngày (N cần xác nhận – xem `OPEN-04`) | Desktop · DB |

### 5.5 Nhóm: Trả sách (Librarian – Desktop)

| Mã | Yêu cầu | Nơi thực hiện |
|----|---------|--------------|
| FR-19 | Tìm phiếu mượn theo mã độc giả hoặc barcode bản sao | Desktop · DB |
| FR-20 | Ghi nhận ngày trả thực tế vào `LoanItem.ReturnedDate` | Desktop · DB |
| FR-21 | Nếu `ReturnedDate > LoanItem.DueDate` → **tính phí phạt** theo quy tắc (`OPEN-05`) | Desktop · DB |
| FR-22 | Ghi tình trạng sách khi trả (`ConditionOnReturn`); nếu hỏng → cập nhật `CopyStatus = 'Damaged'` | Desktop · DB |
| FR-23 | Sau khi trả, tự động cập nhật `BookCopy.CopyStatus = 'Available'` (trừ khi hỏng/mất) | DB |
| FR-24 | Phiếu mượn được đánh dấu `LoanStatus = 'Returned'` khi tất cả mục đã trả | DB |

### 5.6 Nhóm: Web dành cho độc giả (Member – Web)

| Mã | Yêu cầu | Nơi thực hiện |
|----|---------|--------------|
| FR-25 | Đăng nhập bằng Username / mật khẩu | Web · DB |
| FR-26 | Trang chủ: tìm kiếm sách nhanh | Web |
| FR-27 | Trang chi tiết sách: hiển thị số bản có thể mượn, danh sách kệ | Web · DB |
| FR-28 | Lịch sử mượn cá nhân: danh sách phiếu, hạn trả, trạng thái | Web · DB |
| FR-29 | Cảnh báo sách sắp đến hạn (hiển thị trên giao diện) | Web |

### 5.7 Nhóm: Báo cáo (Admin – Desktop)

| Mã | Yêu cầu | Nơi thực hiện |
|----|---------|--------------|
| FR-30 | Danh sách phiếu mượn quá hạn | Desktop · DB |
| FR-31 | Tồn kho: số bản có thể mượn theo từng đầu sách | Desktop · DB |
| FR-32 | Lịch sử mượn theo độc giả | Desktop · DB |

---

## 6. Use Case tóm tắt

```
┌──────────────────────────────────────────────────────────────┐
│                       <<system>>                             │
│                    LibraryManagement                         │
│                                                              │
│  [FR-11,12,13] Tìm kiếm sách ◄──── Độc giả (Web)           │
│  [FR-25..29]   Xem lịch sử / cảnh báo ◄──── Độc giả (Web)  │
│                                                              │
│  [FR-14..18]   Lập phiếu mượn  ◄──── Nhân viên (Desktop)   │
│  [FR-19..24]   Lập phiếu trả   ◄──── Nhân viên (Desktop)   │
│  [FR-01..06]   Quản lý danh mục ◄─── Nhân viên (Desktop)   │
│  [FR-07..10]   Quản lý tài khoản ◄── Admin (Desktop)        │
│  [FR-30..32]   Báo cáo ◄─────────── Admin (Desktop)         │
└──────────────────────────────────────────────────────────────┘
        │                  │
   Library.Web       Library.Admin
   (ASP.NET MVC)     (WinForms)
        └──────────┬────────┘
                   │
           Library.Data (chung)
                   │
            SQL Server
          LibraryManagement DB
```

---

## 7. Quy tắc nghiệp vụ mượn – trả

### 7.1 Số bản có thể mượn

```
AvailableCopies = số bản có CopyStatus = 'Available'
```

Được tính trực tiếp qua view `lib.vw_Inventory`. Độc giả và nhân viên thấy con số này theo thời gian thực.

### 7.2 Trạng thái phiếu mượn (Loan.LoanStatus)

| Trạng thái | Ý nghĩa | Điều kiện chuyển |
|------------|---------|-----------------|
| `Active` | Phiếu đang hiệu lực, chưa đến hạn | Mới tạo |
| `Overdue` | Quá hạn, chưa trả | Hệ thống/job kiểm tra `DueDate < ngày hôm nay` |
| `Returned` | Tất cả mục đã trả | Khi `LoanItem.ReturnedDate` được ghi cho tất cả mục |
| `Cancelled` | Hủy trước khi mượn | Admin/Librarian thực hiện |

> `OPEN-06`: Việc chuyển `Active → Overdue` được thực hiện bởi **SQL Agent Job** chạy mỗi đêm, hay bởi **ứng dụng kiểm tra** mỗi lần mở? → Cần xác nhận.

### 7.3 Hạn trả

- `Loan.DueDate` = ngày trả tối đa cho toàn phiếu
- `LoanItem.DueDate` = hạn riêng từng cuốn (cho phép gia hạn từng cuốn)
- Mặc định: `DueDate = LoanDate + N ngày` (`OPEN-04`: N = 14 hay 30?)

### 7.4 Phí phạt

- Áp dụng khi `LoanItem.ReturnedDate > LoanItem.DueDate`
- Ghi vào `LoanItem.OverdueFine`
- Công thức: `OPEN-05` (ví dụ: 500 VND/ngày/cuốn – cần xác nhận)

---

## 8. Yêu cầu phi chức năng

| Mã | Yêu cầu | Ghi chú |
|----|---------|---------|
| NFR-01 | Cả Web và Desktop dùng chung một SQL Server database | Đảm bảo dữ liệu nhất quán real-time |
| NFR-02 | Mật khẩu lưu dạng hash (bcrypt / PBKDF2), không plain-text | Bảo mật tối thiểu |
| NFR-03 | Collation cơ sở dữ liệu: `Vietnamese_CI_AS` | Hỗ trợ tìm kiếm tiếng Việt |
| NFR-04 | Xóa mềm (soft-delete) bằng `IsActive = 0` | Không mất dữ liệu lịch sử |
| NFR-05 | Trang tìm kiếm sách phải trả kết quả trong < 2 giây với 10.000 đầu sách | `OPEN-07`: chưa có benchmark thực tế |

---

## 9. Điểm mở – cần xác nhận

| Mã | Câu hỏi | Ảnh hưởng |
|----|---------|-----------|
| `OPEN-01` | Tầng dữ liệu dùng **ADO.NET thuần** hay **Entity Framework Core**? | Ảnh hưởng toàn bộ Library.Data |
| `OPEN-02` | Có gửi email/SMS nhắc nhở quá hạn không? | FR mới + cấu hình SMTP |
| `OPEN-03` | Độc giả có thể **đặt trước** (Reserved) trực tuyến không? | FR-14 mở rộng, Web thêm tính năng |
| `OPEN-04` | Hạn mượn mặc định là bao nhiêu ngày? (14 hay 30?) | FR-18, seed data |
| `OPEN-05` | Phí phạt quá hạn: bao nhiêu VND/ngày/cuốn? | FR-21, tính toán LoanItem.OverdueFine |
| `OPEN-06` | `Active → Overdue` chuyển tự động (SQL Agent) hay thủ công? | Kiến trúc deployment |
| `OPEN-07` | Yêu cầu hiệu năng cụ thể (SLA) của nhóm/giảng viên? | NFR-05 |

---

## 10. Kiểm tra đủ điều kiện (Definition of Ready – Cổng C)

| # | Tiêu chí | Trạng thái |
|---|---------|-----------|
| ✅ | Schema SQL Server đã tạo thành công (V1__Create_Schema.sql) | Hoàn thành |
| ✅ | Dữ liệu demo đã nhập (V1__Seed_Data.sql) | Hoàn thành |
| ✅ | FK / UNIQUE / CHECK đã xác nhận qua V1__Validation.sql | Hoàn thành |
| ✅ | `vw_Inventory` cung cấp AvailableCopies theo thời gian thực | Hoàn thành |
| ✅ | `vw_ActiveLoans` phát hiện quá hạn | Hoàn thành |
| ⬜ | Library.Data kết nối thành công từ cả Web và Desktop | Chờ sprint 2 |
| ⬜ | Các OPEN item được nhóm/giảng viên xác nhận | Chờ review |

---

*Tài liệu này được tạo bởi nhóm; các điểm đánh dấu `OPEN-xxx` cần được xác nhận trước khi bắt đầu cài đặt chức năng liên quan.*
