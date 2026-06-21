enum PrivilegeUsageMode {
  oneShot,
  durable;

  String get wireValue {
    switch (this) {
      case PrivilegeUsageMode.oneShot:
        return 'one_shot';
      default:
        return name;
    }
  }

  static PrivilegeUsageMode fromWire(String value) {
    if (value == 'one_shot') {
      return PrivilegeUsageMode.oneShot;
    }
    return PrivilegeUsageMode.values.byName(value);
  }
}
