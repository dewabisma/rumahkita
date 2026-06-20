// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalUserSettingsTable extends LocalUserSettings
    with TableInfo<$LocalUserSettingsTable, LocalUserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tailscaleNodeIdMeta = const VerificationMeta(
    'tailscaleNodeId',
  );
  @override
  late final GeneratedColumn<String> tailscaleNodeId = GeneratedColumn<String>(
    'tailscale_node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _activeHouseIdMeta = const VerificationMeta(
    'activeHouseId',
  );
  @override
  late final GeneratedColumn<String> activeHouseId = GeneratedColumn<String>(
    'active_house_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtHlcMeta = const VerificationMeta(
    'createdAtHlc',
  );
  @override
  late final GeneratedColumn<Uint8List> createdAtHlc =
      GeneratedColumn<Uint8List>(
        'created_at_hlc',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    deviceId,
    tailscaleNodeId,
    activeHouseId,
    createdAtHlc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalUserSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('tailscale_node_id')) {
      context.handle(
        _tailscaleNodeIdMeta,
        tailscaleNodeId.isAcceptableOrUnknown(
          data['tailscale_node_id']!,
          _tailscaleNodeIdMeta,
        ),
      );
    }
    if (data.containsKey('active_house_id')) {
      context.handle(
        _activeHouseIdMeta,
        activeHouseId.isAcceptableOrUnknown(
          data['active_house_id']!,
          _activeHouseIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at_hlc')) {
      context.handle(
        _createdAtHlcMeta,
        createdAtHlc.isAcceptableOrUnknown(
          data['created_at_hlc']!,
          _createdAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtHlcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  LocalUserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUserSetting(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      tailscaleNodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tailscale_node_id'],
      )!,
      activeHouseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_house_id'],
      ),
      createdAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}created_at_hlc'],
      )!,
    );
  }

  @override
  $LocalUserSettingsTable createAlias(String alias) {
    return $LocalUserSettingsTable(attachedDatabase, alias);
  }
}

