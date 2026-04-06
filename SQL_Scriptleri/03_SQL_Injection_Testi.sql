USE DersDB;
GO

-------------------------------------------------------
-- 1. GÜVENSİZ YAPI (SQL Injection'a Açık)
-------------------------------------------------------
-- Kötü kodlama örneği: Kullanıcıdan gelen veri doğrudan SQL metnine ekleniyor
CREATE OR ALTER PROCEDURE sp_GuvenliksizArama
    @LastName NVARCHAR(100)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = 'SELECT EmployeeKey, FirstName, LastName FROM dbo.DimEmployee WHERE LastName = ''' + @LastName + '''';
    EXEC(@SQL);
END
GO

-- TEST 1: Normal Kullanım
-- Sadece soyadı 'Smith' olanları getirir.
EXEC sp_GuvenliksizArama @LastName = 'Smith';

-- TEST 2: SQL Injection Saldırısı
-- Kötü niyetli kullanıcı 'OR 1=1' ekleyerek mantığı bozar ve TÜM personeli listeler!
EXEC sp_GuvenliksizArama @LastName = 'Smith'' OR 1=1 --';
GO

-------------------------------------------------------
-- 2. GÜVENLİ YAPI (SQL Injection Korumalı)
-------------------------------------------------------
-- Doğru kodlama örneği: Parametreli sorgu (Parameterized Query) kullanımı
CREATE OR ALTER PROCEDURE sp_GuvenliArama
    @LastName NVARCHAR(100)
AS
BEGIN
    SELECT EmployeeKey, FirstName, LastName 
    FROM dbo.DimEmployee 
    WHERE LastName = @LastName;
END
GO

-- TEST 3: Güvenli Prosedüre Saldırı Denemesi
-- Sistem bunu bir SQL komutu olarak değil, kelime olarak algılar. 
-- "Smith' OR 1=1 --" adında bir soyisim arar, bulamadığı için boş döner. Korunma başarılı!
EXEC sp_GuvenliArama @LastName = 'Smith'' OR 1=1 --';
GO