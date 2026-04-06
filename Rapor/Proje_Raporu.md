# Proje 3: Veritabanı Güvenliği ve Erişim Kontrolü Raporu

## Proje Özeti ve Amacı
Bu proje, veritabanı sistemlerinin güvenliğini sağlamak amacıyla kullanıcı erişimlerinin sınırlandırılması, hassas verilerin şifrelenmesi ve olası siber saldırılara karşı sistemin korunması adımlarını içermektedir. Proje kapsamında bir veritabanı yöneticisi (DBA) perspektifiyle dört temel güvenlik adımı MSSQL Management Studio (SSMS) üzerinden uygulanmıştır. Çalışmada hedef veritabanı olarak `DersDB` (AdventureWorks mimarisi temel alınarak) kullanılmıştır. Projenin her detayı raporlanmış ve versiyon kontrolü için Git kullanılarak belgelenmiştir.

---

## Erişim Yönetimi ve Rol Bazlı Yetkilendirme (RBAC)
İlk aşamada, veritabanına yetkisiz erişimleri önlemek ve veritabanı güvenliği üzerine odaklanarak "en az yetki prensibini" (Principle of Least Privilege) kurumsal bir düzeyde uygulamak hedeflenmiştir. Kullanıcıların verilere erişim yetkilerini yönetmek amacıyla SQL Server Authentication yöntemi kullanılmış ve yapı, Rol Bazlı Erişim Kontrolü (Role-Based Access Control - RBAC) ile ölçeklendirilmiştir.

* **Temel Yetkilendirme Testi:** Sisteme ilk olarak temel bir güvenlik katmanı sağlamak amacıyla `master` veritabanı üzerinde `ProjeKullanicisi` adında bir giriş (Login) oluşturulmuştur. Bu kullanıcı `DersDB` veritabanında bir User olarak eşleştirilip sadece okuma yetkisi olan `db_datareader` rolüne atanarak tablo silme ve değiştirme yetkileri kısıtlanmıştır.
* **Kurumsal Rollerin Tanımlanması:** Sistemdeki veri izolasyonunu artırmak için departman bazlı roller tasarlanmıştır. "İnsan Kaynakları" (`Rol_IK`) ve "Satış Analisti" (`Rol_Analist`) adında iki farklı veritabanı rolü oluşturulmuştur.
* **Tablo ve İşlem Bazlı Kısıtlamalar:** * `Rol_IK` grubuna, sadece personel verilerini içeren `DimEmployee` tablosunda `SELECT` ve `UPDATE` yapma yetkisi verilmiş (`GRANT`), ancak satış verilerini görmemeleri için `FactInternetSales` tablosuna erişimleri açıkça engellenmiştir (`DENY`).
  * `Rol_Analist` grubuna ise, analiz yapabilmeleri için `FactInternetSales` ve `DimProduct` tablolarında sadece `SELECT` yetkisi verilmiş, personelin kişisel verilerini görmemeleri için `DimEmployee` tablosuna erişimleri reddedilmiştir (`DENY`).
* **Kullanıcı Atamaları:** Testleri gerçekleştirmek üzere `Selin_IK` ve `Arda_Analiz` adında yeni kullanıcılar oluşturularak ilgili rollere üye yapılmıştır.
* **Test Süreci ve Hata Giderimi (Troubleshooting):** Test aşamasında `Arda_Analiz` kullanıcısı ile yeni bir sorgu penceresi açılarak `FactInternetSales` tablosuna `SELECT` işlemi denenmiştir. Bu denemede `Invalid object name 'dbo.FactInternetSales'` hatası ile karşılaşılmıştır.
  * **Hata Analizi:** Hatanın nedeninin, SQL Server Management Studio'da (SSMS) yeni bir kullanıcıyla açılan sekmelerin varsayılan olarak sistemin ana veritabanı olan `master` dizininde başlaması olduğu tespit edilmiştir. `master` veritabanı içinde bu isimde bir tablo bulunmadığı için obje bulunamadı hatası alınmıştır.
  * **Çözüm ve Doğrulama:** Sorgunun en başına `USE DersDB;` komutu eklenerek veritabanı bağlamı düzeltilmiştir. Çözüm sonrası sorgu başarıyla çalışmış ve Arda kullanıcısı satış verilerini listeleyebilmiştir. Aynı kullanıcı yetkisi olmayan `DimEmployee` tablosunu sorgulamaya çalıştığında ise sistem beklenen "The SELECT permission was denied on the object" hatasını fırlatarak kurulan güvenlik mimarisinin başarıyla çalıştığını kanıtlamıştır.

## Bölüm 2: Veri Şifreleme
Veritabanındaki hassas bilgilerin şifrelenmesi amacıyla sistem yapılandırılmıştır. Kullanılan SQL Server Express sürümü fiziksel seviyede Transparent Data Encryption (TDE) desteklemediği için, mimari olarak daha spesifik ve güvenli olan **Kolon Bazlı Şifreleme (Column-Level Encryption)** yöntemi tercih edilmiştir.

