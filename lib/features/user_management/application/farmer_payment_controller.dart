import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/merchant_wallet.dart';
import '../infrastructure/repositories/merchant_payment_repository.dart';
import 'session_controller.dart';

class FarmerPaymentState {
  const FarmerPaymentState({this.yape, this.plin});

  final DigitalWalletAccount? yape;
  final DigitalWalletAccount? plin;

  DigitalWalletAccount? accountFor(DigitalWalletProvider provider) =>
      provider == DigitalWalletProvider.yape ? yape : plin;
}

class FarmerPaymentController extends Notifier<FarmerPaymentState> {
  @override
  FarmerPaymentState build() {
    final email = ref.watch(sessionProvider).user?.email;
    if (email == null || email.isEmpty) return const FarmerPaymentState();
    final repo = ref.read(merchantPaymentRepositoryProvider);
    return FarmerPaymentState(
      yape: repo.loadFarmerWallet(email, DigitalWalletProvider.yape),
      plin: repo.loadFarmerWallet(email, DigitalWalletProvider.plin),
    );
  }

  Future<void> saveAccount(DigitalWalletProvider provider, DigitalWalletAccount account) async {
    final email = ref.read(sessionProvider).user?.email;
    if (email == null) return;
    final repo = ref.read(merchantPaymentRepositoryProvider);
    var yape = state.yape;
    var plin = state.plin;
    if (provider == DigitalWalletProvider.yape) {
      yape = account;
      if (account.isPrimary && plin != null) {
        plin = plin.copyWith(isPrimary: false);
        await repo.saveFarmerWallet(email, DigitalWalletProvider.plin, plin);
      }
    } else {
      plin = account;
      if (account.isPrimary && yape != null) {
        yape = yape.copyWith(isPrimary: false);
        await repo.saveFarmerWallet(email, DigitalWalletProvider.yape, yape);
      }
    }
    await repo.saveFarmerWallet(email, provider, account);
    state = FarmerPaymentState(yape: yape, plin: plin);
  }

  Future<void> unlinkAccount(DigitalWalletProvider provider) async {
    final email = ref.read(sessionProvider).user?.email;
    if (email == null) return;
    await ref.read(merchantPaymentRepositoryProvider).saveFarmerWallet(email, provider, null);
    state = FarmerPaymentState(
      yape: provider == DigitalWalletProvider.yape ? null : state.yape,
      plin: provider == DigitalWalletProvider.plin ? null : state.plin,
    );
  }
}

final farmerPaymentProvider =
    NotifierProvider<FarmerPaymentController, FarmerPaymentState>(FarmerPaymentController.new);
