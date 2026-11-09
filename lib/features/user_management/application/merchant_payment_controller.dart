import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/bank_card.dart';
import '../domain/merchant_wallet.dart';
import '../infrastructure/repositories/merchant_payment_repository.dart';
import 'session_controller.dart';

class MerchantPaymentState {
  const MerchantPaymentState({this.card, this.wallet});

  final SavedBankCard? card;
  final MerchantWallet? wallet;
}

class MerchantPaymentController extends Notifier<MerchantPaymentState> {
  @override
  MerchantPaymentState build() {
    final email = ref.watch(sessionProvider).user?.email;
    if (email == null || email.isEmpty) return const MerchantPaymentState();
    final repo = ref.read(merchantPaymentRepositoryProvider);
    return MerchantPaymentState(card: repo.loadCard(email), wallet: repo.loadWallet(email));
  }

  Future<void> saveCard(SavedBankCard card) async {
    final email = ref.read(sessionProvider).user?.email;
    if (email == null) return;
    await ref.read(merchantPaymentRepositoryProvider).saveCard(email, card);
    state = MerchantPaymentState(card: card, wallet: state.wallet);
  }

  Future<void> saveWallet(MerchantWallet wallet) async {
    final email = ref.read(sessionProvider).user?.email;
    if (email == null) return;
    await ref.read(merchantPaymentRepositoryProvider).saveWallet(email, wallet);
    state = MerchantPaymentState(card: state.card, wallet: wallet);
  }

  Future<void> unlinkWallet() async {
    final email = ref.read(sessionProvider).user?.email;
    if (email == null) return;
    await ref.read(merchantPaymentRepositoryProvider).saveWallet(email, null);
    state = MerchantPaymentState(card: state.card);
  }
}

final merchantPaymentProvider = NotifierProvider<MerchantPaymentController, MerchantPaymentState>(
  MerchantPaymentController.new,
);
