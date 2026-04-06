USE DersDB;
GO

-- 1. DersDB içine Master Key oluşturuyoruz (Eğer yoksa)
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'GucluMasterPassword123!';
END
GO

-- 2. Şifreleme işlemi için yeni bir Sertifika oluşturuyoruz (Eğer yoksa)
IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'EmployeeSertifikasi')
BEGIN
    CREATE CERTIFICATE EmployeeSertifikasi WITH SUBJECT = 'Personel Veri Sifreleme';
END
GO

-- 3. Simetrik Anahtar oluşturuyoruz (Eğer yoksa)
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'EmployeeAnahtari')
BEGIN
    CREATE SYMMETRIC KEY EmployeeAnahtari
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE EmployeeSertifikasi;
END
GO

-- Kolon zaten eklendiği için ALTER TABLE adımını atlıyoruz.

-- 4. Anahtarı açıp, verileri şifreleyerek kolona aktarıyoruz
OPEN SYMMETRIC KEY EmployeeAnahtari
DECRYPTION BY CERTIFICATE EmployeeSertifikasi;

UPDATE dbo.DimEmployee
SET SifreliTelefon = EncryptByKey(Key_GUID('EmployeeAnahtari'), Phone);

CLOSE SYMMETRIC KEY EmployeeAnahtari;
GO