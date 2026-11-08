enum DigitalWalletProvider {
  yape,
  plin;

  String get label => switch (this) {
    DigitalWalletProvider.yape => 'Yape',
    DigitalWalletProvider.plin => 'Plin',
  };

  static DigitalWalletProvider? tryParse(String? value) {
    if (value == null) return null;
    for (final provider in values) {
      if (provider.name == value.toLowerCase() || provider.label == value) {
        return provider;
      }
    }
    return null;
  }
}

/// Farmer Yape/Plin account. A new user starts with none linked.
class DigitalWalletAccount {
  const DigitalWalletAccount({
    required this.phone,
    required this.holderName,
    this.isPrimary = true,
    this.isVerified = true,
  });

  final String phone;
  final String holderName;
  final bool isPrimary;
  final bool isVerified;

  DigitalWalletAccount copyWith({bool? isPrimary}) => DigitalWalletAccount(
    phone: phone,
    holderName: holderName,
    isPrimary: isPrimary ?? this.isPrimary,
    isVerified: isVerified,
  );
}

/// Yape or Plin the merchant uses to pay financing. A new account starts empty.
class MerchantWallet {
  const MerchantWallet({
    required this.provider,
    required this.phone,
    required this.holderName,
  });

  final DigitalWalletProvider provider;
  final String phone;
  final String holderName;
}

String walletPhoneDigits(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  return digits.length <= 9 ? digits : digits.substring(digits.length - 9);
}

String formatWalletPhone(String value) {
  final digits = walletPhoneDigits(value);
  final chunks = <String>[];
  for (var i = 0; i < digits.length; i += 3) {
    chunks.add(digits.substring(i, i + 3 > digits.length ? digits.length : i + 3));
  }
  return chunks.join(' ');
}

String maskWalletPhone(String value) {
  final digits = walletPhoneDigits(value);
  if (digits.length != 9) return digits;
  return '${digits.substring(0, 3)} *** ${digits.substring(6)}';
}

bool isValidWalletPhone(String value) {
  final digits = walletPhoneDigits(value);
  return digits.length == 9 && digits.startsWith('9');
}

String merchantWalletSummary(MerchantWallet wallet) =>
    '${wallet.provider.label} ${maskWalletPhone(wallet.phone)}';