* **Uygulanan İşlem:** Veritabanı seviyesinde `EmployeeSertifikasi` adında bir sertifika ve AES_256 algoritmasını kullanan bir simetrik anahtar (`EmployeeAnahtari`) oluşturulmuştur.
* **Şifreleme:** `dbo.DimEmployee` tablosunda personellerin iletişim numaralarını barındıran `Phone` kolonu hedef alınmıştır. Bu tabloya `SifreliTelefon` adında `VARBINARY` tipinde yeni bir kolon eklenmiş ve mevcut telefon numaraları oluşturulan simetrik anahtarla şifrelenerek bu kolona aktarılmıştır. Bu sayede anahtara sahip olmayan hiçbir kullanıcı gerçek telefon numaralarına ulaşamaz hale getirilmiştir.

## Bölüm 3: SQL Injection Testleri ve Korunma
Veritabanının uygulamanın zafiyetlerinden kaynaklanan SQL injection saldırılarına karşı korunması için testler yapılmıştır. 

* **Uygulanan İşlem:** Sisteme önce dışarıdan gelen metinleri doğrudan çalıştıran güvensiz bir Stored Procedure (`sp_GuvenliksizArama`) yazılmıştır. Bu prosedür üzerinden `Smith' OR 1=1 --` mantıksal saldırısı yapılarak tüm tablonun yetkisiz bir şekilde listelendiği tespit edilmiştir.
* **Korunma Yöntemi:** Zafiyeti gidermek için sorgular dinamik string birleştirme yerine **Parametreli Sorgular (Parameterized Queries)** kullanılarak (`sp_GuvenliArama`) yeniden yapılandırılmıştır. Aynı saldırı parametreli sorguya yapıldığında, veritabanı motoru metni bir SQL komutu olarak değil, sadece bir değer (string) olarak okuduğu için saldırı başarılı bir şekilde engellenmiştir.

## Bölüm 4: Audit Logları (Sistem İzleme)
Kullanıcı aktivitelerini izlemek ve şüpheli işlemleri tespit etmek için SQL Server Audit özellikleri kullanılmıştır.

* **Uygulanan İşlem:** Sunucu düzeyinde bir "Server Audit" oluşturulmuş ve logların işletim sisteminde `C:\Temp\` klasörüne yazılması sağlanmıştır.
* **İzleme Kuralları:** `DersDB` veritabanı düzeyinde bir "Database Audit Specification" oluşturularak, özellikle `dbo.DimEmployee` tablosu üzerindeki tüm okuma (`SELECT`) ve güncelleme (`UPDATE`) işlemleri izlemeye alınmıştır. Sisteme gönderilen test sorgularının başarıyla log dosyasına (event_time, action_id, statement) yazıldığı teyit edilmiştir.

## Bölüm 5: Dinamik Veri Maskeleme (Dynamic Data Masking - DDM)

Fiziksel şifrelemeye ek olarak, veri gizliliğini (Data Privacy) sağlamak ve hassas verilerin ekranlarda yetkisiz personellere görünmesini engellemek amacıyla Dinamik Veri Maskeleme (DDM) teknolojisi kullanılmıştır.

* **Uygulanan İşlem:** `dbo.DimEmployee` tablosunda bulunan `EmailAddress` kolonu, SQL Server'ın yerleşik `email()` fonksiyonu kullanılarak maskelenmiştir.
* **Yetki Entegrasyonu:** Kurulan Rol Bazlı Erişim Kontrolü (RBAC) ile entegre çalışacak şekilde, İnsan Kaynakları rolüne (`Rol_IK`) maskeyi kaldırma (`UNMASK`) yetkisi tanımlanmıştır.
* **Test Süreci:** Standart okuma yetkisine sahip `ProjeKullanicisi` hesabı ile sorgu atıldığında e-posta adreslerinin `sXXX@XXXX.com` formatında maskelendiği görülmüştür. Aynı sorgu `Selin_IK` kullanıcısı ile atıldığında ise `UNMASK` yetkisi sayesinde verilerin orijinal ve okunabilir formatta listelendiği test edilerek başarılı bir veri gizliliği mimarisi oluşturulmuştur.

## Bölüm 6: Zaman Bazlı Erişim Kısıtlaması (Logon Trigger)

Veritabanı güvenliğini en üst düzeye çıkarmak ve çalınan kimlik bilgileriyle (credential theft) yapılabilecek mesai dışı sızıntıları engellemek amacıyla sunucu düzeyinde Logon Trigger mimarisi kullanılmıştır.

* **Uygulanan İşlem:** SQL Server üzerinde `trg_MesaiSaatleriKorumasi` adında, her giriş denemesinde tetiklenen bir güvenlik duvarı oluşturulmuştur.
* **Kısıtlama Mantığı:** Sistem, `ORIGINAL_LOGIN()` fonksiyonu ile giriş yapan kullanıcıyı tespit edip `GETDATE()` ile sunucu saatini kontrol etmektedir. 
* **Test ve Kanıt:** Kural gereği 08:00 - 18:00 saatleri dışında giriş yapması yasaklanan `Arda_Analiz` hesabı ile mesai saatleri dışında sisteme bağlanılmaya çalışılmış ve doğru şifre girilmesine rağmen bağlantı isteğinin sunucu tarafından `ROLLBACK` komutuyla iptal edilip erişimin reddedildiği (Logon failed due to trigger execution) kanıtlanmıştır. Sistemin kilitlenmesini önlemek adına bu güvenlik duvarı DBA (sa) hesapları dışında tutulmuştur.