class LocalUserSetting extends DataClass
    implements Insertable<LocalUserSetting> {
  final String deviceId;
  final String tailscaleNodeId;
  final String? activeHouseId;
  final Uint8List createdAtHlc;
  const LocalUserSetting({
    required this.deviceId,
    required this.tailscaleNodeId,
    this.activeHouseId,
    required this.createdAtHlc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['tailscale_node_id'] = Variable<String>(tailscaleNodeId);
    if (!nullToAbsent || activeHouseId != null) {
      map['active_house_id'] = Variable<String>(activeHouseId);
    }
    map['created_at_hlc'] = Variable<Uint8List>(createdAtHlc);
    return map;
  }

  LocalUserSettingsCompanion toCompanion(bool nullToAbsent) {
    return LocalUserSettingsCompanion(
      deviceId: Value(deviceId),
      tailscaleNodeId: Value(tailscaleNodeId),
      activeHouseId: activeHouseId == null && nullToAbsent
          ? const Value.absent()
          : Value(activeHouseId),
      createdAtHlc: Value(createdAtHlc),
    );
  }

  factory LocalUserSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUserSetting(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      tailscaleNodeId: serializer.fromJson<String>(json['tailscaleNodeId']),
      activeHouseId: serializer.fromJson<String?>(json['activeHouseId']),
      createdAtHlc: serializer.fromJson<Uint8List>(json['createdAtHlc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'tailscaleNodeId': serializer.toJson<String>(tailscaleNodeId),
      'activeHouseId': serializer.toJson<String?>(activeHouseId),
      'createdAtHlc': serializer.toJson<Uint8List>(createdAtHlc),
    };
  }

  LocalUserSetting copyWith({
    String? deviceId,
    String? tailscaleNodeId,
    Value<String?> activeHouseId = const Value.absent(),
    Uint8List? createdAtHlc,
  }) => LocalUserSetting(
    deviceId: deviceId ?? this.deviceId,
    tailscaleNodeId: tailscaleNodeId ?? this.tailscaleNodeId,
    activeHouseId: activeHouseId.present
        ? activeHouseId.value
        : this.activeHouseId,
    createdAtHlc: createdAtHlc ?? this.createdAtHlc,
  );
  LocalUserSetting copyWithCompanion(LocalUserSettingsCompanion data) {
    return LocalUserSetting(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      tailscaleNodeId: data.tailscaleNodeId.present
          ? data.tailscaleNodeId.value
          : this.tailscaleNodeId,
      activeHouseId: data.activeHouseId.present
          ? data.activeHouseId.value
          : this.activeHouseId,
      createdAtHlc: data.createdAtHlc.present
          ? data.createdAtHlc.value
          : this.createdAtHlc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserSetting(')
          ..write('deviceId: $deviceId, ')
          ..write('tailscaleNodeId: $tailscaleNodeId, ')
          ..write('activeHouseId: $activeHouseId, ')
          ..write('createdAtHlc: $createdAtHlc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    deviceId,
    tailscaleNodeId,
    activeHouseId,
    $driftBlobEquality.hash(createdAtHlc),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUserSetting &&
          other.deviceId == this.deviceId &&
          other.tailscaleNodeId == this.tailscaleNodeId &&
          other.activeHouseId == this.activeHouseId &&
          $driftBlobEquality.equals(other.createdAtHlc, this.createdAtHlc));
}

class LocalUserSettingsCompanion extends UpdateCompanion<LocalUserSetting> {
  final Value<String> deviceId;
  final Value<String> tailscaleNodeId;
  final Value<String?> activeHouseId;
  final Value<Uint8List> createdAtHlc;
  final Value<int> rowid;
  const LocalUserSettingsCompanion({
    this.deviceId = const Value.absent(),
    this.tailscaleNodeId = const Value.absent(),
    this.activeHouseId = const Value.absent(),
    this.createdAtHlc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalUserSettingsCompanion.insert({
    required String deviceId,
    this.tailscaleNodeId = const Value.absent(),
    this.activeHouseId = const Value.absent(),
    required Uint8List createdAtHlc,
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId),
       createdAtHlc = Value(createdAtHlc);
  static Insertable<LocalUserSetting> custom({
    Expression<String>? deviceId,
    Expression<String>? tailscaleNodeId,
    Expression<String>? activeHouseId,
    Expression<Uint8List>? createdAtHlc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (tailscaleNodeId != null) 'tailscale_node_id': tailscaleNodeId,
      if (activeHouseId != null) 'active_house_id': activeHouseId,
      if (createdAtHlc != null) 'created_at_hlc': createdAtHlc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalUserSettingsCompanion copyWith({
    Value<String>? deviceId,
    Value<String>? tailscaleNodeId,
    Value<String?>? activeHouseId,
    Value<Uint8List>? createdAtHlc,
    Value<int>? rowid,
  }) {
    return LocalUserSettingsCompanion(
      deviceId: deviceId ?? this.deviceId,
      tailscaleNodeId: tailscaleNodeId ?? this.tailscaleNodeId,
      activeHouseId: activeHouseId ?? this.activeHouseId,
      createdAtHlc: createdAtHlc ?? this.createdAtHlc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (tailscaleNodeId.present) {
      map['tailscale_node_id'] = Variable<String>(tailscaleNodeId.value);
    }
    if (activeHouseId.present) {
      map['active_house_id'] = Variable<String>(activeHouseId.value);
    }
    if (createdAtHlc.present) {
      map['created_at_hlc'] = Variable<Uint8List>(createdAtHlc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserSettingsCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('tailscaleNodeId: $tailscaleNodeId, ')
          ..write('activeHouseId: $activeHouseId, ')
          ..write('createdAtHlc: $createdAtHlc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HouseSyncTable extends HouseSync
    with TableInfo<$HouseSyncTable, HouseSyncData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HouseSyncTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _houseIdMeta = const VerificationMeta(
    'houseId',
  );
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
    'house_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creatorMemberIdMeta = const VerificationMeta(
    'creatorMemberId',
  );
  @override
  late final GeneratedColumn<String> creatorMemberId = GeneratedColumn<String>(
    'creator_member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rulesVersionMeta = const VerificationMeta(
    'rulesVersion',
  );
  @override
  late final GeneratedColumn<int> rulesVersion = GeneratedColumn<int>(
    'rules_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtHlcMeta = const VerificationMeta(
    'createdAtHlc',
  );
  @override
  late final GeneratedColumn<Uint8List> createdAtHlc =
      GeneratedColumn<Uint8List>(
        'created_at_hlc',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<Uint8List> updatedAtHlc =
      GeneratedColumn<Uint8List>(
        'updated_at_hlc',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _displayNameHlcMeta = const VerificationMeta(
    'displayNameHlc',
  );
  @override
  late final GeneratedColumn<Uint8List> displayNameHlc =
      GeneratedColumn<Uint8List>(
        'display_name_hlc',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _displayNameDeviceIdMeta =
      const VerificationMeta('displayNameDeviceId');
  @override
  late final GeneratedColumn<String> displayNameDeviceId =
      GeneratedColumn<String>(
        'display_name_device_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _rulesVersionHlcMeta = const VerificationMeta(
    'rulesVersionHlc',
  );
  @override
  late final GeneratedColumn<Uint8List> rulesVersionHlc =
      GeneratedColumn<Uint8List>(
        'rules_version_hlc',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _rulesVersionDeviceIdMeta =
      const VerificationMeta('rulesVersionDeviceId');
  @override
  late final GeneratedColumn<String> rulesVersionDeviceId =
      GeneratedColumn<String>(
        'rules_version_device_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _privilegeTemplatesMeta =
      const VerificationMeta('privilegeTemplates');
  @override
  late final GeneratedColumn<String> privilegeTemplates =
      GeneratedColumn<String>(
        'privilege_templates',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _privilegeTemplatesHlcMeta =
      const VerificationMeta('privilegeTemplatesHlc');
  @override
  late final GeneratedColumn<Uint8List> privilegeTemplatesHlc =
      GeneratedColumn<Uint8List>(
        'privilege_templates_hlc',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _privilegeTemplatesDeviceIdMeta =
      const VerificationMeta('privilegeTemplatesDeviceId');
  @override
  late final GeneratedColumn<String> privilegeTemplatesDeviceId =
      GeneratedColumn<String>(
        'privilege_templates_device_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    houseId,
    displayName,
    creatorMemberId,
    rulesVersion,
    createdAtHlc,
    updatedAtHlc,
    displayNameHlc,
    displayNameDeviceId,
    rulesVersionHlc,
    rulesVersionDeviceId,
    privilegeTemplates,
    privilegeTemplatesHlc,
    privilegeTemplatesDeviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'house_sync';
  @override
  VerificationContext validateIntegrity(
    Insertable<HouseSyncData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('house_id')) {
      context.handle(
        _houseIdMeta,
        houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('creator_member_id')) {
      context.handle(
        _creatorMemberIdMeta,
        creatorMemberId.isAcceptableOrUnknown(
          data['creator_member_id']!,
          _creatorMemberIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_creatorMemberIdMeta);
    }
    if (data.containsKey('rules_version')) {
      context.handle(
        _rulesVersionMeta,
        rulesVersion.isAcceptableOrUnknown(
          data['rules_version']!,
          _rulesVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_at_hlc')) {
      context.handle(
        _createdAtHlcMeta,
        createdAtHlc.isAcceptableOrUnknown(
          data['created_at_hlc']!,
          _createdAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtHlcMeta);
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    if (data.containsKey('display_name_hlc')) {
      context.handle(
        _displayNameHlcMeta,
        displayNameHlc.isAcceptableOrUnknown(
          data['display_name_hlc']!,
          _displayNameHlcMeta,
        ),
      );
    }
    if (data.containsKey('display_name_device_id')) {
      context.handle(
        _displayNameDeviceIdMeta,
        displayNameDeviceId.isAcceptableOrUnknown(
          data['display_name_device_id']!,
          _displayNameDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('rules_version_hlc')) {
      context.handle(
        _rulesVersionHlcMeta,
        rulesVersionHlc.isAcceptableOrUnknown(
          data['rules_version_hlc']!,
          _rulesVersionHlcMeta,
        ),
      );
    }
    if (data.containsKey('rules_version_device_id')) {
      context.handle(
        _rulesVersionDeviceIdMeta,
        rulesVersionDeviceId.isAcceptableOrUnknown(
          data['rules_version_device_id']!,
          _rulesVersionDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('privilege_templates')) {
      context.handle(
        _privilegeTemplatesMeta,
        privilegeTemplates.isAcceptableOrUnknown(
          data['privilege_templates']!,
          _privilegeTemplatesMeta,
        ),
      );
    }
    if (data.containsKey('privilege_templates_hlc')) {
      context.handle(
        _privilegeTemplatesHlcMeta,
        privilegeTemplatesHlc.isAcceptableOrUnknown(
          data['privilege_templates_hlc']!,
          _privilegeTemplatesHlcMeta,
        ),
      );
    }
    if (data.containsKey('privilege_templates_device_id')) {
      context.handle(
        _privilegeTemplatesDeviceIdMeta,
        privilegeTemplatesDeviceId.isAcceptableOrUnknown(
          data['privilege_templates_device_id']!,
          _privilegeTemplatesDeviceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {houseId};
  @override
  HouseSyncData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HouseSyncData(
      houseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}house_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      creatorMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creator_member_id'],
      )!,
      rulesVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rules_version'],
      )!,
      createdAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}created_at_hlc'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      displayNameHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}display_name_hlc'],
      ),
      displayNameDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name_device_id'],
      ),
      rulesVersionHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}rules_version_hlc'],
      ),
      rulesVersionDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rules_version_device_id'],
      ),
      privilegeTemplates: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}privilege_templates'],
      )!,
      privilegeTemplatesHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}privilege_templates_hlc'],
      ),
      privilegeTemplatesDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}privilege_templates_device_id'],
      ),
    );
  }

  @override
  $HouseSyncTable createAlias(String alias) {
    return $HouseSyncTable(attachedDatabase, alias);
  }
}

class HouseSyncData extends DataClass implements Insertable<HouseSyncData> {
  final String houseId;
  final String displayName;
  final String creatorMemberId;
  final int rulesVersion;
  final Uint8List createdAtHlc;
  final Uint8List updatedAtHlc;
  final Uint8List? displayNameHlc;
  final String? displayNameDeviceId;
  final Uint8List? rulesVersionHlc;
  final String? rulesVersionDeviceId;
  final String privilegeTemplates;
  final Uint8List? privilegeTemplatesHlc;
  final String? privilegeTemplatesDeviceId;
  const HouseSyncData({
    required this.houseId,
    required this.displayName,
    required this.creatorMemberId,
    required this.rulesVersion,
    required this.createdAtHlc,
    required this.updatedAtHlc,
    this.displayNameHlc,
    this.displayNameDeviceId,
    this.rulesVersionHlc,
    this.rulesVersionDeviceId,
    required this.privilegeTemplates,
    this.privilegeTemplatesHlc,
    this.privilegeTemplatesDeviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['house_id'] = Variable<String>(houseId);
    map['display_name'] = Variable<String>(displayName);
    map['creator_member_id'] = Variable<String>(creatorMemberId);
    map['rules_version'] = Variable<int>(rulesVersion);
    map['created_at_hlc'] = Variable<Uint8List>(createdAtHlc);
    map['updated_at_hlc'] = Variable<Uint8List>(updatedAtHlc);
    if (!nullToAbsent || displayNameHlc != null) {
      map['display_name_hlc'] = Variable<Uint8List>(displayNameHlc);
    }
    if (!nullToAbsent || displayNameDeviceId != null) {
      map['display_name_device_id'] = Variable<String>(displayNameDeviceId);
    }
    if (!nullToAbsent || rulesVersionHlc != null) {
      map['rules_version_hlc'] = Variable<Uint8List>(rulesVersionHlc);
    }
    if (!nullToAbsent || rulesVersionDeviceId != null) {
      map['rules_version_device_id'] = Variable<String>(rulesVersionDeviceId);
    }
    map['privilege_templates'] = Variable<String>(privilegeTemplates);
    if (!nullToAbsent || privilegeTemplatesHlc != null) {
      map['privilege_templates_hlc'] = Variable<Uint8List>(
        privilegeTemplatesHlc,
      );
    }
    if (!nullToAbsent || privilegeTemplatesDeviceId != null) {
      map['privilege_templates_device_id'] = Variable<String>(
        privilegeTemplatesDeviceId,
      );
    }
    return map;
  }

  HouseSyncCompanion toCompanion(bool nullToAbsent) {
    return HouseSyncCompanion(
      houseId: Value(houseId),
      displayName: Value(displayName),
      creatorMemberId: Value(creatorMemberId),
      rulesVersion: Value(rulesVersion),
      createdAtHlc: Value(createdAtHlc),
      updatedAtHlc: Value(updatedAtHlc),
      displayNameHlc: displayNameHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(displayNameHlc),
      displayNameDeviceId: displayNameDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(displayNameDeviceId),
      rulesVersionHlc: rulesVersionHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(rulesVersionHlc),
      rulesVersionDeviceId: rulesVersionDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(rulesVersionDeviceId),
      privilegeTemplates: Value(privilegeTemplates),
      privilegeTemplatesHlc: privilegeTemplatesHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(privilegeTemplatesHlc),
      privilegeTemplatesDeviceId:
          privilegeTemplatesDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(privilegeTemplatesDeviceId),
    );
  }

  factory HouseSyncData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HouseSyncData(
      houseId: serializer.fromJson<String>(json['houseId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      creatorMemberId: serializer.fromJson<String>(json['creatorMemberId']),
      rulesVersion: serializer.fromJson<int>(json['rulesVersion']),
      createdAtHlc: serializer.fromJson<Uint8List>(json['createdAtHlc']),
      updatedAtHlc: serializer.fromJson<Uint8List>(json['updatedAtHlc']),
      displayNameHlc: serializer.fromJson<Uint8List?>(json['displayNameHlc']),
      displayNameDeviceId: serializer.fromJson<String?>(
        json['displayNameDeviceId'],
      ),
      rulesVersionHlc: serializer.fromJson<Uint8List?>(json['rulesVersionHlc']),
      rulesVersionDeviceId: serializer.fromJson<String?>(
        json['rulesVersionDeviceId'],
      ),
      privilegeTemplates: serializer.fromJson<String>(
        json['privilegeTemplates'],
      ),
      privilegeTemplatesHlc: serializer.fromJson<Uint8List?>(
        json['privilegeTemplatesHlc'],
      ),
      privilegeTemplatesDeviceId: serializer.fromJson<String?>(
        json['privilegeTemplatesDeviceId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'houseId': serializer.toJson<String>(houseId),
      'displayName': serializer.toJson<String>(displayName),
      'creatorMemberId': serializer.toJson<String>(creatorMemberId),
      'rulesVersion': serializer.toJson<int>(rulesVersion),
      'createdAtHlc': serializer.toJson<Uint8List>(createdAtHlc),
      'updatedAtHlc': serializer.toJson<Uint8List>(updatedAtHlc),
      'displayNameHlc': serializer.toJson<Uint8List?>(displayNameHlc),
      'displayNameDeviceId': serializer.toJson<String?>(displayNameDeviceId),
      'rulesVersionHlc': serializer.toJson<Uint8List?>(rulesVersionHlc),
      'rulesVersionDeviceId': serializer.toJson<String?>(rulesVersionDeviceId),
      'privilegeTemplates': serializer.toJson<String>(privilegeTemplates),
      'privilegeTemplatesHlc': serializer.toJson<Uint8List?>(
        privilegeTemplatesHlc,
      ),
      'privilegeTemplatesDeviceId': serializer.toJson<String?>(
        privilegeTemplatesDeviceId,
      ),
    };
  }

  HouseSyncData copyWith({
    String? houseId,
    String? displayName,
    String? creatorMemberId,
    int? rulesVersion,
    Uint8List? createdAtHlc,
    Uint8List? updatedAtHlc,
    Value<Uint8List?> displayNameHlc = const Value.absent(),
    Value<String?> displayNameDeviceId = const Value.absent(),
    Value<Uint8List?> rulesVersionHlc = const Value.absent(),
    Value<String?> rulesVersionDeviceId = const Value.absent(),
    String? privilegeTemplates,
    Value<Uint8List?> privilegeTemplatesHlc = const Value.absent(),
    Value<String?> privilegeTemplatesDeviceId = const Value.absent(),
  }) => HouseSyncData(
    houseId: houseId ?? this.houseId,
    displayName: displayName ?? this.displayName,
    creatorMemberId: creatorMemberId ?? this.creatorMemberId,
    rulesVersion: rulesVersion ?? this.rulesVersion,
    createdAtHlc: createdAtHlc ?? this.createdAtHlc,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    displayNameHlc: displayNameHlc.present
        ? displayNameHlc.value
        : this.displayNameHlc,
    displayNameDeviceId: displayNameDeviceId.present
        ? displayNameDeviceId.value
        : this.displayNameDeviceId,
    rulesVersionHlc: rulesVersionHlc.present
        ? rulesVersionHlc.value
        : this.rulesVersionHlc,
    rulesVersionDeviceId: rulesVersionDeviceId.present
        ? rulesVersionDeviceId.value
        : this.rulesVersionDeviceId,
    privilegeTemplates: privilegeTemplates ?? this.privilegeTemplates,
    privilegeTemplatesHlc: privilegeTemplatesHlc.present
        ? privilegeTemplatesHlc.value
        : this.privilegeTemplatesHlc,
    privilegeTemplatesDeviceId: privilegeTemplatesDeviceId.present
        ? privilegeTemplatesDeviceId.value
        : this.privilegeTemplatesDeviceId,
  );
  HouseSyncData copyWithCompanion(HouseSyncCompanion data) {
    return HouseSyncData(
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      creatorMemberId: data.creatorMemberId.present
          ? data.creatorMemberId.value
          : this.creatorMemberId,
      rulesVersion: data.rulesVersion.present
          ? data.rulesVersion.value
          : this.rulesVersion,
      createdAtHlc: data.createdAtHlc.present
          ? data.createdAtHlc.value
          : this.createdAtHlc,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      displayNameHlc: data.displayNameHlc.present
          ? data.displayNameHlc.value
          : this.displayNameHlc,
      displayNameDeviceId: data.displayNameDeviceId.present
          ? data.displayNameDeviceId.value
          : this.displayNameDeviceId,
      rulesVersionHlc: data.rulesVersionHlc.present
          ? data.rulesVersionHlc.value
          : this.rulesVersionHlc,
      rulesVersionDeviceId: data.rulesVersionDeviceId.present
          ? data.rulesVersionDeviceId.value
          : this.rulesVersionDeviceId,
      privilegeTemplates: data.privilegeTemplates.present
          ? data.privilegeTemplates.value
          : this.privilegeTemplates,
      privilegeTemplatesHlc: data.privilegeTemplatesHlc.present
          ? data.privilegeTemplatesHlc.value
          : this.privilegeTemplatesHlc,
      privilegeTemplatesDeviceId: data.privilegeTemplatesDeviceId.present
          ? data.privilegeTemplatesDeviceId.value
          : this.privilegeTemplatesDeviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HouseSyncData(')
          ..write('houseId: $houseId, ')
          ..write('displayName: $displayName, ')
          ..write('creatorMemberId: $creatorMemberId, ')
          ..write('rulesVersion: $rulesVersion, ')
          ..write('createdAtHlc: $createdAtHlc, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('displayNameHlc: $displayNameHlc, ')
          ..write('displayNameDeviceId: $displayNameDeviceId, ')
          ..write('rulesVersionHlc: $rulesVersionHlc, ')
          ..write('rulesVersionDeviceId: $rulesVersionDeviceId, ')
          ..write('privilegeTemplates: $privilegeTemplates, ')
          ..write('privilegeTemplatesHlc: $privilegeTemplatesHlc, ')
          ..write('privilegeTemplatesDeviceId: $privilegeTemplatesDeviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    houseId,
    displayName,
    creatorMemberId,
    rulesVersion,
    $driftBlobEquality.hash(createdAtHlc),
    $driftBlobEquality.hash(updatedAtHlc),
    $driftBlobEquality.hash(displayNameHlc),
    displayNameDeviceId,
    $driftBlobEquality.hash(rulesVersionHlc),
    rulesVersionDeviceId,
    privilegeTemplates,
    $driftBlobEquality.hash(privilegeTemplatesHlc),
    privilegeTemplatesDeviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HouseSyncData &&
          other.houseId == this.houseId &&
          other.displayName == this.displayName &&
          other.creatorMemberId == this.creatorMemberId &&
          other.rulesVersion == this.rulesVersion &&
          $driftBlobEquality.equals(other.createdAtHlc, this.createdAtHlc) &&
          $driftBlobEquality.equals(other.updatedAtHlc, this.updatedAtHlc) &&
          $driftBlobEquality.equals(
            other.displayNameHlc,
            this.displayNameHlc,
          ) &&
          other.displayNameDeviceId == this.displayNameDeviceId &&
          $driftBlobEquality.equals(
            other.rulesVersionHlc,
            this.rulesVersionHlc,
          ) &&
          other.rulesVersionDeviceId == this.rulesVersionDeviceId &&
          other.privilegeTemplates == this.privilegeTemplates &&
          $driftBlobEquality.equals(
            other.privilegeTemplatesHlc,
            this.privilegeTemplatesHlc,
          ) &&
          other.privilegeTemplatesDeviceId == this.privilegeTemplatesDeviceId);
}

class HouseSyncCompanion extends UpdateCompanion<HouseSyncData> {
  final Value<String> houseId;
  final Value<String> displayName;
  final Value<String> creatorMemberId;
  final Value<int> rulesVersion;
  final Value<Uint8List> createdAtHlc;
  final Value<Uint8List> updatedAtHlc;
  final Value<Uint8List?> displayNameHlc;
  final Value<String?> displayNameDeviceId;
  final Value<Uint8List?> rulesVersionHlc;
  final Value<String?> rulesVersionDeviceId;
  final Value<String> privilegeTemplates;
  final Value<Uint8List?> privilegeTemplatesHlc;
  final Value<String?> privilegeTemplatesDeviceId;
  final Value<int> rowid;
  const HouseSyncCompanion({
    this.houseId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.creatorMemberId = const Value.absent(),
    this.rulesVersion = const Value.absent(),
    this.createdAtHlc = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.displayNameHlc = const Value.absent(),
    this.displayNameDeviceId = const Value.absent(),
    this.rulesVersionHlc = const Value.absent(),
    this.rulesVersionDeviceId = const Value.absent(),
    this.privilegeTemplates = const Value.absent(),
    this.privilegeTemplatesHlc = const Value.absent(),
    this.privilegeTemplatesDeviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HouseSyncCompanion.insert({
    required String houseId,
    required String displayName,
    required String creatorMemberId,
    this.rulesVersion = const Value.absent(),
    required Uint8List createdAtHlc,
    required Uint8List updatedAtHlc,
    this.displayNameHlc = const Value.absent(),
    this.displayNameDeviceId = const Value.absent(),
    this.rulesVersionHlc = const Value.absent(),
    this.rulesVersionDeviceId = const Value.absent(),
    this.privilegeTemplates = const Value.absent(),
    this.privilegeTemplatesHlc = const Value.absent(),
    this.privilegeTemplatesDeviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : houseId = Value(houseId),
       displayName = Value(displayName),
       creatorMemberId = Value(creatorMemberId),
       createdAtHlc = Value(createdAtHlc),
       updatedAtHlc = Value(updatedAtHlc);
  static Insertable<HouseSyncData> custom({
    Expression<String>? houseId,
    Expression<String>? displayName,
    Expression<String>? creatorMemberId,
    Expression<int>? rulesVersion,
    Expression<Uint8List>? createdAtHlc,
    Expression<Uint8List>? updatedAtHlc,
    Expression<Uint8List>? displayNameHlc,
    Expression<String>? displayNameDeviceId,
    Expression<Uint8List>? rulesVersionHlc,
    Expression<String>? rulesVersionDeviceId,
    Expression<String>? privilegeTemplates,
    Expression<Uint8List>? privilegeTemplatesHlc,
    Expression<String>? privilegeTemplatesDeviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (houseId != null) 'house_id': houseId,
      if (displayName != null) 'display_name': displayName,
      if (creatorMemberId != null) 'creator_member_id': creatorMemberId,
      if (rulesVersion != null) 'rules_version': rulesVersion,
      if (createdAtHlc != null) 'created_at_hlc': createdAtHlc,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (displayNameHlc != null) 'display_name_hlc': displayNameHlc,
      if (displayNameDeviceId != null)
        'display_name_device_id': displayNameDeviceId,
      if (rulesVersionHlc != null) 'rules_version_hlc': rulesVersionHlc,
      if (rulesVersionDeviceId != null)
        'rules_version_device_id': rulesVersionDeviceId,
      if (privilegeTemplates != null) 'privilege_templates': privilegeTemplates,
      if (privilegeTemplatesHlc != null)
        'privilege_templates_hlc': privilegeTemplatesHlc,
      if (privilegeTemplatesDeviceId != null)
        'privilege_templates_device_id': privilegeTemplatesDeviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HouseSyncCompanion copyWith({
    Value<String>? houseId,
    Value<String>? displayName,
    Value<String>? creatorMemberId,
    Value<int>? rulesVersion,
    Value<Uint8List>? createdAtHlc,
    Value<Uint8List>? updatedAtHlc,
    Value<Uint8List?>? displayNameHlc,
    Value<String?>? displayNameDeviceId,
    Value<Uint8List?>? rulesVersionHlc,
    Value<String?>? rulesVersionDeviceId,
    Value<String>? privilegeTemplates,
    Value<Uint8List?>? privilegeTemplatesHlc,
    Value<String?>? privilegeTemplatesDeviceId,
    Value<int>? rowid,
  }) {
    return HouseSyncCompanion(
      houseId: houseId ?? this.houseId,
      displayName: displayName ?? this.displayName,
      creatorMemberId: creatorMemberId ?? this.creatorMemberId,
      rulesVersion: rulesVersion ?? this.rulesVersion,
      createdAtHlc: createdAtHlc ?? this.createdAtHlc,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      displayNameHlc: displayNameHlc ?? this.displayNameHlc,
      displayNameDeviceId: displayNameDeviceId ?? this.displayNameDeviceId,
      rulesVersionHlc: rulesVersionHlc ?? this.rulesVersionHlc,
      rulesVersionDeviceId: rulesVersionDeviceId ?? this.rulesVersionDeviceId,
      privilegeTemplates: privilegeTemplates ?? this.privilegeTemplates,
      privilegeTemplatesHlc:
          privilegeTemplatesHlc ?? this.privilegeTemplatesHlc,
      privilegeTemplatesDeviceId:
          privilegeTemplatesDeviceId ?? this.privilegeTemplatesDeviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (creatorMemberId.present) {
      map['creator_member_id'] = Variable<String>(creatorMemberId.value);
    }
    if (rulesVersion.present) {
      map['rules_version'] = Variable<int>(rulesVersion.value);
    }
    if (createdAtHlc.present) {
      map['created_at_hlc'] = Variable<Uint8List>(createdAtHlc.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<Uint8List>(updatedAtHlc.value);
    }
    if (displayNameHlc.present) {
      map['display_name_hlc'] = Variable<Uint8List>(displayNameHlc.value);
    }
    if (displayNameDeviceId.present) {
      map['display_name_device_id'] = Variable<String>(
        displayNameDeviceId.value,
      );
    }
    if (rulesVersionHlc.present) {
      map['rules_version_hlc'] = Variable<Uint8List>(rulesVersionHlc.value);
    }
    if (rulesVersionDeviceId.present) {
      map['rules_version_device_id'] = Variable<String>(
        rulesVersionDeviceId.value,
      );
    }
    if (privilegeTemplates.present) {
      map['privilege_templates'] = Variable<String>(privilegeTemplates.value);
    }
    if (privilegeTemplatesHlc.present) {
      map['privilege_templates_hlc'] = Variable<Uint8List>(
        privilegeTemplatesHlc.value,
      );
    }
    if (privilegeTemplatesDeviceId.present) {
      map['privilege_templates_device_id'] = Variable<String>(
        privilegeTemplatesDeviceId.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HouseSyncCompanion(')
          ..write('houseId: $houseId, ')
          ..write('displayName: $displayName, ')
          ..write('creatorMemberId: $creatorMemberId, ')
          ..write('rulesVersion: $rulesVersion, ')
          ..write('createdAtHlc: $createdAtHlc, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('displayNameHlc: $displayNameHlc, ')
          ..write('displayNameDeviceId: $displayNameDeviceId, ')
          ..write('rulesVersionHlc: $rulesVersionHlc, ')
          ..write('rulesVersionDeviceId: $rulesVersionDeviceId, ')
          ..write('privilegeTemplates: $privilegeTemplates, ')
          ..write('privilegeTemplatesHlc: $privilegeTemplatesHlc, ')
          ..write('privilegeTemplatesDeviceId: $privilegeTemplatesDeviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HousematesSyncTable extends HousematesSync
    with TableInfo<$HousematesSyncTable, HousematesSyncData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HousematesSyncTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _houseIdMeta = const VerificationMeta(
    'houseId',
  );
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
    'house_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tailscaleUserIdMeta = const VerificationMeta(
    'tailscaleUserId',
  );
  @override
  late final GeneratedColumn<String> tailscaleUserId = GeneratedColumn<String>(
    'tailscale_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tailscaleNodeKeyMeta = const VerificationMeta(
    'tailscaleNodeKey',
  );
  @override
  late final GeneratedColumn<String> tailscaleNodeKey = GeneratedColumn<String>(
    'tailscale_node_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lifetimeScoreMeta = const VerificationMeta(
    'lifetimeScore',
  );
  @override
  late final GeneratedColumn<int> lifetimeScore = GeneratedColumn<int>(
    'lifetime_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rotationOrderIndexMeta =
      const VerificationMeta('rotationOrderIndex');
  @override
  late final GeneratedColumn<int> rotationOrderIndex = GeneratedColumn<int>(
    'rotation_order_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memberStatusMeta = const VerificationMeta(
    'memberStatus',
  );
  @override
  late final GeneratedColumn<String> memberStatus = GeneratedColumn<String>(
    'member_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _evictedAtHlcMeta = const VerificationMeta(
    'evictedAtHlc',
  );
  @override
  late final GeneratedColumn<Uint8List> evictedAtHlc =
      GeneratedColumn<Uint8List>(
        'evicted_at_hlc',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<Uint8List> updatedAtHlc =
      GeneratedColumn<Uint8List>(
        'updated_at_hlc',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _nicknameHlcMeta = const VerificationMeta(
    'nicknameHlc',
  );
  @override
  late final GeneratedColumn<Uint8List> nicknameHlc =
      GeneratedColumn<Uint8List>(
        'nickname_hlc',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nicknameDeviceIdMeta = const VerificationMeta(
    'nicknameDeviceId',
  );
  @override
  late final GeneratedColumn<String> nicknameDeviceId = GeneratedColumn<String>(
    'nickname_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    memberId,
    houseId,
    tailscaleUserId,
    tailscaleNodeKey,
    nickname,
    lifetimeScore,
    rotationOrderIndex,
    memberStatus,
    evictedAtHlc,
    updatedAtHlc,
    nicknameHlc,
    nicknameDeviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'housemates_sync';
  @override
  VerificationContext validateIntegrity(
    Insertable<HousematesSyncData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('house_id')) {
      context.handle(
        _houseIdMeta,
        houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('tailscale_user_id')) {
      context.handle(
        _tailscaleUserIdMeta,
        tailscaleUserId.isAcceptableOrUnknown(
          data['tailscale_user_id']!,
          _tailscaleUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tailscaleUserIdMeta);
    }
    if (data.containsKey('tailscale_node_key')) {
      context.handle(
        _tailscaleNodeKeyMeta,
        tailscaleNodeKey.isAcceptableOrUnknown(
          data['tailscale_node_key']!,
          _tailscaleNodeKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tailscaleNodeKeyMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('lifetime_score')) {
      context.handle(
        _lifetimeScoreMeta,
        lifetimeScore.isAcceptableOrUnknown(
          data['lifetime_score']!,
          _lifetimeScoreMeta,
        ),
      );
    }
    if (data.containsKey('rotation_order_index')) {
      context.handle(
        _rotationOrderIndexMeta,
        rotationOrderIndex.isAcceptableOrUnknown(
          data['rotation_order_index']!,
          _rotationOrderIndexMeta,
        ),
      );
    }
    if (data.containsKey('member_status')) {
      context.handle(
        _memberStatusMeta,
        memberStatus.isAcceptableOrUnknown(
          data['member_status']!,
          _memberStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_memberStatusMeta);
    }
    if (data.containsKey('evicted_at_hlc')) {
      context.handle(
        _evictedAtHlcMeta,
        evictedAtHlc.isAcceptableOrUnknown(
          data['evicted_at_hlc']!,
          _evictedAtHlcMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    if (data.containsKey('nickname_hlc')) {
      context.handle(
        _nicknameHlcMeta,
        nicknameHlc.isAcceptableOrUnknown(
          data['nickname_hlc']!,
          _nicknameHlcMeta,
        ),
      );
    }
    if (data.containsKey('nickname_device_id')) {
      context.handle(
        _nicknameDeviceIdMeta,
        nicknameDeviceId.isAcceptableOrUnknown(
          data['nickname_device_id']!,
          _nicknameDeviceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {memberId};
  @override
  HousematesSyncData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HousematesSyncData(
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      houseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}house_id'],
      )!,
      tailscaleUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tailscale_user_id'],
      )!,
      tailscaleNodeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tailscale_node_key'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      )!,
      lifetimeScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lifetime_score'],
      )!,
      rotationOrderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rotation_order_index'],
      ),
      memberStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_status'],
      )!,
      evictedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}evicted_at_hlc'],
      ),
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      nicknameHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}nickname_hlc'],
      ),
      nicknameDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname_device_id'],
      ),
    );
  }

  @override
  $HousematesSyncTable createAlias(String alias) {
    return $HousematesSyncTable(attachedDatabase, alias);
  }
}

class HousematesSyncData extends DataClass
    implements Insertable<HousematesSyncData> {
  final String memberId;
  final String houseId;
  final String tailscaleUserId;
  final String tailscaleNodeKey;
  final String nickname;
  final int lifetimeScore;
  final int? rotationOrderIndex;
  final String memberStatus;
  final Uint8List? evictedAtHlc;
  final Uint8List updatedAtHlc;
  final Uint8List? nicknameHlc;
  final String? nicknameDeviceId;
  const HousematesSyncData({
    required this.memberId,
    required this.houseId,
    required this.tailscaleUserId,
    required this.tailscaleNodeKey,
    required this.nickname,
    required this.lifetimeScore,
    this.rotationOrderIndex,
    required this.memberStatus,
    this.evictedAtHlc,
    required this.updatedAtHlc,
    this.nicknameHlc,
    this.nicknameDeviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['member_id'] = Variable<String>(memberId);
    map['house_id'] = Variable<String>(houseId);
    map['tailscale_user_id'] = Variable<String>(tailscaleUserId);
    map['tailscale_node_key'] = Variable<String>(tailscaleNodeKey);
    map['nickname'] = Variable<String>(nickname);
    map['lifetime_score'] = Variable<int>(lifetimeScore);
    if (!nullToAbsent || rotationOrderIndex != null) {
      map['rotation_order_index'] = Variable<int>(rotationOrderIndex);
    }
    map['member_status'] = Variable<String>(memberStatus);
    if (!nullToAbsent || evictedAtHlc != null) {
      map['evicted_at_hlc'] = Variable<Uint8List>(evictedAtHlc);
    }
    map['updated_at_hlc'] = Variable<Uint8List>(updatedAtHlc);
    if (!nullToAbsent || nicknameHlc != null) {
      map['nickname_hlc'] = Variable<Uint8List>(nicknameHlc);
    }
    if (!nullToAbsent || nicknameDeviceId != null) {
      map['nickname_device_id'] = Variable<String>(nicknameDeviceId);
    }
    return map;
  }

  HousematesSyncCompanion toCompanion(bool nullToAbsent) {
    return HousematesSyncCompanion(
      memberId: Value(memberId),
      houseId: Value(houseId),
      tailscaleUserId: Value(tailscaleUserId),
      tailscaleNodeKey: Value(tailscaleNodeKey),
      nickname: Value(nickname),
      lifetimeScore: Value(lifetimeScore),
      rotationOrderIndex: rotationOrderIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(rotationOrderIndex),
      memberStatus: Value(memberStatus),
      evictedAtHlc: evictedAtHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(evictedAtHlc),
      updatedAtHlc: Value(updatedAtHlc),
      nicknameHlc: nicknameHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(nicknameHlc),
      nicknameDeviceId: nicknameDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(nicknameDeviceId),
    );
  }

  factory HousematesSyncData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HousematesSyncData(
      memberId: serializer.fromJson<String>(json['memberId']),
      houseId: serializer.fromJson<String>(json['houseId']),
      tailscaleUserId: serializer.fromJson<String>(json['tailscaleUserId']),
      tailscaleNodeKey: serializer.fromJson<String>(json['tailscaleNodeKey']),
      nickname: serializer.fromJson<String>(json['nickname']),
      lifetimeScore: serializer.fromJson<int>(json['lifetimeScore']),
      rotationOrderIndex: serializer.fromJson<int?>(json['rotationOrderIndex']),
      memberStatus: serializer.fromJson<String>(json['memberStatus']),
      evictedAtHlc: serializer.fromJson<Uint8List?>(json['evictedAtHlc']),
      updatedAtHlc: serializer.fromJson<Uint8List>(json['updatedAtHlc']),
      nicknameHlc: serializer.fromJson<Uint8List?>(json['nicknameHlc']),
      nicknameDeviceId: serializer.fromJson<String?>(json['nicknameDeviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'memberId': serializer.toJson<String>(memberId),
      'houseId': serializer.toJson<String>(houseId),
      'tailscaleUserId': serializer.toJson<String>(tailscaleUserId),
      'tailscaleNodeKey': serializer.toJson<String>(tailscaleNodeKey),
      'nickname': serializer.toJson<String>(nickname),
      'lifetimeScore': serializer.toJson<int>(lifetimeScore),
      'rotationOrderIndex': serializer.toJson<int?>(rotationOrderIndex),
      'memberStatus': serializer.toJson<String>(memberStatus),
      'evictedAtHlc': serializer.toJson<Uint8List?>(evictedAtHlc),
      'updatedAtHlc': serializer.toJson<Uint8List>(updatedAtHlc),
      'nicknameHlc': serializer.toJson<Uint8List?>(nicknameHlc),
      'nicknameDeviceId': serializer.toJson<String?>(nicknameDeviceId),
    };
  }

  HousematesSyncData copyWith({
    String? memberId,
    String? houseId,
    String? tailscaleUserId,
    String? tailscaleNodeKey,
    String? nickname,
    int? lifetimeScore,
    Value<int?> rotationOrderIndex = const Value.absent(),
    String? memberStatus,
    Value<Uint8List?> evictedAtHlc = const Value.absent(),
    Uint8List? updatedAtHlc,
    Value<Uint8List?> nicknameHlc = const Value.absent(),
    Value<String?> nicknameDeviceId = const Value.absent(),
  }) => HousematesSyncData(
    memberId: memberId ?? this.memberId,
    houseId: houseId ?? this.houseId,
    tailscaleUserId: tailscaleUserId ?? this.tailscaleUserId,
    tailscaleNodeKey: tailscaleNodeKey ?? this.tailscaleNodeKey,
    nickname: nickname ?? this.nickname,
    lifetimeScore: lifetimeScore ?? this.lifetimeScore,
    rotationOrderIndex: rotationOrderIndex.present
        ? rotationOrderIndex.value
        : this.rotationOrderIndex,
    memberStatus: memberStatus ?? this.memberStatus,
    evictedAtHlc: evictedAtHlc.present ? evictedAtHlc.value : this.evictedAtHlc,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    nicknameHlc: nicknameHlc.present ? nicknameHlc.value : this.nicknameHlc,
    nicknameDeviceId: nicknameDeviceId.present
        ? nicknameDeviceId.value
        : this.nicknameDeviceId,
  );
  HousematesSyncData copyWithCompanion(HousematesSyncCompanion data) {
    return HousematesSyncData(
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      tailscaleUserId: data.tailscaleUserId.present
          ? data.tailscaleUserId.value
          : this.tailscaleUserId,
      tailscaleNodeKey: data.tailscaleNodeKey.present
          ? data.tailscaleNodeKey.value
          : this.tailscaleNodeKey,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      lifetimeScore: data.lifetimeScore.present
          ? data.lifetimeScore.value
          : this.lifetimeScore,
      rotationOrderIndex: data.rotationOrderIndex.present
          ? data.rotationOrderIndex.value
          : this.rotationOrderIndex,
      memberStatus: data.memberStatus.present
          ? data.memberStatus.value
          : this.memberStatus,
      evictedAtHlc: data.evictedAtHlc.present
          ? data.evictedAtHlc.value
          : this.evictedAtHlc,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      nicknameHlc: data.nicknameHlc.present
          ? data.nicknameHlc.value
          : this.nicknameHlc,
      nicknameDeviceId: data.nicknameDeviceId.present
          ? data.nicknameDeviceId.value
          : this.nicknameDeviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HousematesSyncData(')
          ..write('memberId: $memberId, ')
          ..write('houseId: $houseId, ')
          ..write('tailscaleUserId: $tailscaleUserId, ')
          ..write('tailscaleNodeKey: $tailscaleNodeKey, ')
          ..write('nickname: $nickname, ')
          ..write('lifetimeScore: $lifetimeScore, ')
          ..write('rotationOrderIndex: $rotationOrderIndex, ')
          ..write('memberStatus: $memberStatus, ')
          ..write('evictedAtHlc: $evictedAtHlc, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('nicknameHlc: $nicknameHlc, ')
          ..write('nicknameDeviceId: $nicknameDeviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    memberId,
    houseId,
    tailscaleUserId,
    tailscaleNodeKey,
    nickname,
    lifetimeScore,
    rotationOrderIndex,
    memberStatus,
    $driftBlobEquality.hash(evictedAtHlc),
    $driftBlobEquality.hash(updatedAtHlc),
    $driftBlobEquality.hash(nicknameHlc),
    nicknameDeviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HousematesSyncData &&
          other.memberId == this.memberId &&
          other.houseId == this.houseId &&
          other.tailscaleUserId == this.tailscaleUserId &&
          other.tailscaleNodeKey == this.tailscaleNodeKey &&
          other.nickname == this.nickname &&
          other.lifetimeScore == this.lifetimeScore &&
          other.rotationOrderIndex == this.rotationOrderIndex &&
          other.memberStatus == this.memberStatus &&
          $driftBlobEquality.equals(other.evictedAtHlc, this.evictedAtHlc) &&
          $driftBlobEquality.equals(other.updatedAtHlc, this.updatedAtHlc) &&
          $driftBlobEquality.equals(other.nicknameHlc, this.nicknameHlc) &&
          other.nicknameDeviceId == this.nicknameDeviceId);
}

class HousematesSyncCompanion extends UpdateCompanion<HousematesSyncData> {
  final Value<String> memberId;
  final Value<String> houseId;
  final Value<String> tailscaleUserId;
  final Value<String> tailscaleNodeKey;
  final Value<String> nickname;
  final Value<int> lifetimeScore;
  final Value<int?> rotationOrderIndex;
  final Value<String> memberStatus;
  final Value<Uint8List?> evictedAtHlc;
  final Value<Uint8List> updatedAtHlc;
  final Value<Uint8List?> nicknameHlc;
  final Value<String?> nicknameDeviceId;
  final Value<int> rowid;
  const HousematesSyncCompanion({
    this.memberId = const Value.absent(),
    this.houseId = const Value.absent(),
    this.tailscaleUserId = const Value.absent(),
    this.tailscaleNodeKey = const Value.absent(),
    this.nickname = const Value.absent(),
    this.lifetimeScore = const Value.absent(),
    this.rotationOrderIndex = const Value.absent(),
    this.memberStatus = const Value.absent(),
    this.evictedAtHlc = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.nicknameHlc = const Value.absent(),
    this.nicknameDeviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HousematesSyncCompanion.insert({
    required String memberId,
    required String houseId,
    required String tailscaleUserId,
    required String tailscaleNodeKey,
    required String nickname,
    this.lifetimeScore = const Value.absent(),
    this.rotationOrderIndex = const Value.absent(),
    required String memberStatus,
    this.evictedAtHlc = const Value.absent(),
    required Uint8List updatedAtHlc,
    this.nicknameHlc = const Value.absent(),
    this.nicknameDeviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : memberId = Value(memberId),
       houseId = Value(houseId),
       tailscaleUserId = Value(tailscaleUserId),
       tailscaleNodeKey = Value(tailscaleNodeKey),
       nickname = Value(nickname),
       memberStatus = Value(memberStatus),
       updatedAtHlc = Value(updatedAtHlc);
  static Insertable<HousematesSyncData> custom({
    Expression<String>? memberId,
    Expression<String>? houseId,
    Expression<String>? tailscaleUserId,
    Expression<String>? tailscaleNodeKey,
    Expression<String>? nickname,
    Expression<int>? lifetimeScore,
    Expression<int>? rotationOrderIndex,
    Expression<String>? memberStatus,
    Expression<Uint8List>? evictedAtHlc,
    Expression<Uint8List>? updatedAtHlc,
    Expression<Uint8List>? nicknameHlc,
    Expression<String>? nicknameDeviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (memberId != null) 'member_id': memberId,
      if (houseId != null) 'house_id': houseId,
      if (tailscaleUserId != null) 'tailscale_user_id': tailscaleUserId,
      if (tailscaleNodeKey != null) 'tailscale_node_key': tailscaleNodeKey,
      if (nickname != null) 'nickname': nickname,
      if (lifetimeScore != null) 'lifetime_score': lifetimeScore,
      if (rotationOrderIndex != null)
        'rotation_order_index': rotationOrderIndex,
      if (memberStatus != null) 'member_status': memberStatus,
      if (evictedAtHlc != null) 'evicted_at_hlc': evictedAtHlc,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (nicknameHlc != null) 'nickname_hlc': nicknameHlc,
      if (nicknameDeviceId != null) 'nickname_device_id': nicknameDeviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HousematesSyncCompanion copyWith({
    Value<String>? memberId,
    Value<String>? houseId,
    Value<String>? tailscaleUserId,
    Value<String>? tailscaleNodeKey,
    Value<String>? nickname,
    Value<int>? lifetimeScore,
    Value<int?>? rotationOrderIndex,
    Value<String>? memberStatus,
    Value<Uint8List?>? evictedAtHlc,
    Value<Uint8List>? updatedAtHlc,
    Value<Uint8List?>? nicknameHlc,
    Value<String?>? nicknameDeviceId,
    Value<int>? rowid,
  }) {
    return HousematesSyncCompanion(
      memberId: memberId ?? this.memberId,
      houseId: houseId ?? this.houseId,
      tailscaleUserId: tailscaleUserId ?? this.tailscaleUserId,
      tailscaleNodeKey: tailscaleNodeKey ?? this.tailscaleNodeKey,
      nickname: nickname ?? this.nickname,
      lifetimeScore: lifetimeScore ?? this.lifetimeScore,
      rotationOrderIndex: rotationOrderIndex ?? this.rotationOrderIndex,
      memberStatus: memberStatus ?? this.memberStatus,
      evictedAtHlc: evictedAtHlc ?? this.evictedAtHlc,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      nicknameHlc: nicknameHlc ?? this.nicknameHlc,
      nicknameDeviceId: nicknameDeviceId ?? this.nicknameDeviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (tailscaleUserId.present) {
      map['tailscale_user_id'] = Variable<String>(tailscaleUserId.value);
    }
    if (tailscaleNodeKey.present) {
      map['tailscale_node_key'] = Variable<String>(tailscaleNodeKey.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (lifetimeScore.present) {
      map['lifetime_score'] = Variable<int>(lifetimeScore.value);
    }
    if (rotationOrderIndex.present) {
      map['rotation_order_index'] = Variable<int>(rotationOrderIndex.value);
    }
    if (memberStatus.present) {
      map['member_status'] = Variable<String>(memberStatus.value);
    }
    if (evictedAtHlc.present) {
      map['evicted_at_hlc'] = Variable<Uint8List>(evictedAtHlc.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<Uint8List>(updatedAtHlc.value);
    }
    if (nicknameHlc.present) {
      map['nickname_hlc'] = Variable<Uint8List>(nicknameHlc.value);
    }
    if (nicknameDeviceId.present) {
      map['nickname_device_id'] = Variable<String>(nicknameDeviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HousematesSyncCompanion(')
          ..write('memberId: $memberId, ')
          ..write('houseId: $houseId, ')
          ..write('tailscaleUserId: $tailscaleUserId, ')
          ..write('tailscaleNodeKey: $tailscaleNodeKey, ')
          ..write('nickname: $nickname, ')
          ..write('lifetimeScore: $lifetimeScore, ')
          ..write('rotationOrderIndex: $rotationOrderIndex, ')
          ..write('memberStatus: $memberStatus, ')
          ..write('evictedAtHlc: $evictedAtHlc, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('nicknameHlc: $nicknameHlc, ')
          ..write('nicknameDeviceId: $nicknameDeviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScoreEventsTable extends ScoreEvents
    with TableInfo<$ScoreEventsTable, ScoreEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScoreEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _houseIdMeta = const VerificationMeta(
    'houseId',
  );
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
    'house_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deltaMeta = const VerificationMeta('delta');
  @override
  late final GeneratedColumn<int> delta = GeneratedColumn<int>(
    'delta',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonRefMeta = const VerificationMeta(
    'reasonRef',
  );
  @override
  late final GeneratedColumn<String> reasonRef = GeneratedColumn<String>(
    'reason_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<Uint8List> hlc = GeneratedColumn<Uint8List>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorDeviceIdMeta = const VerificationMeta(
    'actorDeviceId',
  );
  @override
  late final GeneratedColumn<String> actorDeviceId = GeneratedColumn<String>(
    'actor_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    eventId,
    houseId,
    memberId,
    delta,
    reasonRef,
    hlc,
    actorDeviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'score_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScoreEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('house_id')) {
      context.handle(
        _houseIdMeta,
        houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('delta')) {
      context.handle(
        _deltaMeta,
        delta.isAcceptableOrUnknown(data['delta']!, _deltaMeta),
      );
    } else if (isInserting) {
      context.missing(_deltaMeta);
    }
    if (data.containsKey('reason_ref')) {
      context.handle(
        _reasonRefMeta,
        reasonRef.isAcceptableOrUnknown(data['reason_ref']!, _reasonRefMeta),
      );
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('actor_device_id')) {
      context.handle(
        _actorDeviceIdMeta,
        actorDeviceId.isAcceptableOrUnknown(
          data['actor_device_id']!,
          _actorDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actorDeviceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  ScoreEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScoreEvent(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      houseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}house_id'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      delta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delta'],
      )!,
      reasonRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason_ref'],
      ),
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}hlc'],
      )!,
      actorDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_device_id'],
      )!,
    );
  }

  @override
  $ScoreEventsTable createAlias(String alias) {
    return $ScoreEventsTable(attachedDatabase, alias);
  }
}

class ScoreEvent extends DataClass implements Insertable<ScoreEvent> {
  final String eventId;
  final String houseId;
  final String memberId;
  final int delta;
  final String? reasonRef;
  final Uint8List hlc;
  final String actorDeviceId;
  const ScoreEvent({
    required this.eventId,
    required this.houseId,
    required this.memberId,
    required this.delta,
    this.reasonRef,
    required this.hlc,
    required this.actorDeviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['house_id'] = Variable<String>(houseId);
    map['member_id'] = Variable<String>(memberId);
    map['delta'] = Variable<int>(delta);
    if (!nullToAbsent || reasonRef != null) {
      map['reason_ref'] = Variable<String>(reasonRef);
    }
    map['hlc'] = Variable<Uint8List>(hlc);
    map['actor_device_id'] = Variable<String>(actorDeviceId);
    return map;
  }

  ScoreEventsCompanion toCompanion(bool nullToAbsent) {
    return ScoreEventsCompanion(
      eventId: Value(eventId),
      houseId: Value(houseId),
      memberId: Value(memberId),
      delta: Value(delta),
      reasonRef: reasonRef == null && nullToAbsent
          ? const Value.absent()
          : Value(reasonRef),
      hlc: Value(hlc),
      actorDeviceId: Value(actorDeviceId),
    );
  }

  factory ScoreEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScoreEvent(
      eventId: serializer.fromJson<String>(json['eventId']),
      houseId: serializer.fromJson<String>(json['houseId']),
      memberId: serializer.fromJson<String>(json['memberId']),
      delta: serializer.fromJson<int>(json['delta']),
      reasonRef: serializer.fromJson<String?>(json['reasonRef']),
      hlc: serializer.fromJson<Uint8List>(json['hlc']),
      actorDeviceId: serializer.fromJson<String>(json['actorDeviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'houseId': serializer.toJson<String>(houseId),
      'memberId': serializer.toJson<String>(memberId),
      'delta': serializer.toJson<int>(delta),
      'reasonRef': serializer.toJson<String?>(reasonRef),
      'hlc': serializer.toJson<Uint8List>(hlc),
      'actorDeviceId': serializer.toJson<String>(actorDeviceId),
    };
  }

  ScoreEvent copyWith({
    String? eventId,
    String? houseId,
    String? memberId,
    int? delta,
    Value<String?> reasonRef = const Value.absent(),
    Uint8List? hlc,
    String? actorDeviceId,
  }) => ScoreEvent(
    eventId: eventId ?? this.eventId,
    houseId: houseId ?? this.houseId,
    memberId: memberId ?? this.memberId,
    delta: delta ?? this.delta,
    reasonRef: reasonRef.present ? reasonRef.value : this.reasonRef,
    hlc: hlc ?? this.hlc,
    actorDeviceId: actorDeviceId ?? this.actorDeviceId,
  );
  ScoreEvent copyWithCompanion(ScoreEventsCompanion data) {
    return ScoreEvent(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      delta: data.delta.present ? data.delta.value : this.delta,
      reasonRef: data.reasonRef.present ? data.reasonRef.value : this.reasonRef,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      actorDeviceId: data.actorDeviceId.present
          ? data.actorDeviceId.value
          : this.actorDeviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScoreEvent(')
          ..write('eventId: $eventId, ')
          ..write('houseId: $houseId, ')
          ..write('memberId: $memberId, ')
          ..write('delta: $delta, ')
          ..write('reasonRef: $reasonRef, ')
          ..write('hlc: $hlc, ')
          ..write('actorDeviceId: $actorDeviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    eventId,
    houseId,
    memberId,
    delta,
    reasonRef,
    $driftBlobEquality.hash(hlc),
    actorDeviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScoreEvent &&
          other.eventId == this.eventId &&
          other.houseId == this.houseId &&
          other.memberId == this.memberId &&
          other.delta == this.delta &&
          other.reasonRef == this.reasonRef &&
          $driftBlobEquality.equals(other.hlc, this.hlc) &&
          other.actorDeviceId == this.actorDeviceId);
}

class ScoreEventsCompanion extends UpdateCompanion<ScoreEvent> {
  final Value<String> eventId;
  final Value<String> houseId;
  final Value<String> memberId;
  final Value<int> delta;
  final Value<String?> reasonRef;
  final Value<Uint8List> hlc;
  final Value<String> actorDeviceId;
  final Value<int> rowid;
  const ScoreEventsCompanion({
    this.eventId = const Value.absent(),
    this.houseId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.delta = const Value.absent(),
    this.reasonRef = const Value.absent(),
    this.hlc = const Value.absent(),
    this.actorDeviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScoreEventsCompanion.insert({
    required String eventId,
    required String houseId,
    required String memberId,
    required int delta,
    this.reasonRef = const Value.absent(),
    required Uint8List hlc,
    required String actorDeviceId,
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       houseId = Value(houseId),
       memberId = Value(memberId),
       delta = Value(delta),
       hlc = Value(hlc),
       actorDeviceId = Value(actorDeviceId);
  static Insertable<ScoreEvent> custom({
    Expression<String>? eventId,
    Expression<String>? houseId,
    Expression<String>? memberId,
    Expression<int>? delta,
    Expression<String>? reasonRef,
    Expression<Uint8List>? hlc,
    Expression<String>? actorDeviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (houseId != null) 'house_id': houseId,
      if (memberId != null) 'member_id': memberId,
      if (delta != null) 'delta': delta,
      if (reasonRef != null) 'reason_ref': reasonRef,
      if (hlc != null) 'hlc': hlc,
      if (actorDeviceId != null) 'actor_device_id': actorDeviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScoreEventsCompanion copyWith({
    Value<String>? eventId,
    Value<String>? houseId,
    Value<String>? memberId,
    Value<int>? delta,
    Value<String?>? reasonRef,
    Value<Uint8List>? hlc,
    Value<String>? actorDeviceId,
    Value<int>? rowid,
  }) {
    return ScoreEventsCompanion(
      eventId: eventId ?? this.eventId,
      houseId: houseId ?? this.houseId,
      memberId: memberId ?? this.memberId,
      delta: delta ?? this.delta,
      reasonRef: reasonRef ?? this.reasonRef,
      hlc: hlc ?? this.hlc,
      actorDeviceId: actorDeviceId ?? this.actorDeviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (delta.present) {
      map['delta'] = Variable<int>(delta.value);
    }
    if (reasonRef.present) {
      map['reason_ref'] = Variable<String>(reasonRef.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<Uint8List>(hlc.value);
    }
    if (actorDeviceId.present) {
      map['actor_device_id'] = Variable<String>(actorDeviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScoreEventsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('houseId: $houseId, ')
          ..write('memberId: $memberId, ')
          ..write('delta: $delta, ')
          ..write('reasonRef: $reasonRef, ')
          ..write('hlc: $hlc, ')
          ..write('actorDeviceId: $actorDeviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemovalProposalsSyncTable extends RemovalProposalsSync
    with TableInfo<$RemovalProposalsSyncTable, RemovalProposalsSyncData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemovalProposalsSyncTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _proposalIdMeta = const VerificationMeta(
    'proposalId',
  );
  @override
  late final GeneratedColumn<String> proposalId = GeneratedColumn<String>(
    'proposal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _houseIdMeta = const VerificationMeta(
    'houseId',
  );
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
    'house_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMemberIdMeta = const VerificationMeta(
    'targetMemberId',
  );
  @override
  late final GeneratedColumn<String> targetMemberId = GeneratedColumn<String>(
    'target_member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proposerMemberIdMeta = const VerificationMeta(
    'proposerMemberId',
  );
  @override
  late final GeneratedColumn<String> proposerMemberId = GeneratedColumn<String>(
    'proposer_member_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtHlcMeta = const VerificationMeta(
    'createdAtHlc',
  );
  @override
  late final GeneratedColumn<Uint8List> createdAtHlc =
      GeneratedColumn<Uint8List>(
        'created_at_hlc',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<Uint8List> updatedAtHlc =
      GeneratedColumn<Uint8List>(
        'updated_at_hlc',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusHlcMeta = const VerificationMeta(
    'statusHlc',
  );
  @override
  late final GeneratedColumn<Uint8List> statusHlc = GeneratedColumn<Uint8List>(
    'status_hlc',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusDeviceIdMeta = const VerificationMeta(
    'statusDeviceId',
  );
  @override
  late final GeneratedColumn<String> statusDeviceId = GeneratedColumn<String>(
    'status_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    proposalId,
    houseId,
    targetMemberId,
    proposerMemberId,
    type,
    status,
    createdAtHlc,
    updatedAtHlc,
    statusHlc,
    statusDeviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'removal_proposals_sync';
  @override
  VerificationContext validateIntegrity(
    Insertable<RemovalProposalsSyncData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('proposal_id')) {
      context.handle(
        _proposalIdMeta,
        proposalId.isAcceptableOrUnknown(data['proposal_id']!, _proposalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_proposalIdMeta);
    }
    if (data.containsKey('house_id')) {
      context.handle(
        _houseIdMeta,
        houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('target_member_id')) {
      context.handle(
        _targetMemberIdMeta,
        targetMemberId.isAcceptableOrUnknown(
          data['target_member_id']!,
          _targetMemberIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetMemberIdMeta);
    }
    if (data.containsKey('proposer_member_id')) {
      context.handle(
        _proposerMemberIdMeta,
        proposerMemberId.isAcceptableOrUnknown(
          data['proposer_member_id']!,
          _proposerMemberIdMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at_hlc')) {
      context.handle(
        _createdAtHlcMeta,
        createdAtHlc.isAcceptableOrUnknown(
          data['created_at_hlc']!,
          _createdAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtHlcMeta);
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    if (data.containsKey('status_hlc')) {
      context.handle(
        _statusHlcMeta,
        statusHlc.isAcceptableOrUnknown(data['status_hlc']!, _statusHlcMeta),
      );
    }
    if (data.containsKey('status_device_id')) {
      context.handle(
        _statusDeviceIdMeta,
        statusDeviceId.isAcceptableOrUnknown(
          data['status_device_id']!,
          _statusDeviceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {proposalId};
  @override
  RemovalProposalsSyncData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RemovalProposalsSyncData(
      proposalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proposal_id'],
      )!,
      houseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}house_id'],
      )!,
      targetMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_member_id'],
      )!,
      proposerMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proposer_member_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}created_at_hlc'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      statusHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}status_hlc'],
      ),
      statusDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_device_id'],
      ),
    );
  }

  @override
  $RemovalProposalsSyncTable createAlias(String alias) {
    return $RemovalProposalsSyncTable(attachedDatabase, alias);
  }
}

class RemovalProposalsSyncData extends DataClass
    implements Insertable<RemovalProposalsSyncData> {
  final String proposalId;
  final String houseId;
  final String targetMemberId;
  final String? proposerMemberId;
  final String type;
  final String status;
  final Uint8List createdAtHlc;
  final Uint8List updatedAtHlc;
  final Uint8List? statusHlc;
  final String? statusDeviceId;
  const RemovalProposalsSyncData({
    required this.proposalId,
    required this.houseId,
    required this.targetMemberId,
    this.proposerMemberId,
    required this.type,
    required this.status,
    required this.createdAtHlc,
    required this.updatedAtHlc,
    this.statusHlc,
    this.statusDeviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['proposal_id'] = Variable<String>(proposalId);
    map['house_id'] = Variable<String>(houseId);
    map['target_member_id'] = Variable<String>(targetMemberId);
    if (!nullToAbsent || proposerMemberId != null) {
      map['proposer_member_id'] = Variable<String>(proposerMemberId);
    }
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    map['created_at_hlc'] = Variable<Uint8List>(createdAtHlc);
    map['updated_at_hlc'] = Variable<Uint8List>(updatedAtHlc);
    if (!nullToAbsent || statusHlc != null) {
      map['status_hlc'] = Variable<Uint8List>(statusHlc);
    }
    if (!nullToAbsent || statusDeviceId != null) {
      map['status_device_id'] = Variable<String>(statusDeviceId);
    }
    return map;
  }

  RemovalProposalsSyncCompanion toCompanion(bool nullToAbsent) {
    return RemovalProposalsSyncCompanion(
      proposalId: Value(proposalId),
      houseId: Value(houseId),
      targetMemberId: Value(targetMemberId),
      proposerMemberId: proposerMemberId == null && nullToAbsent
          ? const Value.absent()
          : Value(proposerMemberId),
      type: Value(type),
      status: Value(status),
      createdAtHlc: Value(createdAtHlc),
      updatedAtHlc: Value(updatedAtHlc),
      statusHlc: statusHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(statusHlc),
      statusDeviceId: statusDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(statusDeviceId),
    );
  }

  factory RemovalProposalsSyncData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RemovalProposalsSyncData(
      proposalId: serializer.fromJson<String>(json['proposalId']),
      houseId: serializer.fromJson<String>(json['houseId']),
      targetMemberId: serializer.fromJson<String>(json['targetMemberId']),
      proposerMemberId: serializer.fromJson<String?>(json['proposerMemberId']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      createdAtHlc: serializer.fromJson<Uint8List>(json['createdAtHlc']),
      updatedAtHlc: serializer.fromJson<Uint8List>(json['updatedAtHlc']),
      statusHlc: serializer.fromJson<Uint8List?>(json['statusHlc']),
      statusDeviceId: serializer.fromJson<String?>(json['statusDeviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'proposalId': serializer.toJson<String>(proposalId),
      'houseId': serializer.toJson<String>(houseId),
      'targetMemberId': serializer.toJson<String>(targetMemberId),
      'proposerMemberId': serializer.toJson<String?>(proposerMemberId),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'createdAtHlc': serializer.toJson<Uint8List>(createdAtHlc),
      'updatedAtHlc': serializer.toJson<Uint8List>(updatedAtHlc),
      'statusHlc': serializer.toJson<Uint8List?>(statusHlc),
      'statusDeviceId': serializer.toJson<String?>(statusDeviceId),
    };
  }

  RemovalProposalsSyncData copyWith({
    String? proposalId,
    String? houseId,
    String? targetMemberId,
    Value<String?> proposerMemberId = const Value.absent(),
    String? type,
    String? status,
    Uint8List? createdAtHlc,
    Uint8List? updatedAtHlc,
    Value<Uint8List?> statusHlc = const Value.absent(),
    Value<String?> statusDeviceId = const Value.absent(),
  }) => RemovalProposalsSyncData(
    proposalId: proposalId ?? this.proposalId,
    houseId: houseId ?? this.houseId,
    targetMemberId: targetMemberId ?? this.targetMemberId,
    proposerMemberId: proposerMemberId.present
        ? proposerMemberId.value
        : this.proposerMemberId,
    type: type ?? this.type,
    status: status ?? this.status,
    createdAtHlc: createdAtHlc ?? this.createdAtHlc,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    statusHlc: statusHlc.present ? statusHlc.value : this.statusHlc,
    statusDeviceId: statusDeviceId.present
        ? statusDeviceId.value
        : this.statusDeviceId,
  );
  RemovalProposalsSyncData copyWithCompanion(
    RemovalProposalsSyncCompanion data,
  ) {
    return RemovalProposalsSyncData(
      proposalId: data.proposalId.present
          ? data.proposalId.value
          : this.proposalId,
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      targetMemberId: data.targetMemberId.present
          ? data.targetMemberId.value
          : this.targetMemberId,
      proposerMemberId: data.proposerMemberId.present
          ? data.proposerMemberId.value
          : this.proposerMemberId,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      createdAtHlc: data.createdAtHlc.present
          ? data.createdAtHlc.value
          : this.createdAtHlc,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      statusHlc: data.statusHlc.present ? data.statusHlc.value : this.statusHlc,
      statusDeviceId: data.statusDeviceId.present
          ? data.statusDeviceId.value
          : this.statusDeviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RemovalProposalsSyncData(')
          ..write('proposalId: $proposalId, ')
          ..write('houseId: $houseId, ')
          ..write('targetMemberId: $targetMemberId, ')
          ..write('proposerMemberId: $proposerMemberId, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('createdAtHlc: $createdAtHlc, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('statusHlc: $statusHlc, ')
          ..write('statusDeviceId: $statusDeviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    proposalId,
    houseId,
    targetMemberId,
    proposerMemberId,
    type,
    status,
    $driftBlobEquality.hash(createdAtHlc),
    $driftBlobEquality.hash(updatedAtHlc),
    $driftBlobEquality.hash(statusHlc),
    statusDeviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RemovalProposalsSyncData &&
          other.proposalId == this.proposalId &&
          other.houseId == this.houseId &&
          other.targetMemberId == this.targetMemberId &&
          other.proposerMemberId == this.proposerMemberId &&
          other.type == this.type &&
          other.status == this.status &&
          $driftBlobEquality.equals(other.createdAtHlc, this.createdAtHlc) &&
          $driftBlobEquality.equals(other.updatedAtHlc, this.updatedAtHlc) &&
          $driftBlobEquality.equals(other.statusHlc, this.statusHlc) &&
          other.statusDeviceId == this.statusDeviceId);
}

class RemovalProposalsSyncCompanion
    extends UpdateCompanion<RemovalProposalsSyncData> {
  final Value<String> proposalId;
  final Value<String> houseId;
  final Value<String> targetMemberId;
  final Value<String?> proposerMemberId;
  final Value<String> type;
  final Value<String> status;
  final Value<Uint8List> createdAtHlc;
  final Value<Uint8List> updatedAtHlc;
  final Value<Uint8List?> statusHlc;
  final Value<String?> statusDeviceId;
  final Value<int> rowid;
  const RemovalProposalsSyncCompanion({
    this.proposalId = const Value.absent(),
    this.houseId = const Value.absent(),
    this.targetMemberId = const Value.absent(),
    this.proposerMemberId = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAtHlc = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.statusHlc = const Value.absent(),
    this.statusDeviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemovalProposalsSyncCompanion.insert({
    required String proposalId,
    required String houseId,
    required String targetMemberId,
    this.proposerMemberId = const Value.absent(),
    required String type,
    required String status,
    required Uint8List createdAtHlc,
    required Uint8List updatedAtHlc,
    this.statusHlc = const Value.absent(),
    this.statusDeviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : proposalId = Value(proposalId),
       houseId = Value(houseId),
       targetMemberId = Value(targetMemberId),
       type = Value(type),
       status = Value(status),
       createdAtHlc = Value(createdAtHlc),
       updatedAtHlc = Value(updatedAtHlc);
  static Insertable<RemovalProposalsSyncData> custom({
    Expression<String>? proposalId,
    Expression<String>? houseId,
    Expression<String>? targetMemberId,
    Expression<String>? proposerMemberId,
    Expression<String>? type,
    Expression<String>? status,
    Expression<Uint8List>? createdAtHlc,
    Expression<Uint8List>? updatedAtHlc,
    Expression<Uint8List>? statusHlc,
    Expression<String>? statusDeviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (proposalId != null) 'proposal_id': proposalId,
      if (houseId != null) 'house_id': houseId,
      if (targetMemberId != null) 'target_member_id': targetMemberId,
      if (proposerMemberId != null) 'proposer_member_id': proposerMemberId,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (createdAtHlc != null) 'created_at_hlc': createdAtHlc,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (statusHlc != null) 'status_hlc': statusHlc,
      if (statusDeviceId != null) 'status_device_id': statusDeviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemovalProposalsSyncCompanion copyWith({
    Value<String>? proposalId,
    Value<String>? houseId,
    Value<String>? targetMemberId,
    Value<String?>? proposerMemberId,
    Value<String>? type,
    Value<String>? status,
    Value<Uint8List>? createdAtHlc,
    Value<Uint8List>? updatedAtHlc,
    Value<Uint8List?>? statusHlc,
    Value<String?>? statusDeviceId,
    Value<int>? rowid,
  }) {
    return RemovalProposalsSyncCompanion(
      proposalId: proposalId ?? this.proposalId,
      houseId: houseId ?? this.houseId,
      targetMemberId: targetMemberId ?? this.targetMemberId,
      proposerMemberId: proposerMemberId ?? this.proposerMemberId,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAtHlc: createdAtHlc ?? this.createdAtHlc,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      statusHlc: statusHlc ?? this.statusHlc,
      statusDeviceId: statusDeviceId ?? this.statusDeviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (proposalId.present) {
      map['proposal_id'] = Variable<String>(proposalId.value);
    }
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (targetMemberId.present) {
      map['target_member_id'] = Variable<String>(targetMemberId.value);
    }
    if (proposerMemberId.present) {
      map['proposer_member_id'] = Variable<String>(proposerMemberId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAtHlc.present) {
      map['created_at_hlc'] = Variable<Uint8List>(createdAtHlc.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<Uint8List>(updatedAtHlc.value);
    }
    if (statusHlc.present) {
      map['status_hlc'] = Variable<Uint8List>(statusHlc.value);
    }
    if (statusDeviceId.present) {
      map['status_device_id'] = Variable<String>(statusDeviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemovalProposalsSyncCompanion(')
          ..write('proposalId: $proposalId, ')
          ..write('houseId: $houseId, ')
          ..write('targetMemberId: $targetMemberId, ')
          ..write('proposerMemberId: $proposerMemberId, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('createdAtHlc: $createdAtHlc, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('statusHlc: $statusHlc, ')
          ..write('statusDeviceId: $statusDeviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProposalVotesSyncTable extends ProposalVotesSync
    with TableInfo<$ProposalVotesSyncTable, ProposalVotesSyncData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProposalVotesSyncTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _voteIdMeta = const VerificationMeta('voteId');
  @override
  late final GeneratedColumn<String> voteId = GeneratedColumn<String>(
    'vote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _houseIdMeta = const VerificationMeta(
    'houseId',
  );
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
    'house_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proposalIdMeta = const VerificationMeta(
    'proposalId',
  );
  @override
  late final GeneratedColumn<String> proposalId = GeneratedColumn<String>(
    'proposal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _voterMemberIdMeta = const VerificationMeta(
    'voterMemberId',
  );
  @override
  late final GeneratedColumn<String> voterMemberId = GeneratedColumn<String>(
    'voter_member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _voteCastMeta = const VerificationMeta(
    'voteCast',
  );
  @override
  late final GeneratedColumn<int> voteCast = GeneratedColumn<int>(
    'vote_cast',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<Uint8List> hlc = GeneratedColumn<Uint8List>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    voteId,
    houseId,
    proposalId,
    voterMemberId,
    voteCast,
    hlc,
    originDeviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'proposal_votes_sync';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProposalVotesSyncData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('vote_id')) {
      context.handle(
        _voteIdMeta,
        voteId.isAcceptableOrUnknown(data['vote_id']!, _voteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_voteIdMeta);
    }
    if (data.containsKey('house_id')) {
      context.handle(
        _houseIdMeta,
        houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('proposal_id')) {
      context.handle(
        _proposalIdMeta,
        proposalId.isAcceptableOrUnknown(data['proposal_id']!, _proposalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_proposalIdMeta);
    }
    if (data.containsKey('voter_member_id')) {
      context.handle(
        _voterMemberIdMeta,
        voterMemberId.isAcceptableOrUnknown(
          data['voter_member_id']!,
          _voterMemberIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_voterMemberIdMeta);
    }
    if (data.containsKey('vote_cast')) {
      context.handle(
        _voteCastMeta,
        voteCast.isAcceptableOrUnknown(data['vote_cast']!, _voteCastMeta),
      );
    } else if (isInserting) {
      context.missing(_voteCastMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {voteId};
  @override
  ProposalVotesSyncData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProposalVotesSyncData(
      voteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vote_id'],
      )!,
      houseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}house_id'],
      )!,
      proposalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proposal_id'],
      )!,
      voterMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voter_member_id'],
      )!,
      voteCast: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vote_cast'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}hlc'],
      )!,
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      ),
    );
  }

  @override
  $ProposalVotesSyncTable createAlias(String alias) {
    return $ProposalVotesSyncTable(attachedDatabase, alias);
  }
}

class ProposalVotesSyncData extends DataClass
    implements Insertable<ProposalVotesSyncData> {
  final String voteId;
  final String houseId;
  final String proposalId;
  final String voterMemberId;
  final int voteCast;
  final Uint8List hlc;
  final String? originDeviceId;
  const ProposalVotesSyncData({
    required this.voteId,
    required this.houseId,
    required this.proposalId,
    required this.voterMemberId,
    required this.voteCast,
    required this.hlc,
    this.originDeviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['vote_id'] = Variable<String>(voteId);
    map['house_id'] = Variable<String>(houseId);
    map['proposal_id'] = Variable<String>(proposalId);
    map['voter_member_id'] = Variable<String>(voterMemberId);
    map['vote_cast'] = Variable<int>(voteCast);
    map['hlc'] = Variable<Uint8List>(hlc);
    if (!nullToAbsent || originDeviceId != null) {
      map['origin_device_id'] = Variable<String>(originDeviceId);
    }
    return map;
  }

  ProposalVotesSyncCompanion toCompanion(bool nullToAbsent) {
    return ProposalVotesSyncCompanion(
      voteId: Value(voteId),
      houseId: Value(houseId),
      proposalId: Value(proposalId),
      voterMemberId: Value(voterMemberId),
      voteCast: Value(voteCast),
      hlc: Value(hlc),
      originDeviceId: originDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(originDeviceId),
    );
  }

  factory ProposalVotesSyncData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProposalVotesSyncData(
      voteId: serializer.fromJson<String>(json['voteId']),
      houseId: serializer.fromJson<String>(json['houseId']),
      proposalId: serializer.fromJson<String>(json['proposalId']),
      voterMemberId: serializer.fromJson<String>(json['voterMemberId']),
      voteCast: serializer.fromJson<int>(json['voteCast']),
      hlc: serializer.fromJson<Uint8List>(json['hlc']),
      originDeviceId: serializer.fromJson<String?>(json['originDeviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'voteId': serializer.toJson<String>(voteId),
      'houseId': serializer.toJson<String>(houseId),
      'proposalId': serializer.toJson<String>(proposalId),
      'voterMemberId': serializer.toJson<String>(voterMemberId),
      'voteCast': serializer.toJson<int>(voteCast),
      'hlc': serializer.toJson<Uint8List>(hlc),
      'originDeviceId': serializer.toJson<String?>(originDeviceId),
    };
  }

  ProposalVotesSyncData copyWith({
    String? voteId,
    String? houseId,
    String? proposalId,
    String? voterMemberId,
    int? voteCast,
    Uint8List? hlc,
    Value<String?> originDeviceId = const Value.absent(),
  }) => ProposalVotesSyncData(
    voteId: voteId ?? this.voteId,
    houseId: houseId ?? this.houseId,
    proposalId: proposalId ?? this.proposalId,
    voterMemberId: voterMemberId ?? this.voterMemberId,
    voteCast: voteCast ?? this.voteCast,
    hlc: hlc ?? this.hlc,
    originDeviceId: originDeviceId.present
        ? originDeviceId.value
        : this.originDeviceId,
  );
  ProposalVotesSyncData copyWithCompanion(ProposalVotesSyncCompanion data) {
    return ProposalVotesSyncData(
      voteId: data.voteId.present ? data.voteId.value : this.voteId,
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      proposalId: data.proposalId.present
          ? data.proposalId.value
          : this.proposalId,
      voterMemberId: data.voterMemberId.present
          ? data.voterMemberId.value
          : this.voterMemberId,
      voteCast: data.voteCast.present ? data.voteCast.value : this.voteCast,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProposalVotesSyncData(')
          ..write('voteId: $voteId, ')
          ..write('houseId: $houseId, ')
          ..write('proposalId: $proposalId, ')
          ..write('voterMemberId: $voterMemberId, ')
          ..write('voteCast: $voteCast, ')
          ..write('hlc: $hlc, ')
          ..write('originDeviceId: $originDeviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    voteId,
    houseId,
    proposalId,
    voterMemberId,
    voteCast,
    $driftBlobEquality.hash(hlc),
    originDeviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProposalVotesSyncData &&
          other.voteId == this.voteId &&
          other.houseId == this.houseId &&
          other.proposalId == this.proposalId &&
          other.voterMemberId == this.voterMemberId &&
          other.voteCast == this.voteCast &&
          $driftBlobEquality.equals(other.hlc, this.hlc) &&
          other.originDeviceId == this.originDeviceId);
}

class ProposalVotesSyncCompanion
    extends UpdateCompanion<ProposalVotesSyncData> {
  final Value<String> voteId;
  final Value<String> houseId;
  final Value<String> proposalId;
  final Value<String> voterMemberId;
  final Value<int> voteCast;
  final Value<Uint8List> hlc;
  final Value<String?> originDeviceId;
  final Value<int> rowid;
  const ProposalVotesSyncCompanion({
    this.voteId = const Value.absent(),
    this.houseId = const Value.absent(),
    this.proposalId = const Value.absent(),
    this.voterMemberId = const Value.absent(),
    this.voteCast = const Value.absent(),
    this.hlc = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProposalVotesSyncCompanion.insert({
    required String voteId,
    required String houseId,
    required String proposalId,
    required String voterMemberId,
    required int voteCast,
    required Uint8List hlc,
    this.originDeviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : voteId = Value(voteId),
       houseId = Value(houseId),
       proposalId = Value(proposalId),
       voterMemberId = Value(voterMemberId),
       voteCast = Value(voteCast),
       hlc = Value(hlc);
  static Insertable<ProposalVotesSyncData> custom({
    Expression<String>? voteId,
    Expression<String>? houseId,
    Expression<String>? proposalId,
    Expression<String>? voterMemberId,
    Expression<int>? voteCast,
    Expression<Uint8List>? hlc,
    Expression<String>? originDeviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (voteId != null) 'vote_id': voteId,
      if (houseId != null) 'house_id': houseId,
      if (proposalId != null) 'proposal_id': proposalId,
      if (voterMemberId != null) 'voter_member_id': voterMemberId,
      if (voteCast != null) 'vote_cast': voteCast,
      if (hlc != null) 'hlc': hlc,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProposalVotesSyncCompanion copyWith({
    Value<String>? voteId,
    Value<String>? houseId,
    Value<String>? proposalId,
    Value<String>? voterMemberId,
    Value<int>? voteCast,
    Value<Uint8List>? hlc,
    Value<String?>? originDeviceId,
    Value<int>? rowid,
  }) {
    return ProposalVotesSyncCompanion(
      voteId: voteId ?? this.voteId,
      houseId: houseId ?? this.houseId,
      proposalId: proposalId ?? this.proposalId,
      voterMemberId: voterMemberId ?? this.voterMemberId,
      voteCast: voteCast ?? this.voteCast,
      hlc: hlc ?? this.hlc,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (voteId.present) {
      map['vote_id'] = Variable<String>(voteId.value);
    }
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (proposalId.present) {
      map['proposal_id'] = Variable<String>(proposalId.value);
    }
    if (voterMemberId.present) {
      map['voter_member_id'] = Variable<String>(voterMemberId.value);
    }
    if (voteCast.present) {
      map['vote_cast'] = Variable<int>(voteCast.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<Uint8List>(hlc.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProposalVotesSyncCompanion(')
          ..write('voteId: $voteId, ')
          ..write('houseId: $houseId, ')
          ..write('proposalId: $proposalId, ')
          ..write('voterMemberId: $voterMemberId, ')
          ..write('voteCast: $voteCast, ')
          ..write('hlc: $hlc, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CyclesSyncTable extends CyclesSync
    with TableInfo<$CyclesSyncTable, CyclesSyncData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CyclesSyncTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cycleIdMeta = const VerificationMeta(
    'cycleId',
  );
  @override
  late final GeneratedColumn<String> cycleId = GeneratedColumn<String>(
    'cycle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _houseIdMeta = const VerificationMeta(
    'houseId',
  );
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
    'house_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeGuardianMemberIdMeta =
      const VerificationMeta('activeGuardianMemberId');
  @override
  late final GeneratedColumn<String> activeGuardianMemberId =
      GeneratedColumn<String>(
        'active_guardian_member_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ceremonySignoffsMeta = const VerificationMeta(
    'ceremonySignoffs',
  );
  @override
  late final GeneratedColumn<String> ceremonySignoffs = GeneratedColumn<String>(
    'ceremony_signoffs',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _rulesVersionAtSignoffMeta =
      const VerificationMeta('rulesVersionAtSignoff');
  @override
  late final GeneratedColumn<int> rulesVersionAtSignoff = GeneratedColumn<int>(
    'rules_version_at_signoff',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<Uint8List> updatedAtHlc =
      GeneratedColumn<Uint8List>(
        'updated_at_hlc',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusHlcMeta = const VerificationMeta(
    'statusHlc',
  );
  @override
  late final GeneratedColumn<Uint8List> statusHlc = GeneratedColumn<Uint8List>(
    'status_hlc',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusDeviceIdMeta = const VerificationMeta(
    'statusDeviceId',
  );
  @override
  late final GeneratedColumn<String> statusDeviceId = GeneratedColumn<String>(
    'status_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _guardianHlcMeta = const VerificationMeta(
    'guardianHlc',
  );
  @override
  late final GeneratedColumn<Uint8List> guardianHlc =
      GeneratedColumn<Uint8List>(
        'guardian_hlc',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _guardianDeviceIdMeta = const VerificationMeta(
    'guardianDeviceId',
  );
  @override
  late final GeneratedColumn<String> guardianDeviceId = GeneratedColumn<String>(
    'guardian_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rulesVersionAtSignoffHlcMeta =
      const VerificationMeta('rulesVersionAtSignoffHlc');
  @override
  late final GeneratedColumn<Uint8List> rulesVersionAtSignoffHlc =
      GeneratedColumn<Uint8List>(
        'rules_version_at_signoff_hlc',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _rulesVersionAtSignoffDeviceIdMeta =
      const VerificationMeta('rulesVersionAtSignoffDeviceId');
  @override
  late final GeneratedColumn<String> rulesVersionAtSignoffDeviceId =
      GeneratedColumn<String>(
        'rules_version_at_signoff_device_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    cycleId,
    houseId,
    activeGuardianMemberId,
    status,
    ceremonySignoffs,
    rulesVersionAtSignoff,
    updatedAtHlc,
    statusHlc,
    statusDeviceId,
    guardianHlc,
    guardianDeviceId,
    rulesVersionAtSignoffHlc,
    rulesVersionAtSignoffDeviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cycles_sync';
  @override
  VerificationContext validateIntegrity(
    Insertable<CyclesSyncData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cycle_id')) {
      context.handle(
        _cycleIdMeta,
        cycleId.isAcceptableOrUnknown(data['cycle_id']!, _cycleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleIdMeta);
    }
    if (data.containsKey('house_id')) {
      context.handle(
        _houseIdMeta,
        houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('active_guardian_member_id')) {
      context.handle(
        _activeGuardianMemberIdMeta,
        activeGuardianMemberId.isAcceptableOrUnknown(
          data['active_guardian_member_id']!,
          _activeGuardianMemberIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activeGuardianMemberIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('ceremony_signoffs')) {
      context.handle(
        _ceremonySignoffsMeta,
        ceremonySignoffs.isAcceptableOrUnknown(
          data['ceremony_signoffs']!,
          _ceremonySignoffsMeta,
        ),
      );
    }
    if (data.containsKey('rules_version_at_signoff')) {
      context.handle(
        _rulesVersionAtSignoffMeta,
        rulesVersionAtSignoff.isAcceptableOrUnknown(
          data['rules_version_at_signoff']!,
          _rulesVersionAtSignoffMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    if (data.containsKey('status_hlc')) {
      context.handle(
        _statusHlcMeta,
        statusHlc.isAcceptableOrUnknown(data['status_hlc']!, _statusHlcMeta),
      );
    }
    if (data.containsKey('status_device_id')) {
      context.handle(
        _statusDeviceIdMeta,
        statusDeviceId.isAcceptableOrUnknown(
          data['status_device_id']!,
          _statusDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('guardian_hlc')) {
      context.handle(
        _guardianHlcMeta,
        guardianHlc.isAcceptableOrUnknown(
          data['guardian_hlc']!,
          _guardianHlcMeta,
        ),
      );
    }
    if (data.containsKey('guardian_device_id')) {
      context.handle(
        _guardianDeviceIdMeta,
        guardianDeviceId.isAcceptableOrUnknown(
          data['guardian_device_id']!,
          _guardianDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('rules_version_at_signoff_hlc')) {
      context.handle(
        _rulesVersionAtSignoffHlcMeta,
        rulesVersionAtSignoffHlc.isAcceptableOrUnknown(
          data['rules_version_at_signoff_hlc']!,
          _rulesVersionAtSignoffHlcMeta,
        ),
      );
    }
    if (data.containsKey('rules_version_at_signoff_device_id')) {
      context.handle(
        _rulesVersionAtSignoffDeviceIdMeta,
        rulesVersionAtSignoffDeviceId.isAcceptableOrUnknown(
          data['rules_version_at_signoff_device_id']!,
          _rulesVersionAtSignoffDeviceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cycleId};
  @override
  CyclesSyncData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CyclesSyncData(
      cycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cycle_id'],
      )!,
      houseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}house_id'],
      )!,
      activeGuardianMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_guardian_member_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      ceremonySignoffs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ceremony_signoffs'],
      )!,
      rulesVersionAtSignoff: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rules_version_at_signoff'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      statusHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}status_hlc'],
      ),
      statusDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_device_id'],
      ),
      guardianHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}guardian_hlc'],
      ),
      guardianDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guardian_device_id'],
      ),
      rulesVersionAtSignoffHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}rules_version_at_signoff_hlc'],
      ),
      rulesVersionAtSignoffDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rules_version_at_signoff_device_id'],
      ),
    );
  }

  @override
  $CyclesSyncTable createAlias(String alias) {
    return $CyclesSyncTable(attachedDatabase, alias);
  }
}

class CyclesSyncData extends DataClass implements Insertable<CyclesSyncData> {
  final String cycleId;
  final String houseId;
  final String activeGuardianMemberId;
  final String status;
  final String ceremonySignoffs;
  final int rulesVersionAtSignoff;
  final Uint8List updatedAtHlc;
  final Uint8List? statusHlc;
  final String? statusDeviceId;
  final Uint8List? guardianHlc;
  final String? guardianDeviceId;
  final Uint8List? rulesVersionAtSignoffHlc;
  final String? rulesVersionAtSignoffDeviceId;
  const CyclesSyncData({
    required this.cycleId,
    required this.houseId,
    required this.activeGuardianMemberId,
    required this.status,
    required this.ceremonySignoffs,
    required this.rulesVersionAtSignoff,
    required this.updatedAtHlc,
    this.statusHlc,
    this.statusDeviceId,
    this.guardianHlc,
    this.guardianDeviceId,
    this.rulesVersionAtSignoffHlc,
    this.rulesVersionAtSignoffDeviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cycle_id'] = Variable<String>(cycleId);
    map['house_id'] = Variable<String>(houseId);
    map['active_guardian_member_id'] = Variable<String>(activeGuardianMemberId);
    map['status'] = Variable<String>(status);
    map['ceremony_signoffs'] = Variable<String>(ceremonySignoffs);
    map['rules_version_at_signoff'] = Variable<int>(rulesVersionAtSignoff);
    map['updated_at_hlc'] = Variable<Uint8List>(updatedAtHlc);
    if (!nullToAbsent || statusHlc != null) {
      map['status_hlc'] = Variable<Uint8List>(statusHlc);
    }
    if (!nullToAbsent || statusDeviceId != null) {
      map['status_device_id'] = Variable<String>(statusDeviceId);
    }
    if (!nullToAbsent || guardianHlc != null) {
      map['guardian_hlc'] = Variable<Uint8List>(guardianHlc);
    }
    if (!nullToAbsent || guardianDeviceId != null) {
      map['guardian_device_id'] = Variable<String>(guardianDeviceId);
    }
    if (!nullToAbsent || rulesVersionAtSignoffHlc != null) {
      map['rules_version_at_signoff_hlc'] = Variable<Uint8List>(
        rulesVersionAtSignoffHlc,
      );
    }
    if (!nullToAbsent || rulesVersionAtSignoffDeviceId != null) {
      map['rules_version_at_signoff_device_id'] = Variable<String>(
        rulesVersionAtSignoffDeviceId,
      );
    }
    return map;
  }

  CyclesSyncCompanion toCompanion(bool nullToAbsent) {
    return CyclesSyncCompanion(
      cycleId: Value(cycleId),
      houseId: Value(houseId),
      activeGuardianMemberId: Value(activeGuardianMemberId),
      status: Value(status),
      ceremonySignoffs: Value(ceremonySignoffs),
      rulesVersionAtSignoff: Value(rulesVersionAtSignoff),
      updatedAtHlc: Value(updatedAtHlc),
      statusHlc: statusHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(statusHlc),
      statusDeviceId: statusDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(statusDeviceId),
      guardianHlc: guardianHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(guardianHlc),
      guardianDeviceId: guardianDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(guardianDeviceId),
      rulesVersionAtSignoffHlc: rulesVersionAtSignoffHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(rulesVersionAtSignoffHlc),
      rulesVersionAtSignoffDeviceId:
          rulesVersionAtSignoffDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(rulesVersionAtSignoffDeviceId),
    );
  }

  factory CyclesSyncData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CyclesSyncData(
      cycleId: serializer.fromJson<String>(json['cycleId']),
      houseId: serializer.fromJson<String>(json['houseId']),
      activeGuardianMemberId: serializer.fromJson<String>(
        json['activeGuardianMemberId'],
      ),
      status: serializer.fromJson<String>(json['status']),
      ceremonySignoffs: serializer.fromJson<String>(json['ceremonySignoffs']),
      rulesVersionAtSignoff: serializer.fromJson<int>(
        json['rulesVersionAtSignoff'],
      ),
      updatedAtHlc: serializer.fromJson<Uint8List>(json['updatedAtHlc']),
      statusHlc: serializer.fromJson<Uint8List?>(json['statusHlc']),
      statusDeviceId: serializer.fromJson<String?>(json['statusDeviceId']),
      guardianHlc: serializer.fromJson<Uint8List?>(json['guardianHlc']),
      guardianDeviceId: serializer.fromJson<String?>(json['guardianDeviceId']),
      rulesVersionAtSignoffHlc: serializer.fromJson<Uint8List?>(
        json['rulesVersionAtSignoffHlc'],
      ),
      rulesVersionAtSignoffDeviceId: serializer.fromJson<String?>(
        json['rulesVersionAtSignoffDeviceId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cycleId': serializer.toJson<String>(cycleId),
      'houseId': serializer.toJson<String>(houseId),
      'activeGuardianMemberId': serializer.toJson<String>(
        activeGuardianMemberId,
      ),
      'status': serializer.toJson<String>(status),
      'ceremonySignoffs': serializer.toJson<String>(ceremonySignoffs),
      'rulesVersionAtSignoff': serializer.toJson<int>(rulesVersionAtSignoff),
      'updatedAtHlc': serializer.toJson<Uint8List>(updatedAtHlc),
      'statusHlc': serializer.toJson<Uint8List?>(statusHlc),
      'statusDeviceId': serializer.toJson<String?>(statusDeviceId),
      'guardianHlc': serializer.toJson<Uint8List?>(guardianHlc),
      'guardianDeviceId': serializer.toJson<String?>(guardianDeviceId),
      'rulesVersionAtSignoffHlc': serializer.toJson<Uint8List?>(
        rulesVersionAtSignoffHlc,
      ),
      'rulesVersionAtSignoffDeviceId': serializer.toJson<String?>(
        rulesVersionAtSignoffDeviceId,
      ),
    };
  }

  CyclesSyncData copyWith({
    String? cycleId,
    String? houseId,
    String? activeGuardianMemberId,
    String? status,
    String? ceremonySignoffs,
    int? rulesVersionAtSignoff,
    Uint8List? updatedAtHlc,
    Value<Uint8List?> statusHlc = const Value.absent(),
    Value<String?> statusDeviceId = const Value.absent(),
    Value<Uint8List?> guardianHlc = const Value.absent(),
    Value<String?> guardianDeviceId = const Value.absent(),
    Value<Uint8List?> rulesVersionAtSignoffHlc = const Value.absent(),
    Value<String?> rulesVersionAtSignoffDeviceId = const Value.absent(),
  }) => CyclesSyncData(
    cycleId: cycleId ?? this.cycleId,
    houseId: houseId ?? this.houseId,
    activeGuardianMemberId:
        activeGuardianMemberId ?? this.activeGuardianMemberId,
    status: status ?? this.status,
    ceremonySignoffs: ceremonySignoffs ?? this.ceremonySignoffs,
    rulesVersionAtSignoff: rulesVersionAtSignoff ?? this.rulesVersionAtSignoff,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    statusHlc: statusHlc.present ? statusHlc.value : this.statusHlc,
    statusDeviceId: statusDeviceId.present
        ? statusDeviceId.value
        : this.statusDeviceId,
    guardianHlc: guardianHlc.present ? guardianHlc.value : this.guardianHlc,
    guardianDeviceId: guardianDeviceId.present
        ? guardianDeviceId.value
        : this.guardianDeviceId,
    rulesVersionAtSignoffHlc: rulesVersionAtSignoffHlc.present
        ? rulesVersionAtSignoffHlc.value
        : this.rulesVersionAtSignoffHlc,
    rulesVersionAtSignoffDeviceId: rulesVersionAtSignoffDeviceId.present
        ? rulesVersionAtSignoffDeviceId.value
        : this.rulesVersionAtSignoffDeviceId,
  );
  CyclesSyncData copyWithCompanion(CyclesSyncCompanion data) {
    return CyclesSyncData(
      cycleId: data.cycleId.present ? data.cycleId.value : this.cycleId,
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      activeGuardianMemberId: data.activeGuardianMemberId.present
          ? data.activeGuardianMemberId.value
          : this.activeGuardianMemberId,
      status: data.status.present ? data.status.value : this.status,
      ceremonySignoffs: data.ceremonySignoffs.present
          ? data.ceremonySignoffs.value
          : this.ceremonySignoffs,
      rulesVersionAtSignoff: data.rulesVersionAtSignoff.present
          ? data.rulesVersionAtSignoff.value
          : this.rulesVersionAtSignoff,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      statusHlc: data.statusHlc.present ? data.statusHlc.value : this.statusHlc,
      statusDeviceId: data.statusDeviceId.present
          ? data.statusDeviceId.value
          : this.statusDeviceId,
      guardianHlc: data.guardianHlc.present
          ? data.guardianHlc.value
          : this.guardianHlc,
      guardianDeviceId: data.guardianDeviceId.present
          ? data.guardianDeviceId.value
          : this.guardianDeviceId,
      rulesVersionAtSignoffHlc: data.rulesVersionAtSignoffHlc.present
          ? data.rulesVersionAtSignoffHlc.value
          : this.rulesVersionAtSignoffHlc,
      rulesVersionAtSignoffDeviceId: data.rulesVersionAtSignoffDeviceId.present
          ? data.rulesVersionAtSignoffDeviceId.value
          : this.rulesVersionAtSignoffDeviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CyclesSyncData(')
          ..write('cycleId: $cycleId, ')
          ..write('houseId: $houseId, ')
          ..write('activeGuardianMemberId: $activeGuardianMemberId, ')
          ..write('status: $status, ')
          ..write('ceremonySignoffs: $ceremonySignoffs, ')
          ..write('rulesVersionAtSignoff: $rulesVersionAtSignoff, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('statusHlc: $statusHlc, ')
          ..write('statusDeviceId: $statusDeviceId, ')
          ..write('guardianHlc: $guardianHlc, ')
          ..write('guardianDeviceId: $guardianDeviceId, ')
          ..write('rulesVersionAtSignoffHlc: $rulesVersionAtSignoffHlc, ')
          ..write(
            'rulesVersionAtSignoffDeviceId: $rulesVersionAtSignoffDeviceId',
          )
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    cycleId,
    houseId,
    activeGuardianMemberId,
    status,
    ceremonySignoffs,
    rulesVersionAtSignoff,
    $driftBlobEquality.hash(updatedAtHlc),
    $driftBlobEquality.hash(statusHlc),
    statusDeviceId,
    $driftBlobEquality.hash(guardianHlc),
    guardianDeviceId,
    $driftBlobEquality.hash(rulesVersionAtSignoffHlc),
    rulesVersionAtSignoffDeviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CyclesSyncData &&
          other.cycleId == this.cycleId &&
          other.houseId == this.houseId &&
          other.activeGuardianMemberId == this.activeGuardianMemberId &&
          other.status == this.status &&
          other.ceremonySignoffs == this.ceremonySignoffs &&
          other.rulesVersionAtSignoff == this.rulesVersionAtSignoff &&
          $driftBlobEquality.equals(other.updatedAtHlc, this.updatedAtHlc) &&
          $driftBlobEquality.equals(other.statusHlc, this.statusHlc) &&
          other.statusDeviceId == this.statusDeviceId &&
          $driftBlobEquality.equals(other.guardianHlc, this.guardianHlc) &&
          other.guardianDeviceId == this.guardianDeviceId &&
          $driftBlobEquality.equals(
            other.rulesVersionAtSignoffHlc,
            this.rulesVersionAtSignoffHlc,
          ) &&
          other.rulesVersionAtSignoffDeviceId ==
              this.rulesVersionAtSignoffDeviceId);
}

class CyclesSyncCompanion extends UpdateCompanion<CyclesSyncData> {
  final Value<String> cycleId;
  final Value<String> houseId;
  final Value<String> activeGuardianMemberId;
  final Value<String> status;
  final Value<String> ceremonySignoffs;
  final Value<int> rulesVersionAtSignoff;
  final Value<Uint8List> updatedAtHlc;
  final Value<Uint8List?> statusHlc;
  final Value<String?> statusDeviceId;
  final Value<Uint8List?> guardianHlc;
  final Value<String?> guardianDeviceId;
  final Value<Uint8List?> rulesVersionAtSignoffHlc;
  final Value<String?> rulesVersionAtSignoffDeviceId;
  final Value<int> rowid;
  const CyclesSyncCompanion({
    this.cycleId = const Value.absent(),
    this.houseId = const Value.absent(),
    this.activeGuardianMemberId = const Value.absent(),
    this.status = const Value.absent(),
    this.ceremonySignoffs = const Value.absent(),
    this.rulesVersionAtSignoff = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.statusHlc = const Value.absent(),
    this.statusDeviceId = const Value.absent(),
    this.guardianHlc = const Value.absent(),
    this.guardianDeviceId = const Value.absent(),
    this.rulesVersionAtSignoffHlc = const Value.absent(),
    this.rulesVersionAtSignoffDeviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CyclesSyncCompanion.insert({
    required String cycleId,
    required String houseId,
    required String activeGuardianMemberId,
    required String status,
    this.ceremonySignoffs = const Value.absent(),
    this.rulesVersionAtSignoff = const Value.absent(),
    required Uint8List updatedAtHlc,
    this.statusHlc = const Value.absent(),
    this.statusDeviceId = const Value.absent(),
    this.guardianHlc = const Value.absent(),
    this.guardianDeviceId = const Value.absent(),
    this.rulesVersionAtSignoffHlc = const Value.absent(),
    this.rulesVersionAtSignoffDeviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cycleId = Value(cycleId),
       houseId = Value(houseId),
       activeGuardianMemberId = Value(activeGuardianMemberId),
       status = Value(status),
       updatedAtHlc = Value(updatedAtHlc);
  static Insertable<CyclesSyncData> custom({
    Expression<String>? cycleId,
    Expression<String>? houseId,
    Expression<String>? activeGuardianMemberId,
    Expression<String>? status,
    Expression<String>? ceremonySignoffs,
    Expression<int>? rulesVersionAtSignoff,
    Expression<Uint8List>? updatedAtHlc,
    Expression<Uint8List>? statusHlc,
    Expression<String>? statusDeviceId,
    Expression<Uint8List>? guardianHlc,
    Expression<String>? guardianDeviceId,
    Expression<Uint8List>? rulesVersionAtSignoffHlc,
    Expression<String>? rulesVersionAtSignoffDeviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cycleId != null) 'cycle_id': cycleId,
      if (houseId != null) 'house_id': houseId,
      if (activeGuardianMemberId != null)
        'active_guardian_member_id': activeGuardianMemberId,
      if (status != null) 'status': status,
      if (ceremonySignoffs != null) 'ceremony_signoffs': ceremonySignoffs,
      if (rulesVersionAtSignoff != null)
        'rules_version_at_signoff': rulesVersionAtSignoff,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (statusHlc != null) 'status_hlc': statusHlc,
      if (statusDeviceId != null) 'status_device_id': statusDeviceId,
      if (guardianHlc != null) 'guardian_hlc': guardianHlc,
      if (guardianDeviceId != null) 'guardian_device_id': guardianDeviceId,
      if (rulesVersionAtSignoffHlc != null)
        'rules_version_at_signoff_hlc': rulesVersionAtSignoffHlc,
      if (rulesVersionAtSignoffDeviceId != null)
        'rules_version_at_signoff_device_id': rulesVersionAtSignoffDeviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CyclesSyncCompanion copyWith({
    Value<String>? cycleId,
    Value<String>? houseId,
    Value<String>? activeGuardianMemberId,
    Value<String>? status,
    Value<String>? ceremonySignoffs,
    Value<int>? rulesVersionAtSignoff,
    Value<Uint8List>? updatedAtHlc,
    Value<Uint8List?>? statusHlc,
    Value<String?>? statusDeviceId,
    Value<Uint8List?>? guardianHlc,
    Value<String?>? guardianDeviceId,
    Value<Uint8List?>? rulesVersionAtSignoffHlc,
    Value<String?>? rulesVersionAtSignoffDeviceId,
    Value<int>? rowid,
  }) {
    return CyclesSyncCompanion(
      cycleId: cycleId ?? this.cycleId,
      houseId: houseId ?? this.houseId,
      activeGuardianMemberId:
          activeGuardianMemberId ?? this.activeGuardianMemberId,
      status: status ?? this.status,
      ceremonySignoffs: ceremonySignoffs ?? this.ceremonySignoffs,
      rulesVersionAtSignoff:
          rulesVersionAtSignoff ?? this.rulesVersionAtSignoff,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      statusHlc: statusHlc ?? this.statusHlc,
      statusDeviceId: statusDeviceId ?? this.statusDeviceId,
      guardianHlc: guardianHlc ?? this.guardianHlc,
      guardianDeviceId: guardianDeviceId ?? this.guardianDeviceId,
      rulesVersionAtSignoffHlc:
          rulesVersionAtSignoffHlc ?? this.rulesVersionAtSignoffHlc,
      rulesVersionAtSignoffDeviceId:
          rulesVersionAtSignoffDeviceId ?? this.rulesVersionAtSignoffDeviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cycleId.present) {
      map['cycle_id'] = Variable<String>(cycleId.value);
    }
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (activeGuardianMemberId.present) {
      map['active_guardian_member_id'] = Variable<String>(
        activeGuardianMemberId.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (ceremonySignoffs.present) {
      map['ceremony_signoffs'] = Variable<String>(ceremonySignoffs.value);
    }
    if (rulesVersionAtSignoff.present) {
      map['rules_version_at_signoff'] = Variable<int>(
        rulesVersionAtSignoff.value,
      );
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<Uint8List>(updatedAtHlc.value);
    }
    if (statusHlc.present) {
      map['status_hlc'] = Variable<Uint8List>(statusHlc.value);
    }
    if (statusDeviceId.present) {
      map['status_device_id'] = Variable<String>(statusDeviceId.value);
    }
    if (guardianHlc.present) {
      map['guardian_hlc'] = Variable<Uint8List>(guardianHlc.value);
    }
    if (guardianDeviceId.present) {
      map['guardian_device_id'] = Variable<String>(guardianDeviceId.value);
    }
    if (rulesVersionAtSignoffHlc.present) {
      map['rules_version_at_signoff_hlc'] = Variable<Uint8List>(
        rulesVersionAtSignoffHlc.value,
      );
    }
    if (rulesVersionAtSignoffDeviceId.present) {
      map['rules_version_at_signoff_device_id'] = Variable<String>(
        rulesVersionAtSignoffDeviceId.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CyclesSyncCompanion(')
          ..write('cycleId: $cycleId, ')
          ..write('houseId: $houseId, ')
          ..write('activeGuardianMemberId: $activeGuardianMemberId, ')
          ..write('status: $status, ')
          ..write('ceremonySignoffs: $ceremonySignoffs, ')
          ..write('rulesVersionAtSignoff: $rulesVersionAtSignoff, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('statusHlc: $statusHlc, ')
          ..write('statusDeviceId: $statusDeviceId, ')
          ..write('guardianHlc: $guardianHlc, ')
          ..write('guardianDeviceId: $guardianDeviceId, ')
          ..write('rulesVersionAtSignoffHlc: $rulesVersionAtSignoffHlc, ')
          ..write(
            'rulesVersionAtSignoffDeviceId: $rulesVersionAtSignoffDeviceId, ',
          )
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksSyncTable extends TasksSync
    with TableInfo<$TasksSyncTable, TasksSyncData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksSyncTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _houseIdMeta = const VerificationMeta(
    'houseId',
  );
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
    'house_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cycleIdMeta = const VerificationMeta(
    'cycleId',
  );
  @override
  late final GeneratedColumn<String> cycleId = GeneratedColumn<String>(
    'cycle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _negotiatedPointsMeta = const VerificationMeta(
    'negotiatedPoints',
  );
  @override
  late final GeneratedColumn<int> negotiatedPoints = GeneratedColumn<int>(
    'negotiated_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _claimedByMemberIdsMeta =
      const VerificationMeta('claimedByMemberIds');
  @override
  late final GeneratedColumn<String> claimedByMemberIds =
      GeneratedColumn<String>(
        'claimed_by_member_ids',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<Uint8List> updatedAtHlc =
      GeneratedColumn<Uint8List>(
        'updated_at_hlc',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _titleHlcMeta = const VerificationMeta(
    'titleHlc',
  );
  @override
  late final GeneratedColumn<Uint8List> titleHlc = GeneratedColumn<Uint8List>(
    'title_hlc',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleDeviceIdMeta = const VerificationMeta(
    'titleDeviceId',
  );
  @override
  late final GeneratedColumn<String> titleDeviceId = GeneratedColumn<String>(
    'title_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pointsHlcMeta = const VerificationMeta(
    'pointsHlc',
  );
  @override
  late final GeneratedColumn<Uint8List> pointsHlc = GeneratedColumn<Uint8List>(
    'points_hlc',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pointsDeviceIdMeta = const VerificationMeta(
    'pointsDeviceId',
  );
  @override
  late final GeneratedColumn<String> pointsDeviceId = GeneratedColumn<String>(
    'points_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusHlcMeta = const VerificationMeta(
    'statusHlc',
  );
  @override
  late final GeneratedColumn<Uint8List> statusHlc = GeneratedColumn<Uint8List>(
    'status_hlc',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusDeviceIdMeta = const VerificationMeta(
    'statusDeviceId',
  );
  @override
  late final GeneratedColumn<String> statusDeviceId = GeneratedColumn<String>(
    'status_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    taskId,
    houseId,
    cycleId,
    title,
    negotiatedPoints,
    status,
    claimedByMemberIds,
    updatedAtHlc,
    titleHlc,
    titleDeviceId,
    pointsHlc,
    pointsDeviceId,
    statusHlc,
    statusDeviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks_sync';
  @override
  VerificationContext validateIntegrity(
    Insertable<TasksSyncData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('house_id')) {
      context.handle(
        _houseIdMeta,
        houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('cycle_id')) {
      context.handle(
        _cycleIdMeta,
        cycleId.isAcceptableOrUnknown(data['cycle_id']!, _cycleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('negotiated_points')) {
      context.handle(
        _negotiatedPointsMeta,
        negotiatedPoints.isAcceptableOrUnknown(
          data['negotiated_points']!,
          _negotiatedPointsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_negotiatedPointsMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('claimed_by_member_ids')) {
      context.handle(
        _claimedByMemberIdsMeta,
        claimedByMemberIds.isAcceptableOrUnknown(
          data['claimed_by_member_ids']!,
          _claimedByMemberIdsMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtHlcMeta);
    }
    if (data.containsKey('title_hlc')) {
      context.handle(
        _titleHlcMeta,
        titleHlc.isAcceptableOrUnknown(data['title_hlc']!, _titleHlcMeta),
      );
    }
    if (data.containsKey('title_device_id')) {
      context.handle(
        _titleDeviceIdMeta,
        titleDeviceId.isAcceptableOrUnknown(
          data['title_device_id']!,
          _titleDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('points_hlc')) {
      context.handle(
        _pointsHlcMeta,
        pointsHlc.isAcceptableOrUnknown(data['points_hlc']!, _pointsHlcMeta),
      );
    }
    if (data.containsKey('points_device_id')) {
      context.handle(
        _pointsDeviceIdMeta,
        pointsDeviceId.isAcceptableOrUnknown(
          data['points_device_id']!,
          _pointsDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('status_hlc')) {
      context.handle(
        _statusHlcMeta,
        statusHlc.isAcceptableOrUnknown(data['status_hlc']!, _statusHlcMeta),
      );
    }
    if (data.containsKey('status_device_id')) {
      context.handle(
        _statusDeviceIdMeta,
        statusDeviceId.isAcceptableOrUnknown(
          data['status_device_id']!,
          _statusDeviceIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {taskId};
  @override
  TasksSyncData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TasksSyncData(
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      houseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}house_id'],
      )!,
      cycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cycle_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      negotiatedPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}negotiated_points'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      claimedByMemberIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}claimed_by_member_ids'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      titleHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}title_hlc'],
      ),
      titleDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_device_id'],
      ),
      pointsHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}points_hlc'],
      ),
      pointsDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}points_device_id'],
      ),
      statusHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}status_hlc'],
      ),
      statusDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_device_id'],
      ),
    );
  }

  @override
  $TasksSyncTable createAlias(String alias) {
    return $TasksSyncTable(attachedDatabase, alias);
  }
}

class TasksSyncData extends DataClass implements Insertable<TasksSyncData> {
  final String taskId;
  final String houseId;
  final String cycleId;
  final String title;
  final int negotiatedPoints;
  final String status;
  final String claimedByMemberIds;
  final Uint8List updatedAtHlc;
  final Uint8List? titleHlc;
  final String? titleDeviceId;
  final Uint8List? pointsHlc;
  final String? pointsDeviceId;
  final Uint8List? statusHlc;
  final String? statusDeviceId;
  const TasksSyncData({
    required this.taskId,
    required this.houseId,
    required this.cycleId,
    required this.title,
    required this.negotiatedPoints,
    required this.status,
    required this.claimedByMemberIds,
    required this.updatedAtHlc,
    this.titleHlc,
    this.titleDeviceId,
    this.pointsHlc,
    this.pointsDeviceId,
    this.statusHlc,
    this.statusDeviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<String>(taskId);
    map['house_id'] = Variable<String>(houseId);
    map['cycle_id'] = Variable<String>(cycleId);
    map['title'] = Variable<String>(title);
    map['negotiated_points'] = Variable<int>(negotiatedPoints);
    map['status'] = Variable<String>(status);
    map['claimed_by_member_ids'] = Variable<String>(claimedByMemberIds);
    map['updated_at_hlc'] = Variable<Uint8List>(updatedAtHlc);
    if (!nullToAbsent || titleHlc != null) {
      map['title_hlc'] = Variable<Uint8List>(titleHlc);
    }
    if (!nullToAbsent || titleDeviceId != null) {
      map['title_device_id'] = Variable<String>(titleDeviceId);
    }
    if (!nullToAbsent || pointsHlc != null) {
      map['points_hlc'] = Variable<Uint8List>(pointsHlc);
    }
    if (!nullToAbsent || pointsDeviceId != null) {
      map['points_device_id'] = Variable<String>(pointsDeviceId);
    }
    if (!nullToAbsent || statusHlc != null) {
      map['status_hlc'] = Variable<Uint8List>(statusHlc);
    }
    if (!nullToAbsent || statusDeviceId != null) {
      map['status_device_id'] = Variable<String>(statusDeviceId);
    }
    return map;
  }

  TasksSyncCompanion toCompanion(bool nullToAbsent) {
    return TasksSyncCompanion(
      taskId: Value(taskId),
      houseId: Value(houseId),
      cycleId: Value(cycleId),
      title: Value(title),
      negotiatedPoints: Value(negotiatedPoints),
      status: Value(status),
      claimedByMemberIds: Value(claimedByMemberIds),
      updatedAtHlc: Value(updatedAtHlc),
      titleHlc: titleHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(titleHlc),
      titleDeviceId: titleDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(titleDeviceId),
      pointsHlc: pointsHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(pointsHlc),
      pointsDeviceId: pointsDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(pointsDeviceId),
      statusHlc: statusHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(statusHlc),
      statusDeviceId: statusDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(statusDeviceId),
    );
  }

  factory TasksSyncData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TasksSyncData(
      taskId: serializer.fromJson<String>(json['taskId']),
      houseId: serializer.fromJson<String>(json['houseId']),
      cycleId: serializer.fromJson<String>(json['cycleId']),
      title: serializer.fromJson<String>(json['title']),
      negotiatedPoints: serializer.fromJson<int>(json['negotiatedPoints']),
      status: serializer.fromJson<String>(json['status']),
      claimedByMemberIds: serializer.fromJson<String>(
        json['claimedByMemberIds'],
      ),
      updatedAtHlc: serializer.fromJson<Uint8List>(json['updatedAtHlc']),
      titleHlc: serializer.fromJson<Uint8List?>(json['titleHlc']),
      titleDeviceId: serializer.fromJson<String?>(json['titleDeviceId']),
      pointsHlc: serializer.fromJson<Uint8List?>(json['pointsHlc']),
      pointsDeviceId: serializer.fromJson<String?>(json['pointsDeviceId']),
      statusHlc: serializer.fromJson<Uint8List?>(json['statusHlc']),
      statusDeviceId: serializer.fromJson<String?>(json['statusDeviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<String>(taskId),
      'houseId': serializer.toJson<String>(houseId),
      'cycleId': serializer.toJson<String>(cycleId),
      'title': serializer.toJson<String>(title),
      'negotiatedPoints': serializer.toJson<int>(negotiatedPoints),
      'status': serializer.toJson<String>(status),
      'claimedByMemberIds': serializer.toJson<String>(claimedByMemberIds),
      'updatedAtHlc': serializer.toJson<Uint8List>(updatedAtHlc),
      'titleHlc': serializer.toJson<Uint8List?>(titleHlc),
      'titleDeviceId': serializer.toJson<String?>(titleDeviceId),
      'pointsHlc': serializer.toJson<Uint8List?>(pointsHlc),
      'pointsDeviceId': serializer.toJson<String?>(pointsDeviceId),
      'statusHlc': serializer.toJson<Uint8List?>(statusHlc),
      'statusDeviceId': serializer.toJson<String?>(statusDeviceId),
    };
  }

  TasksSyncData copyWith({
    String? taskId,
    String? houseId,
    String? cycleId,
    String? title,
    int? negotiatedPoints,
    String? status,
    String? claimedByMemberIds,
    Uint8List? updatedAtHlc,
    Value<Uint8List?> titleHlc = const Value.absent(),
    Value<String?> titleDeviceId = const Value.absent(),
    Value<Uint8List?> pointsHlc = const Value.absent(),
    Value<String?> pointsDeviceId = const Value.absent(),
    Value<Uint8List?> statusHlc = const Value.absent(),
    Value<String?> statusDeviceId = const Value.absent(),
  }) => TasksSyncData(
    taskId: taskId ?? this.taskId,
    houseId: houseId ?? this.houseId,
    cycleId: cycleId ?? this.cycleId,
    title: title ?? this.title,
    negotiatedPoints: negotiatedPoints ?? this.negotiatedPoints,
    status: status ?? this.status,
    claimedByMemberIds: claimedByMemberIds ?? this.claimedByMemberIds,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    titleHlc: titleHlc.present ? titleHlc.value : this.titleHlc,
    titleDeviceId: titleDeviceId.present
        ? titleDeviceId.value
        : this.titleDeviceId,
    pointsHlc: pointsHlc.present ? pointsHlc.value : this.pointsHlc,
    pointsDeviceId: pointsDeviceId.present
        ? pointsDeviceId.value
        : this.pointsDeviceId,
    statusHlc: statusHlc.present ? statusHlc.value : this.statusHlc,
    statusDeviceId: statusDeviceId.present
        ? statusDeviceId.value
        : this.statusDeviceId,
  );
  TasksSyncData copyWithCompanion(TasksSyncCompanion data) {
    return TasksSyncData(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      cycleId: data.cycleId.present ? data.cycleId.value : this.cycleId,
      title: data.title.present ? data.title.value : this.title,
      negotiatedPoints: data.negotiatedPoints.present
          ? data.negotiatedPoints.value
          : this.negotiatedPoints,
      status: data.status.present ? data.status.value : this.status,
      claimedByMemberIds: data.claimedByMemberIds.present
          ? data.claimedByMemberIds.value
          : this.claimedByMemberIds,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      titleHlc: data.titleHlc.present ? data.titleHlc.value : this.titleHlc,
      titleDeviceId: data.titleDeviceId.present
          ? data.titleDeviceId.value
          : this.titleDeviceId,
      pointsHlc: data.pointsHlc.present ? data.pointsHlc.value : this.pointsHlc,
      pointsDeviceId: data.pointsDeviceId.present
          ? data.pointsDeviceId.value
          : this.pointsDeviceId,
      statusHlc: data.statusHlc.present ? data.statusHlc.value : this.statusHlc,
      statusDeviceId: data.statusDeviceId.present
          ? data.statusDeviceId.value
          : this.statusDeviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TasksSyncData(')
          ..write('taskId: $taskId, ')
          ..write('houseId: $houseId, ')
          ..write('cycleId: $cycleId, ')
          ..write('title: $title, ')
          ..write('negotiatedPoints: $negotiatedPoints, ')
          ..write('status: $status, ')
          ..write('claimedByMemberIds: $claimedByMemberIds, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('titleHlc: $titleHlc, ')
          ..write('titleDeviceId: $titleDeviceId, ')
          ..write('pointsHlc: $pointsHlc, ')
          ..write('pointsDeviceId: $pointsDeviceId, ')
          ..write('statusHlc: $statusHlc, ')
          ..write('statusDeviceId: $statusDeviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    taskId,
    houseId,
    cycleId,
    title,
    negotiatedPoints,
    status,
    claimedByMemberIds,
    $driftBlobEquality.hash(updatedAtHlc),
    $driftBlobEquality.hash(titleHlc),
    titleDeviceId,
    $driftBlobEquality.hash(pointsHlc),
    pointsDeviceId,
    $driftBlobEquality.hash(statusHlc),
    statusDeviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TasksSyncData &&
          other.taskId == this.taskId &&
          other.houseId == this.houseId &&
          other.cycleId == this.cycleId &&
          other.title == this.title &&
          other.negotiatedPoints == this.negotiatedPoints &&
          other.status == this.status &&
          other.claimedByMemberIds == this.claimedByMemberIds &&
          $driftBlobEquality.equals(other.updatedAtHlc, this.updatedAtHlc) &&
          $driftBlobEquality.equals(other.titleHlc, this.titleHlc) &&
          other.titleDeviceId == this.titleDeviceId &&
          $driftBlobEquality.equals(other.pointsHlc, this.pointsHlc) &&
          other.pointsDeviceId == this.pointsDeviceId &&
          $driftBlobEquality.equals(other.statusHlc, this.statusHlc) &&
          other.statusDeviceId == this.statusDeviceId);
}

class TasksSyncCompanion extends UpdateCompanion<TasksSyncData> {
  final Value<String> taskId;
  final Value<String> houseId;
  final Value<String> cycleId;
  final Value<String> title;
  final Value<int> negotiatedPoints;
  final Value<String> status;
  final Value<String> claimedByMemberIds;
  final Value<Uint8List> updatedAtHlc;
  final Value<Uint8List?> titleHlc;
  final Value<String?> titleDeviceId;
  final Value<Uint8List?> pointsHlc;
  final Value<String?> pointsDeviceId;
  final Value<Uint8List?> statusHlc;
  final Value<String?> statusDeviceId;
  final Value<int> rowid;
  const TasksSyncCompanion({
    this.taskId = const Value.absent(),
    this.houseId = const Value.absent(),
    this.cycleId = const Value.absent(),
    this.title = const Value.absent(),
    this.negotiatedPoints = const Value.absent(),
    this.status = const Value.absent(),
    this.claimedByMemberIds = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.titleHlc = const Value.absent(),
    this.titleDeviceId = const Value.absent(),
    this.pointsHlc = const Value.absent(),
    this.pointsDeviceId = const Value.absent(),
    this.statusHlc = const Value.absent(),
    this.statusDeviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksSyncCompanion.insert({
    required String taskId,
    required String houseId,
    required String cycleId,
    required String title,
    required int negotiatedPoints,
    required String status,
    this.claimedByMemberIds = const Value.absent(),
    required Uint8List updatedAtHlc,
    this.titleHlc = const Value.absent(),
    this.titleDeviceId = const Value.absent(),
    this.pointsHlc = const Value.absent(),
    this.pointsDeviceId = const Value.absent(),
    this.statusHlc = const Value.absent(),
    this.statusDeviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : taskId = Value(taskId),
       houseId = Value(houseId),
       cycleId = Value(cycleId),
       title = Value(title),
       negotiatedPoints = Value(negotiatedPoints),
       status = Value(status),
       updatedAtHlc = Value(updatedAtHlc);
  static Insertable<TasksSyncData> custom({
    Expression<String>? taskId,
    Expression<String>? houseId,
    Expression<String>? cycleId,
    Expression<String>? title,
    Expression<int>? negotiatedPoints,
    Expression<String>? status,
    Expression<String>? claimedByMemberIds,
    Expression<Uint8List>? updatedAtHlc,
    Expression<Uint8List>? titleHlc,
    Expression<String>? titleDeviceId,
    Expression<Uint8List>? pointsHlc,
    Expression<String>? pointsDeviceId,
    Expression<Uint8List>? statusHlc,
    Expression<String>? statusDeviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (houseId != null) 'house_id': houseId,
      if (cycleId != null) 'cycle_id': cycleId,
      if (title != null) 'title': title,
      if (negotiatedPoints != null) 'negotiated_points': negotiatedPoints,
      if (status != null) 'status': status,
      if (claimedByMemberIds != null)
        'claimed_by_member_ids': claimedByMemberIds,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (titleHlc != null) 'title_hlc': titleHlc,
      if (titleDeviceId != null) 'title_device_id': titleDeviceId,
      if (pointsHlc != null) 'points_hlc': pointsHlc,
      if (pointsDeviceId != null) 'points_device_id': pointsDeviceId,
      if (statusHlc != null) 'status_hlc': statusHlc,
      if (statusDeviceId != null) 'status_device_id': statusDeviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksSyncCompanion copyWith({
    Value<String>? taskId,
    Value<String>? houseId,
    Value<String>? cycleId,
    Value<String>? title,
    Value<int>? negotiatedPoints,
    Value<String>? status,
    Value<String>? claimedByMemberIds,
    Value<Uint8List>? updatedAtHlc,
    Value<Uint8List?>? titleHlc,
    Value<String?>? titleDeviceId,
    Value<Uint8List?>? pointsHlc,
    Value<String?>? pointsDeviceId,
    Value<Uint8List?>? statusHlc,
    Value<String?>? statusDeviceId,
    Value<int>? rowid,
  }) {
    return TasksSyncCompanion(
      taskId: taskId ?? this.taskId,
      houseId: houseId ?? this.houseId,
      cycleId: cycleId ?? this.cycleId,
      title: title ?? this.title,
      negotiatedPoints: negotiatedPoints ?? this.negotiatedPoints,
      status: status ?? this.status,
      claimedByMemberIds: claimedByMemberIds ?? this.claimedByMemberIds,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      titleHlc: titleHlc ?? this.titleHlc,
      titleDeviceId: titleDeviceId ?? this.titleDeviceId,
      pointsHlc: pointsHlc ?? this.pointsHlc,
      pointsDeviceId: pointsDeviceId ?? this.pointsDeviceId,
      statusHlc: statusHlc ?? this.statusHlc,
      statusDeviceId: statusDeviceId ?? this.statusDeviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (cycleId.present) {
      map['cycle_id'] = Variable<String>(cycleId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (negotiatedPoints.present) {
      map['negotiated_points'] = Variable<int>(negotiatedPoints.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (claimedByMemberIds.present) {
      map['claimed_by_member_ids'] = Variable<String>(claimedByMemberIds.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<Uint8List>(updatedAtHlc.value);
    }
    if (titleHlc.present) {
      map['title_hlc'] = Variable<Uint8List>(titleHlc.value);
    }
    if (titleDeviceId.present) {
      map['title_device_id'] = Variable<String>(titleDeviceId.value);
    }
    if (pointsHlc.present) {
      map['points_hlc'] = Variable<Uint8List>(pointsHlc.value);
    }
    if (pointsDeviceId.present) {
      map['points_device_id'] = Variable<String>(pointsDeviceId.value);
    }
    if (statusHlc.present) {
      map['status_hlc'] = Variable<Uint8List>(statusHlc.value);
    }
    if (statusDeviceId.present) {
      map['status_device_id'] = Variable<String>(statusDeviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksSyncCompanion(')
          ..write('taskId: $taskId, ')
          ..write('houseId: $houseId, ')
          ..write('cycleId: $cycleId, ')
          ..write('title: $title, ')
          ..write('negotiatedPoints: $negotiatedPoints, ')
          ..write('status: $status, ')
          ..write('claimedByMemberIds: $claimedByMemberIds, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('titleHlc: $titleHlc, ')
          ..write('titleDeviceId: $titleDeviceId, ')
          ..write('pointsHlc: $pointsHlc, ')
          ..write('pointsDeviceId: $pointsDeviceId, ')
          ..write('statusHlc: $statusHlc, ')
          ..write('statusDeviceId: $statusDeviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskClaimEventsTable extends TaskClaimEvents
    with TableInfo<$TaskClaimEventsTable, TaskClaimEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskClaimEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _houseIdMeta = const VerificationMeta(
    'houseId',
  );
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
    'house_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<Uint8List> hlc = GeneratedColumn<Uint8List>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    eventId,
    houseId,
    taskId,
    memberId,
    hlc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_claim_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskClaimEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('house_id')) {
      context.handle(
        _houseIdMeta,
        houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  TaskClaimEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskClaimEvent(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      houseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}house_id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}hlc'],
      )!,
    );
  }

  @override
  $TaskClaimEventsTable createAlias(String alias) {
    return $TaskClaimEventsTable(attachedDatabase, alias);
  }
}

class TaskClaimEvent extends DataClass implements Insertable<TaskClaimEvent> {
  final String eventId;
  final String houseId;
  final String taskId;
  final String memberId;
  final Uint8List hlc;
  const TaskClaimEvent({
    required this.eventId,
    required this.houseId,
    required this.taskId,
    required this.memberId,
    required this.hlc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['house_id'] = Variable<String>(houseId);
    map['task_id'] = Variable<String>(taskId);
    map['member_id'] = Variable<String>(memberId);
    map['hlc'] = Variable<Uint8List>(hlc);
    return map;
  }

  TaskClaimEventsCompanion toCompanion(bool nullToAbsent) {
    return TaskClaimEventsCompanion(
      eventId: Value(eventId),
      houseId: Value(houseId),
      taskId: Value(taskId),
      memberId: Value(memberId),
      hlc: Value(hlc),
    );
  }

  factory TaskClaimEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskClaimEvent(
      eventId: serializer.fromJson<String>(json['eventId']),
      houseId: serializer.fromJson<String>(json['houseId']),
      taskId: serializer.fromJson<String>(json['taskId']),
      memberId: serializer.fromJson<String>(json['memberId']),
      hlc: serializer.fromJson<Uint8List>(json['hlc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'houseId': serializer.toJson<String>(houseId),
      'taskId': serializer.toJson<String>(taskId),
      'memberId': serializer.toJson<String>(memberId),
      'hlc': serializer.toJson<Uint8List>(hlc),
    };
  }

  TaskClaimEvent copyWith({
    String? eventId,
    String? houseId,
    String? taskId,
    String? memberId,
    Uint8List? hlc,
  }) => TaskClaimEvent(
    eventId: eventId ?? this.eventId,
    houseId: houseId ?? this.houseId,
    taskId: taskId ?? this.taskId,
    memberId: memberId ?? this.memberId,
    hlc: hlc ?? this.hlc,
  );
  TaskClaimEvent copyWithCompanion(TaskClaimEventsCompanion data) {
    return TaskClaimEvent(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskClaimEvent(')
          ..write('eventId: $eventId, ')
          ..write('houseId: $houseId, ')
          ..write('taskId: $taskId, ')
          ..write('memberId: $memberId, ')
          ..write('hlc: $hlc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    eventId,
    houseId,
    taskId,
    memberId,
    $driftBlobEquality.hash(hlc),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskClaimEvent &&
          other.eventId == this.eventId &&
          other.houseId == this.houseId &&
          other.taskId == this.taskId &&
          other.memberId == this.memberId &&
          $driftBlobEquality.equals(other.hlc, this.hlc));
}

class TaskClaimEventsCompanion extends UpdateCompanion<TaskClaimEvent> {
  final Value<String> eventId;
  final Value<String> houseId;
  final Value<String> taskId;
  final Value<String> memberId;
  final Value<Uint8List> hlc;
  final Value<int> rowid;
  const TaskClaimEventsCompanion({
    this.eventId = const Value.absent(),
    this.houseId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.hlc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskClaimEventsCompanion.insert({
    required String eventId,
    required String houseId,
    required String taskId,
    required String memberId,
    required Uint8List hlc,
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       houseId = Value(houseId),
       taskId = Value(taskId),
       memberId = Value(memberId),
       hlc = Value(hlc);
  static Insertable<TaskClaimEvent> custom({
    Expression<String>? eventId,
    Expression<String>? houseId,
    Expression<String>? taskId,
    Expression<String>? memberId,
    Expression<Uint8List>? hlc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (houseId != null) 'house_id': houseId,
      if (taskId != null) 'task_id': taskId,
      if (memberId != null) 'member_id': memberId,
      if (hlc != null) 'hlc': hlc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskClaimEventsCompanion copyWith({
    Value<String>? eventId,
    Value<String>? houseId,
    Value<String>? taskId,
    Value<String>? memberId,
    Value<Uint8List>? hlc,
    Value<int>? rowid,
  }) {
    return TaskClaimEventsCompanion(
      eventId: eventId ?? this.eventId,
      houseId: houseId ?? this.houseId,
      taskId: taskId ?? this.taskId,
      memberId: memberId ?? this.memberId,
      hlc: hlc ?? this.hlc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<Uint8List>(hlc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskClaimEventsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('houseId: $houseId, ')
          ..write('taskId: $taskId, ')
          ..write('memberId: $memberId, ')
          ..write('hlc: $hlc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogAppendOnlyTable extends AuditLogAppendOnly
    with TableInfo<$AuditLogAppendOnlyTable, AuditLogAppendOnlyData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogAppendOnlyTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _logIdMeta = const VerificationMeta('logId');
  @override
  late final GeneratedColumn<String> logId = GeneratedColumn<String>(
    'log_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _houseIdMeta = const VerificationMeta(
    'houseId',
  );
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
    'house_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorMemberIdMeta = const VerificationMeta(
    'actorMemberId',
  );
  @override
  late final GeneratedColumn<String> actorMemberId = GeneratedColumn<String>(
    'actor_member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _justificationNotesMeta =
      const VerificationMeta('justificationNotes');
  @override
  late final GeneratedColumn<String> justificationNotes =
      GeneratedColumn<String>(
        'justification_notes',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<Uint8List> hlc = GeneratedColumn<Uint8List>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    logId,
    houseId,
    taskId,
    actorMemberId,
    action,
    justificationNotes,
    hlc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_log_append_only';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLogAppendOnlyData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('log_id')) {
      context.handle(
        _logIdMeta,
        logId.isAcceptableOrUnknown(data['log_id']!, _logIdMeta),
      );
    } else if (isInserting) {
      context.missing(_logIdMeta);
    }
    if (data.containsKey('house_id')) {
      context.handle(
        _houseIdMeta,
        houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('actor_member_id')) {
      context.handle(
        _actorMemberIdMeta,
        actorMemberId.isAcceptableOrUnknown(
          data['actor_member_id']!,
          _actorMemberIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actorMemberIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('justification_notes')) {
      context.handle(
        _justificationNotesMeta,
        justificationNotes.isAcceptableOrUnknown(
          data['justification_notes']!,
          _justificationNotesMeta,
        ),
      );
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {logId};
  @override
  AuditLogAppendOnlyData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLogAppendOnlyData(
      logId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}log_id'],
      )!,
      houseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}house_id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      actorMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_member_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      justificationNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}justification_notes'],
      ),
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}hlc'],
      )!,
    );
  }

  @override
  $AuditLogAppendOnlyTable createAlias(String alias) {
    return $AuditLogAppendOnlyTable(attachedDatabase, alias);
  }
}

class AuditLogAppendOnlyData extends DataClass
    implements Insertable<AuditLogAppendOnlyData> {
  final String logId;
  final String houseId;
  final String taskId;
  final String actorMemberId;
  final String action;
  final String? justificationNotes;
  final Uint8List hlc;
  const AuditLogAppendOnlyData({
    required this.logId,
    required this.houseId,
    required this.taskId,
    required this.actorMemberId,
    required this.action,
    this.justificationNotes,
    required this.hlc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['log_id'] = Variable<String>(logId);
    map['house_id'] = Variable<String>(houseId);
    map['task_id'] = Variable<String>(taskId);
    map['actor_member_id'] = Variable<String>(actorMemberId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || justificationNotes != null) {
      map['justification_notes'] = Variable<String>(justificationNotes);
    }
    map['hlc'] = Variable<Uint8List>(hlc);
    return map;
  }

  AuditLogAppendOnlyCompanion toCompanion(bool nullToAbsent) {
    return AuditLogAppendOnlyCompanion(
      logId: Value(logId),
      houseId: Value(houseId),
      taskId: Value(taskId),
      actorMemberId: Value(actorMemberId),
      action: Value(action),
      justificationNotes: justificationNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(justificationNotes),
      hlc: Value(hlc),
    );
  }

  factory AuditLogAppendOnlyData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLogAppendOnlyData(
      logId: serializer.fromJson<String>(json['logId']),
      houseId: serializer.fromJson<String>(json['houseId']),
      taskId: serializer.fromJson<String>(json['taskId']),
      actorMemberId: serializer.fromJson<String>(json['actorMemberId']),
      action: serializer.fromJson<String>(json['action']),
      justificationNotes: serializer.fromJson<String?>(
        json['justificationNotes'],
      ),
      hlc: serializer.fromJson<Uint8List>(json['hlc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'logId': serializer.toJson<String>(logId),
      'houseId': serializer.toJson<String>(houseId),
      'taskId': serializer.toJson<String>(taskId),
      'actorMemberId': serializer.toJson<String>(actorMemberId),
      'action': serializer.toJson<String>(action),
      'justificationNotes': serializer.toJson<String?>(justificationNotes),
      'hlc': serializer.toJson<Uint8List>(hlc),
    };
  }

  AuditLogAppendOnlyData copyWith({
    String? logId,
    String? houseId,
    String? taskId,
    String? actorMemberId,
    String? action,
    Value<String?> justificationNotes = const Value.absent(),
    Uint8List? hlc,
  }) => AuditLogAppendOnlyData(
    logId: logId ?? this.logId,
    houseId: houseId ?? this.houseId,
    taskId: taskId ?? this.taskId,
    actorMemberId: actorMemberId ?? this.actorMemberId,
    action: action ?? this.action,
    justificationNotes: justificationNotes.present
        ? justificationNotes.value
        : this.justificationNotes,
    hlc: hlc ?? this.hlc,
  );
  AuditLogAppendOnlyData copyWithCompanion(AuditLogAppendOnlyCompanion data) {
    return AuditLogAppendOnlyData(
      logId: data.logId.present ? data.logId.value : this.logId,
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      actorMemberId: data.actorMemberId.present
          ? data.actorMemberId.value
          : this.actorMemberId,
      action: data.action.present ? data.action.value : this.action,
      justificationNotes: data.justificationNotes.present
          ? data.justificationNotes.value
          : this.justificationNotes,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogAppendOnlyData(')
          ..write('logId: $logId, ')
          ..write('houseId: $houseId, ')
          ..write('taskId: $taskId, ')
          ..write('actorMemberId: $actorMemberId, ')
          ..write('action: $action, ')
          ..write('justificationNotes: $justificationNotes, ')
          ..write('hlc: $hlc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    logId,
    houseId,
    taskId,
    actorMemberId,
    action,
    justificationNotes,
    $driftBlobEquality.hash(hlc),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLogAppendOnlyData &&
          other.logId == this.logId &&
          other.houseId == this.houseId &&
          other.taskId == this.taskId &&
          other.actorMemberId == this.actorMemberId &&
          other.action == this.action &&
          other.justificationNotes == this.justificationNotes &&
          $driftBlobEquality.equals(other.hlc, this.hlc));
}

class AuditLogAppendOnlyCompanion
    extends UpdateCompanion<AuditLogAppendOnlyData> {
  final Value<String> logId;
  final Value<String> houseId;
  final Value<String> taskId;
  final Value<String> actorMemberId;
  final Value<String> action;
  final Value<String?> justificationNotes;
  final Value<Uint8List> hlc;
  final Value<int> rowid;
  const AuditLogAppendOnlyCompanion({
    this.logId = const Value.absent(),
    this.houseId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.actorMemberId = const Value.absent(),
    this.action = const Value.absent(),
    this.justificationNotes = const Value.absent(),
    this.hlc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogAppendOnlyCompanion.insert({
    required String logId,
    required String houseId,
    required String taskId,
    required String actorMemberId,
    required String action,
    this.justificationNotes = const Value.absent(),
    required Uint8List hlc,
    this.rowid = const Value.absent(),
  }) : logId = Value(logId),
       houseId = Value(houseId),
       taskId = Value(taskId),
       actorMemberId = Value(actorMemberId),
       action = Value(action),
       hlc = Value(hlc);
  static Insertable<AuditLogAppendOnlyData> custom({
    Expression<String>? logId,
    Expression<String>? houseId,
    Expression<String>? taskId,
    Expression<String>? actorMemberId,
    Expression<String>? action,
    Expression<String>? justificationNotes,
    Expression<Uint8List>? hlc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (logId != null) 'log_id': logId,
      if (houseId != null) 'house_id': houseId,
      if (taskId != null) 'task_id': taskId,
      if (actorMemberId != null) 'actor_member_id': actorMemberId,
      if (action != null) 'action': action,
      if (justificationNotes != null) 'justification_notes': justificationNotes,
      if (hlc != null) 'hlc': hlc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogAppendOnlyCompanion copyWith({
    Value<String>? logId,
    Value<String>? houseId,
    Value<String>? taskId,
    Value<String>? actorMemberId,
    Value<String>? action,
    Value<String?>? justificationNotes,
    Value<Uint8List>? hlc,
    Value<int>? rowid,
  }) {
    return AuditLogAppendOnlyCompanion(
      logId: logId ?? this.logId,
      houseId: houseId ?? this.houseId,
      taskId: taskId ?? this.taskId,
      actorMemberId: actorMemberId ?? this.actorMemberId,
      action: action ?? this.action,
      justificationNotes: justificationNotes ?? this.justificationNotes,
      hlc: hlc ?? this.hlc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (logId.present) {
      map['log_id'] = Variable<String>(logId.value);
    }
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (actorMemberId.present) {
      map['actor_member_id'] = Variable<String>(actorMemberId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (justificationNotes.present) {
      map['justification_notes'] = Variable<String>(justificationNotes.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<Uint8List>(hlc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogAppendOnlyCompanion(')
          ..write('logId: $logId, ')
          ..write('houseId: $houseId, ')
          ..write('taskId: $taskId, ')
          ..write('actorMemberId: $actorMemberId, ')
          ..write('action: $action, ')
          ..write('justificationNotes: $justificationNotes, ')
          ..write('hlc: $hlc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxEntriesTable extends SyncOutboxEntries
    with TableInfo<$SyncOutboxEntriesTable, SyncOutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _houseIdMeta = const VerificationMeta(
    'houseId',
  );
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
    'house_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _envelopeJsonMeta = const VerificationMeta(
    'envelopeJson',
  );
  @override
  late final GeneratedColumn<String> envelopeJson = GeneratedColumn<String>(
    'envelope_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _broadcastedMeta = const VerificationMeta(
    'broadcasted',
  );
  @override
  late final GeneratedColumn<bool> broadcasted = GeneratedColumn<bool>(
    'broadcasted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("broadcasted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    houseId,
    envelopeJson,
    createdAtMs,
    broadcasted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('house_id')) {
      context.handle(
        _houseIdMeta,
        houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('envelope_json')) {
      context.handle(
        _envelopeJsonMeta,
        envelopeJson.isAcceptableOrUnknown(
          data['envelope_json']!,
          _envelopeJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_envelopeJsonMeta);
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('broadcasted')) {
      context.handle(
        _broadcastedMeta,
        broadcasted.isAcceptableOrUnknown(
          data['broadcasted']!,
          _broadcastedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {opId};
  @override
  SyncOutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxEntry(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      houseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}house_id'],
      )!,
      envelopeJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}envelope_json'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      broadcasted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}broadcasted'],
      )!,
    );
  }

  @override
  $SyncOutboxEntriesTable createAlias(String alias) {
    return $SyncOutboxEntriesTable(attachedDatabase, alias);
  }
}

class SyncOutboxEntry extends DataClass implements Insertable<SyncOutboxEntry> {
  final String opId;
  final String houseId;
  final String envelopeJson;
  final int createdAtMs;
  final bool broadcasted;
  const SyncOutboxEntry({
    required this.opId,
    required this.houseId,
    required this.envelopeJson,
    required this.createdAtMs,
    required this.broadcasted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['op_id'] = Variable<String>(opId);
    map['house_id'] = Variable<String>(houseId);
    map['envelope_json'] = Variable<String>(envelopeJson);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['broadcasted'] = Variable<bool>(broadcasted);
    return map;
  }

  SyncOutboxEntriesCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxEntriesCompanion(
      opId: Value(opId),
      houseId: Value(houseId),
      envelopeJson: Value(envelopeJson),
      createdAtMs: Value(createdAtMs),
      broadcasted: Value(broadcasted),
    );
  }

  factory SyncOutboxEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxEntry(
      opId: serializer.fromJson<String>(json['opId']),
      houseId: serializer.fromJson<String>(json['houseId']),
      envelopeJson: serializer.fromJson<String>(json['envelopeJson']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      broadcasted: serializer.fromJson<bool>(json['broadcasted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String>(opId),
      'houseId': serializer.toJson<String>(houseId),
      'envelopeJson': serializer.toJson<String>(envelopeJson),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'broadcasted': serializer.toJson<bool>(broadcasted),
    };
  }

  SyncOutboxEntry copyWith({
    String? opId,
    String? houseId,
    String? envelopeJson,
    int? createdAtMs,
    bool? broadcasted,
  }) => SyncOutboxEntry(
    opId: opId ?? this.opId,
    houseId: houseId ?? this.houseId,
    envelopeJson: envelopeJson ?? this.envelopeJson,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    broadcasted: broadcasted ?? this.broadcasted,
  );
  SyncOutboxEntry copyWithCompanion(SyncOutboxEntriesCompanion data) {
    return SyncOutboxEntry(
      opId: data.opId.present ? data.opId.value : this.opId,
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      envelopeJson: data.envelopeJson.present
          ? data.envelopeJson.value
          : this.envelopeJson,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      broadcasted: data.broadcasted.present
          ? data.broadcasted.value
          : this.broadcasted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxEntry(')
          ..write('opId: $opId, ')
          ..write('houseId: $houseId, ')
          ..write('envelopeJson: $envelopeJson, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('broadcasted: $broadcasted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(opId, houseId, envelopeJson, createdAtMs, broadcasted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxEntry &&
          other.opId == this.opId &&
          other.houseId == this.houseId &&
          other.envelopeJson == this.envelopeJson &&
          other.createdAtMs == this.createdAtMs &&
          other.broadcasted == this.broadcasted);
}

class SyncOutboxEntriesCompanion extends UpdateCompanion<SyncOutboxEntry> {
  final Value<String> opId;
  final Value<String> houseId;
  final Value<String> envelopeJson;
  final Value<int> createdAtMs;
  final Value<bool> broadcasted;
  final Value<int> rowid;
  const SyncOutboxEntriesCompanion({
    this.opId = const Value.absent(),
    this.houseId = const Value.absent(),
    this.envelopeJson = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.broadcasted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxEntriesCompanion.insert({
    required String opId,
    required String houseId,
    required String envelopeJson,
    required int createdAtMs,
    this.broadcasted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : opId = Value(opId),
       houseId = Value(houseId),
       envelopeJson = Value(envelopeJson),
       createdAtMs = Value(createdAtMs);
  static Insertable<SyncOutboxEntry> custom({
    Expression<String>? opId,
    Expression<String>? houseId,
    Expression<String>? envelopeJson,
    Expression<int>? createdAtMs,
    Expression<bool>? broadcasted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (houseId != null) 'house_id': houseId,
      if (envelopeJson != null) 'envelope_json': envelopeJson,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (broadcasted != null) 'broadcasted': broadcasted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxEntriesCompanion copyWith({
    Value<String>? opId,
    Value<String>? houseId,
    Value<String>? envelopeJson,
    Value<int>? createdAtMs,
    Value<bool>? broadcasted,
    Value<int>? rowid,
  }) {
    return SyncOutboxEntriesCompanion(
      opId: opId ?? this.opId,
      houseId: houseId ?? this.houseId,
      envelopeJson: envelopeJson ?? this.envelopeJson,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      broadcasted: broadcasted ?? this.broadcasted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (envelopeJson.present) {
      map['envelope_json'] = Variable<String>(envelopeJson.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (broadcasted.present) {
      map['broadcasted'] = Variable<bool>(broadcasted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxEntriesCompanion(')
          ..write('opId: $opId, ')
          ..write('houseId: $houseId, ')
          ..write('envelopeJson: $envelopeJson, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('broadcasted: $broadcasted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncAppliedOpsTable extends SyncAppliedOps
    with TableInfo<$SyncAppliedOpsTable, SyncAppliedOp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncAppliedOpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _houseIdMeta = const VerificationMeta(
    'houseId',
  );
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
    'house_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedAtHlcMeta = const VerificationMeta(
    'appliedAtHlc',
  );
  @override
  late final GeneratedColumn<Uint8List> appliedAtHlc =
      GeneratedColumn<Uint8List>(
        'applied_at_hlc',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [opId, houseId, appliedAtHlc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_applied_ops';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncAppliedOp> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('house_id')) {
      context.handle(
        _houseIdMeta,
        houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('applied_at_hlc')) {
      context.handle(
        _appliedAtHlcMeta,
        appliedAtHlc.isAcceptableOrUnknown(
          data['applied_at_hlc']!,
          _appliedAtHlcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_appliedAtHlcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {opId};
  @override
  SyncAppliedOp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncAppliedOp(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      houseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}house_id'],
      )!,
      appliedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}applied_at_hlc'],
      )!,
    );
  }

  @override
  $SyncAppliedOpsTable createAlias(String alias) {
    return $SyncAppliedOpsTable(attachedDatabase, alias);
  }
}

class SyncAppliedOp extends DataClass implements Insertable<SyncAppliedOp> {
  final String opId;
  final String houseId;
  final Uint8List appliedAtHlc;
  const SyncAppliedOp({
    required this.opId,
    required this.houseId,
    required this.appliedAtHlc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['op_id'] = Variable<String>(opId);
    map['house_id'] = Variable<String>(houseId);
    map['applied_at_hlc'] = Variable<Uint8List>(appliedAtHlc);
    return map;
  }

  SyncAppliedOpsCompanion toCompanion(bool nullToAbsent) {
    return SyncAppliedOpsCompanion(
      opId: Value(opId),
      houseId: Value(houseId),
      appliedAtHlc: Value(appliedAtHlc),
    );
  }

  factory SyncAppliedOp.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncAppliedOp(
      opId: serializer.fromJson<String>(json['opId']),
      houseId: serializer.fromJson<String>(json['houseId']),
      appliedAtHlc: serializer.fromJson<Uint8List>(json['appliedAtHlc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String>(opId),
      'houseId': serializer.toJson<String>(houseId),
      'appliedAtHlc': serializer.toJson<Uint8List>(appliedAtHlc),
    };
  }

  SyncAppliedOp copyWith({
    String? opId,
    String? houseId,
    Uint8List? appliedAtHlc,
  }) => SyncAppliedOp(
    opId: opId ?? this.opId,
    houseId: houseId ?? this.houseId,
    appliedAtHlc: appliedAtHlc ?? this.appliedAtHlc,
  );
  SyncAppliedOp copyWithCompanion(SyncAppliedOpsCompanion data) {
    return SyncAppliedOp(
      opId: data.opId.present ? data.opId.value : this.opId,
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      appliedAtHlc: data.appliedAtHlc.present
          ? data.appliedAtHlc.value
          : this.appliedAtHlc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncAppliedOp(')
          ..write('opId: $opId, ')
          ..write('houseId: $houseId, ')
          ..write('appliedAtHlc: $appliedAtHlc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(opId, houseId, $driftBlobEquality.hash(appliedAtHlc));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncAppliedOp &&
          other.opId == this.opId &&
          other.houseId == this.houseId &&
          $driftBlobEquality.equals(other.appliedAtHlc, this.appliedAtHlc));
}

class SyncAppliedOpsCompanion extends UpdateCompanion<SyncAppliedOp> {
  final Value<String> opId;
  final Value<String> houseId;
  final Value<Uint8List> appliedAtHlc;
  final Value<int> rowid;
  const SyncAppliedOpsCompanion({
    this.opId = const Value.absent(),
    this.houseId = const Value.absent(),
    this.appliedAtHlc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncAppliedOpsCompanion.insert({
    required String opId,
    required String houseId,
    required Uint8List appliedAtHlc,
    this.rowid = const Value.absent(),
  }) : opId = Value(opId),
       houseId = Value(houseId),
       appliedAtHlc = Value(appliedAtHlc);
  static Insertable<SyncAppliedOp> custom({
    Expression<String>? opId,
    Expression<String>? houseId,
    Expression<Uint8List>? appliedAtHlc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (houseId != null) 'house_id': houseId,
      if (appliedAtHlc != null) 'applied_at_hlc': appliedAtHlc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncAppliedOpsCompanion copyWith({
    Value<String>? opId,
    Value<String>? houseId,
    Value<Uint8List>? appliedAtHlc,
    Value<int>? rowid,
  }) {
    return SyncAppliedOpsCompanion(
      opId: opId ?? this.opId,
      houseId: houseId ?? this.houseId,
      appliedAtHlc: appliedAtHlc ?? this.appliedAtHlc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (appliedAtHlc.present) {
      map['applied_at_hlc'] = Variable<Uint8List>(appliedAtHlc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncAppliedOpsCompanion(')
          ..write('opId: $opId, ')
          ..write('houseId: $houseId, ')
          ..write('appliedAtHlc: $appliedAtHlc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncPeerStateTable extends SyncPeerState
    with TableInfo<$SyncPeerStateTable, SyncPeerStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncPeerStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _peerNodeKeyMeta = const VerificationMeta(
    'peerNodeKey',
  );
  @override
  late final GeneratedColumn<String> peerNodeKey = GeneratedColumn<String>(
    'peer_node_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _houseIdMeta = const VerificationMeta(
    'houseId',
  );
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
    'house_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastEnvelopeIdMeta = const VerificationMeta(
    'lastEnvelopeId',
  );
  @override
  late final GeneratedColumn<String> lastEnvelopeId = GeneratedColumn<String>(
    'last_envelope_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeenHlcMeta = const VerificationMeta(
    'lastSeenHlc',
  );
  @override
  late final GeneratedColumn<Uint8List> lastSeenHlc =
      GeneratedColumn<Uint8List>(
        'last_seen_hlc',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    peerNodeKey,
    houseId,
    lastEnvelopeId,
    lastSeenHlc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_peer_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncPeerStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('peer_node_key')) {
      context.handle(
        _peerNodeKeyMeta,
        peerNodeKey.isAcceptableOrUnknown(
          data['peer_node_key']!,
          _peerNodeKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_peerNodeKeyMeta);
    }
    if (data.containsKey('house_id')) {
      context.handle(
        _houseIdMeta,
        houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('last_envelope_id')) {
      context.handle(
        _lastEnvelopeIdMeta,
        lastEnvelopeId.isAcceptableOrUnknown(
          data['last_envelope_id']!,
          _lastEnvelopeIdMeta,
        ),
      );
    }
    if (data.containsKey('last_seen_hlc')) {
      context.handle(
        _lastSeenHlcMeta,
        lastSeenHlc.isAcceptableOrUnknown(
          data['last_seen_hlc']!,
          _lastSeenHlcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {peerNodeKey, houseId};
  @override
  SyncPeerStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncPeerStateData(
      peerNodeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}peer_node_key'],
      )!,
      houseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}house_id'],
      )!,
      lastEnvelopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_envelope_id'],
      ),
      lastSeenHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}last_seen_hlc'],
      ),
    );
  }

  @override
  $SyncPeerStateTable createAlias(String alias) {
    return $SyncPeerStateTable(attachedDatabase, alias);
  }
}

class SyncPeerStateData extends DataClass
    implements Insertable<SyncPeerStateData> {
  final String peerNodeKey;
  final String houseId;
  final String? lastEnvelopeId;
  final Uint8List? lastSeenHlc;
  const SyncPeerStateData({
    required this.peerNodeKey,
    required this.houseId,
    this.lastEnvelopeId,
    this.lastSeenHlc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['peer_node_key'] = Variable<String>(peerNodeKey);
    map['house_id'] = Variable<String>(houseId);
    if (!nullToAbsent || lastEnvelopeId != null) {
      map['last_envelope_id'] = Variable<String>(lastEnvelopeId);
    }
    if (!nullToAbsent || lastSeenHlc != null) {
      map['last_seen_hlc'] = Variable<Uint8List>(lastSeenHlc);
    }
    return map;
  }

  SyncPeerStateCompanion toCompanion(bool nullToAbsent) {
    return SyncPeerStateCompanion(
      peerNodeKey: Value(peerNodeKey),
      houseId: Value(houseId),
      lastEnvelopeId: lastEnvelopeId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastEnvelopeId),
      lastSeenHlc: lastSeenHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenHlc),
    );
  }

  factory SyncPeerStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncPeerStateData(
      peerNodeKey: serializer.fromJson<String>(json['peerNodeKey']),
      houseId: serializer.fromJson<String>(json['houseId']),
      lastEnvelopeId: serializer.fromJson<String?>(json['lastEnvelopeId']),
      lastSeenHlc: serializer.fromJson<Uint8List?>(json['lastSeenHlc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'peerNodeKey': serializer.toJson<String>(peerNodeKey),
      'houseId': serializer.toJson<String>(houseId),
      'lastEnvelopeId': serializer.toJson<String?>(lastEnvelopeId),
      'lastSeenHlc': serializer.toJson<Uint8List?>(lastSeenHlc),
    };
  }

  SyncPeerStateData copyWith({
    String? peerNodeKey,
    String? houseId,
    Value<String?> lastEnvelopeId = const Value.absent(),
    Value<Uint8List?> lastSeenHlc = const Value.absent(),
  }) => SyncPeerStateData(
    peerNodeKey: peerNodeKey ?? this.peerNodeKey,
    houseId: houseId ?? this.houseId,
    lastEnvelopeId: lastEnvelopeId.present
        ? lastEnvelopeId.value
        : this.lastEnvelopeId,
    lastSeenHlc: lastSeenHlc.present ? lastSeenHlc.value : this.lastSeenHlc,
  );
  SyncPeerStateData copyWithCompanion(SyncPeerStateCompanion data) {
    return SyncPeerStateData(
      peerNodeKey: data.peerNodeKey.present
          ? data.peerNodeKey.value
          : this.peerNodeKey,
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      lastEnvelopeId: data.lastEnvelopeId.present
          ? data.lastEnvelopeId.value
          : this.lastEnvelopeId,
      lastSeenHlc: data.lastSeenHlc.present
          ? data.lastSeenHlc.value
          : this.lastSeenHlc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncPeerStateData(')
          ..write('peerNodeKey: $peerNodeKey, ')
          ..write('houseId: $houseId, ')
          ..write('lastEnvelopeId: $lastEnvelopeId, ')
          ..write('lastSeenHlc: $lastSeenHlc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    peerNodeKey,
    houseId,
    lastEnvelopeId,
    $driftBlobEquality.hash(lastSeenHlc),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncPeerStateData &&
          other.peerNodeKey == this.peerNodeKey &&
          other.houseId == this.houseId &&
          other.lastEnvelopeId == this.lastEnvelopeId &&
          $driftBlobEquality.equals(other.lastSeenHlc, this.lastSeenHlc));
}

class SyncPeerStateCompanion extends UpdateCompanion<SyncPeerStateData> {
  final Value<String> peerNodeKey;
  final Value<String> houseId;
  final Value<String?> lastEnvelopeId;
  final Value<Uint8List?> lastSeenHlc;
  final Value<int> rowid;
  const SyncPeerStateCompanion({
    this.peerNodeKey = const Value.absent(),
    this.houseId = const Value.absent(),
    this.lastEnvelopeId = const Value.absent(),
    this.lastSeenHlc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncPeerStateCompanion.insert({
    required String peerNodeKey,
    required String houseId,
    this.lastEnvelopeId = const Value.absent(),
    this.lastSeenHlc = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : peerNodeKey = Value(peerNodeKey),
       houseId = Value(houseId);
  static Insertable<SyncPeerStateData> custom({
    Expression<String>? peerNodeKey,
    Expression<String>? houseId,
    Expression<String>? lastEnvelopeId,
    Expression<Uint8List>? lastSeenHlc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (peerNodeKey != null) 'peer_node_key': peerNodeKey,
      if (houseId != null) 'house_id': houseId,
      if (lastEnvelopeId != null) 'last_envelope_id': lastEnvelopeId,
      if (lastSeenHlc != null) 'last_seen_hlc': lastSeenHlc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncPeerStateCompanion copyWith({
    Value<String>? peerNodeKey,
    Value<String>? houseId,
    Value<String?>? lastEnvelopeId,
    Value<Uint8List?>? lastSeenHlc,
    Value<int>? rowid,
  }) {
    return SyncPeerStateCompanion(
      peerNodeKey: peerNodeKey ?? this.peerNodeKey,
      houseId: houseId ?? this.houseId,
      lastEnvelopeId: lastEnvelopeId ?? this.lastEnvelopeId,
      lastSeenHlc: lastSeenHlc ?? this.lastSeenHlc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (peerNodeKey.present) {
      map['peer_node_key'] = Variable<String>(peerNodeKey.value);
    }
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (lastEnvelopeId.present) {
      map['last_envelope_id'] = Variable<String>(lastEnvelopeId.value);
    }
    if (lastSeenHlc.present) {
      map['last_seen_hlc'] = Variable<Uint8List>(lastSeenHlc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncPeerStateCompanion(')
          ..write('peerNodeKey: $peerNodeKey, ')
          ..write('houseId: $houseId, ')
          ..write('lastEnvelopeId: $lastEnvelopeId, ')
          ..write('lastSeenHlc: $lastSeenHlc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncPeerAllowlistTable extends SyncPeerAllowlist
    with TableInfo<$SyncPeerAllowlistTable, SyncPeerAllowlistData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncPeerAllowlistTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tailscaleNodeKeyMeta = const VerificationMeta(
    'tailscaleNodeKey',
  );
  @override
  late final GeneratedColumn<String> tailscaleNodeKey = GeneratedColumn<String>(
    'tailscale_node_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _houseIdMeta = const VerificationMeta(
    'houseId',
  );
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
    'house_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isLocalDeviceMeta = const VerificationMeta(
    'isLocalDevice',
  );
  @override
  late final GeneratedColumn<bool> isLocalDevice = GeneratedColumn<bool>(
    'is_local_device',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_local_device" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    tailscaleNodeKey,
    houseId,
    memberId,
    isLocalDevice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_peer_allowlist';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncPeerAllowlistData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tailscale_node_key')) {
      context.handle(
        _tailscaleNodeKeyMeta,
        tailscaleNodeKey.isAcceptableOrUnknown(
          data['tailscale_node_key']!,
          _tailscaleNodeKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tailscaleNodeKeyMeta);
    }
    if (data.containsKey('house_id')) {
      context.handle(
        _houseIdMeta,
        houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    }
    if (data.containsKey('is_local_device')) {
      context.handle(
        _isLocalDeviceMeta,
        isLocalDevice.isAcceptableOrUnknown(
          data['is_local_device']!,
          _isLocalDeviceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tailscaleNodeKey, houseId};
  @override
  SyncPeerAllowlistData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncPeerAllowlistData(
      tailscaleNodeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tailscale_node_key'],
      )!,
      houseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}house_id'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      ),
      isLocalDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_local_device'],
      )!,
    );
  }

  @override
  $SyncPeerAllowlistTable createAlias(String alias) {
    return $SyncPeerAllowlistTable(attachedDatabase, alias);
  }
}

class SyncPeerAllowlistData extends DataClass
    implements Insertable<SyncPeerAllowlistData> {
  final String tailscaleNodeKey;
  final String houseId;
  final String? memberId;
  final bool isLocalDevice;
  const SyncPeerAllowlistData({
    required this.tailscaleNodeKey,
    required this.houseId,
    this.memberId,
    required this.isLocalDevice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tailscale_node_key'] = Variable<String>(tailscaleNodeKey);
    map['house_id'] = Variable<String>(houseId);
    if (!nullToAbsent || memberId != null) {
      map['member_id'] = Variable<String>(memberId);
    }
    map['is_local_device'] = Variable<bool>(isLocalDevice);
    return map;
  }

  SyncPeerAllowlistCompanion toCompanion(bool nullToAbsent) {
    return SyncPeerAllowlistCompanion(
      tailscaleNodeKey: Value(tailscaleNodeKey),
      houseId: Value(houseId),
      memberId: memberId == null && nullToAbsent
          ? const Value.absent()
          : Value(memberId),
      isLocalDevice: Value(isLocalDevice),
    );
  }

  factory SyncPeerAllowlistData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncPeerAllowlistData(
      tailscaleNodeKey: serializer.fromJson<String>(json['tailscaleNodeKey']),
      houseId: serializer.fromJson<String>(json['houseId']),
      memberId: serializer.fromJson<String?>(json['memberId']),
      isLocalDevice: serializer.fromJson<bool>(json['isLocalDevice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tailscaleNodeKey': serializer.toJson<String>(tailscaleNodeKey),
      'houseId': serializer.toJson<String>(houseId),
      'memberId': serializer.toJson<String?>(memberId),
      'isLocalDevice': serializer.toJson<bool>(isLocalDevice),
    };
  }

  SyncPeerAllowlistData copyWith({
    String? tailscaleNodeKey,
    String? houseId,
    Value<String?> memberId = const Value.absent(),
    bool? isLocalDevice,
  }) => SyncPeerAllowlistData(
    tailscaleNodeKey: tailscaleNodeKey ?? this.tailscaleNodeKey,
    houseId: houseId ?? this.houseId,
    memberId: memberId.present ? memberId.value : this.memberId,
    isLocalDevice: isLocalDevice ?? this.isLocalDevice,
  );
  SyncPeerAllowlistData copyWithCompanion(SyncPeerAllowlistCompanion data) {
    return SyncPeerAllowlistData(
      tailscaleNodeKey: data.tailscaleNodeKey.present
          ? data.tailscaleNodeKey.value
          : this.tailscaleNodeKey,
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      isLocalDevice: data.isLocalDevice.present
          ? data.isLocalDevice.value
          : this.isLocalDevice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncPeerAllowlistData(')
          ..write('tailscaleNodeKey: $tailscaleNodeKey, ')
          ..write('houseId: $houseId, ')
          ..write('memberId: $memberId, ')
          ..write('isLocalDevice: $isLocalDevice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(tailscaleNodeKey, houseId, memberId, isLocalDevice);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncPeerAllowlistData &&
          other.tailscaleNodeKey == this.tailscaleNodeKey &&
          other.houseId == this.houseId &&
          other.memberId == this.memberId &&
          other.isLocalDevice == this.isLocalDevice);
}

class SyncPeerAllowlistCompanion
    extends UpdateCompanion<SyncPeerAllowlistData> {
  final Value<String> tailscaleNodeKey;
  final Value<String> houseId;
  final Value<String?> memberId;
  final Value<bool> isLocalDevice;
  final Value<int> rowid;
  const SyncPeerAllowlistCompanion({
    this.tailscaleNodeKey = const Value.absent(),
    this.houseId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.isLocalDevice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncPeerAllowlistCompanion.insert({
    required String tailscaleNodeKey,
    required String houseId,
    this.memberId = const Value.absent(),
    this.isLocalDevice = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tailscaleNodeKey = Value(tailscaleNodeKey),
       houseId = Value(houseId);
  static Insertable<SyncPeerAllowlistData> custom({
    Expression<String>? tailscaleNodeKey,
    Expression<String>? houseId,
    Expression<String>? memberId,
    Expression<bool>? isLocalDevice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tailscaleNodeKey != null) 'tailscale_node_key': tailscaleNodeKey,
      if (houseId != null) 'house_id': houseId,
      if (memberId != null) 'member_id': memberId,
      if (isLocalDevice != null) 'is_local_device': isLocalDevice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncPeerAllowlistCompanion copyWith({
    Value<String>? tailscaleNodeKey,
    Value<String>? houseId,
    Value<String?>? memberId,
    Value<bool>? isLocalDevice,
    Value<int>? rowid,
  }) {
    return SyncPeerAllowlistCompanion(
      tailscaleNodeKey: tailscaleNodeKey ?? this.tailscaleNodeKey,
      houseId: houseId ?? this.houseId,
      memberId: memberId ?? this.memberId,
      isLocalDevice: isLocalDevice ?? this.isLocalDevice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tailscaleNodeKey.present) {
      map['tailscale_node_key'] = Variable<String>(tailscaleNodeKey.value);
    }
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (isLocalDevice.present) {
      map['is_local_device'] = Variable<bool>(isLocalDevice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncPeerAllowlistCompanion(')
          ..write('tailscaleNodeKey: $tailscaleNodeKey, ')
          ..write('houseId: $houseId, ')
          ..write('memberId: $memberId, ')
          ..write('isLocalDevice: $isLocalDevice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConsumedJoinCredentialsTable extends ConsumedJoinCredentials
    with TableInfo<$ConsumedJoinCredentialsTable, ConsumedJoinCredential> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConsumedJoinCredentialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nonceMeta = const VerificationMeta('nonce');
  @override
  late final GeneratedColumn<String> nonce = GeneratedColumn<String>(
    'nonce',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _houseIdMeta = const VerificationMeta(
    'houseId',
  );
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
    'house_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _consumedByNodeKeyMeta = const VerificationMeta(
    'consumedByNodeKey',
  );
  @override
  late final GeneratedColumn<String> consumedByNodeKey =
      GeneratedColumn<String>(
        'consumed_by_node_key',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _consumedAtMsMeta = const VerificationMeta(
    'consumedAtMs',
  );
  @override
  late final GeneratedColumn<int> consumedAtMs = GeneratedColumn<int>(
    'consumed_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    nonce,
    houseId,
    consumedByNodeKey,
    consumedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'consumed_join_credentials';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConsumedJoinCredential> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('nonce')) {
      context.handle(
        _nonceMeta,
        nonce.isAcceptableOrUnknown(data['nonce']!, _nonceMeta),
      );
    } else if (isInserting) {
      context.missing(_nonceMeta);
    }
    if (data.containsKey('house_id')) {
      context.handle(
        _houseIdMeta,
        houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('consumed_by_node_key')) {
      context.handle(
        _consumedByNodeKeyMeta,
        consumedByNodeKey.isAcceptableOrUnknown(
          data['consumed_by_node_key']!,
          _consumedByNodeKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_consumedByNodeKeyMeta);
    }
    if (data.containsKey('consumed_at_ms')) {
      context.handle(
        _consumedAtMsMeta,
        consumedAtMs.isAcceptableOrUnknown(
          data['consumed_at_ms']!,
          _consumedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_consumedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {nonce};
  @override
  ConsumedJoinCredential map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConsumedJoinCredential(
      nonce: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nonce'],
      )!,
      houseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}house_id'],
      )!,
      consumedByNodeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}consumed_by_node_key'],
      )!,
      consumedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}consumed_at_ms'],
      )!,
    );
  }

  @override
  $ConsumedJoinCredentialsTable createAlias(String alias) {
    return $ConsumedJoinCredentialsTable(attachedDatabase, alias);
  }
}

class ConsumedJoinCredential extends DataClass
    implements Insertable<ConsumedJoinCredential> {
  final String nonce;
  final String houseId;
  final String consumedByNodeKey;
  final int consumedAtMs;
  const ConsumedJoinCredential({
    required this.nonce,
    required this.houseId,
    required this.consumedByNodeKey,
    required this.consumedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['nonce'] = Variable<String>(nonce);
    map['house_id'] = Variable<String>(houseId);
    map['consumed_by_node_key'] = Variable<String>(consumedByNodeKey);
    map['consumed_at_ms'] = Variable<int>(consumedAtMs);
    return map;
  }

  ConsumedJoinCredentialsCompanion toCompanion(bool nullToAbsent) {
    return ConsumedJoinCredentialsCompanion(
      nonce: Value(nonce),
      houseId: Value(houseId),
      consumedByNodeKey: Value(consumedByNodeKey),
      consumedAtMs: Value(consumedAtMs),
    );
  }

  factory ConsumedJoinCredential.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConsumedJoinCredential(
      nonce: serializer.fromJson<String>(json['nonce']),
      houseId: serializer.fromJson<String>(json['houseId']),
      consumedByNodeKey: serializer.fromJson<String>(json['consumedByNodeKey']),
      consumedAtMs: serializer.fromJson<int>(json['consumedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'nonce': serializer.toJson<String>(nonce),
      'houseId': serializer.toJson<String>(houseId),
      'consumedByNodeKey': serializer.toJson<String>(consumedByNodeKey),
      'consumedAtMs': serializer.toJson<int>(consumedAtMs),
    };
  }

  ConsumedJoinCredential copyWith({
    String? nonce,
    String? houseId,
    String? consumedByNodeKey,
    int? consumedAtMs,
  }) => ConsumedJoinCredential(
    nonce: nonce ?? this.nonce,
    houseId: houseId ?? this.houseId,
    consumedByNodeKey: consumedByNodeKey ?? this.consumedByNodeKey,
    consumedAtMs: consumedAtMs ?? this.consumedAtMs,
  );
  ConsumedJoinCredential copyWithCompanion(
    ConsumedJoinCredentialsCompanion data,
  ) {
    return ConsumedJoinCredential(
      nonce: data.nonce.present ? data.nonce.value : this.nonce,
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      consumedByNodeKey: data.consumedByNodeKey.present
          ? data.consumedByNodeKey.value
          : this.consumedByNodeKey,
      consumedAtMs: data.consumedAtMs.present
          ? data.consumedAtMs.value
          : this.consumedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConsumedJoinCredential(')
          ..write('nonce: $nonce, ')
          ..write('houseId: $houseId, ')
          ..write('consumedByNodeKey: $consumedByNodeKey, ')
          ..write('consumedAtMs: $consumedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(nonce, houseId, consumedByNodeKey, consumedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConsumedJoinCredential &&
          other.nonce == this.nonce &&
          other.houseId == this.houseId &&
          other.consumedByNodeKey == this.consumedByNodeKey &&
          other.consumedAtMs == this.consumedAtMs);
}

class ConsumedJoinCredentialsCompanion
    extends UpdateCompanion<ConsumedJoinCredential> {
  final Value<String> nonce;
  final Value<String> houseId;
  final Value<String> consumedByNodeKey;
  final Value<int> consumedAtMs;
  final Value<int> rowid;
  const ConsumedJoinCredentialsCompanion({
    this.nonce = const Value.absent(),
    this.houseId = const Value.absent(),
    this.consumedByNodeKey = const Value.absent(),
    this.consumedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConsumedJoinCredentialsCompanion.insert({
    required String nonce,
    required String houseId,
    required String consumedByNodeKey,
    required int consumedAtMs,
    this.rowid = const Value.absent(),
  }) : nonce = Value(nonce),
       houseId = Value(houseId),
       consumedByNodeKey = Value(consumedByNodeKey),
       consumedAtMs = Value(consumedAtMs);
  static Insertable<ConsumedJoinCredential> custom({
    Expression<String>? nonce,
    Expression<String>? houseId,
    Expression<String>? consumedByNodeKey,
    Expression<int>? consumedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (nonce != null) 'nonce': nonce,
      if (houseId != null) 'house_id': houseId,
      if (consumedByNodeKey != null) 'consumed_by_node_key': consumedByNodeKey,
      if (consumedAtMs != null) 'consumed_at_ms': consumedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConsumedJoinCredentialsCompanion copyWith({
    Value<String>? nonce,
    Value<String>? houseId,
    Value<String>? consumedByNodeKey,
    Value<int>? consumedAtMs,
    Value<int>? rowid,
  }) {
    return ConsumedJoinCredentialsCompanion(
      nonce: nonce ?? this.nonce,
      houseId: houseId ?? this.houseId,
      consumedByNodeKey: consumedByNodeKey ?? this.consumedByNodeKey,
      consumedAtMs: consumedAtMs ?? this.consumedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (nonce.present) {
      map['nonce'] = Variable<String>(nonce.value);
    }
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (consumedByNodeKey.present) {
      map['consumed_by_node_key'] = Variable<String>(consumedByNodeKey.value);
    }
    if (consumedAtMs.present) {
      map['consumed_at_ms'] = Variable<int>(consumedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConsumedJoinCredentialsCompanion(')
          ..write('nonce: $nonce, ')
          ..write('houseId: $houseId, ')
          ..write('consumedByNodeKey: $consumedByNodeKey, ')
          ..write('consumedAtMs: $consumedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HouseJoinSecretsTable extends HouseJoinSecrets
    with TableInfo<$HouseJoinSecretsTable, HouseJoinSecret> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HouseJoinSecretsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _houseIdMeta = const VerificationMeta(
    'houseId',
  );
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
    'house_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secretBase64Meta = const VerificationMeta(
    'secretBase64',
  );
  @override
  late final GeneratedColumn<String> secretBase64 = GeneratedColumn<String>(
    'secret_base64',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [houseId, secretBase64];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'house_join_secrets';
  @override
  VerificationContext validateIntegrity(
    Insertable<HouseJoinSecret> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('house_id')) {
      context.handle(
        _houseIdMeta,
        houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('secret_base64')) {
      context.handle(
        _secretBase64Meta,
        secretBase64.isAcceptableOrUnknown(
          data['secret_base64']!,
          _secretBase64Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_secretBase64Meta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {houseId};
  @override
  HouseJoinSecret map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HouseJoinSecret(
      houseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}house_id'],
      )!,
      secretBase64: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secret_base64'],
      )!,
    );
  }

  @override
  $HouseJoinSecretsTable createAlias(String alias) {
    return $HouseJoinSecretsTable(attachedDatabase, alias);
  }
}

class HouseJoinSecret extends DataClass implements Insertable<HouseJoinSecret> {
  final String houseId;
  final String secretBase64;
  const HouseJoinSecret({required this.houseId, required this.secretBase64});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['house_id'] = Variable<String>(houseId);
    map['secret_base64'] = Variable<String>(secretBase64);
    return map;
  }

  HouseJoinSecretsCompanion toCompanion(bool nullToAbsent) {
    return HouseJoinSecretsCompanion(
      houseId: Value(houseId),
      secretBase64: Value(secretBase64),
    );
  }

  factory HouseJoinSecret.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HouseJoinSecret(
      houseId: serializer.fromJson<String>(json['houseId']),
      secretBase64: serializer.fromJson<String>(json['secretBase64']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'houseId': serializer.toJson<String>(houseId),
      'secretBase64': serializer.toJson<String>(secretBase64),
    };
  }

  HouseJoinSecret copyWith({String? houseId, String? secretBase64}) =>
      HouseJoinSecret(
        houseId: houseId ?? this.houseId,
        secretBase64: secretBase64 ?? this.secretBase64,
      );
  HouseJoinSecret copyWithCompanion(HouseJoinSecretsCompanion data) {
    return HouseJoinSecret(
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      secretBase64: data.secretBase64.present
          ? data.secretBase64.value
          : this.secretBase64,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HouseJoinSecret(')
          ..write('houseId: $houseId, ')
          ..write('secretBase64: $secretBase64')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(houseId, secretBase64);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HouseJoinSecret &&
          other.houseId == this.houseId &&
          other.secretBase64 == this.secretBase64);
}

class HouseJoinSecretsCompanion extends UpdateCompanion<HouseJoinSecret> {
  final Value<String> houseId;
  final Value<String> secretBase64;
  final Value<int> rowid;
  const HouseJoinSecretsCompanion({
    this.houseId = const Value.absent(),
    this.secretBase64 = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HouseJoinSecretsCompanion.insert({
    required String houseId,
    required String secretBase64,
    this.rowid = const Value.absent(),
  }) : houseId = Value(houseId),
       secretBase64 = Value(secretBase64);
  static Insertable<HouseJoinSecret> custom({
    Expression<String>? houseId,
    Expression<String>? secretBase64,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (houseId != null) 'house_id': houseId,
      if (secretBase64 != null) 'secret_base64': secretBase64,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HouseJoinSecretsCompanion copyWith({
    Value<String>? houseId,
    Value<String>? secretBase64,
    Value<int>? rowid,
  }) {
    return HouseJoinSecretsCompanion(
      houseId: houseId ?? this.houseId,
      secretBase64: secretBase64 ?? this.secretBase64,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (secretBase64.present) {
      map['secret_base64'] = Variable<String>(secretBase64.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HouseJoinSecretsCompanion(')
          ..write('houseId: $houseId, ')
          ..write('secretBase64: $secretBase64, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalUserSettingsTable localUserSettings =
      $LocalUserSettingsTable(this);
  late final $HouseSyncTable houseSync = $HouseSyncTable(this);
  late final $HousematesSyncTable housematesSync = $HousematesSyncTable(this);
  late final $ScoreEventsTable scoreEvents = $ScoreEventsTable(this);
  late final $RemovalProposalsSyncTable removalProposalsSync =
      $RemovalProposalsSyncTable(this);
  late final $ProposalVotesSyncTable proposalVotesSync =
      $ProposalVotesSyncTable(this);
  late final $CyclesSyncTable cyclesSync = $CyclesSyncTable(this);
  late final $TasksSyncTable tasksSync = $TasksSyncTable(this);
  late final $TaskClaimEventsTable taskClaimEvents = $TaskClaimEventsTable(
    this,
  );
  late final $AuditLogAppendOnlyTable auditLogAppendOnly =
      $AuditLogAppendOnlyTable(this);
  late final $SyncOutboxEntriesTable syncOutboxEntries =
      $SyncOutboxEntriesTable(this);
  late final $SyncAppliedOpsTable syncAppliedOps = $SyncAppliedOpsTable(this);
  late final $SyncPeerStateTable syncPeerState = $SyncPeerStateTable(this);
  late final $SyncPeerAllowlistTable syncPeerAllowlist =
      $SyncPeerAllowlistTable(this);
  late final $ConsumedJoinCredentialsTable consumedJoinCredentials =
      $ConsumedJoinCredentialsTable(this);
  late final $HouseJoinSecretsTable houseJoinSecrets = $HouseJoinSecretsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localUserSettings,
    houseSync,
    housematesSync,
    scoreEvents,
    removalProposalsSync,
    proposalVotesSync,
    cyclesSync,
    tasksSync,
    taskClaimEvents,
    auditLogAppendOnly,
    syncOutboxEntries,
    syncAppliedOps,
    syncPeerState,
    syncPeerAllowlist,
    consumedJoinCredentials,
    houseJoinSecrets,
  ];
}

typedef $$LocalUserSettingsTableCreateCompanionBuilder =
    LocalUserSettingsCompanion Function({
      required String deviceId,
      Value<String> tailscaleNodeId,
      Value<String?> activeHouseId,
      required Uint8List createdAtHlc,
      Value<int> rowid,
    });
typedef $$LocalUserSettingsTableUpdateCompanionBuilder =
    LocalUserSettingsCompanion Function({
      Value<String> deviceId,
      Value<String> tailscaleNodeId,
      Value<String?> activeHouseId,
      Value<Uint8List> createdAtHlc,
      Value<int> rowid,
    });

class $$LocalUserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUserSettingsTable> {
  $$LocalUserSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tailscaleNodeId => $composableBuilder(
    column: $table.tailscaleNodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeHouseId => $composableBuilder(
    column: $table.activeHouseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get createdAtHlc => $composableBuilder(
    column: $table.createdAtHlc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalUserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUserSettingsTable> {
  $$LocalUserSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tailscaleNodeId => $composableBuilder(
    column: $table.tailscaleNodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeHouseId => $composableBuilder(
    column: $table.activeHouseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get createdAtHlc => $composableBuilder(
    column: $table.createdAtHlc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalUserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUserSettingsTable> {
  $$LocalUserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get tailscaleNodeId => $composableBuilder(
    column: $table.tailscaleNodeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activeHouseId => $composableBuilder(
    column: $table.activeHouseId,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get createdAtHlc => $composableBuilder(
    column: $table.createdAtHlc,
    builder: (column) => column,
  );
}

class $$LocalUserSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalUserSettingsTable,
          LocalUserSetting,
          $$LocalUserSettingsTableFilterComposer,
          $$LocalUserSettingsTableOrderingComposer,
          $$LocalUserSettingsTableAnnotationComposer,
          $$LocalUserSettingsTableCreateCompanionBuilder,
          $$LocalUserSettingsTableUpdateCompanionBuilder,
          (
            LocalUserSetting,
            BaseReferences<
              _$AppDatabase,
              $LocalUserSettingsTable,
              LocalUserSetting
            >,
          ),
          LocalUserSetting,
          PrefetchHooks Function()
        > {
  $$LocalUserSettingsTableTableManager(
    _$AppDatabase db,
    $LocalUserSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUserSettingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> deviceId = const Value.absent(),
                Value<String> tailscaleNodeId = const Value.absent(),
                Value<String?> activeHouseId = const Value.absent(),
                Value<Uint8List> createdAtHlc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUserSettingsCompanion(
                deviceId: deviceId,
                tailscaleNodeId: tailscaleNodeId,
                activeHouseId: activeHouseId,
                createdAtHlc: createdAtHlc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deviceId,
                Value<String> tailscaleNodeId = const Value.absent(),
                Value<String?> activeHouseId = const Value.absent(),
                required Uint8List createdAtHlc,
                Value<int> rowid = const Value.absent(),
              }) => LocalUserSettingsCompanion.insert(
                deviceId: deviceId,
                tailscaleNodeId: tailscaleNodeId,
                activeHouseId: activeHouseId,
                createdAtHlc: createdAtHlc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalUserSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalUserSettingsTable,
      LocalUserSetting,
      $$LocalUserSettingsTableFilterComposer,
      $$LocalUserSettingsTableOrderingComposer,
      $$LocalUserSettingsTableAnnotationComposer,
      $$LocalUserSettingsTableCreateCompanionBuilder,
      $$LocalUserSettingsTableUpdateCompanionBuilder,
      (
        LocalUserSetting,
        BaseReferences<
          _$AppDatabase,
          $LocalUserSettingsTable,
          LocalUserSetting
        >,
      ),
      LocalUserSetting,
      PrefetchHooks Function()
    >;
typedef $$HouseSyncTableCreateCompanionBuilder =
    HouseSyncCompanion Function({
      required String houseId,
      required String displayName,
      required String creatorMemberId,
      Value<int> rulesVersion,
      required Uint8List createdAtHlc,
      required Uint8List updatedAtHlc,
      Value<Uint8List?> displayNameHlc,
      Value<String?> displayNameDeviceId,
      Value<Uint8List?> rulesVersionHlc,
      Value<String?> rulesVersionDeviceId,
      Value<String> privilegeTemplates,
      Value<Uint8List?> privilegeTemplatesHlc,
      Value<String?> privilegeTemplatesDeviceId,
      Value<int> rowid,
    });
typedef $$HouseSyncTableUpdateCompanionBuilder =
    HouseSyncCompanion Function({
      Value<String> houseId,
      Value<String> displayName,
      Value<String> creatorMemberId,
      Value<int> rulesVersion,
      Value<Uint8List> createdAtHlc,
      Value<Uint8List> updatedAtHlc,
      Value<Uint8List?> displayNameHlc,
      Value<String?> displayNameDeviceId,
      Value<Uint8List?> rulesVersionHlc,
      Value<String?> rulesVersionDeviceId,
      Value<String> privilegeTemplates,
      Value<Uint8List?> privilegeTemplatesHlc,
      Value<String?> privilegeTemplatesDeviceId,
      Value<int> rowid,
    });

class $$HouseSyncTableFilterComposer
    extends Composer<_$AppDatabase, $HouseSyncTable> {
  $$HouseSyncTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creatorMemberId => $composableBuilder(
    column: $table.creatorMemberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rulesVersion => $composableBuilder(
    column: $table.rulesVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get createdAtHlc => $composableBuilder(
    column: $table.createdAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get displayNameHlc => $composableBuilder(
    column: $table.displayNameHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayNameDeviceId => $composableBuilder(
    column: $table.displayNameDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get rulesVersionHlc => $composableBuilder(
    column: $table.rulesVersionHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rulesVersionDeviceId => $composableBuilder(
    column: $table.rulesVersionDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privilegeTemplates => $composableBuilder(
    column: $table.privilegeTemplates,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get privilegeTemplatesHlc => $composableBuilder(
    column: $table.privilegeTemplatesHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privilegeTemplatesDeviceId => $composableBuilder(
    column: $table.privilegeTemplatesDeviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HouseSyncTableOrderingComposer
    extends Composer<_$AppDatabase, $HouseSyncTable> {
  $$HouseSyncTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creatorMemberId => $composableBuilder(
    column: $table.creatorMemberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rulesVersion => $composableBuilder(
    column: $table.rulesVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get createdAtHlc => $composableBuilder(
    column: $table.createdAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get displayNameHlc => $composableBuilder(
    column: $table.displayNameHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayNameDeviceId => $composableBuilder(
    column: $table.displayNameDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get rulesVersionHlc => $composableBuilder(
    column: $table.rulesVersionHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rulesVersionDeviceId => $composableBuilder(
    column: $table.rulesVersionDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privilegeTemplates => $composableBuilder(
    column: $table.privilegeTemplates,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get privilegeTemplatesHlc => $composableBuilder(
    column: $table.privilegeTemplatesHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privilegeTemplatesDeviceId => $composableBuilder(
    column: $table.privilegeTemplatesDeviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HouseSyncTableAnnotationComposer
    extends Composer<_$AppDatabase, $HouseSyncTable> {
  $$HouseSyncTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get houseId =>
      $composableBuilder(column: $table.houseId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get creatorMemberId => $composableBuilder(
    column: $table.creatorMemberId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rulesVersion => $composableBuilder(
    column: $table.rulesVersion,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get createdAtHlc => $composableBuilder(
    column: $table.createdAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get displayNameHlc => $composableBuilder(
    column: $table.displayNameHlc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayNameDeviceId => $composableBuilder(
    column: $table.displayNameDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get rulesVersionHlc => $composableBuilder(
    column: $table.rulesVersionHlc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rulesVersionDeviceId => $composableBuilder(
    column: $table.rulesVersionDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get privilegeTemplates => $composableBuilder(
    column: $table.privilegeTemplates,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get privilegeTemplatesHlc => $composableBuilder(
    column: $table.privilegeTemplatesHlc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get privilegeTemplatesDeviceId => $composableBuilder(
    column: $table.privilegeTemplatesDeviceId,
    builder: (column) => column,
  );
}

class $$HouseSyncTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HouseSyncTable,
          HouseSyncData,
          $$HouseSyncTableFilterComposer,
          $$HouseSyncTableOrderingComposer,
          $$HouseSyncTableAnnotationComposer,
          $$HouseSyncTableCreateCompanionBuilder,
          $$HouseSyncTableUpdateCompanionBuilder,
          (
            HouseSyncData,
            BaseReferences<_$AppDatabase, $HouseSyncTable, HouseSyncData>,
          ),
          HouseSyncData,
          PrefetchHooks Function()
        > {
  $$HouseSyncTableTableManager(_$AppDatabase db, $HouseSyncTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HouseSyncTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HouseSyncTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HouseSyncTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> houseId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> creatorMemberId = const Value.absent(),
                Value<int> rulesVersion = const Value.absent(),
                Value<Uint8List> createdAtHlc = const Value.absent(),
                Value<Uint8List> updatedAtHlc = const Value.absent(),
                Value<Uint8List?> displayNameHlc = const Value.absent(),
                Value<String?> displayNameDeviceId = const Value.absent(),
                Value<Uint8List?> rulesVersionHlc = const Value.absent(),
                Value<String?> rulesVersionDeviceId = const Value.absent(),
                Value<String> privilegeTemplates = const Value.absent(),
                Value<Uint8List?> privilegeTemplatesHlc = const Value.absent(),
                Value<String?> privilegeTemplatesDeviceId =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HouseSyncCompanion(
                houseId: houseId,
                displayName: displayName,
                creatorMemberId: creatorMemberId,
                rulesVersion: rulesVersion,
                createdAtHlc: createdAtHlc,
                updatedAtHlc: updatedAtHlc,
                displayNameHlc: displayNameHlc,
                displayNameDeviceId: displayNameDeviceId,
                rulesVersionHlc: rulesVersionHlc,
                rulesVersionDeviceId: rulesVersionDeviceId,
                privilegeTemplates: privilegeTemplates,
                privilegeTemplatesHlc: privilegeTemplatesHlc,
                privilegeTemplatesDeviceId: privilegeTemplatesDeviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String houseId,
                required String displayName,
                required String creatorMemberId,
                Value<int> rulesVersion = const Value.absent(),
                required Uint8List createdAtHlc,
                required Uint8List updatedAtHlc,
                Value<Uint8List?> displayNameHlc = const Value.absent(),
                Value<String?> displayNameDeviceId = const Value.absent(),
                Value<Uint8List?> rulesVersionHlc = const Value.absent(),
                Value<String?> rulesVersionDeviceId = const Value.absent(),
                Value<String> privilegeTemplates = const Value.absent(),
                Value<Uint8List?> privilegeTemplatesHlc = const Value.absent(),
                Value<String?> privilegeTemplatesDeviceId =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HouseSyncCompanion.insert(
                houseId: houseId,
                displayName: displayName,
                creatorMemberId: creatorMemberId,
                rulesVersion: rulesVersion,
                createdAtHlc: createdAtHlc,
                updatedAtHlc: updatedAtHlc,
                displayNameHlc: displayNameHlc,
                displayNameDeviceId: displayNameDeviceId,
                rulesVersionHlc: rulesVersionHlc,
                rulesVersionDeviceId: rulesVersionDeviceId,
                privilegeTemplates: privilegeTemplates,
                privilegeTemplatesHlc: privilegeTemplatesHlc,
                privilegeTemplatesDeviceId: privilegeTemplatesDeviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HouseSyncTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HouseSyncTable,
      HouseSyncData,
      $$HouseSyncTableFilterComposer,
      $$HouseSyncTableOrderingComposer,
      $$HouseSyncTableAnnotationComposer,
      $$HouseSyncTableCreateCompanionBuilder,
      $$HouseSyncTableUpdateCompanionBuilder,
      (
        HouseSyncData,
        BaseReferences<_$AppDatabase, $HouseSyncTable, HouseSyncData>,
      ),
      HouseSyncData,
      PrefetchHooks Function()
    >;
typedef $$HousematesSyncTableCreateCompanionBuilder =
    HousematesSyncCompanion Function({
      required String memberId,
      required String houseId,
      required String tailscaleUserId,
      required String tailscaleNodeKey,
      required String nickname,
      Value<int> lifetimeScore,
      Value<int?> rotationOrderIndex,
      required String memberStatus,
      Value<Uint8List?> evictedAtHlc,
      required Uint8List updatedAtHlc,
      Value<Uint8List?> nicknameHlc,
      Value<String?> nicknameDeviceId,
      Value<int> rowid,
    });
typedef $$HousematesSyncTableUpdateCompanionBuilder =
    HousematesSyncCompanion Function({
      Value<String> memberId,
      Value<String> houseId,
      Value<String> tailscaleUserId,
      Value<String> tailscaleNodeKey,
      Value<String> nickname,
      Value<int> lifetimeScore,
      Value<int?> rotationOrderIndex,
      Value<String> memberStatus,
      Value<Uint8List?> evictedAtHlc,
      Value<Uint8List> updatedAtHlc,
      Value<Uint8List?> nicknameHlc,
      Value<String?> nicknameDeviceId,
      Value<int> rowid,
    });

class $$HousematesSyncTableFilterComposer
    extends Composer<_$AppDatabase, $HousematesSyncTable> {
  $$HousematesSyncTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tailscaleUserId => $composableBuilder(
    column: $table.tailscaleUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tailscaleNodeKey => $composableBuilder(
    column: $table.tailscaleNodeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lifetimeScore => $composableBuilder(
    column: $table.lifetimeScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rotationOrderIndex => $composableBuilder(
    column: $table.rotationOrderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberStatus => $composableBuilder(
    column: $table.memberStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get evictedAtHlc => $composableBuilder(
    column: $table.evictedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get nicknameHlc => $composableBuilder(
    column: $table.nicknameHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nicknameDeviceId => $composableBuilder(
    column: $table.nicknameDeviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HousematesSyncTableOrderingComposer
    extends Composer<_$AppDatabase, $HousematesSyncTable> {
  $$HousematesSyncTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tailscaleUserId => $composableBuilder(
    column: $table.tailscaleUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tailscaleNodeKey => $composableBuilder(
    column: $table.tailscaleNodeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lifetimeScore => $composableBuilder(
    column: $table.lifetimeScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rotationOrderIndex => $composableBuilder(
    column: $table.rotationOrderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberStatus => $composableBuilder(
    column: $table.memberStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get evictedAtHlc => $composableBuilder(
    column: $table.evictedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get nicknameHlc => $composableBuilder(
    column: $table.nicknameHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nicknameDeviceId => $composableBuilder(
    column: $table.nicknameDeviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HousematesSyncTableAnnotationComposer
    extends Composer<_$AppDatabase, $HousematesSyncTable> {
  $$HousematesSyncTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get houseId =>
      $composableBuilder(column: $table.houseId, builder: (column) => column);

  GeneratedColumn<String> get tailscaleUserId => $composableBuilder(
    column: $table.tailscaleUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tailscaleNodeKey => $composableBuilder(
    column: $table.tailscaleNodeKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<int> get lifetimeScore => $composableBuilder(
    column: $table.lifetimeScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rotationOrderIndex => $composableBuilder(
    column: $table.rotationOrderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memberStatus => $composableBuilder(
    column: $table.memberStatus,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get evictedAtHlc => $composableBuilder(
    column: $table.evictedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get nicknameHlc => $composableBuilder(
    column: $table.nicknameHlc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nicknameDeviceId => $composableBuilder(
    column: $table.nicknameDeviceId,
    builder: (column) => column,
  );
}

class $$HousematesSyncTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HousematesSyncTable,
          HousematesSyncData,
          $$HousematesSyncTableFilterComposer,
          $$HousematesSyncTableOrderingComposer,
          $$HousematesSyncTableAnnotationComposer,
          $$HousematesSyncTableCreateCompanionBuilder,
          $$HousematesSyncTableUpdateCompanionBuilder,
          (
            HousematesSyncData,
            BaseReferences<
              _$AppDatabase,
              $HousematesSyncTable,
              HousematesSyncData
            >,
          ),
          HousematesSyncData,
          PrefetchHooks Function()
        > {
  $$HousematesSyncTableTableManager(
    _$AppDatabase db,
    $HousematesSyncTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HousematesSyncTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HousematesSyncTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HousematesSyncTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> memberId = const Value.absent(),
                Value<String> houseId = const Value.absent(),
                Value<String> tailscaleUserId = const Value.absent(),
                Value<String> tailscaleNodeKey = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<int> lifetimeScore = const Value.absent(),
                Value<int?> rotationOrderIndex = const Value.absent(),
                Value<String> memberStatus = const Value.absent(),
                Value<Uint8List?> evictedAtHlc = const Value.absent(),
                Value<Uint8List> updatedAtHlc = const Value.absent(),
                Value<Uint8List?> nicknameHlc = const Value.absent(),
                Value<String?> nicknameDeviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HousematesSyncCompanion(
                memberId: memberId,
                houseId: houseId,
                tailscaleUserId: tailscaleUserId,
                tailscaleNodeKey: tailscaleNodeKey,
                nickname: nickname,
                lifetimeScore: lifetimeScore,
                rotationOrderIndex: rotationOrderIndex,
                memberStatus: memberStatus,
                evictedAtHlc: evictedAtHlc,
                updatedAtHlc: updatedAtHlc,
                nicknameHlc: nicknameHlc,
                nicknameDeviceId: nicknameDeviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String memberId,
                required String houseId,
                required String tailscaleUserId,
                required String tailscaleNodeKey,
                required String nickname,
                Value<int> lifetimeScore = const Value.absent(),
                Value<int?> rotationOrderIndex = const Value.absent(),
                required String memberStatus,
                Value<Uint8List?> evictedAtHlc = const Value.absent(),
                required Uint8List updatedAtHlc,
                Value<Uint8List?> nicknameHlc = const Value.absent(),
                Value<String?> nicknameDeviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HousematesSyncCompanion.insert(
                memberId: memberId,
                houseId: houseId,
                tailscaleUserId: tailscaleUserId,
                tailscaleNodeKey: tailscaleNodeKey,
                nickname: nickname,
                lifetimeScore: lifetimeScore,
                rotationOrderIndex: rotationOrderIndex,
                memberStatus: memberStatus,
                evictedAtHlc: evictedAtHlc,
                updatedAtHlc: updatedAtHlc,
                nicknameHlc: nicknameHlc,
                nicknameDeviceId: nicknameDeviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HousematesSyncTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HousematesSyncTable,
      HousematesSyncData,
      $$HousematesSyncTableFilterComposer,
      $$HousematesSyncTableOrderingComposer,
      $$HousematesSyncTableAnnotationComposer,
      $$HousematesSyncTableCreateCompanionBuilder,
      $$HousematesSyncTableUpdateCompanionBuilder,
      (
        HousematesSyncData,
        BaseReferences<_$AppDatabase, $HousematesSyncTable, HousematesSyncData>,
      ),
      HousematesSyncData,
      PrefetchHooks Function()
    >;
typedef $$ScoreEventsTableCreateCompanionBuilder =
    ScoreEventsCompanion Function({
      required String eventId,
      required String houseId,
      required String memberId,
      required int delta,
      Value<String?> reasonRef,
      required Uint8List hlc,
      required String actorDeviceId,
      Value<int> rowid,
    });
typedef $$ScoreEventsTableUpdateCompanionBuilder =
    ScoreEventsCompanion Function({
      Value<String> eventId,
      Value<String> houseId,
      Value<String> memberId,
      Value<int> delta,
      Value<String?> reasonRef,
      Value<Uint8List> hlc,
      Value<String> actorDeviceId,
      Value<int> rowid,
    });

class $$ScoreEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ScoreEventsTable> {
  $$ScoreEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reasonRef => $composableBuilder(
    column: $table.reasonRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorDeviceId => $composableBuilder(
    column: $table.actorDeviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScoreEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScoreEventsTable> {
  $$ScoreEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reasonRef => $composableBuilder(
    column: $table.reasonRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorDeviceId => $composableBuilder(
    column: $table.actorDeviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScoreEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScoreEventsTable> {
  $$ScoreEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get houseId =>
      $composableBuilder(column: $table.houseId, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<int> get delta =>
      $composableBuilder(column: $table.delta, builder: (column) => column);

  GeneratedColumn<String> get reasonRef =>
      $composableBuilder(column: $table.reasonRef, builder: (column) => column);

  GeneratedColumn<Uint8List> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<String> get actorDeviceId => $composableBuilder(
    column: $table.actorDeviceId,
    builder: (column) => column,
  );
}

class $$ScoreEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScoreEventsTable,
          ScoreEvent,
          $$ScoreEventsTableFilterComposer,
          $$ScoreEventsTableOrderingComposer,
          $$ScoreEventsTableAnnotationComposer,
          $$ScoreEventsTableCreateCompanionBuilder,
          $$ScoreEventsTableUpdateCompanionBuilder,
          (
            ScoreEvent,
            BaseReferences<_$AppDatabase, $ScoreEventsTable, ScoreEvent>,
          ),
          ScoreEvent,
          PrefetchHooks Function()
        > {
  $$ScoreEventsTableTableManager(_$AppDatabase db, $ScoreEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScoreEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScoreEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScoreEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> houseId = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<int> delta = const Value.absent(),
                Value<String?> reasonRef = const Value.absent(),
                Value<Uint8List> hlc = const Value.absent(),
                Value<String> actorDeviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScoreEventsCompanion(
                eventId: eventId,
                houseId: houseId,
                memberId: memberId,
                delta: delta,
                reasonRef: reasonRef,
                hlc: hlc,
                actorDeviceId: actorDeviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String houseId,
                required String memberId,
                required int delta,
                Value<String?> reasonRef = const Value.absent(),
                required Uint8List hlc,
                required String actorDeviceId,
                Value<int> rowid = const Value.absent(),
              }) => ScoreEventsCompanion.insert(
                eventId: eventId,
                houseId: houseId,
                memberId: memberId,
                delta: delta,
                reasonRef: reasonRef,
                hlc: hlc,
                actorDeviceId: actorDeviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScoreEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScoreEventsTable,
      ScoreEvent,
      $$ScoreEventsTableFilterComposer,
      $$ScoreEventsTableOrderingComposer,
      $$ScoreEventsTableAnnotationComposer,
      $$ScoreEventsTableCreateCompanionBuilder,
      $$ScoreEventsTableUpdateCompanionBuilder,
      (
        ScoreEvent,
        BaseReferences<_$AppDatabase, $ScoreEventsTable, ScoreEvent>,
      ),
      ScoreEvent,
      PrefetchHooks Function()
    >;
typedef $$RemovalProposalsSyncTableCreateCompanionBuilder =
    RemovalProposalsSyncCompanion Function({
      required String proposalId,
      required String houseId,
      required String targetMemberId,
      Value<String?> proposerMemberId,
      required String type,
      required String status,
      required Uint8List createdAtHlc,
      required Uint8List updatedAtHlc,
      Value<Uint8List?> statusHlc,
      Value<String?> statusDeviceId,
      Value<int> rowid,
    });
typedef $$RemovalProposalsSyncTableUpdateCompanionBuilder =
    RemovalProposalsSyncCompanion Function({
      Value<String> proposalId,
      Value<String> houseId,
      Value<String> targetMemberId,
      Value<String?> proposerMemberId,
      Value<String> type,
      Value<String> status,
      Value<Uint8List> createdAtHlc,
      Value<Uint8List> updatedAtHlc,
      Value<Uint8List?> statusHlc,
      Value<String?> statusDeviceId,
      Value<int> rowid,
    });

class $$RemovalProposalsSyncTableFilterComposer
    extends Composer<_$AppDatabase, $RemovalProposalsSyncTable> {
  $$RemovalProposalsSyncTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get proposalId => $composableBuilder(
    column: $table.proposalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetMemberId => $composableBuilder(
    column: $table.targetMemberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proposerMemberId => $composableBuilder(
    column: $table.proposerMemberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get createdAtHlc => $composableBuilder(
    column: $table.createdAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get statusHlc => $composableBuilder(
    column: $table.statusHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusDeviceId => $composableBuilder(
    column: $table.statusDeviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RemovalProposalsSyncTableOrderingComposer
    extends Composer<_$AppDatabase, $RemovalProposalsSyncTable> {
  $$RemovalProposalsSyncTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get proposalId => $composableBuilder(
    column: $table.proposalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetMemberId => $composableBuilder(
    column: $table.targetMemberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proposerMemberId => $composableBuilder(
    column: $table.proposerMemberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get createdAtHlc => $composableBuilder(
    column: $table.createdAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get statusHlc => $composableBuilder(
    column: $table.statusHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusDeviceId => $composableBuilder(
    column: $table.statusDeviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemovalProposalsSyncTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemovalProposalsSyncTable> {
  $$RemovalProposalsSyncTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get proposalId => $composableBuilder(
    column: $table.proposalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get houseId =>
      $composableBuilder(column: $table.houseId, builder: (column) => column);

  GeneratedColumn<String> get targetMemberId => $composableBuilder(
    column: $table.targetMemberId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get proposerMemberId => $composableBuilder(
    column: $table.proposerMemberId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<Uint8List> get createdAtHlc => $composableBuilder(
    column: $table.createdAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get statusHlc =>
      $composableBuilder(column: $table.statusHlc, builder: (column) => column);

  GeneratedColumn<String> get statusDeviceId => $composableBuilder(
    column: $table.statusDeviceId,
    builder: (column) => column,
  );
}

class $$RemovalProposalsSyncTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemovalProposalsSyncTable,
          RemovalProposalsSyncData,
          $$RemovalProposalsSyncTableFilterComposer,
          $$RemovalProposalsSyncTableOrderingComposer,
          $$RemovalProposalsSyncTableAnnotationComposer,
          $$RemovalProposalsSyncTableCreateCompanionBuilder,
          $$RemovalProposalsSyncTableUpdateCompanionBuilder,
          (
            RemovalProposalsSyncData,
            BaseReferences<
              _$AppDatabase,
              $RemovalProposalsSyncTable,
              RemovalProposalsSyncData
            >,
          ),
          RemovalProposalsSyncData,
          PrefetchHooks Function()
        > {
  $$RemovalProposalsSyncTableTableManager(
    _$AppDatabase db,
    $RemovalProposalsSyncTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemovalProposalsSyncTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemovalProposalsSyncTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RemovalProposalsSyncTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> proposalId = const Value.absent(),
                Value<String> houseId = const Value.absent(),
                Value<String> targetMemberId = const Value.absent(),
                Value<String?> proposerMemberId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<Uint8List> createdAtHlc = const Value.absent(),
                Value<Uint8List> updatedAtHlc = const Value.absent(),
                Value<Uint8List?> statusHlc = const Value.absent(),
                Value<String?> statusDeviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemovalProposalsSyncCompanion(
                proposalId: proposalId,
                houseId: houseId,
                targetMemberId: targetMemberId,
                proposerMemberId: proposerMemberId,
                type: type,
                status: status,
                createdAtHlc: createdAtHlc,
                updatedAtHlc: updatedAtHlc,
                statusHlc: statusHlc,
                statusDeviceId: statusDeviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String proposalId,
                required String houseId,
                required String targetMemberId,
                Value<String?> proposerMemberId = const Value.absent(),
                required String type,
                required String status,
                required Uint8List createdAtHlc,
                required Uint8List updatedAtHlc,
                Value<Uint8List?> statusHlc = const Value.absent(),
                Value<String?> statusDeviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemovalProposalsSyncCompanion.insert(
                proposalId: proposalId,
                houseId: houseId,
                targetMemberId: targetMemberId,
                proposerMemberId: proposerMemberId,
                type: type,
                status: status,
                createdAtHlc: createdAtHlc,
                updatedAtHlc: updatedAtHlc,
                statusHlc: statusHlc,
                statusDeviceId: statusDeviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemovalProposalsSyncTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemovalProposalsSyncTable,
      RemovalProposalsSyncData,
      $$RemovalProposalsSyncTableFilterComposer,
      $$RemovalProposalsSyncTableOrderingComposer,
      $$RemovalProposalsSyncTableAnnotationComposer,
      $$RemovalProposalsSyncTableCreateCompanionBuilder,
      $$RemovalProposalsSyncTableUpdateCompanionBuilder,
      (
        RemovalProposalsSyncData,
        BaseReferences<
          _$AppDatabase,
          $RemovalProposalsSyncTable,
          RemovalProposalsSyncData
        >,
      ),
      RemovalProposalsSyncData,
      PrefetchHooks Function()
    >;
typedef $$ProposalVotesSyncTableCreateCompanionBuilder =
    ProposalVotesSyncCompanion Function({
      required String voteId,
      required String houseId,
      required String proposalId,
      required String voterMemberId,
      required int voteCast,
      required Uint8List hlc,
      Value<String?> originDeviceId,
      Value<int> rowid,
    });
typedef $$ProposalVotesSyncTableUpdateCompanionBuilder =
    ProposalVotesSyncCompanion Function({
      Value<String> voteId,
      Value<String> houseId,
      Value<String> proposalId,
      Value<String> voterMemberId,
      Value<int> voteCast,
      Value<Uint8List> hlc,
      Value<String?> originDeviceId,
      Value<int> rowid,
    });

class $$ProposalVotesSyncTableFilterComposer
    extends Composer<_$AppDatabase, $ProposalVotesSyncTable> {
  $$ProposalVotesSyncTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get voteId => $composableBuilder(
    column: $table.voteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proposalId => $composableBuilder(
    column: $table.proposalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voterMemberId => $composableBuilder(
    column: $table.voterMemberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get voteCast => $composableBuilder(
    column: $table.voteCast,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProposalVotesSyncTableOrderingComposer
    extends Composer<_$AppDatabase, $ProposalVotesSyncTable> {
  $$ProposalVotesSyncTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get voteId => $composableBuilder(
    column: $table.voteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proposalId => $composableBuilder(
    column: $table.proposalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voterMemberId => $composableBuilder(
    column: $table.voterMemberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get voteCast => $composableBuilder(
    column: $table.voteCast,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProposalVotesSyncTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProposalVotesSyncTable> {
  $$ProposalVotesSyncTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get voteId =>
      $composableBuilder(column: $table.voteId, builder: (column) => column);

  GeneratedColumn<String> get houseId =>
      $composableBuilder(column: $table.houseId, builder: (column) => column);

  GeneratedColumn<String> get proposalId => $composableBuilder(
    column: $table.proposalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get voterMemberId => $composableBuilder(
    column: $table.voterMemberId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get voteCast =>
      $composableBuilder(column: $table.voteCast, builder: (column) => column);

  GeneratedColumn<Uint8List> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );
}

class $$ProposalVotesSyncTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProposalVotesSyncTable,
          ProposalVotesSyncData,
          $$ProposalVotesSyncTableFilterComposer,
          $$ProposalVotesSyncTableOrderingComposer,
          $$ProposalVotesSyncTableAnnotationComposer,
          $$ProposalVotesSyncTableCreateCompanionBuilder,
          $$ProposalVotesSyncTableUpdateCompanionBuilder,
          (
            ProposalVotesSyncData,
            BaseReferences<
              _$AppDatabase,
              $ProposalVotesSyncTable,
              ProposalVotesSyncData
            >,
          ),
          ProposalVotesSyncData,
          PrefetchHooks Function()
        > {
  $$ProposalVotesSyncTableTableManager(
    _$AppDatabase db,
    $ProposalVotesSyncTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProposalVotesSyncTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProposalVotesSyncTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProposalVotesSyncTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> voteId = const Value.absent(),
                Value<String> houseId = const Value.absent(),
                Value<String> proposalId = const Value.absent(),
                Value<String> voterMemberId = const Value.absent(),
                Value<int> voteCast = const Value.absent(),
                Value<Uint8List> hlc = const Value.absent(),
                Value<String?> originDeviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProposalVotesSyncCompanion(
                voteId: voteId,
                houseId: houseId,
                proposalId: proposalId,
                voterMemberId: voterMemberId,
                voteCast: voteCast,
                hlc: hlc,
                originDeviceId: originDeviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String voteId,
                required String houseId,
                required String proposalId,
                required String voterMemberId,
                required int voteCast,
                required Uint8List hlc,
                Value<String?> originDeviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProposalVotesSyncCompanion.insert(
                voteId: voteId,
                houseId: houseId,
                proposalId: proposalId,
                voterMemberId: voterMemberId,
                voteCast: voteCast,
                hlc: hlc,
                originDeviceId: originDeviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProposalVotesSyncTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProposalVotesSyncTable,
      ProposalVotesSyncData,
      $$ProposalVotesSyncTableFilterComposer,
      $$ProposalVotesSyncTableOrderingComposer,
      $$ProposalVotesSyncTableAnnotationComposer,
      $$ProposalVotesSyncTableCreateCompanionBuilder,
      $$ProposalVotesSyncTableUpdateCompanionBuilder,
      (
        ProposalVotesSyncData,
        BaseReferences<
          _$AppDatabase,
          $ProposalVotesSyncTable,
          ProposalVotesSyncData
        >,
      ),
      ProposalVotesSyncData,
      PrefetchHooks Function()
    >;
typedef $$CyclesSyncTableCreateCompanionBuilder =
    CyclesSyncCompanion Function({
      required String cycleId,
      required String houseId,
      required String activeGuardianMemberId,
      required String status,
      Value<String> ceremonySignoffs,
      Value<int> rulesVersionAtSignoff,
      required Uint8List updatedAtHlc,
      Value<Uint8List?> statusHlc,
      Value<String?> statusDeviceId,
      Value<Uint8List?> guardianHlc,
      Value<String?> guardianDeviceId,
      Value<Uint8List?> rulesVersionAtSignoffHlc,
      Value<String?> rulesVersionAtSignoffDeviceId,
      Value<int> rowid,
    });
typedef $$CyclesSyncTableUpdateCompanionBuilder =
    CyclesSyncCompanion Function({
      Value<String> cycleId,
      Value<String> houseId,
      Value<String> activeGuardianMemberId,
      Value<String> status,
      Value<String> ceremonySignoffs,
      Value<int> rulesVersionAtSignoff,
      Value<Uint8List> updatedAtHlc,
      Value<Uint8List?> statusHlc,
      Value<String?> statusDeviceId,
      Value<Uint8List?> guardianHlc,
      Value<String?> guardianDeviceId,
      Value<Uint8List?> rulesVersionAtSignoffHlc,
      Value<String?> rulesVersionAtSignoffDeviceId,
      Value<int> rowid,
    });

class $$CyclesSyncTableFilterComposer
    extends Composer<_$AppDatabase, $CyclesSyncTable> {
  $$CyclesSyncTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cycleId => $composableBuilder(
    column: $table.cycleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeGuardianMemberId => $composableBuilder(
    column: $table.activeGuardianMemberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ceremonySignoffs => $composableBuilder(
    column: $table.ceremonySignoffs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rulesVersionAtSignoff => $composableBuilder(
    column: $table.rulesVersionAtSignoff,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get statusHlc => $composableBuilder(
    column: $table.statusHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusDeviceId => $composableBuilder(
    column: $table.statusDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get guardianHlc => $composableBuilder(
    column: $table.guardianHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guardianDeviceId => $composableBuilder(
    column: $table.guardianDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get rulesVersionAtSignoffHlc => $composableBuilder(
    column: $table.rulesVersionAtSignoffHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rulesVersionAtSignoffDeviceId => $composableBuilder(
    column: $table.rulesVersionAtSignoffDeviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CyclesSyncTableOrderingComposer
    extends Composer<_$AppDatabase, $CyclesSyncTable> {
  $$CyclesSyncTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cycleId => $composableBuilder(
    column: $table.cycleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeGuardianMemberId => $composableBuilder(
    column: $table.activeGuardianMemberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ceremonySignoffs => $composableBuilder(
    column: $table.ceremonySignoffs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rulesVersionAtSignoff => $composableBuilder(
    column: $table.rulesVersionAtSignoff,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get statusHlc => $composableBuilder(
    column: $table.statusHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusDeviceId => $composableBuilder(
    column: $table.statusDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get guardianHlc => $composableBuilder(
    column: $table.guardianHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guardianDeviceId => $composableBuilder(
    column: $table.guardianDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get rulesVersionAtSignoffHlc => $composableBuilder(
    column: $table.rulesVersionAtSignoffHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rulesVersionAtSignoffDeviceId =>
      $composableBuilder(
        column: $table.rulesVersionAtSignoffDeviceId,
        builder: (column) => ColumnOrderings(column),
      );
}

class $$CyclesSyncTableAnnotationComposer
    extends Composer<_$AppDatabase, $CyclesSyncTable> {
  $$CyclesSyncTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cycleId =>
      $composableBuilder(column: $table.cycleId, builder: (column) => column);

  GeneratedColumn<String> get houseId =>
      $composableBuilder(column: $table.houseId, builder: (column) => column);

  GeneratedColumn<String> get activeGuardianMemberId => $composableBuilder(
    column: $table.activeGuardianMemberId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get ceremonySignoffs => $composableBuilder(
    column: $table.ceremonySignoffs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rulesVersionAtSignoff => $composableBuilder(
    column: $table.rulesVersionAtSignoff,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get statusHlc =>
      $composableBuilder(column: $table.statusHlc, builder: (column) => column);

  GeneratedColumn<String> get statusDeviceId => $composableBuilder(
    column: $table.statusDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get guardianHlc => $composableBuilder(
    column: $table.guardianHlc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get guardianDeviceId => $composableBuilder(
    column: $table.guardianDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get rulesVersionAtSignoffHlc => $composableBuilder(
    column: $table.rulesVersionAtSignoffHlc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rulesVersionAtSignoffDeviceId =>
      $composableBuilder(
        column: $table.rulesVersionAtSignoffDeviceId,
        builder: (column) => column,
      );
}

class $$CyclesSyncTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CyclesSyncTable,
          CyclesSyncData,
          $$CyclesSyncTableFilterComposer,
          $$CyclesSyncTableOrderingComposer,
          $$CyclesSyncTableAnnotationComposer,
          $$CyclesSyncTableCreateCompanionBuilder,
          $$CyclesSyncTableUpdateCompanionBuilder,
          (
            CyclesSyncData,
            BaseReferences<_$AppDatabase, $CyclesSyncTable, CyclesSyncData>,
          ),
          CyclesSyncData,
          PrefetchHooks Function()
        > {
  $$CyclesSyncTableTableManager(_$AppDatabase db, $CyclesSyncTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CyclesSyncTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CyclesSyncTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CyclesSyncTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cycleId = const Value.absent(),
                Value<String> houseId = const Value.absent(),
                Value<String> activeGuardianMemberId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> ceremonySignoffs = const Value.absent(),
                Value<int> rulesVersionAtSignoff = const Value.absent(),
                Value<Uint8List> updatedAtHlc = const Value.absent(),
                Value<Uint8List?> statusHlc = const Value.absent(),
                Value<String?> statusDeviceId = const Value.absent(),
                Value<Uint8List?> guardianHlc = const Value.absent(),
                Value<String?> guardianDeviceId = const Value.absent(),
                Value<Uint8List?> rulesVersionAtSignoffHlc =
                    const Value.absent(),
                Value<String?> rulesVersionAtSignoffDeviceId =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CyclesSyncCompanion(
                cycleId: cycleId,
                houseId: houseId,
                activeGuardianMemberId: activeGuardianMemberId,
                status: status,
                ceremonySignoffs: ceremonySignoffs,
                rulesVersionAtSignoff: rulesVersionAtSignoff,
                updatedAtHlc: updatedAtHlc,
                statusHlc: statusHlc,
                statusDeviceId: statusDeviceId,
                guardianHlc: guardianHlc,
                guardianDeviceId: guardianDeviceId,
                rulesVersionAtSignoffHlc: rulesVersionAtSignoffHlc,
                rulesVersionAtSignoffDeviceId: rulesVersionAtSignoffDeviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cycleId,
                required String houseId,
                required String activeGuardianMemberId,
                required String status,
                Value<String> ceremonySignoffs = const Value.absent(),
                Value<int> rulesVersionAtSignoff = const Value.absent(),
                required Uint8List updatedAtHlc,
                Value<Uint8List?> statusHlc = const Value.absent(),
                Value<String?> statusDeviceId = const Value.absent(),
                Value<Uint8List?> guardianHlc = const Value.absent(),
                Value<String?> guardianDeviceId = const Value.absent(),
                Value<Uint8List?> rulesVersionAtSignoffHlc =
                    const Value.absent(),
                Value<String?> rulesVersionAtSignoffDeviceId =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CyclesSyncCompanion.insert(
                cycleId: cycleId,
                houseId: houseId,
                activeGuardianMemberId: activeGuardianMemberId,
                status: status,
                ceremonySignoffs: ceremonySignoffs,
                rulesVersionAtSignoff: rulesVersionAtSignoff,
                updatedAtHlc: updatedAtHlc,
                statusHlc: statusHlc,
                statusDeviceId: statusDeviceId,
                guardianHlc: guardianHlc,
                guardianDeviceId: guardianDeviceId,
                rulesVersionAtSignoffHlc: rulesVersionAtSignoffHlc,
                rulesVersionAtSignoffDeviceId: rulesVersionAtSignoffDeviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CyclesSyncTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CyclesSyncTable,
      CyclesSyncData,
      $$CyclesSyncTableFilterComposer,
      $$CyclesSyncTableOrderingComposer,
      $$CyclesSyncTableAnnotationComposer,
      $$CyclesSyncTableCreateCompanionBuilder,
      $$CyclesSyncTableUpdateCompanionBuilder,
      (
        CyclesSyncData,
        BaseReferences<_$AppDatabase, $CyclesSyncTable, CyclesSyncData>,
      ),
      CyclesSyncData,
      PrefetchHooks Function()
    >;
typedef $$TasksSyncTableCreateCompanionBuilder =
    TasksSyncCompanion Function({
      required String taskId,
      required String houseId,
      required String cycleId,
      required String title,
      required int negotiatedPoints,
      required String status,
      Value<String> claimedByMemberIds,
      required Uint8List updatedAtHlc,
      Value<Uint8List?> titleHlc,
      Value<String?> titleDeviceId,
      Value<Uint8List?> pointsHlc,
      Value<String?> pointsDeviceId,
      Value<Uint8List?> statusHlc,
      Value<String?> statusDeviceId,
      Value<int> rowid,
    });
typedef $$TasksSyncTableUpdateCompanionBuilder =
    TasksSyncCompanion Function({
      Value<String> taskId,
      Value<String> houseId,
      Value<String> cycleId,
      Value<String> title,
      Value<int> negotiatedPoints,
      Value<String> status,
      Value<String> claimedByMemberIds,
      Value<Uint8List> updatedAtHlc,
      Value<Uint8List?> titleHlc,
      Value<String?> titleDeviceId,
      Value<Uint8List?> pointsHlc,
      Value<String?> pointsDeviceId,
      Value<Uint8List?> statusHlc,
      Value<String?> statusDeviceId,
      Value<int> rowid,
    });

class $$TasksSyncTableFilterComposer
    extends Composer<_$AppDatabase, $TasksSyncTable> {
  $$TasksSyncTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cycleId => $composableBuilder(
    column: $table.cycleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get negotiatedPoints => $composableBuilder(
    column: $table.negotiatedPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get claimedByMemberIds => $composableBuilder(
    column: $table.claimedByMemberIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get titleHlc => $composableBuilder(
    column: $table.titleHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleDeviceId => $composableBuilder(
    column: $table.titleDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get pointsHlc => $composableBuilder(
    column: $table.pointsHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pointsDeviceId => $composableBuilder(
    column: $table.pointsDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get statusHlc => $composableBuilder(
    column: $table.statusHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusDeviceId => $composableBuilder(
    column: $table.statusDeviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksSyncTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksSyncTable> {
  $$TasksSyncTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cycleId => $composableBuilder(
    column: $table.cycleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get negotiatedPoints => $composableBuilder(
    column: $table.negotiatedPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get claimedByMemberIds => $composableBuilder(
    column: $table.claimedByMemberIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get titleHlc => $composableBuilder(
    column: $table.titleHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleDeviceId => $composableBuilder(
    column: $table.titleDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get pointsHlc => $composableBuilder(
    column: $table.pointsHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pointsDeviceId => $composableBuilder(
    column: $table.pointsDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get statusHlc => $composableBuilder(
    column: $table.statusHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusDeviceId => $composableBuilder(
    column: $table.statusDeviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksSyncTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksSyncTable> {
  $$TasksSyncTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get houseId =>
      $composableBuilder(column: $table.houseId, builder: (column) => column);

  GeneratedColumn<String> get cycleId =>
      $composableBuilder(column: $table.cycleId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get negotiatedPoints => $composableBuilder(
    column: $table.negotiatedPoints,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get claimedByMemberIds => $composableBuilder(
    column: $table.claimedByMemberIds,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get titleHlc =>
      $composableBuilder(column: $table.titleHlc, builder: (column) => column);

  GeneratedColumn<String> get titleDeviceId => $composableBuilder(
    column: $table.titleDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get pointsHlc =>
      $composableBuilder(column: $table.pointsHlc, builder: (column) => column);

  GeneratedColumn<String> get pointsDeviceId => $composableBuilder(
    column: $table.pointsDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get statusHlc =>
      $composableBuilder(column: $table.statusHlc, builder: (column) => column);

  GeneratedColumn<String> get statusDeviceId => $composableBuilder(
    column: $table.statusDeviceId,
    builder: (column) => column,
  );
}

class $$TasksSyncTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksSyncTable,
          TasksSyncData,
          $$TasksSyncTableFilterComposer,
          $$TasksSyncTableOrderingComposer,
          $$TasksSyncTableAnnotationComposer,
          $$TasksSyncTableCreateCompanionBuilder,
          $$TasksSyncTableUpdateCompanionBuilder,
          (
            TasksSyncData,
            BaseReferences<_$AppDatabase, $TasksSyncTable, TasksSyncData>,
          ),
          TasksSyncData,
          PrefetchHooks Function()
        > {
  $$TasksSyncTableTableManager(_$AppDatabase db, $TasksSyncTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksSyncTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksSyncTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksSyncTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> taskId = const Value.absent(),
                Value<String> houseId = const Value.absent(),
                Value<String> cycleId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> negotiatedPoints = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> claimedByMemberIds = const Value.absent(),
                Value<Uint8List> updatedAtHlc = const Value.absent(),
                Value<Uint8List?> titleHlc = const Value.absent(),
                Value<String?> titleDeviceId = const Value.absent(),
                Value<Uint8List?> pointsHlc = const Value.absent(),
                Value<String?> pointsDeviceId = const Value.absent(),
                Value<Uint8List?> statusHlc = const Value.absent(),
                Value<String?> statusDeviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksSyncCompanion(
                taskId: taskId,
                houseId: houseId,
                cycleId: cycleId,
                title: title,
                negotiatedPoints: negotiatedPoints,
                status: status,
                claimedByMemberIds: claimedByMemberIds,
                updatedAtHlc: updatedAtHlc,
                titleHlc: titleHlc,
                titleDeviceId: titleDeviceId,
                pointsHlc: pointsHlc,
                pointsDeviceId: pointsDeviceId,
                statusHlc: statusHlc,
                statusDeviceId: statusDeviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String taskId,
                required String houseId,
                required String cycleId,
                required String title,
                required int negotiatedPoints,
                required String status,
                Value<String> claimedByMemberIds = const Value.absent(),
                required Uint8List updatedAtHlc,
                Value<Uint8List?> titleHlc = const Value.absent(),
                Value<String?> titleDeviceId = const Value.absent(),
                Value<Uint8List?> pointsHlc = const Value.absent(),
                Value<String?> pointsDeviceId = const Value.absent(),
                Value<Uint8List?> statusHlc = const Value.absent(),
                Value<String?> statusDeviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksSyncCompanion.insert(
                taskId: taskId,
                houseId: houseId,
                cycleId: cycleId,
                title: title,
                negotiatedPoints: negotiatedPoints,
                status: status,
                claimedByMemberIds: claimedByMemberIds,
                updatedAtHlc: updatedAtHlc,
                titleHlc: titleHlc,
                titleDeviceId: titleDeviceId,
                pointsHlc: pointsHlc,
                pointsDeviceId: pointsDeviceId,
                statusHlc: statusHlc,
                statusDeviceId: statusDeviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksSyncTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksSyncTable,
      TasksSyncData,
      $$TasksSyncTableFilterComposer,
      $$TasksSyncTableOrderingComposer,
      $$TasksSyncTableAnnotationComposer,
      $$TasksSyncTableCreateCompanionBuilder,
      $$TasksSyncTableUpdateCompanionBuilder,
      (
        TasksSyncData,
        BaseReferences<_$AppDatabase, $TasksSyncTable, TasksSyncData>,
      ),
      TasksSyncData,
      PrefetchHooks Function()
    >;
typedef $$TaskClaimEventsTableCreateCompanionBuilder =
    TaskClaimEventsCompanion Function({
      required String eventId,
      required String houseId,
      required String taskId,
      required String memberId,
      required Uint8List hlc,
      Value<int> rowid,
    });
typedef $$TaskClaimEventsTableUpdateCompanionBuilder =
    TaskClaimEventsCompanion Function({
      Value<String> eventId,
      Value<String> houseId,
      Value<String> taskId,
      Value<String> memberId,
      Value<Uint8List> hlc,
      Value<int> rowid,
    });

class $$TaskClaimEventsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskClaimEventsTable> {
  $$TaskClaimEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskClaimEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskClaimEventsTable> {
  $$TaskClaimEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskClaimEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskClaimEventsTable> {
  $$TaskClaimEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get houseId =>
      $composableBuilder(column: $table.houseId, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<Uint8List> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);
}

class $$TaskClaimEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskClaimEventsTable,
          TaskClaimEvent,
          $$TaskClaimEventsTableFilterComposer,
          $$TaskClaimEventsTableOrderingComposer,
          $$TaskClaimEventsTableAnnotationComposer,
          $$TaskClaimEventsTableCreateCompanionBuilder,
          $$TaskClaimEventsTableUpdateCompanionBuilder,
          (
            TaskClaimEvent,
            BaseReferences<
              _$AppDatabase,
              $TaskClaimEventsTable,
              TaskClaimEvent
            >,
          ),
          TaskClaimEvent,
          PrefetchHooks Function()
        > {
  $$TaskClaimEventsTableTableManager(
    _$AppDatabase db,
    $TaskClaimEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskClaimEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskClaimEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskClaimEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> houseId = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<Uint8List> hlc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskClaimEventsCompanion(
                eventId: eventId,
                houseId: houseId,
                taskId: taskId,
                memberId: memberId,
                hlc: hlc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String houseId,
                required String taskId,
                required String memberId,
                required Uint8List hlc,
                Value<int> rowid = const Value.absent(),
              }) => TaskClaimEventsCompanion.insert(
                eventId: eventId,
                houseId: houseId,
                taskId: taskId,
                memberId: memberId,
                hlc: hlc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskClaimEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskClaimEventsTable,
      TaskClaimEvent,
      $$TaskClaimEventsTableFilterComposer,
      $$TaskClaimEventsTableOrderingComposer,
      $$TaskClaimEventsTableAnnotationComposer,
      $$TaskClaimEventsTableCreateCompanionBuilder,
      $$TaskClaimEventsTableUpdateCompanionBuilder,
      (
        TaskClaimEvent,
        BaseReferences<_$AppDatabase, $TaskClaimEventsTable, TaskClaimEvent>,
      ),
      TaskClaimEvent,
      PrefetchHooks Function()
    >;
typedef $$AuditLogAppendOnlyTableCreateCompanionBuilder =
    AuditLogAppendOnlyCompanion Function({
      required String logId,
      required String houseId,
      required String taskId,
      required String actorMemberId,
      required String action,
      Value<String?> justificationNotes,
      required Uint8List hlc,
      Value<int> rowid,
    });
typedef $$AuditLogAppendOnlyTableUpdateCompanionBuilder =
    AuditLogAppendOnlyCompanion Function({
      Value<String> logId,
      Value<String> houseId,
      Value<String> taskId,
      Value<String> actorMemberId,
      Value<String> action,
      Value<String?> justificationNotes,
      Value<Uint8List> hlc,
      Value<int> rowid,
    });

class $$AuditLogAppendOnlyTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogAppendOnlyTable> {
  $$AuditLogAppendOnlyTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get logId => $composableBuilder(
    column: $table.logId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorMemberId => $composableBuilder(
    column: $table.actorMemberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get justificationNotes => $composableBuilder(
    column: $table.justificationNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditLogAppendOnlyTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogAppendOnlyTable> {
  $$AuditLogAppendOnlyTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get logId => $composableBuilder(
    column: $table.logId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorMemberId => $composableBuilder(
    column: $table.actorMemberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get justificationNotes => $composableBuilder(
    column: $table.justificationNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditLogAppendOnlyTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogAppendOnlyTable> {
  $$AuditLogAppendOnlyTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get logId =>
      $composableBuilder(column: $table.logId, builder: (column) => column);

  GeneratedColumn<String> get houseId =>
      $composableBuilder(column: $table.houseId, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get actorMemberId => $composableBuilder(
    column: $table.actorMemberId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get justificationNotes => $composableBuilder(
    column: $table.justificationNotes,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);
}

class $$AuditLogAppendOnlyTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogAppendOnlyTable,
          AuditLogAppendOnlyData,
          $$AuditLogAppendOnlyTableFilterComposer,
          $$AuditLogAppendOnlyTableOrderingComposer,
          $$AuditLogAppendOnlyTableAnnotationComposer,
          $$AuditLogAppendOnlyTableCreateCompanionBuilder,
          $$AuditLogAppendOnlyTableUpdateCompanionBuilder,
          (
            AuditLogAppendOnlyData,
            BaseReferences<
              _$AppDatabase,
              $AuditLogAppendOnlyTable,
              AuditLogAppendOnlyData
            >,
          ),
          AuditLogAppendOnlyData,
          PrefetchHooks Function()
        > {
  $$AuditLogAppendOnlyTableTableManager(
    _$AppDatabase db,
    $AuditLogAppendOnlyTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogAppendOnlyTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogAppendOnlyTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogAppendOnlyTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> logId = const Value.absent(),
                Value<String> houseId = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> actorMemberId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> justificationNotes = const Value.absent(),
                Value<Uint8List> hlc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogAppendOnlyCompanion(
                logId: logId,
                houseId: houseId,
                taskId: taskId,
                actorMemberId: actorMemberId,
                action: action,
                justificationNotes: justificationNotes,
                hlc: hlc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String logId,
                required String houseId,
                required String taskId,
                required String actorMemberId,
                required String action,
                Value<String?> justificationNotes = const Value.absent(),
                required Uint8List hlc,
                Value<int> rowid = const Value.absent(),
              }) => AuditLogAppendOnlyCompanion.insert(
                logId: logId,
                houseId: houseId,
                taskId: taskId,
                actorMemberId: actorMemberId,
                action: action,
                justificationNotes: justificationNotes,
                hlc: hlc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditLogAppendOnlyTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogAppendOnlyTable,
      AuditLogAppendOnlyData,
      $$AuditLogAppendOnlyTableFilterComposer,
      $$AuditLogAppendOnlyTableOrderingComposer,
      $$AuditLogAppendOnlyTableAnnotationComposer,
      $$AuditLogAppendOnlyTableCreateCompanionBuilder,
      $$AuditLogAppendOnlyTableUpdateCompanionBuilder,
      (
        AuditLogAppendOnlyData,
        BaseReferences<
          _$AppDatabase,
          $AuditLogAppendOnlyTable,
          AuditLogAppendOnlyData
        >,
      ),
      AuditLogAppendOnlyData,
      PrefetchHooks Function()
    >;
typedef $$SyncOutboxEntriesTableCreateCompanionBuilder =
    SyncOutboxEntriesCompanion Function({
      required String opId,
      required String houseId,
      required String envelopeJson,
      required int createdAtMs,
      Value<bool> broadcasted,
      Value<int> rowid,
    });
typedef $$SyncOutboxEntriesTableUpdateCompanionBuilder =
    SyncOutboxEntriesCompanion Function({
      Value<String> opId,
      Value<String> houseId,
      Value<String> envelopeJson,
      Value<int> createdAtMs,
      Value<bool> broadcasted,
      Value<int> rowid,
    });

class $$SyncOutboxEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxEntriesTable> {
  $$SyncOutboxEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get envelopeJson => $composableBuilder(
    column: $table.envelopeJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get broadcasted => $composableBuilder(
    column: $table.broadcasted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxEntriesTable> {
  $$SyncOutboxEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get envelopeJson => $composableBuilder(
    column: $table.envelopeJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get broadcasted => $composableBuilder(
    column: $table.broadcasted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxEntriesTable> {
  $$SyncOutboxEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get houseId =>
      $composableBuilder(column: $table.houseId, builder: (column) => column);

  GeneratedColumn<String> get envelopeJson => $composableBuilder(
    column: $table.envelopeJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get broadcasted => $composableBuilder(
    column: $table.broadcasted,
    builder: (column) => column,
  );
}

class $$SyncOutboxEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxEntriesTable,
          SyncOutboxEntry,
          $$SyncOutboxEntriesTableFilterComposer,
          $$SyncOutboxEntriesTableOrderingComposer,
          $$SyncOutboxEntriesTableAnnotationComposer,
          $$SyncOutboxEntriesTableCreateCompanionBuilder,
          $$SyncOutboxEntriesTableUpdateCompanionBuilder,
          (
            SyncOutboxEntry,
            BaseReferences<
              _$AppDatabase,
              $SyncOutboxEntriesTable,
              SyncOutboxEntry
            >,
          ),
          SyncOutboxEntry,
          PrefetchHooks Function()
        > {
  $$SyncOutboxEntriesTableTableManager(
    _$AppDatabase db,
    $SyncOutboxEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> opId = const Value.absent(),
                Value<String> houseId = const Value.absent(),
                Value<String> envelopeJson = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<bool> broadcasted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxEntriesCompanion(
                opId: opId,
                houseId: houseId,
                envelopeJson: envelopeJson,
                createdAtMs: createdAtMs,
                broadcasted: broadcasted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String opId,
                required String houseId,
                required String envelopeJson,
                required int createdAtMs,
                Value<bool> broadcasted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxEntriesCompanion.insert(
                opId: opId,
                houseId: houseId,
                envelopeJson: envelopeJson,
                createdAtMs: createdAtMs,
                broadcasted: broadcasted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxEntriesTable,
      SyncOutboxEntry,
      $$SyncOutboxEntriesTableFilterComposer,
      $$SyncOutboxEntriesTableOrderingComposer,
      $$SyncOutboxEntriesTableAnnotationComposer,
      $$SyncOutboxEntriesTableCreateCompanionBuilder,
      $$SyncOutboxEntriesTableUpdateCompanionBuilder,
      (
        SyncOutboxEntry,
        BaseReferences<_$AppDatabase, $SyncOutboxEntriesTable, SyncOutboxEntry>,
      ),
      SyncOutboxEntry,
      PrefetchHooks Function()
    >;
typedef $$SyncAppliedOpsTableCreateCompanionBuilder =
    SyncAppliedOpsCompanion Function({
      required String opId,
      required String houseId,
      required Uint8List appliedAtHlc,
      Value<int> rowid,
    });
typedef $$SyncAppliedOpsTableUpdateCompanionBuilder =
    SyncAppliedOpsCompanion Function({
      Value<String> opId,
      Value<String> houseId,
      Value<Uint8List> appliedAtHlc,
      Value<int> rowid,
    });

class $$SyncAppliedOpsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncAppliedOpsTable> {
  $$SyncAppliedOpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get appliedAtHlc => $composableBuilder(
    column: $table.appliedAtHlc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncAppliedOpsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncAppliedOpsTable> {
  $$SyncAppliedOpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get appliedAtHlc => $composableBuilder(
    column: $table.appliedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncAppliedOpsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncAppliedOpsTable> {
  $$SyncAppliedOpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get houseId =>
      $composableBuilder(column: $table.houseId, builder: (column) => column);

  GeneratedColumn<Uint8List> get appliedAtHlc => $composableBuilder(
    column: $table.appliedAtHlc,
    builder: (column) => column,
  );
}

class $$SyncAppliedOpsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncAppliedOpsTable,
          SyncAppliedOp,
          $$SyncAppliedOpsTableFilterComposer,
          $$SyncAppliedOpsTableOrderingComposer,
          $$SyncAppliedOpsTableAnnotationComposer,
          $$SyncAppliedOpsTableCreateCompanionBuilder,
          $$SyncAppliedOpsTableUpdateCompanionBuilder,
          (
            SyncAppliedOp,
            BaseReferences<_$AppDatabase, $SyncAppliedOpsTable, SyncAppliedOp>,
          ),
          SyncAppliedOp,
          PrefetchHooks Function()
        > {
  $$SyncAppliedOpsTableTableManager(
    _$AppDatabase db,
    $SyncAppliedOpsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncAppliedOpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncAppliedOpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncAppliedOpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> opId = const Value.absent(),
                Value<String> houseId = const Value.absent(),
                Value<Uint8List> appliedAtHlc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncAppliedOpsCompanion(
                opId: opId,
                houseId: houseId,
                appliedAtHlc: appliedAtHlc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String opId,
                required String houseId,
                required Uint8List appliedAtHlc,
                Value<int> rowid = const Value.absent(),
              }) => SyncAppliedOpsCompanion.insert(
                opId: opId,
                houseId: houseId,
                appliedAtHlc: appliedAtHlc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncAppliedOpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncAppliedOpsTable,
      SyncAppliedOp,
      $$SyncAppliedOpsTableFilterComposer,
      $$SyncAppliedOpsTableOrderingComposer,
      $$SyncAppliedOpsTableAnnotationComposer,
      $$SyncAppliedOpsTableCreateCompanionBuilder,
      $$SyncAppliedOpsTableUpdateCompanionBuilder,
      (
        SyncAppliedOp,
        BaseReferences<_$AppDatabase, $SyncAppliedOpsTable, SyncAppliedOp>,
      ),
      SyncAppliedOp,
      PrefetchHooks Function()
    >;
typedef $$SyncPeerStateTableCreateCompanionBuilder =
    SyncPeerStateCompanion Function({
      required String peerNodeKey,
      required String houseId,
      Value<String?> lastEnvelopeId,
      Value<Uint8List?> lastSeenHlc,
      Value<int> rowid,
    });
typedef $$SyncPeerStateTableUpdateCompanionBuilder =
    SyncPeerStateCompanion Function({
      Value<String> peerNodeKey,
      Value<String> houseId,
      Value<String?> lastEnvelopeId,
      Value<Uint8List?> lastSeenHlc,
      Value<int> rowid,
    });

class $$SyncPeerStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncPeerStateTable> {
  $$SyncPeerStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get peerNodeKey => $composableBuilder(
    column: $table.peerNodeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastEnvelopeId => $composableBuilder(
    column: $table.lastEnvelopeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get lastSeenHlc => $composableBuilder(
    column: $table.lastSeenHlc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncPeerStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncPeerStateTable> {
  $$SyncPeerStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get peerNodeKey => $composableBuilder(
    column: $table.peerNodeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastEnvelopeId => $composableBuilder(
    column: $table.lastEnvelopeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get lastSeenHlc => $composableBuilder(
    column: $table.lastSeenHlc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncPeerStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncPeerStateTable> {
  $$SyncPeerStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get peerNodeKey => $composableBuilder(
    column: $table.peerNodeKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get houseId =>
      $composableBuilder(column: $table.houseId, builder: (column) => column);

  GeneratedColumn<String> get lastEnvelopeId => $composableBuilder(
    column: $table.lastEnvelopeId,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get lastSeenHlc => $composableBuilder(
    column: $table.lastSeenHlc,
    builder: (column) => column,
  );
}

class $$SyncPeerStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncPeerStateTable,
          SyncPeerStateData,
          $$SyncPeerStateTableFilterComposer,
          $$SyncPeerStateTableOrderingComposer,
          $$SyncPeerStateTableAnnotationComposer,
          $$SyncPeerStateTableCreateCompanionBuilder,
          $$SyncPeerStateTableUpdateCompanionBuilder,
          (
            SyncPeerStateData,
            BaseReferences<
              _$AppDatabase,
              $SyncPeerStateTable,
              SyncPeerStateData
            >,
          ),
          SyncPeerStateData,
          PrefetchHooks Function()
        > {
  $$SyncPeerStateTableTableManager(_$AppDatabase db, $SyncPeerStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncPeerStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncPeerStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncPeerStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> peerNodeKey = const Value.absent(),
                Value<String> houseId = const Value.absent(),
                Value<String?> lastEnvelopeId = const Value.absent(),
                Value<Uint8List?> lastSeenHlc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncPeerStateCompanion(
                peerNodeKey: peerNodeKey,
                houseId: houseId,
                lastEnvelopeId: lastEnvelopeId,
                lastSeenHlc: lastSeenHlc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String peerNodeKey,
                required String houseId,
                Value<String?> lastEnvelopeId = const Value.absent(),
                Value<Uint8List?> lastSeenHlc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncPeerStateCompanion.insert(
                peerNodeKey: peerNodeKey,
                houseId: houseId,
                lastEnvelopeId: lastEnvelopeId,
                lastSeenHlc: lastSeenHlc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncPeerStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncPeerStateTable,
      SyncPeerStateData,
      $$SyncPeerStateTableFilterComposer,
      $$SyncPeerStateTableOrderingComposer,
      $$SyncPeerStateTableAnnotationComposer,
      $$SyncPeerStateTableCreateCompanionBuilder,
      $$SyncPeerStateTableUpdateCompanionBuilder,
      (
        SyncPeerStateData,
        BaseReferences<_$AppDatabase, $SyncPeerStateTable, SyncPeerStateData>,
      ),
      SyncPeerStateData,
      PrefetchHooks Function()
    >;
typedef $$SyncPeerAllowlistTableCreateCompanionBuilder =
    SyncPeerAllowlistCompanion Function({
      required String tailscaleNodeKey,
      required String houseId,
      Value<String?> memberId,
      Value<bool> isLocalDevice,
      Value<int> rowid,
    });
typedef $$SyncPeerAllowlistTableUpdateCompanionBuilder =
    SyncPeerAllowlistCompanion Function({
      Value<String> tailscaleNodeKey,
      Value<String> houseId,
      Value<String?> memberId,
      Value<bool> isLocalDevice,
      Value<int> rowid,
    });

class $$SyncPeerAllowlistTableFilterComposer
    extends Composer<_$AppDatabase, $SyncPeerAllowlistTable> {
  $$SyncPeerAllowlistTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tailscaleNodeKey => $composableBuilder(
    column: $table.tailscaleNodeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocalDevice => $composableBuilder(
    column: $table.isLocalDevice,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncPeerAllowlistTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncPeerAllowlistTable> {
  $$SyncPeerAllowlistTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tailscaleNodeKey => $composableBuilder(
    column: $table.tailscaleNodeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocalDevice => $composableBuilder(
    column: $table.isLocalDevice,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncPeerAllowlistTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncPeerAllowlistTable> {
  $$SyncPeerAllowlistTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tailscaleNodeKey => $composableBuilder(
    column: $table.tailscaleNodeKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get houseId =>
      $composableBuilder(column: $table.houseId, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<bool> get isLocalDevice => $composableBuilder(
    column: $table.isLocalDevice,
    builder: (column) => column,
  );
}

class $$SyncPeerAllowlistTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncPeerAllowlistTable,
          SyncPeerAllowlistData,
          $$SyncPeerAllowlistTableFilterComposer,
          $$SyncPeerAllowlistTableOrderingComposer,
          $$SyncPeerAllowlistTableAnnotationComposer,
          $$SyncPeerAllowlistTableCreateCompanionBuilder,
          $$SyncPeerAllowlistTableUpdateCompanionBuilder,
          (
            SyncPeerAllowlistData,
            BaseReferences<
              _$AppDatabase,
              $SyncPeerAllowlistTable,
              SyncPeerAllowlistData
            >,
          ),
          SyncPeerAllowlistData,
          PrefetchHooks Function()
        > {
  $$SyncPeerAllowlistTableTableManager(
    _$AppDatabase db,
    $SyncPeerAllowlistTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncPeerAllowlistTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncPeerAllowlistTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncPeerAllowlistTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> tailscaleNodeKey = const Value.absent(),
                Value<String> houseId = const Value.absent(),
                Value<String?> memberId = const Value.absent(),
                Value<bool> isLocalDevice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncPeerAllowlistCompanion(
                tailscaleNodeKey: tailscaleNodeKey,
                houseId: houseId,
                memberId: memberId,
                isLocalDevice: isLocalDevice,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tailscaleNodeKey,
                required String houseId,
                Value<String?> memberId = const Value.absent(),
                Value<bool> isLocalDevice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncPeerAllowlistCompanion.insert(
                tailscaleNodeKey: tailscaleNodeKey,
                houseId: houseId,
                memberId: memberId,
                isLocalDevice: isLocalDevice,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncPeerAllowlistTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncPeerAllowlistTable,
      SyncPeerAllowlistData,
      $$SyncPeerAllowlistTableFilterComposer,
      $$SyncPeerAllowlistTableOrderingComposer,
      $$SyncPeerAllowlistTableAnnotationComposer,
      $$SyncPeerAllowlistTableCreateCompanionBuilder,
      $$SyncPeerAllowlistTableUpdateCompanionBuilder,
      (
        SyncPeerAllowlistData,
        BaseReferences<
          _$AppDatabase,
          $SyncPeerAllowlistTable,
          SyncPeerAllowlistData
        >,
      ),
      SyncPeerAllowlistData,
      PrefetchHooks Function()
    >;
typedef $$ConsumedJoinCredentialsTableCreateCompanionBuilder =
    ConsumedJoinCredentialsCompanion Function({
      required String nonce,
      required String houseId,
      required String consumedByNodeKey,
      required int consumedAtMs,
      Value<int> rowid,
    });
typedef $$ConsumedJoinCredentialsTableUpdateCompanionBuilder =
    ConsumedJoinCredentialsCompanion Function({
      Value<String> nonce,
      Value<String> houseId,
      Value<String> consumedByNodeKey,
      Value<int> consumedAtMs,
      Value<int> rowid,
    });

class $$ConsumedJoinCredentialsTableFilterComposer
    extends Composer<_$AppDatabase, $ConsumedJoinCredentialsTable> {
  $$ConsumedJoinCredentialsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get nonce => $composableBuilder(
    column: $table.nonce,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get consumedByNodeKey => $composableBuilder(
    column: $table.consumedByNodeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get consumedAtMs => $composableBuilder(
    column: $table.consumedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConsumedJoinCredentialsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConsumedJoinCredentialsTable> {
  $$ConsumedJoinCredentialsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get nonce => $composableBuilder(
    column: $table.nonce,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consumedByNodeKey => $composableBuilder(
    column: $table.consumedByNodeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get consumedAtMs => $composableBuilder(
    column: $table.consumedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConsumedJoinCredentialsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConsumedJoinCredentialsTable> {
  $$ConsumedJoinCredentialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get nonce =>
      $composableBuilder(column: $table.nonce, builder: (column) => column);

  GeneratedColumn<String> get houseId =>
      $composableBuilder(column: $table.houseId, builder: (column) => column);

  GeneratedColumn<String> get consumedByNodeKey => $composableBuilder(
    column: $table.consumedByNodeKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get consumedAtMs => $composableBuilder(
    column: $table.consumedAtMs,
    builder: (column) => column,
  );
}

class $$ConsumedJoinCredentialsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConsumedJoinCredentialsTable,
          ConsumedJoinCredential,
          $$ConsumedJoinCredentialsTableFilterComposer,
          $$ConsumedJoinCredentialsTableOrderingComposer,
          $$ConsumedJoinCredentialsTableAnnotationComposer,
          $$ConsumedJoinCredentialsTableCreateCompanionBuilder,
          $$ConsumedJoinCredentialsTableUpdateCompanionBuilder,
          (
            ConsumedJoinCredential,
            BaseReferences<
              _$AppDatabase,
              $ConsumedJoinCredentialsTable,
              ConsumedJoinCredential
            >,
          ),
          ConsumedJoinCredential,
          PrefetchHooks Function()
        > {
  $$ConsumedJoinCredentialsTableTableManager(
    _$AppDatabase db,
    $ConsumedJoinCredentialsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConsumedJoinCredentialsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ConsumedJoinCredentialsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ConsumedJoinCredentialsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> nonce = const Value.absent(),
                Value<String> houseId = const Value.absent(),
                Value<String> consumedByNodeKey = const Value.absent(),
                Value<int> consumedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConsumedJoinCredentialsCompanion(
                nonce: nonce,
                houseId: houseId,
                consumedByNodeKey: consumedByNodeKey,
                consumedAtMs: consumedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String nonce,
                required String houseId,
                required String consumedByNodeKey,
                required int consumedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => ConsumedJoinCredentialsCompanion.insert(
                nonce: nonce,
                houseId: houseId,
                consumedByNodeKey: consumedByNodeKey,
                consumedAtMs: consumedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConsumedJoinCredentialsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConsumedJoinCredentialsTable,
      ConsumedJoinCredential,
      $$ConsumedJoinCredentialsTableFilterComposer,
      $$ConsumedJoinCredentialsTableOrderingComposer,
      $$ConsumedJoinCredentialsTableAnnotationComposer,
      $$ConsumedJoinCredentialsTableCreateCompanionBuilder,
      $$ConsumedJoinCredentialsTableUpdateCompanionBuilder,
      (
        ConsumedJoinCredential,
        BaseReferences<
          _$AppDatabase,
          $ConsumedJoinCredentialsTable,
          ConsumedJoinCredential
        >,
      ),
      ConsumedJoinCredential,
      PrefetchHooks Function()
    >;
typedef $$HouseJoinSecretsTableCreateCompanionBuilder =
    HouseJoinSecretsCompanion Function({
      required String houseId,
      required String secretBase64,
      Value<int> rowid,
    });
typedef $$HouseJoinSecretsTableUpdateCompanionBuilder =
    HouseJoinSecretsCompanion Function({
      Value<String> houseId,
      Value<String> secretBase64,
      Value<int> rowid,
    });

class $$HouseJoinSecretsTableFilterComposer
    extends Composer<_$AppDatabase, $HouseJoinSecretsTable> {
  $$HouseJoinSecretsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secretBase64 => $composableBuilder(
    column: $table.secretBase64,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HouseJoinSecretsTableOrderingComposer
    extends Composer<_$AppDatabase, $HouseJoinSecretsTable> {
  $$HouseJoinSecretsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get houseId => $composableBuilder(
    column: $table.houseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secretBase64 => $composableBuilder(
    column: $table.secretBase64,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HouseJoinSecretsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HouseJoinSecretsTable> {
  $$HouseJoinSecretsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get houseId =>
      $composableBuilder(column: $table.houseId, builder: (column) => column);

  GeneratedColumn<String> get secretBase64 => $composableBuilder(
    column: $table.secretBase64,
    builder: (column) => column,
  );
}

class $$HouseJoinSecretsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HouseJoinSecretsTable,
          HouseJoinSecret,
          $$HouseJoinSecretsTableFilterComposer,
          $$HouseJoinSecretsTableOrderingComposer,
          $$HouseJoinSecretsTableAnnotationComposer,
          $$HouseJoinSecretsTableCreateCompanionBuilder,
          $$HouseJoinSecretsTableUpdateCompanionBuilder,
          (
            HouseJoinSecret,
            BaseReferences<
              _$AppDatabase,
              $HouseJoinSecretsTable,
              HouseJoinSecret
            >,
          ),
          HouseJoinSecret,
          PrefetchHooks Function()
        > {
  $$HouseJoinSecretsTableTableManager(
    _$AppDatabase db,
    $HouseJoinSecretsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HouseJoinSecretsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HouseJoinSecretsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HouseJoinSecretsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> houseId = const Value.absent(),
                Value<String> secretBase64 = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HouseJoinSecretsCompanion(
                houseId: houseId,
                secretBase64: secretBase64,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String houseId,
                required String secretBase64,
                Value<int> rowid = const Value.absent(),
              }) => HouseJoinSecretsCompanion.insert(
                houseId: houseId,
                secretBase64: secretBase64,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HouseJoinSecretsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HouseJoinSecretsTable,
      HouseJoinSecret,
      $$HouseJoinSecretsTableFilterComposer,
      $$HouseJoinSecretsTableOrderingComposer,
      $$HouseJoinSecretsTableAnnotationComposer,
      $$HouseJoinSecretsTableCreateCompanionBuilder,
      $$HouseJoinSecretsTableUpdateCompanionBuilder,
      (
        HouseJoinSecret,
        BaseReferences<_$AppDatabase, $HouseJoinSecretsTable, HouseJoinSecret>,
      ),
      HouseJoinSecret,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalUserSettingsTableTableManager get localUserSettings =>
      $$LocalUserSettingsTableTableManager(_db, _db.localUserSettings);
  $$HouseSyncTableTableManager get houseSync =>
      $$HouseSyncTableTableManager(_db, _db.houseSync);
  $$HousematesSyncTableTableManager get housematesSync =>
      $$HousematesSyncTableTableManager(_db, _db.housematesSync);
  $$ScoreEventsTableTableManager get scoreEvents =>
      $$ScoreEventsTableTableManager(_db, _db.scoreEvents);
  $$RemovalProposalsSyncTableTableManager get removalProposalsSync =>
      $$RemovalProposalsSyncTableTableManager(_db, _db.removalProposalsSync);
  $$ProposalVotesSyncTableTableManager get proposalVotesSync =>
      $$ProposalVotesSyncTableTableManager(_db, _db.proposalVotesSync);
  $$CyclesSyncTableTableManager get cyclesSync =>
      $$CyclesSyncTableTableManager(_db, _db.cyclesSync);
  $$TasksSyncTableTableManager get tasksSync =>
      $$TasksSyncTableTableManager(_db, _db.tasksSync);
  $$TaskClaimEventsTableTableManager get taskClaimEvents =>
      $$TaskClaimEventsTableTableManager(_db, _db.taskClaimEvents);
  $$AuditLogAppendOnlyTableTableManager get auditLogAppendOnly =>
      $$AuditLogAppendOnlyTableTableManager(_db, _db.auditLogAppendOnly);
  $$SyncOutboxEntriesTableTableManager get syncOutboxEntries =>
      $$SyncOutboxEntriesTableTableManager(_db, _db.syncOutboxEntries);
  $$SyncAppliedOpsTableTableManager get syncAppliedOps =>
      $$SyncAppliedOpsTableTableManager(_db, _db.syncAppliedOps);
  $$SyncPeerStateTableTableManager get syncPeerState =>
      $$SyncPeerStateTableTableManager(_db, _db.syncPeerState);
  $$SyncPeerAllowlistTableTableManager get syncPeerAllowlist =>
      $$SyncPeerAllowlistTableTableManager(_db, _db.syncPeerAllowlist);
  $$ConsumedJoinCredentialsTableTableManager get consumedJoinCredentials =>
      $$ConsumedJoinCredentialsTableTableManager(
        _db,
        _db.consumedJoinCredentials,
      );
  $$HouseJoinSecretsTableTableManager get houseJoinSecrets =>
      $$HouseJoinSecretsTableTableManager(_db, _db.houseJoinSecrets);
}
