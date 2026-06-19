enum CycleStatus {
  drafting,
  active,
  completed;

  String get wireValue => name;

  static CycleStatus fromWire(String value) =>
      CycleStatus.values.byName(value);
}
