enum RedemptionStatus {
  active,
  consumed;

  String get wireValue => name;

  static RedemptionStatus fromWire(String value) =>
      RedemptionStatus.values.byName(value);
}
