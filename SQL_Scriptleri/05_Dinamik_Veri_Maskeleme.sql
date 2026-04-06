USE DersDB;
GO

-------------------------------------------------------
-- 1. ADIM: KOLONA MASKELEME KURALI EKLENMESİ
-------------------------------------------------------
-- SQL Server'ın yerleşik 'email()' fonksiyonunu kullanarak maskeleme yapıyoruz
ALTER TABLE dbo.DimEmployee
ALTER COLUMN EmailAddress ADD MASKED WITH (FUNCTION = 'email()');
GO

-------------------------------------------------------
-- 2. ADIM: YETKİLENDİRME (UNMASK)
-------------------------------------------------------
-- İnsan Kaynakları departmanının maskesiz orijinal veriyi görebilmesi için yetki veriyoruz
GRANT UNMASK TO Rol_IK;
GO

-------------------------------------------------------
-- 3. ADIM: CANLI TESTLER (Videoda Gösterilecek Kısım)
-------------------------------------------------------

-- TEST A: Standart okuyucu (ProjeKullanicisi) nasıl görüyor?
-- (Not: EXECUTE AS komutu, SSMS'te sürekli çık-gir yapmadan o kullanıcıymış gibi sorgu atmanı sağlar)
EXECUTE AS USER = 'ProjeKullanicisi';
SELECT TOP 5 FirstName, LastName, EmailAddress AS 'Proje_Kullanicisi_Ekrani' 
FROM dbo.DimEmployee;
REVERT; -- Kendi yetkilerimize (sysadmin) geri dönüyoruz
GO

-- TEST B: İnsan Kaynakları (Selin_IK) nasıl görüyor?
EXECUTE AS USER = 'Selin_IK';
SELECT TOP 5 FirstName, LastName, EmailAddress AS 'IK_Selin_Ekrani' 
FROM dbo.DimEmployee;
REVERT;
GO