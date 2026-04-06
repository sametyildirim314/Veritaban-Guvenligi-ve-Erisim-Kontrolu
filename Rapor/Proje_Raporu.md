# Proje 3: Veritabanı Güvenliği ve Erişim Kontrolü Raporu

## Proje Özeti ve Amacı
Bu proje, veritabanı sistemlerinin güvenliğini sağlamak amacıyla kullanıcı erişimlerinin sınırlandırılması, hassas verilerin şifrelenmesi ve olası siber saldırılara karşı sistemin korunması adımlarını içermektedir. Proje kapsamında bir veritabanı yöneticisi (DBA) perspektifiyle dört temel güvenlik adımı MSSQL Management Studio (SSMS) üzerinden uygulanmıştır. Çalışmada hedef veritabanı olarak `DersDB` (AdventureWorks mimarisi temel alınarak) kullanılmıştır. Projenin her detayı raporlanmış ve versiyon kontrolü için Git kullanılarak belgelenmiştir.

---

## Bölüm 1: Erişim Yönetimi
İlk aşamada, veritabanına yetkisiz erişimleri önlemek ve "en az yetki prensibini" (Principle of Least Privilege) uygulamak hedeflenmiştir. Kullanıcıların verilere erişim yetkilerini yönetmek amacıyla SQL Server Authentication yöntemi kullanılmıştır. 

* **Uygulanan İşlem:** `master` veritabanı üzerinde `ProjeKullanicisi` adında yeni bir giriş (Login) oluşturulmuştur. 
* **Yetkilendirme:** Bu kullanıcı `DersDB` veritabanına bir User olarak eklenmiş ve sadece verileri okuma yetkisi olan `db_datareader` rolüne atanmıştır. Bu sayede kullanıcının tabloları silme veya değiştirme (UPDATE/DELETE) işlemleri yapması engellenmiştir.

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