enum PaymentMethod {
  card,
  wallet,
  agentDeposit,
  bankTransfer;

  String label(bool es) => switch (this) {
    PaymentMethod.card => es ? 'Tarjeta' : 'Card',
    PaymentMethod.wallet => es ? 'Billetera digital' : 'Digital wallet',
    PaymentMethod.agentDeposit => es ? 'Depósito en agente' : 'Agent deposit',
    PaymentMethod.bankTransfer => es ? 'Transferencia bancaria' : 'Bank transfer',
  };
}

class FinancingResult {
  const FinancingResult({required this.paymentMethod});

  final PaymentMethod paymentMethod;
}
