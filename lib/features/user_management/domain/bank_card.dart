enum BankCardType { debit, credit }

enum BankCardBrand { visa, mastercard, unknown }

/// Last four digits of a card the merchant registered. Full PAN is never stored.
class SavedBankCard {
  const SavedBankCard({
    required this.lastFour,
    required this.holderName,
    required this.expiration,
    required this.type,
    required this.brand,
    this.isPrimary = true,
  });

  final String lastFour;
  final String holderName;
  final String expiration;
  final BankCardType type;
  final BankCardBrand brand;
  final bool isPrimary;

  Map<String, dynamic> toJson() => {
    'lastFour': lastFour,
    'holderName': holderName,
    'expiration': expiration,
    'type': type.name,
    'brand': brand.name,
    'isPrimary': isPrimary,
  };

  factory SavedBankCard.fromJson(Map<String, dynamic> json) => SavedBankCard(
    lastFour: json['lastFour'] as String? ?? '',
    holderName: json['holderName'] as String? ?? '',
    expiration: json['expiration'] as String? ?? '',
    type: BankCardType.values.firstWhere(
      (value) => value.name == json['type'],
      orElse: () => BankCardType.debit,
    ),
    brand: BankCardBrand.values.firstWhere(
      (value) => value.name == json['brand'],
      orElse: () => BankCardBrand.unknown,
    ),
    isPrimary: json['isPrimary'] as bool? ?? true,
  );
}

BankCardBrand detectCardBrand(String number) {
  final digits = number.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('4')) return BankCardBrand.visa;

  final firstTwo = int.tryParse(digits.length >= 2 ? digits.substring(0, 2) : '');
  final firstFour = int.tryParse(digits.length >= 4 ? digits.substring(0, 4) : '');
  if ((firstTwo != null && firstTwo >= 51 && firstTwo <= 55) ||
      (firstFour != null && firstFour >= 2221 && firstFour <= 2720)) {
    return BankCardBrand.mastercard;
  }
  return BankCardBrand.unknown;
}

String formatCardNumberInput(String number) {
  final digits = number.replaceAll(RegExp(r'\D'), '');
  final taken = digits.length > 16 ? digits.substring(0, 16) : digits;
  final chunks = <String>[];
  for (var i = 0; i < taken.length; i += 4) {
    chunks.add(taken.substring(i, i + 4 > taken.length ? taken.length : i + 4));
  }
  return chunks.join(' ');
}

String formatExpiration(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  final taken = digits.length > 4 ? digits.substring(0, 4) : digits;
  if (taken.length <= 2) return taken;
  return '${taken.substring(0, 2)}/${taken.substring(2)}';
}

bool validExpiration(String value, {DateTime? now}) {
  if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) return false;
  final month = int.tryParse(value.substring(0, 2));
  final year = int.tryParse(value.substring(3));
  if (month == null || year == null || month < 1 || month > 12) return false;
  final today = now ?? DateTime.now();
  final expiry = DateTime(2000 + year, month);
  final current = DateTime(today.year, today.month);
  return !expiry.isBefore(current);
}

bool passesLuhnCheck(String number) {
  final digits = number.replaceAll(RegExp(r'\D'), '');
  if (digits.length != 16) return false;
  var sum = 0;
  for (var i = 0; i < digits.length; i++) {
    var value = int.parse(digits[digits.length - 1 - i]);
    if (i.isOdd) {
      value *= 2;
      if (value > 9) value -= 9;
    }
    sum += value;
  }
  return sum % 10 == 0;
}

String maskedCardNumber(String lastFour) => '••••    ••••    ••••    $lastFour';

String formatReleasedBalance(double value) {
  final rounded = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < rounded.length; i++) {
    if (i > 0 && (rounded.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(rounded[i]);
  }
  return 'S/ $buffer';
}

String bankCardSummary(SavedBankCard card) {
  final brand = switch (card.brand) {
    BankCardBrand.visa => 'Visa',
    BankCardBrand.mastercard => 'Mastercard',
    BankCardBrand.unknown => '',
  };
  return [brand, '•••• ${card.lastFour}'].where((part) => part.trim().isNotEmpty).join(' ');
}
