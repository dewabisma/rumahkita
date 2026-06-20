enum HandoverStep {
  closeout,
  retro,
  ceremonyPending;

  String get wireValue {
    switch (this) {
      case HandoverStep.closeout:
        return 'closeout';
      case HandoverStep.retro:
        return 'retro';
      case HandoverStep.ceremonyPending:
        return 'ceremony_pending';
    }
  }

  static HandoverStep fromWire(String value) {
    switch (value) {
      case 'closeout':
        return HandoverStep.closeout;
      case 'retro':
        return HandoverStep.retro;
      case 'ceremony_pending':
        return HandoverStep.ceremonyPending;
      default:
        throw ArgumentError('Unknown handover step: $value');
    }
  }
}
