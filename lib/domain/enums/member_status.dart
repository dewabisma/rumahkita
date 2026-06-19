enum MemberStatus {
  active,
  inactive,
  evicted;

  String get wireValue => name;

  static MemberStatus fromWire(String value) =>
      MemberStatus.values.byName(value);
}
