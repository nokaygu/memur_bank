class AdvanceRequestModel {
  final String id;
  final String userId;
  final String fullName;
  final double amount;
  final String reason;
  final String status; // 'bekliyor', 'onaylandi', 'reddedildi'
  final DateTime createdAt;

  const AdvanceRequestModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.amount,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  bool get isPending => status == 'bekliyor';
  bool get isApproved => status == 'onaylandi';
  bool get isRejected => status == 'reddedildi';

  String get statusLabel {
    switch (status) {
      case 'onaylandi':
        return 'Onaylandı';
      case 'reddedildi':
        return 'Reddedildi';
      default:
        return 'Onay Bekliyor';
    }
  }

  AdvanceRequestModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    double? amount,
    String? reason,
    String? status,
    DateTime? createdAt,
  }) {
    return AdvanceRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AdvanceRequestModel.fromJson(Map<String, dynamic> json) {
    return AdvanceRequestModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'bekliyor',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'amount': amount,
      'reason': reason,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
