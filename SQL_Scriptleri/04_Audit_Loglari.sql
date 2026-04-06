



USE master;
GO

-- 1. Server düzeyinde Audit oluşturuyoruz (Loglar C:\Temp klasörüne yazılacak)
CREATE SERVER AUDIT Proje3_ServerAudit
TO FILE (FILEPATH = 'C:\Temp\')
WITH (ON_FAILURE = CONTINUE);
GO

-- Audit'i başlatıyoruz
ALTER SERVER AUDIT Proje3_ServerAudit WITH (STATE = ON);
GO

USE DersDB;
GO

-- 2. Veritabanı düzeyinde Audit Specification oluşturuyoruz
-- Bu sayede DimEmployee tablosuna yapılan okuma ve güncellemeleri izleyeceğiz
CREATE DATABASE AUDIT SPECIFICATION Proje3_DatabaseAudit
FOR SERVER AUDIT Proje3_ServerAudit
ADD (SELECT ON dbo.DimEmployee BY public),
ADD (UPDATE ON dbo.DimEmployee BY public)
WITH (STATE = ON);
GO


USE DersDB;
GO

-- 1. Tabloya rastgele bir okuma (SELECT) sorgusu atalım ki sistem bunu kaydetsin
SELECT TOP 5 EmployeeKey, FirstName, LastName FROM dbo.DimEmployee;
GO

-- 2. Şimdi C:\Temp klasörüne yazılan Audit Log dosyasını okuyalım
SELECT 
    event_time AS IslemZamani, 
    server_principal_name AS KullaniciAdi, 
    action_id AS IslemTipi, -- 'SL' = Select, 'UP' = Update
    statement AS CalistirilanSorgu
FROM sys.fn_get_audit_file('C:\Temp\Proje3_ServerAudit*', DEFAULT, DEFAULT);
GO