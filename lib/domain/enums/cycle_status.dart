enum CycleStatus {
  drafting,
  active,
  handover,
  completed;

  String get wireValue => name;

  static CycleStatus fromWire(String value) =>
      CycleStatus.values.byName(value);
}
