/// Static fallback data. In production, packages/prices are fetched live
/// from Supabase (`packages` table) so admins can edit them without an app
/// update — see ProductService. These constants are used only as a
/// first-paint placeholder / offline fallback.
class AppConstants {
  AppConstants._();

  static const String appName = 'Muza Top-Up';

  // Payment
  static const List<String> paymentMethods = ['ZAAD', 'eDahab', 'Sahal Pay'];
  static const String paymentNumber = '614457264';

  // WhatsApp support number (same as payment number unless changed)
  static const String whatsappNumber = '614457264';
  static const String whatsappCountryCode = '252'; // Somalia — adjust as needed

  static const String efootballSecurityNotice =
      'Your eFootball login information will only be used to complete your '
      'order and will not be shared with third parties.';

  static const List<Map<String, dynamic>> pubgPackages = [
    {'name': '60 UC', 'amount': 60, 'price': 0.99},
    {'name': '325 UC', 'amount': 325, 'price': 4.99},
    {'name': '660 UC', 'amount': 660, 'price': 9.99},
    {'name': '1800 UC', 'amount': 1800, 'price': 24.99},
    {'name': '3850 UC', 'amount': 3850, 'price': 49.99},
    {'name': '8100 UC', 'amount': 8100, 'price': 99.99},
  ];

  static const List<Map<String, dynamic>> efootballPackages = [
    {'name': '130 Coins', 'amount': 130, 'price': 1.99},
    {'name': '550 Coins', 'amount': 550, 'price': 7.99},
    {'name': '1040 Coins', 'amount': 1040, 'price': 14.99},
    {'name': '2130 Coins', 'amount': 2130, 'price': 27.99},
    {'name': '3250 Coins', 'amount': 3250, 'price': 39.99},
    {'name': '5700 Coins', 'amount': 5700, 'price': 64.99},
    {'name': '12800 Coins', 'amount': 12800, 'price': 129.99},
  ];

  static const List<Map<String, String>> faqs = [
    {
      'q': 'How long does an order take to complete?',
      'a': 'Most orders are processed within 5-30 minutes after payment is '
          'verified. Complex or high-volume periods may take longer.',
    },
    {
      'q': 'What payment methods do you accept?',
      'a': 'We accept ZAAD, eDahab, and Sahal Pay. Send payment to '
          '$paymentNumber and upload your screenshot.',
    },
    {
      'q': 'Is my eFootball account safe?',
      'a': efootballSecurityNotice,
    },
    {
      'q': 'What if my order is rejected?',
      'a': 'If a screenshot cannot be verified, our support team will '
          'contact you via WhatsApp to resolve it or issue a refund.',
    },
    {
      'q': 'Can I cancel an order?',
      'a': 'Orders can be cancelled only while in "Pending" status. Contact '
          'support immediately if you need to cancel.',
    },
  ];
}

enum OrderStatus { pending, processing, completed, cancelled }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => OrderStatus.pending,
    );
  }
}

enum GameType { pubg, efootball }

extension GameTypeX on GameType {
  String get label => this == GameType.pubg ? 'PUBG Mobile' : 'eFootball';
  static GameType fromString(String value) =>
      value.toLowerCase() == 'pubg' ? GameType.pubg : GameType.efootball;
}
