enum PrivilegeStatus {
  active,
  archived;

  String get wireValue => name;

  static PrivilegeStatus fromWire(String value) =>
      PrivilegeStatus.values.byName(value);
}
