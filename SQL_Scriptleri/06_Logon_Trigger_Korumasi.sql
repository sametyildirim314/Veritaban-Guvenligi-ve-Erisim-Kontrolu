USE master;
GO

-------------------------------------------------------
-- 1. ADIM: EĞER VARSA ESKİ TRIGGER'I TEMİZLEME
-------------------------------------------------------
IF EXISTS (SELECT * FROM sys.server_triggers WHERE name = 'trg_MesaiSaatleriKorumasi')
BEGIN
    DROP TRIGGER trg_MesaiSaatleriKorumasi ON ALL SERVER;
END
GO

-------------------------------------------------------
-- 2. ADIM: LOGON TRIGGER (GİRİŞ TETİKLEYİCİSİ) OLUŞTURMA
-------------------------------------------------------
CREATE TRIGGER trg_MesaiSaatleriKorumasi
ON ALL SERVER
FOR LOGON
AS
BEGIN
    -- Sadece analistimiz Arda'nın hareketlerini kısıtlıyoruz (Adminleri kilitlememek için)
    IF ORIGINAL_LOGIN() = 'Arda_Analiz'
    BEGIN
        -- Sunucunun o anki saatini alıyoruz (0-23 formatında)
        DECLARE @SuAnkiSaat INT = DATEPART(HOUR, GETDATE());

        -- Eğer saat sabah 08'den küçük veya akşam 18'den büyük/eşitse (Mesai dışıysa)
        IF @SuAnkiSaat < 8 OR @SuAnkiSaat >= 18
        BEGIN
            -- Giriş işlemini iptal et ve bağlantıyı kopar
            ROLLBACK;
        END
    END
END
GO