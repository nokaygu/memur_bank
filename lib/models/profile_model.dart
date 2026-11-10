class ProfileModel {
  final String id;
  final String fullName;
  final String kurumSicilNo;
  final String password;
  final String unvan;
  final double balance;
  final String role; // 'user', 'manager', 'admin'
  final bool isFrozen;

  const ProfileModel({
    required this.id,
    required this.fullName,
    required this.kurumSicilNo,
    required this.password,
    required this.unvan,
    required this.balance,
    required this.role,
    this.isFrozen = false,
  });

  /// Merkezi Kurumsal Türk Lirası Formatlayıcı (`42.500 ₺` veya `42.500,00 ₺`)
  static String formatCurrency(double value, {bool showDecimals = false}) {
    final isNeg = value < 0;
    final absVal = value.abs();
    final whole = absVal.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      final reverseIndex = whole.length - i;
      buffer.write(whole[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    final prefix = isNeg ? '-' : '';
    final suffix = showDecimals ? ',00 ₺' : ' ₺';
    return '$prefix${buffer.toString()}$suffix';
  }

  bool get isAdmin => role == 'admin';
  bool get isManager => role == 'manager';
  bool get isAdminOrManager => role == 'admin' || role == 'manager';

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'MB';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get roleDisplayTitle {
    switch (role) {
      case 'admin':
        return 'Bakanlık Başmüfettişi (God Mode)';
      case 'manager':
        return 'Kurum Mutemedi / Şube Müdürü';
      default:
        return 'Standart Kamu Personeli';
    }
  }

  String get institutionName {
    if (kurumSicilNo.startsWith('MEB')) {
      return 'T.C. Millî Eğitim Bakanlığı • Ankara İl MEM';
    }
    if (kurumSicilNo.startsWith('EGM')) {
      return 'T.C. İçişleri Bakanlığı • Emniyet Genel Müdürlüğü';
    }
    if (kurumSicilNo.startsWith('MAL')) {
      return 'T.C. Hazine ve Maliye Bakanlığı • Muhasebat Genel Müd.';
    }
    if (kurumSicilNo.startsWith('MUF')) {
      return 'T.C. Hazine ve Maliye Bakanlığı • Teftiş Kurulu Başkanlığı';
    }
    return 'T.C. Kamu Kurumu • Merkez Teşkilatı';
  }

  String get derecekademe {
    if (isAdmin) return '1/4 • Ek Gösterge: 6400';
    if (isManager) return '2/1 • Ek Gösterge: 4200';
    return '3/2 • Ek Gösterge: 3600';
  }

  String get formattedIban {
    final suffix = kurumSicilNo
        .replaceAll(RegExp(r'[^0-9]'), '')
        .padLeft(4, '0');
    return 'TR46 0001 2001 4660 0010 00$suffix';
  }

  double get estimatedNetSalary {
    if (isAdmin) return 65000.0;
    if (isManager) return 52000.0;
    return 42000.0;
  }

  double get estimatedGrossSalary => estimatedNetSalary * 1.28;
  double get estimatedSeyyanenBonus => 12050.0;
  double get estimatedTaxDeduction => estimatedGrossSalary - estimatedNetSalary;

  ProfileModel copyWith({
    String? id,
    String? fullName,
    String? kurumSicilNo,
    String? password,
    String? unvan,
    double? balance,
    String? role,
    bool? isFrozen,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      kurumSicilNo: kurumSicilNo ?? this.kurumSicilNo,
      password: password ?? this.password,
      unvan: unvan ?? this.unvan,
      balance: balance ?? this.balance,
      role: role ?? this.role,
      isFrozen: isFrozen ?? this.isFrozen,
    );
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      kurumSicilNo: json['kurum_sicil_no'] as String? ?? '',
      password: json['password'] as String? ?? '',
      unvan: json['unvan'] as String? ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      role: json['role'] as String? ?? 'user',
      isFrozen: json['is_frozen'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'kurum_sicil_no': kurumSicilNo,
      'password': password,
      'unvan': unvan,
      'balance': balance,
      'role': role,
      'is_frozen': isFrozen,
    };
  }
}
