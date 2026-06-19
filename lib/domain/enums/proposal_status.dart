enum ProposalStatus {
  proposed,
  approved,
  readyToExecute,
  executed,
  cancelled,
  rejected;

  String get wireValue {
    switch (this) {
      case ProposalStatus.readyToExecute:
        return 'ready_to_execute';
      default:
        return name;
    }
  }

  static ProposalStatus fromWire(String value) {
    if (value == 'ready_to_execute') {
      return ProposalStatus.readyToExecute;
    }
    return ProposalStatus.values.byName(value);
  }
}
