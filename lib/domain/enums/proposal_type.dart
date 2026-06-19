enum ProposalType {
  eviction,
  selfRemoval;

  String get wireValue {
    switch (this) {
      case ProposalType.selfRemoval:
        return 'self_removal';
      default:
        return name;
    }
  }

  static ProposalType fromWire(String value) {
    if (value == 'self_removal') {
      return ProposalType.selfRemoval;
    }
    return ProposalType.values.byName(value);
  }
}
