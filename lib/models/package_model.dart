import '../core/constants.dart';

class PackageModel {
  final String id;
  final GameType game;
  final String name;
  final int amount; // UC or Coins amount
  final double price;
  final bool isActive;
  final int sortOrder;

  PackageModel({
    required this.id,
    required this.game,
    required this.name,
    required this.amount,
    required this.price,
    required this.isActive,
    required this.sortOrder,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] as String,
      game: GameTypeX.fromString(json['game'] as String),
      name: json['name'] as String,
      amount: (json['amount'] ?? 0) as int,
      price: (json['price'] as num).toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: (json['sort_order'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'game': game.name,
        'name': name,
        'amount': amount,
        'price': price,
        'is_active': isActive,
        'sort_order': sortOrder,
      };
}
