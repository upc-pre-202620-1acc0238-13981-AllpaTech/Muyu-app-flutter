import 'package:flutter_test/flutter_test.dart';
import 'package:muyu_app/features/user_management/domain/bank_card.dart';
import 'package:muyu_app/features/user_management/domain/merchant_wallet.dart';

void main() {
  group('bank card helpers', () {
    test('detects Visa and Mastercard from the first digits', () {
      expect(detectCardBrand('4111111111111111'), BankCardBrand.visa);
      expect(detectCardBrand('5555555555554444'), BankCardBrand.mastercard);
      expect(detectCardBrand('2221000000000009'), BankCardBrand.mastercard);
      expect(detectCardBrand('6011111111111117'), BankCardBrand.unknown);
    });

    test('formats the PAN in groups of four', () {
      expect(formatCardNumberInput('4111111111111111'), '4111 1111 1111 1111');
      expect(formatCardNumberInput('41111abc'), '4111 1');
    });

    test('accepts a Luhn-valid 16-digit number', () {
      expect(passesLuhnCheck('4111111111111111'), isTrue);
      expect(passesLuhnCheck('4111111111111112'), isFalse);
      expect(passesLuhnCheck('4111'), isFalse);
    });

    test('accepts current or future MM/YY dates', () {
      expect(validExpiration('13/29'), isFalse);
      expect(validExpiration('09/29', now: DateTime(2026, 1)), isTrue);
      expect(validExpiration('01/25', now: DateTime(2026, 1)), isFalse);
      expect(validExpiration('01/26', now: DateTime(2026, 1)), isTrue);
    });

    test('summarizes a saved card without the full PAN', () {
      const card = SavedBankCard(
        lastFour: '4589',
        holderName: 'Ana',
        expiration: '09/29',
        type: BankCardType.debit,
        brand: BankCardBrand.visa,
      );
      expect(bankCardSummary(card), 'Visa •••• 4589');
    });
  });

  group('wallet phone helpers', () {
    test('keeps the last nine digits and formats them', () {
      expect(walletPhoneDigits('+51 987 654 321'), '987654321');
      expect(formatWalletPhone('987654321'), '987 654 321');
      expect(maskWalletPhone('987654321'), '987 *** 321');
    });

    test('only accepts Peruvian mobiles starting with 9', () {
      expect(isValidWalletPhone('987654321'), isTrue);
      expect(isValidWalletPhone('187654321'), isFalse);
      expect(isValidWalletPhone('98765'), isFalse);
    });
  });
}
