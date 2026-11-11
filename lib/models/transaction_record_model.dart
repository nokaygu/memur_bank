/// Hesap Hareketleri & Dijital Dekont kaydı modeli.
class TransactionRecord {
  final String id;
  final String userId;
  final String title;
  final String subtitle;
  final String category;
  final String referenceCode;
  final double amount;
  final bool isIncoming;
  final DateTime createdAt;

  const TransactionRecord({
    required this.id,
    required this.userId,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.referenceCode,
    required this.amount,
    required this.isIncoming,
    required this.createdAt,
  });
}
