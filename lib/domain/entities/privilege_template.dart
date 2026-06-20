class PrivilegeTemplate {
  const PrivilegeTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.enabled,
    required this.unlockThreshold,
    required this.isPenalty,
  });

  final String id;
  final String name;
  final String description;
  final bool enabled;
  final int unlockThreshold;
  final bool isPenalty;

  PrivilegeTemplate copyWith({
    String? id,
    String? name,
    String? description,
    bool? enabled,
    int? unlockThreshold,
    bool? isPenalty,
  }) {
    return PrivilegeTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
      unlockThreshold: unlockThreshold ?? this.unlockThreshold,
      isPenalty: isPenalty ?? this.isPenalty,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'enabled': enabled,
        'unlock_threshold': unlockThreshold,
        'is_penalty': isPenalty,
      };

  factory PrivilegeTemplate.fromJson(Map<String, dynamic> json) {
    return PrivilegeTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      enabled: json['enabled'] as bool? ?? true,
      unlockThreshold: json['unlock_threshold'] as int,
      isPenalty: json['is_penalty'] as bool? ?? false,
    );
  }

  /// Default templates from the PRD privilege tier table.
  static List<PrivilegeTemplate> defaults() => const [
        PrivilegeTemplate(
          id: 'parking',
          name: 'Master Parking Spot',
          description: 'Choose the best parking spot',
          enabled: true,
          unlockThreshold: 80,
          isPenalty: false,
        ),
        PrivilegeTemplate(
          id: 'chore_pass',
          name: 'Chore Pass',
          description: 'Veto or swap one chore this month',
          enabled: true,
          unlockThreshold: 90,
          isPenalty: false,
        ),
        PrivilegeTemplate(
          id: 'cleaning_exempt',
          name: 'Emergency Cleaning Exempt',
          description: 'Skip the next emergency house cleaning',
          enabled: true,
          unlockThreshold: 70,
          isPenalty: false,
        ),
        PrivilegeTemplate(
          id: 'slot_restriction',
          name: 'Chore Slot Restriction',
          description: 'Locked from preferred chore slots next cycle',
          enabled: true,
          unlockThreshold: 30,
          isPenalty: true,
        ),
      ];

  static Map<String, PrivilegeTemplate> defaultsMap() => {
        for (final t in defaults()) t.id: t,
      };
}
