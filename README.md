# Đồ án Quản lý Thư viện

Repository đồ án môn học. Hiện tại chỉ có cấu trúc solution và các project khởi tạo; chưa có nghiệp vụ.

## Thành viên

- Thành viên 1: Đinh Công Thành
- Thành viên 2: Trần Huỳnh Phát

## Cấu trúc

- `Library.Data`: Class Library cho tầng dữ liệu.
- `Library.Business`: Class Library cho tầng nghiệp vụ.
- `Library.Admin`: ứng dụng desktop Windows Forms.
- `Library.Web`: ứng dụng web ASP.NET Core MVC.
- `docs`: tài liệu đồ án.
- `Database`: tệp liên quan đến cơ sở dữ liệu.
- `Screenshots`: ảnh chụp minh họa.

## Hướng phụ thuộc

```text
Library.Admin ──┐
                ├──> Library.Business ───> Library.Data
Library.Web ────┘

Yêu cầu
- .NET SDK 10.0
- Visual Studio có workload .NET desktop development và ASP.NET and web development
Build
dotnet build LibraryManagement.sln