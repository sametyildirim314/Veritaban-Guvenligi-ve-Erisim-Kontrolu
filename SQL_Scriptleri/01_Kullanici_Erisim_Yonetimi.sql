

USE [master];
GO
-- 1. SQL Server Authentication ile yeni bir Login oluşturuyoruz 
CREATE LOGIN ProjeKullanicisi WITH PASSWORD = 'StrongPassword123!';
GO

USE [DersDB];
GO
-- 2. Bu Login için DersDB veritabanında bir User oluşturuyoruz 
CREATE USER ProjeKullanicisi FOR LOGIN ProjeKullanicisi;
GO

-- 3. Kullanıcıya sadece verileri 'okuma' (db_datareader) yetkisi veriyoruz 
ALTER ROLE db_datareader ADD MEMBER ProjeKullanicisi;
GO