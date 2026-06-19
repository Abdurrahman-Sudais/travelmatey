class WalletModel {
  final double balance;
  final double earningsWeek;
  final double earningsMonth;
  final double earningsYear;

  const WalletModel({
    required this.balance,
    required this.earningsWeek,
    required this.earningsMonth,
    required this.earningsYear,
  });

  factory WalletModel.mock() => const WalletModel(
        balance: 25000,
        earningsWeek: 120000,
        earningsMonth: 450000,
        earningsYear: 4200000,
      );

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
        balance: (json['balance'] as num?)?.toDouble() ?? 0,
        earningsWeek: (json['earnings_week'] as num?)?.toDouble() ?? 0,
        earningsMonth: (json['earnings_month'] as num?)?.toDouble() ?? 0,
        earningsYear: (json['earnings_year'] as num?)?.toDouble() ?? 0,
      );

  WalletModel copyWith({double? balance}) => WalletModel(
        balance: balance ?? this.balance,
        earningsWeek: earningsWeek,
        earningsMonth: earningsMonth,
        earningsYear: earningsYear,
      );
}
