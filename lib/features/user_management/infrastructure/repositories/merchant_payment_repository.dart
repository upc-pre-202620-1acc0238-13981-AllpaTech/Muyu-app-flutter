import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/user_preferences.dart';
import '../../domain/bank_card.dart';
import '../../domain/merchant_wallet.dart';

/// Persists the merchant's card and Yape/Plin per email, like `AppContainer`.
class MerchantPaymentRepository {
  MerchantPaymentRepository(this._prefs);

  static const _walletSeparator = '\u001F';

  final UserPreferences _prefs;

  SavedBankCard? loadCard(String email) {
    final raw = _prefs.loadString(email, UserPreferences.keyMerchantBankCard);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return SavedBankCard.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCard(String email, SavedBankCard? card) async {
    if (card == null) {
      await _prefs.remove(email, UserPreferences.keyMerchantBankCard);
      return;
    }
    await _prefs.saveString(email, UserPreferences.keyMerchantBankCard, jsonEncode(card.toJson()));
  }

  MerchantWallet? loadWallet(String email) {
    final raw = _prefs.loadString(email, UserPreferences.keyMerchantWallet) ?? '';
    final parts = raw.split(_walletSeparator);
    if (parts.length < 2 || parts[1].trim().isEmpty) return null;
    final provider = DigitalWalletProvider.tryParse(parts[0]);
    if (provider == null) return null;
    return MerchantWallet(
      provider: provider,
      phone: parts[1],
      holderName: parts.length > 2 ? parts[2] : '',
    );
  }

  Future<void> saveWallet(String email, MerchantWallet? wallet) async {
    if (wallet == null) {
      await _prefs.remove(email, UserPreferences.keyMerchantWallet);
      return;
    }
    final value = [
      wallet.provider.label,
      walletPhoneDigits(wallet.phone),
      wallet.holderName,
    ].join(_walletSeparator);
    await _prefs.saveString(email, UserPreferences.keyMerchantWallet, value);
  }

  DigitalWalletAccount? loadFarmerWallet(String email, DigitalWalletProvider provider) {
    final key = provider == DigitalWalletProvider.yape
        ? UserPreferences.keyYapeAccount
        : UserPreferences.keyPlinAccount;
    final raw = _prefs.loadString(email, key) ?? '';
    final parts = raw.split(_walletSeparator);
    final phone = parts.isEmpty ? '' : parts[0];
    if (phone.trim().isEmpty) return null;
    return DigitalWalletAccount(
      phone: phone,
      holderName: parts.length > 1 ? parts[1] : '',
      isPrimary: parts.length > 2 && parts[2] == '1',
      isVerified: parts.length <= 3 || parts[3] == '1',
    );
  }

  Future<void> saveFarmerWallet(
    String email,
    DigitalWalletProvider provider,
    DigitalWalletAccount? account,
  ) async {
    final key = provider == DigitalWalletProvider.yape
        ? UserPreferences.keyYapeAccount
        : UserPreferences.keyPlinAccount;
    if (account == null) {
      await _prefs.remove(email, key);
      return;
    }
    final value = [
      walletPhoneDigits(account.phone),
      account.holderName,
      account.isPrimary ? '1' : '0',
      account.isVerified ? '1' : '0',
    ].join(_walletSeparator);
    await _prefs.saveString(email, key, value);
  }
}

final merchantPaymentRepositoryProvider = Provider<MerchantPaymentRepository>(
  (ref) => MerchantPaymentRepository(ref.watch(userPreferencesProvider)),
);
