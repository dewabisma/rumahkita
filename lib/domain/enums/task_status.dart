enum TaskStatus {
  open,
  claimed,
  pendingReview,
  approved,
  rejected;

  String get wireValue {
    switch (this) {
      case TaskStatus.pendingReview:
        return 'pending_review';
      default:
        return name;
    }
  }

  static TaskStatus fromWire(String value) {
    if (value == 'pending_review') {
      return TaskStatus.pendingReview;
    }
    return TaskStatus.values.byName(value);
  }
}
