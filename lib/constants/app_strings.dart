/// MemurBank uygulamasında kullanılan sabit metinler, varlık yolları, unvan ve kurum tanımları.
class AppStrings {
  const AppStrings._();

  static const String appName = 'MemurBank';
  static const String appSubtitle = 'Kamu & Memur Dijital Bankacılık Platformu';
  static const String appLogoAsset = 'assets/images/memurbank_logo.png';
  static const String securityStamp =
      'Hazine ve Maliye Bakanlığı KEP & Kamu Bankacılığı Güvencesindedir';

  // Navigasyon Sekmeleri
  static const String navHome = 'Hesabım';
  static const String navTransfer = 'Transfer & Avans';
  static const String navProfile = 'Profil';
  static const String navManagement = 'Teftiş/Yönetim';

  // Roller
  static const String roleUser = 'user';
  static const String roleManager = 'manager';
  static const String roleAdmin = 'admin';

  static const String roleUserLabel = 'Standart Memur (User)';
  static const String roleManagerLabel = 'Kurum Mutemedi (Manager)';
  static const String roleAdminLabel = 'Bakanlık Başmüfettişi (Admin)';

  // Talep Durumları
  static const String statusPending = 'bekliyor';
  static const String statusApproved = 'onaylandi';
  static const String statusRejected = 'reddedildi';

  // Maaş ve Bakiye
  static const String salaryAccountTitle = 'Vadesiz Kamu Maaş Hesabı';
  static const String branchName = 'Ankara Kamu Merkez Şubesi • 01466';
  static const String salaryCountdownTitle = 'Ayın 15\'i Maaş Yatış Sayacı';
  static const String salaryTargetNote =
      'Kamu Personeli Maaş Protokolü • Her Ayın 15\'i';

  // Yöntem B & C Başlıkları
  static const String inspectorCardTitle = 'Teftiş Kurulu & Mutemetlik Paneli';
  static const String godModeBadge = 'TANRI MODU (GOD MODE)';
  static const String devRoleSwitchTitle = 'Rol Değiştir (Test)';
  static const String resetDbButtonLabel =
      'Veritabanını Sıfırla ve Demo Verileri Kur';

  // Hızlı Avans Sebepleri
  static const List<String> presetReasons = [
    'Okul Dönemi Kırtasiye/Eğitim Avansı',
    'Şark Görevi Taşınma Yolluğu',
    'Sağlık / Tedavi Destek Avansı',
    'Kurum İçi Görevlendirme Harcırahı',
  ];

  // Unvan Seçenekleri
  static const List<String> officerTitles = [
    'Öğretmen',
    'Polis Memuru',
    'Kurum Mutemedi',
    'Bakanlık Başmüfettişi',
    'Uzman Tabip',
    'Gelir Uzmanı',
    'Mühendis',
  ];
}
