
# Video: https://youtu.be/fQPXV_XUyXU
# BLM4522 Proje 3: Veritabanı Güvenliği ve Erişim Kontrolü

Bu depo, Ağ Tabanlı Paralel Dağıtım Sistemleri dersi kapsamındaki proje ödevlerinden **"Proje 3: Veritabanı Güvenliği ve Erişim Kontrolü"** uygulamasını içermektedir. Proje, MSSQL Server üzerinde veritabanı güvenliğini sağlamaya yönelik temel adımların uygulamalı bir şekilde gerçekleştirilmesini ve belgelenmesini amaçlamaktadır.

## 🗂️ Klasör Yapısı

Projeye ait dosyalar aşağıdaki hiyerarşiye göre düzenlenmiştir:

```text
├── Rapor/
│   └── Proje_Raporu.md                 # Projenin tüm adımlarını anlatan detaylı rapor
├── SQL_Scriptleri/
│   ├── 01_Kullanici_Erisim_Yonetimi.sql  # SQL Server Auth ve Yetkilendirme kodları
│   ├── 02_Veri_Sifreleme_Kolon_Bazli.sql # AES_256 ile Kolon Bazlı Şifreleme kodları
│   ├── 03_SQL_Injection_Testi.sql        # Zafiyet testi ve Parametreli Sorgu koruması
│   └── 04_Audit_Loglari.sql              # SQL Server Audit loglama yapılandırması
├── Ekran_Goruntuleri/                    # Test sorgularının çıktıları ve kanıt görselleri
└── README.md                             # Proje genel bakış dosyası# Veritabanı Güvenliği ve Erişim Kontrolü