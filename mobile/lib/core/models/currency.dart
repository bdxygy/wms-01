class Currency {
  final String code;
  final String name;
  final String symbol;
  final String displayName;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.displayName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => displayName;
}

class SupportedCurrencies {
  static const Currency usd = Currency(
    code: 'USD',
    name: 'US Dollar',
    symbol: '\$',
    displayName: 'USD - US Dollar (\$)',
  );

  static const Currency idr = Currency(
    code: 'IDR',
    name: 'Indonesian Rupiah',
    symbol: 'Rp',
    displayName: 'IDR - Indonesian Rupiah (Rp)',
  );

  static const Currency eur = Currency(
    code: 'EUR',
    name: 'Euro',
    symbol: '€',
    displayName: 'EUR - Euro (€)',
  );

  static const Currency gbp = Currency(
    code: 'GBP',
    name: 'British Pound',
    symbol: '£',
    displayName: 'GBP - British Pound (£)',
  );

  static const Currency jpy = Currency(
    code: 'JPY',
    name: 'Japanese Yen',
    symbol: '¥',
    displayName: 'JPY - Japanese Yen (¥)',
  );

  static const Currency sgd = Currency(
    code: 'SGD',
    name: 'Singapore Dollar',
    symbol: 'S\$',
    displayName: 'SGD - Singapore Dollar (S\$)',
  );

  static const Currency myr = Currency(
    code: 'MYR',
    name: 'Malaysian Ringgit',
    symbol: 'RM',
    displayName: 'MYR - Malaysian Ringgit (RM)',
  );

  static const Currency thb = Currency(
    code: 'THB',
    name: 'Thai Baht',
    symbol: '฿',
    displayName: 'THB - Thai Baht (฿)',
  );

  static const List<Currency> all = [
    usd,
    idr,
    eur,
    gbp,
    jpy,
    sgd,
    myr,
    thb,
  ];

  static Currency fromCode(String code) {
    return all.firstWhere(
      (currency) => currency.code == code,
      orElse: () => usd, // Default to USD if not found
    );
  }
}