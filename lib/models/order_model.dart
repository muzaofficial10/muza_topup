import '../core/constants.dart';

class OrderModel {
  final String id;
  final String userId;
  final GameType game;
  final String? playerId;
  final String? efootballEmail;
  final String? efootballPassword;
  final String packageName;
  final int packageAmount;
  final double amount;
  final String? paymentScreenshotUrl;
  final String paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;
  final String? adminNote;
  final String? verificationCode;
  final bool codeRequested;

  OrderModel({
    required this.id,
    required this.userId,
    required this.game,
    this.playerId,
    this.efootballEmail,
    this.efootballPassword,
    required this.packageName,
    required this.packageAmount,
    required this.amount,
    this.paymentScreenshotUrl,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.adminNote,
    this.verificationCode,
    this.codeRequested = false,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      game: GameTypeX.fromString(json['game'] as String),
      playerId: json['player_id'] as String?,
      efootballEmail: json['efootball_email'] as String?,
      efootballPassword: json['efootball_password'] as String?,
      packageName: json['package_name'] as String,
      packageAmount: (json['package_amount'] ?? 0) as int,
      amount: (json['amount'] as num).toDouble(),
      paymentScreenshotUrl: json['payment_screenshot'] as String?,
      paymentMethod: json['payment_method'] as String? ?? '',
      status: OrderStatusX.fromString(json['status'] as String? ?? 'pending'),
      createdAt: DateTime.parse(json['created_at'] as String),
      adminNote: json['admin_note'] as String?,
      verificationCode: json['verification_code'] as String?,
      codeRequested: json['code_requested'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'game': game.name,
      if (playerId != null) 'player_id': playerId,
      if (efootballEmail != null) 'efootball_email': efootballEmail,
      if (efootballPassword != null) 'efootball_password': efootballPassword,
      'package_name': packageName,
      'package_amount': packageAmount,
      'amount': amount,
      'payment_screenshot': paymentScreenshotUrl,
      'payment_method': paymentMethod,
      'status': status.name,
      if (verificationCode != null) 'verification_code': verificationCode,
    };
  }
}
