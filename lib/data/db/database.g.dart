// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AccountKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AccountKind>($AccountsTable.$converterkind);
  static const VerificationMeta _displayHostMeta = const VerificationMeta(
    'displayHost',
  );
  @override
  late final GeneratedColumn<String> displayHost = GeneratedColumn<String>(
    'display_host',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AccountStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(AccountStatus.unknown.name),
      ).withConverter<AccountStatus>($AccountsTable.$converterstatus);
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxConnectionsMeta = const VerificationMeta(
    'maxConnections',
  );
  @override
  late final GeneratedColumn<int> maxConnections = GeneratedColumn<int>(
    'max_connections',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _guideUpdatedAtMeta = const VerificationMeta(
    'guideUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> guideUpdatedAt =
      GeneratedColumn<DateTime>(
        'guide_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _guideSourceCountMeta = const VerificationMeta(
    'guideSourceCount',
  );
  @override
  late final GeneratedColumn<int> guideSourceCount = GeneratedColumn<int>(
    'guide_source_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _liveCountMeta = const VerificationMeta(
    'liveCount',
  );
  @override
  late final GeneratedColumn<int> liveCount = GeneratedColumn<int>(
    'live_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _movieCountMeta = const VerificationMeta(
    'movieCount',
  );
  @override
  late final GeneratedColumn<int> movieCount = GeneratedColumn<int>(
    'movie_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _seriesCountMeta = const VerificationMeta(
    'seriesCount',
  );
  @override
  late final GeneratedColumn<int> seriesCount = GeneratedColumn<int>(
    'series_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _guideShiftMinutesMeta = const VerificationMeta(
    'guideShiftMinutes',
  );
  @override
  late final GeneratedColumn<int> guideShiftMinutes = GeneratedColumn<int>(
    'guide_shift_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    displayHost,
    status,
    expiresAt,
    maxConnections,
    isDefault,
    sortOrder,
    createdAt,
    lastUsedAt,
    lastSyncedAt,
    guideUpdatedAt,
    guideSourceCount,
    liveCount,
    movieCount,
    seriesCount,
    guideShiftMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('display_host')) {
      context.handle(
        _displayHostMeta,
        displayHost.isAcceptableOrUnknown(
          data['display_host']!,
          _displayHostMeta,
        ),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('max_connections')) {
      context.handle(
        _maxConnectionsMeta,
        maxConnections.isAcceptableOrUnknown(
          data['max_connections']!,
          _maxConnectionsMeta,
        ),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('guide_updated_at')) {
      context.handle(
        _guideUpdatedAtMeta,
        guideUpdatedAt.isAcceptableOrUnknown(
          data['guide_updated_at']!,
          _guideUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('guide_source_count')) {
      context.handle(
        _guideSourceCountMeta,
        guideSourceCount.isAcceptableOrUnknown(
          data['guide_source_count']!,
          _guideSourceCountMeta,
        ),
      );
    }
    if (data.containsKey('live_count')) {
      context.handle(
        _liveCountMeta,
        liveCount.isAcceptableOrUnknown(data['live_count']!, _liveCountMeta),
      );
    }
    if (data.containsKey('movie_count')) {
      context.handle(
        _movieCountMeta,
        movieCount.isAcceptableOrUnknown(data['movie_count']!, _movieCountMeta),
      );
    }
    if (data.containsKey('series_count')) {
      context.handle(
        _seriesCountMeta,
        seriesCount.isAcceptableOrUnknown(
          data['series_count']!,
          _seriesCountMeta,
        ),
      );
    }
    if (data.containsKey('guide_shift_minutes')) {
      context.handle(
        _guideShiftMinutesMeta,
        guideShiftMinutes.isAcceptableOrUnknown(
          data['guide_shift_minutes']!,
          _guideShiftMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: $AccountsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      displayHost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_host'],
      ),
      status: $AccountsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
      maxConnections: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_connections'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      guideUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}guide_updated_at'],
      ),
      guideSourceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}guide_source_count'],
      )!,
      liveCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}live_count'],
      )!,
      movieCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}movie_count'],
      )!,
      seriesCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_count'],
      )!,
      guideShiftMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}guide_shift_minutes'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AccountKind, String, String> $converterkind =
      const EnumNameConverter<AccountKind>(AccountKind.values);
  static JsonTypeConverter2<AccountStatus, String, String> $converterstatus =
      const EnumNameConverter<AccountStatus>(AccountStatus.values);
}

class Account extends DataClass implements Insertable<Account> {
  final String id;
  final String name;
  final AccountKind kind;

  /// `host:port` for display only.
  final String? displayHost;
  final AccountStatus status;
  final DateTime? expiresAt;
  final int? maxConnections;
  final bool isDefault;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final DateTime? lastSyncedAt;
  final DateTime? guideUpdatedAt;
  final int guideSourceCount;
  final int liveCount;
  final int movieCount;
  final int seriesCount;

  /// Settings › Guide time shift, applied when reading programmes.
  final int guideShiftMinutes;
  const Account({
    required this.id,
    required this.name,
    required this.kind,
    this.displayHost,
    required this.status,
    this.expiresAt,
    this.maxConnections,
    required this.isDefault,
    required this.sortOrder,
    required this.createdAt,
    this.lastUsedAt,
    this.lastSyncedAt,
    this.guideUpdatedAt,
    required this.guideSourceCount,
    required this.liveCount,
    required this.movieCount,
    required this.seriesCount,
    required this.guideShiftMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['kind'] = Variable<String>($AccountsTable.$converterkind.toSql(kind));
    }
    if (!nullToAbsent || displayHost != null) {
      map['display_host'] = Variable<String>(displayHost);
    }
    {
      map['status'] = Variable<String>(
        $AccountsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    if (!nullToAbsent || maxConnections != null) {
      map['max_connections'] = Variable<int>(maxConnections);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || guideUpdatedAt != null) {
      map['guide_updated_at'] = Variable<DateTime>(guideUpdatedAt);
    }
    map['guide_source_count'] = Variable<int>(guideSourceCount);
    map['live_count'] = Variable<int>(liveCount);
    map['movie_count'] = Variable<int>(movieCount);
    map['series_count'] = Variable<int>(seriesCount);
    map['guide_shift_minutes'] = Variable<int>(guideShiftMinutes);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      displayHost: displayHost == null && nullToAbsent
          ? const Value.absent()
          : Value(displayHost),
      status: Value(status),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      maxConnections: maxConnections == null && nullToAbsent
          ? const Value.absent()
          : Value(maxConnections),
      isDefault: Value(isDefault),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      guideUpdatedAt: guideUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(guideUpdatedAt),
      guideSourceCount: Value(guideSourceCount),
      liveCount: Value(liveCount),
      movieCount: Value(movieCount),
      seriesCount: Value(seriesCount),
      guideShiftMinutes: Value(guideShiftMinutes),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: $AccountsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      displayHost: serializer.fromJson<String?>(json['displayHost']),
      status: $AccountsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      maxConnections: serializer.fromJson<int?>(json['maxConnections']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUsedAt: serializer.fromJson<DateTime?>(json['lastUsedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      guideUpdatedAt: serializer.fromJson<DateTime?>(json['guideUpdatedAt']),
      guideSourceCount: serializer.fromJson<int>(json['guideSourceCount']),
      liveCount: serializer.fromJson<int>(json['liveCount']),
      movieCount: serializer.fromJson<int>(json['movieCount']),
      seriesCount: serializer.fromJson<int>(json['seriesCount']),
      guideShiftMinutes: serializer.fromJson<int>(json['guideShiftMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(
        $AccountsTable.$converterkind.toJson(kind),
      ),
      'displayHost': serializer.toJson<String?>(displayHost),
      'status': serializer.toJson<String>(
        $AccountsTable.$converterstatus.toJson(status),
      ),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'maxConnections': serializer.toJson<int?>(maxConnections),
      'isDefault': serializer.toJson<bool>(isDefault),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUsedAt': serializer.toJson<DateTime?>(lastUsedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'guideUpdatedAt': serializer.toJson<DateTime?>(guideUpdatedAt),
      'guideSourceCount': serializer.toJson<int>(guideSourceCount),
      'liveCount': serializer.toJson<int>(liveCount),
      'movieCount': serializer.toJson<int>(movieCount),
      'seriesCount': serializer.toJson<int>(seriesCount),
      'guideShiftMinutes': serializer.toJson<int>(guideShiftMinutes),
    };
  }

  Account copyWith({
    String? id,
    String? name,
    AccountKind? kind,
    Value<String?> displayHost = const Value.absent(),
    AccountStatus? status,
    Value<DateTime?> expiresAt = const Value.absent(),
    Value<int?> maxConnections = const Value.absent(),
    bool? isDefault,
    int? sortOrder,
    DateTime? createdAt,
    Value<DateTime?> lastUsedAt = const Value.absent(),
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<DateTime?> guideUpdatedAt = const Value.absent(),
    int? guideSourceCount,
    int? liveCount,
    int? movieCount,
    int? seriesCount,
    int? guideShiftMinutes,
  }) => Account(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    displayHost: displayHost.present ? displayHost.value : this.displayHost,
    status: status ?? this.status,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    maxConnections: maxConnections.present
        ? maxConnections.value
        : this.maxConnections,
    isDefault: isDefault ?? this.isDefault,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    guideUpdatedAt: guideUpdatedAt.present
        ? guideUpdatedAt.value
        : this.guideUpdatedAt,
    guideSourceCount: guideSourceCount ?? this.guideSourceCount,
    liveCount: liveCount ?? this.liveCount,
    movieCount: movieCount ?? this.movieCount,
    seriesCount: seriesCount ?? this.seriesCount,
    guideShiftMinutes: guideShiftMinutes ?? this.guideShiftMinutes,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      displayHost: data.displayHost.present
          ? data.displayHost.value
          : this.displayHost,
      status: data.status.present ? data.status.value : this.status,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      maxConnections: data.maxConnections.present
          ? data.maxConnections.value
          : this.maxConnections,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      guideUpdatedAt: data.guideUpdatedAt.present
          ? data.guideUpdatedAt.value
          : this.guideUpdatedAt,
      guideSourceCount: data.guideSourceCount.present
          ? data.guideSourceCount.value
          : this.guideSourceCount,
      liveCount: data.liveCount.present ? data.liveCount.value : this.liveCount,
      movieCount: data.movieCount.present
          ? data.movieCount.value
          : this.movieCount,
      seriesCount: data.seriesCount.present
          ? data.seriesCount.value
          : this.seriesCount,
      guideShiftMinutes: data.guideShiftMinutes.present
          ? data.guideShiftMinutes.value
          : this.guideShiftMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('displayHost: $displayHost, ')
          ..write('status: $status, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('maxConnections: $maxConnections, ')
          ..write('isDefault: $isDefault, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('guideUpdatedAt: $guideUpdatedAt, ')
          ..write('guideSourceCount: $guideSourceCount, ')
          ..write('liveCount: $liveCount, ')
          ..write('movieCount: $movieCount, ')
          ..write('seriesCount: $seriesCount, ')
          ..write('guideShiftMinutes: $guideShiftMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kind,
    displayHost,
    status,
    expiresAt,
    maxConnections,
    isDefault,
    sortOrder,
    createdAt,
    lastUsedAt,
    lastSyncedAt,
    guideUpdatedAt,
    guideSourceCount,
    liveCount,
    movieCount,
    seriesCount,
    guideShiftMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.displayHost == this.displayHost &&
          other.status == this.status &&
          other.expiresAt == this.expiresAt &&
          other.maxConnections == this.maxConnections &&
          other.isDefault == this.isDefault &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.lastUsedAt == this.lastUsedAt &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.guideUpdatedAt == this.guideUpdatedAt &&
          other.guideSourceCount == this.guideSourceCount &&
          other.liveCount == this.liveCount &&
          other.movieCount == this.movieCount &&
          other.seriesCount == this.seriesCount &&
          other.guideShiftMinutes == this.guideShiftMinutes);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> id;
  final Value<String> name;
  final Value<AccountKind> kind;
  final Value<String?> displayHost;
  final Value<AccountStatus> status;
  final Value<DateTime?> expiresAt;
  final Value<int?> maxConnections;
  final Value<bool> isDefault;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastUsedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime?> guideUpdatedAt;
  final Value<int> guideSourceCount;
  final Value<int> liveCount;
  final Value<int> movieCount;
  final Value<int> seriesCount;
  final Value<int> guideShiftMinutes;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.displayHost = const Value.absent(),
    this.status = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.maxConnections = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.guideUpdatedAt = const Value.absent(),
    this.guideSourceCount = const Value.absent(),
    this.liveCount = const Value.absent(),
    this.movieCount = const Value.absent(),
    this.seriesCount = const Value.absent(),
    this.guideShiftMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String name,
    required AccountKind kind,
    this.displayHost = const Value.absent(),
    this.status = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.maxConnections = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.lastUsedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.guideUpdatedAt = const Value.absent(),
    this.guideSourceCount = const Value.absent(),
    this.liveCount = const Value.absent(),
    this.movieCount = const Value.absent(),
    this.seriesCount = const Value.absent(),
    this.guideShiftMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       kind = Value(kind),
       createdAt = Value(createdAt);
  static Insertable<Account> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? displayHost,
    Expression<String>? status,
    Expression<DateTime>? expiresAt,
    Expression<int>? maxConnections,
    Expression<bool>? isDefault,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUsedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? guideUpdatedAt,
    Expression<int>? guideSourceCount,
    Expression<int>? liveCount,
    Expression<int>? movieCount,
    Expression<int>? seriesCount,
    Expression<int>? guideShiftMinutes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (displayHost != null) 'display_host': displayHost,
      if (status != null) 'status': status,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (maxConnections != null) 'max_connections': maxConnections,
      if (isDefault != null) 'is_default': isDefault,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (guideUpdatedAt != null) 'guide_updated_at': guideUpdatedAt,
      if (guideSourceCount != null) 'guide_source_count': guideSourceCount,
      if (liveCount != null) 'live_count': liveCount,
      if (movieCount != null) 'movie_count': movieCount,
      if (seriesCount != null) 'series_count': seriesCount,
      if (guideShiftMinutes != null) 'guide_shift_minutes': guideShiftMinutes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<AccountKind>? kind,
    Value<String?>? displayHost,
    Value<AccountStatus>? status,
    Value<DateTime?>? expiresAt,
    Value<int?>? maxConnections,
    Value<bool>? isDefault,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastUsedAt,
    Value<DateTime?>? lastSyncedAt,
    Value<DateTime?>? guideUpdatedAt,
    Value<int>? guideSourceCount,
    Value<int>? liveCount,
    Value<int>? movieCount,
    Value<int>? seriesCount,
    Value<int>? guideShiftMinutes,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      displayHost: displayHost ?? this.displayHost,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      maxConnections: maxConnections ?? this.maxConnections,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      guideUpdatedAt: guideUpdatedAt ?? this.guideUpdatedAt,
      guideSourceCount: guideSourceCount ?? this.guideSourceCount,
      liveCount: liveCount ?? this.liveCount,
      movieCount: movieCount ?? this.movieCount,
      seriesCount: seriesCount ?? this.seriesCount,
      guideShiftMinutes: guideShiftMinutes ?? this.guideShiftMinutes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $AccountsTable.$converterkind.toSql(kind.value),
      );
    }
    if (displayHost.present) {
      map['display_host'] = Variable<String>(displayHost.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $AccountsTable.$converterstatus.toSql(status.value),
      );
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (maxConnections.present) {
      map['max_connections'] = Variable<int>(maxConnections.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (guideUpdatedAt.present) {
      map['guide_updated_at'] = Variable<DateTime>(guideUpdatedAt.value);
    }
    if (guideSourceCount.present) {
      map['guide_source_count'] = Variable<int>(guideSourceCount.value);
    }
    if (liveCount.present) {
      map['live_count'] = Variable<int>(liveCount.value);
    }
    if (movieCount.present) {
      map['movie_count'] = Variable<int>(movieCount.value);
    }
    if (seriesCount.present) {
      map['series_count'] = Variable<int>(seriesCount.value);
    }
    if (guideShiftMinutes.present) {
      map['guide_shift_minutes'] = Variable<int>(guideShiftMinutes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('displayHost: $displayHost, ')
          ..write('status: $status, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('maxConnections: $maxConnections, ')
          ..write('isDefault: $isDefault, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('guideUpdatedAt: $guideUpdatedAt, ')
          ..write('guideSourceCount: $guideSourceCount, ')
          ..write('liveCount: $liveCount, ')
          ..write('movieCount: $movieCount, ')
          ..write('seriesCount: $seriesCount, ')
          ..write('guideShiftMinutes: $guideShiftMinutes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, MediaCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ContentKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ContentKind>($CategoriesTable.$converterkind);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAdultMeta = const VerificationMeta(
    'isAdult',
  );
  @override
  late final GeneratedColumn<bool> isAdult = GeneratedColumn<bool>(
    'is_adult',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_adult" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountId,
    kind,
    id,
    name,
    sortIndex,
    isAdult,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_sortIndexMeta);
    }
    if (data.containsKey('is_adult')) {
      context.handle(
        _isAdultMeta,
        isAdult.isAcceptableOrUnknown(data['is_adult']!, _isAdultMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId, kind, id};
  @override
  MediaCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaCategory(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      kind: $CategoriesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      )!,
      isAdult: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_adult'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ContentKind, String, String> $converterkind =
      const EnumNameConverter<ContentKind>(ContentKind.values);
}

class MediaCategory extends DataClass implements Insertable<MediaCategory> {
  final String accountId;
  final ContentKind kind;
  final String id;
  final String name;
  final int sortIndex;
  final bool isAdult;
  const MediaCategory({
    required this.accountId,
    required this.kind,
    required this.id,
    required this.name,
    required this.sortIndex,
    required this.isAdult,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    {
      map['kind'] = Variable<String>(
        $CategoriesTable.$converterkind.toSql(kind),
      );
    }
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['sort_index'] = Variable<int>(sortIndex);
    map['is_adult'] = Variable<bool>(isAdult);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      accountId: Value(accountId),
      kind: Value(kind),
      id: Value(id),
      name: Value(name),
      sortIndex: Value(sortIndex),
      isAdult: Value(isAdult),
    );
  }

  factory MediaCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaCategory(
      accountId: serializer.fromJson<String>(json['accountId']),
      kind: $CategoriesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
      isAdult: serializer.fromJson<bool>(json['isAdult']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'kind': serializer.toJson<String>(
        $CategoriesTable.$converterkind.toJson(kind),
      ),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sortIndex': serializer.toJson<int>(sortIndex),
      'isAdult': serializer.toJson<bool>(isAdult),
    };
  }

  MediaCategory copyWith({
    String? accountId,
    ContentKind? kind,
    String? id,
    String? name,
    int? sortIndex,
    bool? isAdult,
  }) => MediaCategory(
    accountId: accountId ?? this.accountId,
    kind: kind ?? this.kind,
    id: id ?? this.id,
    name: name ?? this.name,
    sortIndex: sortIndex ?? this.sortIndex,
    isAdult: isAdult ?? this.isAdult,
  );
  MediaCategory copyWithCompanion(CategoriesCompanion data) {
    return MediaCategory(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      kind: data.kind.present ? data.kind.value : this.kind,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
      isAdult: data.isAdult.present ? data.isAdult.value : this.isAdult,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaCategory(')
          ..write('accountId: $accountId, ')
          ..write('kind: $kind, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('isAdult: $isAdult')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(accountId, kind, id, name, sortIndex, isAdult);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaCategory &&
          other.accountId == this.accountId &&
          other.kind == this.kind &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortIndex == this.sortIndex &&
          other.isAdult == this.isAdult);
}

class CategoriesCompanion extends UpdateCompanion<MediaCategory> {
  final Value<String> accountId;
  final Value<ContentKind> kind;
  final Value<String> id;
  final Value<String> name;
  final Value<int> sortIndex;
  final Value<bool> isAdult;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.accountId = const Value.absent(),
    this.kind = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.isAdult = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String accountId,
    required ContentKind kind,
    required String id,
    required String name,
    required int sortIndex,
    this.isAdult = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       kind = Value(kind),
       id = Value(id),
       name = Value(name),
       sortIndex = Value(sortIndex);
  static Insertable<MediaCategory> custom({
    Expression<String>? accountId,
    Expression<String>? kind,
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? sortIndex,
    Expression<bool>? isAdult,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (kind != null) 'kind': kind,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (isAdult != null) 'is_adult': isAdult,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? accountId,
    Value<ContentKind>? kind,
    Value<String>? id,
    Value<String>? name,
    Value<int>? sortIndex,
    Value<bool>? isAdult,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      accountId: accountId ?? this.accountId,
      kind: kind ?? this.kind,
      id: id ?? this.id,
      name: name ?? this.name,
      sortIndex: sortIndex ?? this.sortIndex,
      isAdult: isAdult ?? this.isAdult,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $CategoriesTable.$converterkind.toSql(kind.value),
      );
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    if (isAdult.present) {
      map['is_adult'] = Variable<bool>(isAdult.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('accountId: $accountId, ')
          ..write('kind: $kind, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('isAdult: $isAdult, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChannelsTable extends Channels with TableInfo<$ChannelsTable, Channel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChannelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logoMeta = const VerificationMeta('logo');
  @override
  late final GeneratedColumn<String> logo = GeneratedColumn<String>(
    'logo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _epgIdMeta = const VerificationMeta('epgId');
  @override
  late final GeneratedColumn<String> epgId = GeneratedColumn<String>(
    'epg_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _streamUrlMeta = const VerificationMeta(
    'streamUrl',
  );
  @override
  late final GeneratedColumn<String> streamUrl = GeneratedColumn<String>(
    'stream_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _headersMeta = const VerificationMeta(
    'headers',
  );
  @override
  late final GeneratedColumn<String> headers = GeneratedColumn<String>(
    'headers',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _catchupDaysMeta = const VerificationMeta(
    'catchupDays',
  );
  @override
  late final GeneratedColumn<int> catchupDays = GeneratedColumn<int>(
    'catchup_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountId,
    id,
    name,
    number,
    logo,
    categoryId,
    epgId,
    streamUrl,
    headers,
    catchupDays,
    sortIndex,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'channels';
  @override
  VerificationContext validateIntegrity(
    Insertable<Channel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('logo')) {
      context.handle(
        _logoMeta,
        logo.isAcceptableOrUnknown(data['logo']!, _logoMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('epg_id')) {
      context.handle(
        _epgIdMeta,
        epgId.isAcceptableOrUnknown(data['epg_id']!, _epgIdMeta),
      );
    }
    if (data.containsKey('stream_url')) {
      context.handle(
        _streamUrlMeta,
        streamUrl.isAcceptableOrUnknown(data['stream_url']!, _streamUrlMeta),
      );
    }
    if (data.containsKey('headers')) {
      context.handle(
        _headersMeta,
        headers.isAcceptableOrUnknown(data['headers']!, _headersMeta),
      );
    }
    if (data.containsKey('catchup_days')) {
      context.handle(
        _catchupDaysMeta,
        catchupDays.isAcceptableOrUnknown(
          data['catchup_days']!,
          _catchupDaysMeta,
        ),
      );
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_sortIndexMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId, id};
  @override
  Channel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Channel(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      ),
      logo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      epgId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}epg_id'],
      ),
      streamUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stream_url'],
      ),
      headers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}headers'],
      ),
      catchupDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}catchup_days'],
      )!,
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      ),
    );
  }

  @override
  $ChannelsTable createAlias(String alias) {
    return $ChannelsTable(attachedDatabase, alias);
  }
}

class Channel extends DataClass implements Insertable<Channel> {
  final String accountId;
  final String id;
  final String name;
  final int? number;
  final String? logo;
  final String? categoryId;
  final String? epgId;
  final String? streamUrl;

  /// JSON object of per-stream HTTP headers.
  final String? headers;
  final int catchupDays;
  final int sortIndex;
  final DateTime? addedAt;
  const Channel({
    required this.accountId,
    required this.id,
    required this.name,
    this.number,
    this.logo,
    this.categoryId,
    this.epgId,
    this.streamUrl,
    this.headers,
    required this.catchupDays,
    required this.sortIndex,
    this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || number != null) {
      map['number'] = Variable<int>(number);
    }
    if (!nullToAbsent || logo != null) {
      map['logo'] = Variable<String>(logo);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || epgId != null) {
      map['epg_id'] = Variable<String>(epgId);
    }
    if (!nullToAbsent || streamUrl != null) {
      map['stream_url'] = Variable<String>(streamUrl);
    }
    if (!nullToAbsent || headers != null) {
      map['headers'] = Variable<String>(headers);
    }
    map['catchup_days'] = Variable<int>(catchupDays);
    map['sort_index'] = Variable<int>(sortIndex);
    if (!nullToAbsent || addedAt != null) {
      map['added_at'] = Variable<DateTime>(addedAt);
    }
    return map;
  }

  ChannelsCompanion toCompanion(bool nullToAbsent) {
    return ChannelsCompanion(
      accountId: Value(accountId),
      id: Value(id),
      name: Value(name),
      number: number == null && nullToAbsent
          ? const Value.absent()
          : Value(number),
      logo: logo == null && nullToAbsent ? const Value.absent() : Value(logo),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      epgId: epgId == null && nullToAbsent
          ? const Value.absent()
          : Value(epgId),
      streamUrl: streamUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(streamUrl),
      headers: headers == null && nullToAbsent
          ? const Value.absent()
          : Value(headers),
      catchupDays: Value(catchupDays),
      sortIndex: Value(sortIndex),
      addedAt: addedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(addedAt),
    );
  }

  factory Channel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Channel(
      accountId: serializer.fromJson<String>(json['accountId']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      number: serializer.fromJson<int?>(json['number']),
      logo: serializer.fromJson<String?>(json['logo']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      epgId: serializer.fromJson<String?>(json['epgId']),
      streamUrl: serializer.fromJson<String?>(json['streamUrl']),
      headers: serializer.fromJson<String?>(json['headers']),
      catchupDays: serializer.fromJson<int>(json['catchupDays']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
      addedAt: serializer.fromJson<DateTime?>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'number': serializer.toJson<int?>(number),
      'logo': serializer.toJson<String?>(logo),
      'categoryId': serializer.toJson<String?>(categoryId),
      'epgId': serializer.toJson<String?>(epgId),
      'streamUrl': serializer.toJson<String?>(streamUrl),
      'headers': serializer.toJson<String?>(headers),
      'catchupDays': serializer.toJson<int>(catchupDays),
      'sortIndex': serializer.toJson<int>(sortIndex),
      'addedAt': serializer.toJson<DateTime?>(addedAt),
    };
  }

  Channel copyWith({
    String? accountId,
    String? id,
    String? name,
    Value<int?> number = const Value.absent(),
    Value<String?> logo = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    Value<String?> epgId = const Value.absent(),
    Value<String?> streamUrl = const Value.absent(),
    Value<String?> headers = const Value.absent(),
    int? catchupDays,
    int? sortIndex,
    Value<DateTime?> addedAt = const Value.absent(),
  }) => Channel(
    accountId: accountId ?? this.accountId,
    id: id ?? this.id,
    name: name ?? this.name,
    number: number.present ? number.value : this.number,
    logo: logo.present ? logo.value : this.logo,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    epgId: epgId.present ? epgId.value : this.epgId,
    streamUrl: streamUrl.present ? streamUrl.value : this.streamUrl,
    headers: headers.present ? headers.value : this.headers,
    catchupDays: catchupDays ?? this.catchupDays,
    sortIndex: sortIndex ?? this.sortIndex,
    addedAt: addedAt.present ? addedAt.value : this.addedAt,
  );
  Channel copyWithCompanion(ChannelsCompanion data) {
    return Channel(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      number: data.number.present ? data.number.value : this.number,
      logo: data.logo.present ? data.logo.value : this.logo,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      epgId: data.epgId.present ? data.epgId.value : this.epgId,
      streamUrl: data.streamUrl.present ? data.streamUrl.value : this.streamUrl,
      headers: data.headers.present ? data.headers.value : this.headers,
      catchupDays: data.catchupDays.present
          ? data.catchupDays.value
          : this.catchupDays,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Channel(')
          ..write('accountId: $accountId, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('number: $number, ')
          ..write('logo: $logo, ')
          ..write('categoryId: $categoryId, ')
          ..write('epgId: $epgId, ')
          ..write('streamUrl: $streamUrl, ')
          ..write('headers: $headers, ')
          ..write('catchupDays: $catchupDays, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    accountId,
    id,
    name,
    number,
    logo,
    categoryId,
    epgId,
    streamUrl,
    headers,
    catchupDays,
    sortIndex,
    addedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Channel &&
          other.accountId == this.accountId &&
          other.id == this.id &&
          other.name == this.name &&
          other.number == this.number &&
          other.logo == this.logo &&
          other.categoryId == this.categoryId &&
          other.epgId == this.epgId &&
          other.streamUrl == this.streamUrl &&
          other.headers == this.headers &&
          other.catchupDays == this.catchupDays &&
          other.sortIndex == this.sortIndex &&
          other.addedAt == this.addedAt);
}

class ChannelsCompanion extends UpdateCompanion<Channel> {
  final Value<String> accountId;
  final Value<String> id;
  final Value<String> name;
  final Value<int?> number;
  final Value<String?> logo;
  final Value<String?> categoryId;
  final Value<String?> epgId;
  final Value<String?> streamUrl;
  final Value<String?> headers;
  final Value<int> catchupDays;
  final Value<int> sortIndex;
  final Value<DateTime?> addedAt;
  final Value<int> rowid;
  const ChannelsCompanion({
    this.accountId = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.number = const Value.absent(),
    this.logo = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.epgId = const Value.absent(),
    this.streamUrl = const Value.absent(),
    this.headers = const Value.absent(),
    this.catchupDays = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChannelsCompanion.insert({
    required String accountId,
    required String id,
    required String name,
    this.number = const Value.absent(),
    this.logo = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.epgId = const Value.absent(),
    this.streamUrl = const Value.absent(),
    this.headers = const Value.absent(),
    this.catchupDays = const Value.absent(),
    required int sortIndex,
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       id = Value(id),
       name = Value(name),
       sortIndex = Value(sortIndex);
  static Insertable<Channel> custom({
    Expression<String>? accountId,
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? number,
    Expression<String>? logo,
    Expression<String>? categoryId,
    Expression<String>? epgId,
    Expression<String>? streamUrl,
    Expression<String>? headers,
    Expression<int>? catchupDays,
    Expression<int>? sortIndex,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (number != null) 'number': number,
      if (logo != null) 'logo': logo,
      if (categoryId != null) 'category_id': categoryId,
      if (epgId != null) 'epg_id': epgId,
      if (streamUrl != null) 'stream_url': streamUrl,
      if (headers != null) 'headers': headers,
      if (catchupDays != null) 'catchup_days': catchupDays,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChannelsCompanion copyWith({
    Value<String>? accountId,
    Value<String>? id,
    Value<String>? name,
    Value<int?>? number,
    Value<String?>? logo,
    Value<String?>? categoryId,
    Value<String?>? epgId,
    Value<String?>? streamUrl,
    Value<String?>? headers,
    Value<int>? catchupDays,
    Value<int>? sortIndex,
    Value<DateTime?>? addedAt,
    Value<int>? rowid,
  }) {
    return ChannelsCompanion(
      accountId: accountId ?? this.accountId,
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      logo: logo ?? this.logo,
      categoryId: categoryId ?? this.categoryId,
      epgId: epgId ?? this.epgId,
      streamUrl: streamUrl ?? this.streamUrl,
      headers: headers ?? this.headers,
      catchupDays: catchupDays ?? this.catchupDays,
      sortIndex: sortIndex ?? this.sortIndex,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (logo.present) {
      map['logo'] = Variable<String>(logo.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (epgId.present) {
      map['epg_id'] = Variable<String>(epgId.value);
    }
    if (streamUrl.present) {
      map['stream_url'] = Variable<String>(streamUrl.value);
    }
    if (headers.present) {
      map['headers'] = Variable<String>(headers.value);
    }
    if (catchupDays.present) {
      map['catchup_days'] = Variable<int>(catchupDays.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChannelsCompanion(')
          ..write('accountId: $accountId, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('number: $number, ')
          ..write('logo: $logo, ')
          ..write('categoryId: $categoryId, ')
          ..write('epgId: $epgId, ')
          ..write('streamUrl: $streamUrl, ')
          ..write('headers: $headers, ')
          ..write('catchupDays: $catchupDays, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MoviesTable extends Movies with TableInfo<$MoviesTable, Movie> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoviesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posterMeta = const VerificationMeta('poster');
  @override
  late final GeneratedColumn<String> poster = GeneratedColumn<String>(
    'poster',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _containerExtMeta = const VerificationMeta(
    'containerExt',
  );
  @override
  late final GeneratedColumn<String> containerExt = GeneratedColumn<String>(
    'container_ext',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _streamUrlMeta = const VerificationMeta(
    'streamUrl',
  );
  @override
  late final GeneratedColumn<String> streamUrl = GeneratedColumn<String>(
    'stream_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountId,
    id,
    name,
    poster,
    rating,
    year,
    addedAt,
    categoryId,
    containerExt,
    streamUrl,
    sortIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Movie> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('poster')) {
      context.handle(
        _posterMeta,
        poster.isAcceptableOrUnknown(data['poster']!, _posterMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('container_ext')) {
      context.handle(
        _containerExtMeta,
        containerExt.isAcceptableOrUnknown(
          data['container_ext']!,
          _containerExtMeta,
        ),
      );
    }
    if (data.containsKey('stream_url')) {
      context.handle(
        _streamUrlMeta,
        streamUrl.isAcceptableOrUnknown(data['stream_url']!, _streamUrlMeta),
      );
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_sortIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId, id};
  @override
  Movie map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Movie(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      poster: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poster'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      containerExt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}container_ext'],
      ),
      streamUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stream_url'],
      ),
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      )!,
    );
  }

  @override
  $MoviesTable createAlias(String alias) {
    return $MoviesTable(attachedDatabase, alias);
  }
}

class Movie extends DataClass implements Insertable<Movie> {
  final String accountId;
  final String id;
  final String name;
  final String? poster;
  final double? rating;
  final int? year;
  final DateTime? addedAt;
  final String? categoryId;
  final String? containerExt;
  final String? streamUrl;
  final int sortIndex;
  const Movie({
    required this.accountId,
    required this.id,
    required this.name,
    this.poster,
    this.rating,
    this.year,
    this.addedAt,
    this.categoryId,
    this.containerExt,
    this.streamUrl,
    required this.sortIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || poster != null) {
      map['poster'] = Variable<String>(poster);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || addedAt != null) {
      map['added_at'] = Variable<DateTime>(addedAt);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || containerExt != null) {
      map['container_ext'] = Variable<String>(containerExt);
    }
    if (!nullToAbsent || streamUrl != null) {
      map['stream_url'] = Variable<String>(streamUrl);
    }
    map['sort_index'] = Variable<int>(sortIndex);
    return map;
  }

  MoviesCompanion toCompanion(bool nullToAbsent) {
    return MoviesCompanion(
      accountId: Value(accountId),
      id: Value(id),
      name: Value(name),
      poster: poster == null && nullToAbsent
          ? const Value.absent()
          : Value(poster),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      addedAt: addedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(addedAt),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      containerExt: containerExt == null && nullToAbsent
          ? const Value.absent()
          : Value(containerExt),
      streamUrl: streamUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(streamUrl),
      sortIndex: Value(sortIndex),
    );
  }

  factory Movie.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Movie(
      accountId: serializer.fromJson<String>(json['accountId']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      poster: serializer.fromJson<String?>(json['poster']),
      rating: serializer.fromJson<double?>(json['rating']),
      year: serializer.fromJson<int?>(json['year']),
      addedAt: serializer.fromJson<DateTime?>(json['addedAt']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      containerExt: serializer.fromJson<String?>(json['containerExt']),
      streamUrl: serializer.fromJson<String?>(json['streamUrl']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'poster': serializer.toJson<String?>(poster),
      'rating': serializer.toJson<double?>(rating),
      'year': serializer.toJson<int?>(year),
      'addedAt': serializer.toJson<DateTime?>(addedAt),
      'categoryId': serializer.toJson<String?>(categoryId),
      'containerExt': serializer.toJson<String?>(containerExt),
      'streamUrl': serializer.toJson<String?>(streamUrl),
      'sortIndex': serializer.toJson<int>(sortIndex),
    };
  }

  Movie copyWith({
    String? accountId,
    String? id,
    String? name,
    Value<String?> poster = const Value.absent(),
    Value<double?> rating = const Value.absent(),
    Value<int?> year = const Value.absent(),
    Value<DateTime?> addedAt = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    Value<String?> containerExt = const Value.absent(),
    Value<String?> streamUrl = const Value.absent(),
    int? sortIndex,
  }) => Movie(
    accountId: accountId ?? this.accountId,
    id: id ?? this.id,
    name: name ?? this.name,
    poster: poster.present ? poster.value : this.poster,
    rating: rating.present ? rating.value : this.rating,
    year: year.present ? year.value : this.year,
    addedAt: addedAt.present ? addedAt.value : this.addedAt,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    containerExt: containerExt.present ? containerExt.value : this.containerExt,
    streamUrl: streamUrl.present ? streamUrl.value : this.streamUrl,
    sortIndex: sortIndex ?? this.sortIndex,
  );
  Movie copyWithCompanion(MoviesCompanion data) {
    return Movie(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      poster: data.poster.present ? data.poster.value : this.poster,
      rating: data.rating.present ? data.rating.value : this.rating,
      year: data.year.present ? data.year.value : this.year,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      containerExt: data.containerExt.present
          ? data.containerExt.value
          : this.containerExt,
      streamUrl: data.streamUrl.present ? data.streamUrl.value : this.streamUrl,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Movie(')
          ..write('accountId: $accountId, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('poster: $poster, ')
          ..write('rating: $rating, ')
          ..write('year: $year, ')
          ..write('addedAt: $addedAt, ')
          ..write('categoryId: $categoryId, ')
          ..write('containerExt: $containerExt, ')
          ..write('streamUrl: $streamUrl, ')
          ..write('sortIndex: $sortIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    accountId,
    id,
    name,
    poster,
    rating,
    year,
    addedAt,
    categoryId,
    containerExt,
    streamUrl,
    sortIndex,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Movie &&
          other.accountId == this.accountId &&
          other.id == this.id &&
          other.name == this.name &&
          other.poster == this.poster &&
          other.rating == this.rating &&
          other.year == this.year &&
          other.addedAt == this.addedAt &&
          other.categoryId == this.categoryId &&
          other.containerExt == this.containerExt &&
          other.streamUrl == this.streamUrl &&
          other.sortIndex == this.sortIndex);
}

class MoviesCompanion extends UpdateCompanion<Movie> {
  final Value<String> accountId;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> poster;
  final Value<double?> rating;
  final Value<int?> year;
  final Value<DateTime?> addedAt;
  final Value<String?> categoryId;
  final Value<String?> containerExt;
  final Value<String?> streamUrl;
  final Value<int> sortIndex;
  final Value<int> rowid;
  const MoviesCompanion({
    this.accountId = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.poster = const Value.absent(),
    this.rating = const Value.absent(),
    this.year = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.containerExt = const Value.absent(),
    this.streamUrl = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MoviesCompanion.insert({
    required String accountId,
    required String id,
    required String name,
    this.poster = const Value.absent(),
    this.rating = const Value.absent(),
    this.year = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.containerExt = const Value.absent(),
    this.streamUrl = const Value.absent(),
    required int sortIndex,
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       id = Value(id),
       name = Value(name),
       sortIndex = Value(sortIndex);
  static Insertable<Movie> custom({
    Expression<String>? accountId,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? poster,
    Expression<double>? rating,
    Expression<int>? year,
    Expression<DateTime>? addedAt,
    Expression<String>? categoryId,
    Expression<String>? containerExt,
    Expression<String>? streamUrl,
    Expression<int>? sortIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (poster != null) 'poster': poster,
      if (rating != null) 'rating': rating,
      if (year != null) 'year': year,
      if (addedAt != null) 'added_at': addedAt,
      if (categoryId != null) 'category_id': categoryId,
      if (containerExt != null) 'container_ext': containerExt,
      if (streamUrl != null) 'stream_url': streamUrl,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MoviesCompanion copyWith({
    Value<String>? accountId,
    Value<String>? id,
    Value<String>? name,
    Value<String?>? poster,
    Value<double?>? rating,
    Value<int?>? year,
    Value<DateTime?>? addedAt,
    Value<String?>? categoryId,
    Value<String?>? containerExt,
    Value<String?>? streamUrl,
    Value<int>? sortIndex,
    Value<int>? rowid,
  }) {
    return MoviesCompanion(
      accountId: accountId ?? this.accountId,
      id: id ?? this.id,
      name: name ?? this.name,
      poster: poster ?? this.poster,
      rating: rating ?? this.rating,
      year: year ?? this.year,
      addedAt: addedAt ?? this.addedAt,
      categoryId: categoryId ?? this.categoryId,
      containerExt: containerExt ?? this.containerExt,
      streamUrl: streamUrl ?? this.streamUrl,
      sortIndex: sortIndex ?? this.sortIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (poster.present) {
      map['poster'] = Variable<String>(poster.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (containerExt.present) {
      map['container_ext'] = Variable<String>(containerExt.value);
    }
    if (streamUrl.present) {
      map['stream_url'] = Variable<String>(streamUrl.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoviesCompanion(')
          ..write('accountId: $accountId, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('poster: $poster, ')
          ..write('rating: $rating, ')
          ..write('year: $year, ')
          ..write('addedAt: $addedAt, ')
          ..write('categoryId: $categoryId, ')
          ..write('containerExt: $containerExt, ')
          ..write('streamUrl: $streamUrl, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeriesTableTable extends SeriesTable
    with TableInfo<$SeriesTableTable, Show> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverMeta = const VerificationMeta('cover');
  @override
  late final GeneratedColumn<String> cover = GeneratedColumn<String>(
    'cover',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _backdropMeta = const VerificationMeta(
    'backdrop',
  );
  @override
  late final GeneratedColumn<String> backdrop = GeneratedColumn<String>(
    'backdrop',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plotMeta = const VerificationMeta('plot');
  @override
  late final GeneratedColumn<String> plot = GeneratedColumn<String>(
    'plot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountId,
    id,
    name,
    cover,
    backdrop,
    plot,
    rating,
    year,
    genre,
    updatedAt,
    categoryId,
    sortIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series';
  @override
  VerificationContext validateIntegrity(
    Insertable<Show> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cover')) {
      context.handle(
        _coverMeta,
        cover.isAcceptableOrUnknown(data['cover']!, _coverMeta),
      );
    }
    if (data.containsKey('backdrop')) {
      context.handle(
        _backdropMeta,
        backdrop.isAcceptableOrUnknown(data['backdrop']!, _backdropMeta),
      );
    }
    if (data.containsKey('plot')) {
      context.handle(
        _plotMeta,
        plot.isAcceptableOrUnknown(data['plot']!, _plotMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_sortIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId, id};
  @override
  Show map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Show(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      cover: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover'],
      ),
      backdrop: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backdrop'],
      ),
      plot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plot'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      )!,
    );
  }

  @override
  $SeriesTableTable createAlias(String alias) {
    return $SeriesTableTable(attachedDatabase, alias);
  }
}

class Show extends DataClass implements Insertable<Show> {
  final String accountId;
  final String id;
  final String name;
  final String? cover;
  final String? backdrop;
  final String? plot;
  final double? rating;
  final int? year;
  final String? genre;
  final DateTime? updatedAt;
  final String? categoryId;
  final int sortIndex;
  const Show({
    required this.accountId,
    required this.id,
    required this.name,
    this.cover,
    this.backdrop,
    this.plot,
    this.rating,
    this.year,
    this.genre,
    this.updatedAt,
    this.categoryId,
    required this.sortIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || cover != null) {
      map['cover'] = Variable<String>(cover);
    }
    if (!nullToAbsent || backdrop != null) {
      map['backdrop'] = Variable<String>(backdrop);
    }
    if (!nullToAbsent || plot != null) {
      map['plot'] = Variable<String>(plot);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['sort_index'] = Variable<int>(sortIndex);
    return map;
  }

  SeriesTableCompanion toCompanion(bool nullToAbsent) {
    return SeriesTableCompanion(
      accountId: Value(accountId),
      id: Value(id),
      name: Value(name),
      cover: cover == null && nullToAbsent
          ? const Value.absent()
          : Value(cover),
      backdrop: backdrop == null && nullToAbsent
          ? const Value.absent()
          : Value(backdrop),
      plot: plot == null && nullToAbsent ? const Value.absent() : Value(plot),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      sortIndex: Value(sortIndex),
    );
  }

  factory Show.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Show(
      accountId: serializer.fromJson<String>(json['accountId']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      cover: serializer.fromJson<String?>(json['cover']),
      backdrop: serializer.fromJson<String?>(json['backdrop']),
      plot: serializer.fromJson<String?>(json['plot']),
      rating: serializer.fromJson<double?>(json['rating']),
      year: serializer.fromJson<int?>(json['year']),
      genre: serializer.fromJson<String?>(json['genre']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'cover': serializer.toJson<String?>(cover),
      'backdrop': serializer.toJson<String?>(backdrop),
      'plot': serializer.toJson<String?>(plot),
      'rating': serializer.toJson<double?>(rating),
      'year': serializer.toJson<int?>(year),
      'genre': serializer.toJson<String?>(genre),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'categoryId': serializer.toJson<String?>(categoryId),
      'sortIndex': serializer.toJson<int>(sortIndex),
    };
  }

  Show copyWith({
    String? accountId,
    String? id,
    String? name,
    Value<String?> cover = const Value.absent(),
    Value<String?> backdrop = const Value.absent(),
    Value<String?> plot = const Value.absent(),
    Value<double?> rating = const Value.absent(),
    Value<int?> year = const Value.absent(),
    Value<String?> genre = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    int? sortIndex,
  }) => Show(
    accountId: accountId ?? this.accountId,
    id: id ?? this.id,
    name: name ?? this.name,
    cover: cover.present ? cover.value : this.cover,
    backdrop: backdrop.present ? backdrop.value : this.backdrop,
    plot: plot.present ? plot.value : this.plot,
    rating: rating.present ? rating.value : this.rating,
    year: year.present ? year.value : this.year,
    genre: genre.present ? genre.value : this.genre,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    sortIndex: sortIndex ?? this.sortIndex,
  );
  Show copyWithCompanion(SeriesTableCompanion data) {
    return Show(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      cover: data.cover.present ? data.cover.value : this.cover,
      backdrop: data.backdrop.present ? data.backdrop.value : this.backdrop,
      plot: data.plot.present ? data.plot.value : this.plot,
      rating: data.rating.present ? data.rating.value : this.rating,
      year: data.year.present ? data.year.value : this.year,
      genre: data.genre.present ? data.genre.value : this.genre,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Show(')
          ..write('accountId: $accountId, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cover: $cover, ')
          ..write('backdrop: $backdrop, ')
          ..write('plot: $plot, ')
          ..write('rating: $rating, ')
          ..write('year: $year, ')
          ..write('genre: $genre, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('categoryId: $categoryId, ')
          ..write('sortIndex: $sortIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    accountId,
    id,
    name,
    cover,
    backdrop,
    plot,
    rating,
    year,
    genre,
    updatedAt,
    categoryId,
    sortIndex,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Show &&
          other.accountId == this.accountId &&
          other.id == this.id &&
          other.name == this.name &&
          other.cover == this.cover &&
          other.backdrop == this.backdrop &&
          other.plot == this.plot &&
          other.rating == this.rating &&
          other.year == this.year &&
          other.genre == this.genre &&
          other.updatedAt == this.updatedAt &&
          other.categoryId == this.categoryId &&
          other.sortIndex == this.sortIndex);
}

class SeriesTableCompanion extends UpdateCompanion<Show> {
  final Value<String> accountId;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> cover;
  final Value<String?> backdrop;
  final Value<String?> plot;
  final Value<double?> rating;
  final Value<int?> year;
  final Value<String?> genre;
  final Value<DateTime?> updatedAt;
  final Value<String?> categoryId;
  final Value<int> sortIndex;
  final Value<int> rowid;
  const SeriesTableCompanion({
    this.accountId = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.cover = const Value.absent(),
    this.backdrop = const Value.absent(),
    this.plot = const Value.absent(),
    this.rating = const Value.absent(),
    this.year = const Value.absent(),
    this.genre = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeriesTableCompanion.insert({
    required String accountId,
    required String id,
    required String name,
    this.cover = const Value.absent(),
    this.backdrop = const Value.absent(),
    this.plot = const Value.absent(),
    this.rating = const Value.absent(),
    this.year = const Value.absent(),
    this.genre = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.categoryId = const Value.absent(),
    required int sortIndex,
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       id = Value(id),
       name = Value(name),
       sortIndex = Value(sortIndex);
  static Insertable<Show> custom({
    Expression<String>? accountId,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? cover,
    Expression<String>? backdrop,
    Expression<String>? plot,
    Expression<double>? rating,
    Expression<int>? year,
    Expression<String>? genre,
    Expression<DateTime>? updatedAt,
    Expression<String>? categoryId,
    Expression<int>? sortIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (cover != null) 'cover': cover,
      if (backdrop != null) 'backdrop': backdrop,
      if (plot != null) 'plot': plot,
      if (rating != null) 'rating': rating,
      if (year != null) 'year': year,
      if (genre != null) 'genre': genre,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (categoryId != null) 'category_id': categoryId,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeriesTableCompanion copyWith({
    Value<String>? accountId,
    Value<String>? id,
    Value<String>? name,
    Value<String?>? cover,
    Value<String?>? backdrop,
    Value<String?>? plot,
    Value<double?>? rating,
    Value<int?>? year,
    Value<String?>? genre,
    Value<DateTime?>? updatedAt,
    Value<String?>? categoryId,
    Value<int>? sortIndex,
    Value<int>? rowid,
  }) {
    return SeriesTableCompanion(
      accountId: accountId ?? this.accountId,
      id: id ?? this.id,
      name: name ?? this.name,
      cover: cover ?? this.cover,
      backdrop: backdrop ?? this.backdrop,
      plot: plot ?? this.plot,
      rating: rating ?? this.rating,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryId: categoryId ?? this.categoryId,
      sortIndex: sortIndex ?? this.sortIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (cover.present) {
      map['cover'] = Variable<String>(cover.value);
    }
    if (backdrop.present) {
      map['backdrop'] = Variable<String>(backdrop.value);
    }
    if (plot.present) {
      map['plot'] = Variable<String>(plot.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesTableCompanion(')
          ..write('accountId: $accountId, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cover: $cover, ')
          ..write('backdrop: $backdrop, ')
          ..write('plot: $plot, ')
          ..write('rating: $rating, ')
          ..write('year: $year, ')
          ..write('genre: $genre, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('categoryId: $categoryId, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EpisodesTable extends Episodes with TableInfo<$EpisodesTable, Episode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpisodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<int> season = GeneratedColumn<int>(
    'season',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _episodeMeta = const VerificationMeta(
    'episode',
  );
  @override
  late final GeneratedColumn<int> episode = GeneratedColumn<int>(
    'episode',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _containerExtMeta = const VerificationMeta(
    'containerExt',
  );
  @override
  late final GeneratedColumn<String> containerExt = GeneratedColumn<String>(
    'container_ext',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _streamUrlMeta = const VerificationMeta(
    'streamUrl',
  );
  @override
  late final GeneratedColumn<String> streamUrl = GeneratedColumn<String>(
    'stream_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecsMeta = const VerificationMeta(
    'durationSecs',
  );
  @override
  late final GeneratedColumn<int> durationSecs = GeneratedColumn<int>(
    'duration_secs',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plotMeta = const VerificationMeta('plot');
  @override
  late final GeneratedColumn<String> plot = GeneratedColumn<String>(
    'plot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stillMeta = const VerificationMeta('still');
  @override
  late final GeneratedColumn<String> still = GeneratedColumn<String>(
    'still',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _airDateMeta = const VerificationMeta(
    'airDate',
  );
  @override
  late final GeneratedColumn<DateTime> airDate = GeneratedColumn<DateTime>(
    'air_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountId,
    id,
    seriesId,
    season,
    episode,
    title,
    containerExt,
    streamUrl,
    durationSecs,
    plot,
    still,
    airDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'episodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Episode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesIdMeta);
    }
    if (data.containsKey('season')) {
      context.handle(
        _seasonMeta,
        season.isAcceptableOrUnknown(data['season']!, _seasonMeta),
      );
    } else if (isInserting) {
      context.missing(_seasonMeta);
    }
    if (data.containsKey('episode')) {
      context.handle(
        _episodeMeta,
        episode.isAcceptableOrUnknown(data['episode']!, _episodeMeta),
      );
    } else if (isInserting) {
      context.missing(_episodeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('container_ext')) {
      context.handle(
        _containerExtMeta,
        containerExt.isAcceptableOrUnknown(
          data['container_ext']!,
          _containerExtMeta,
        ),
      );
    }
    if (data.containsKey('stream_url')) {
      context.handle(
        _streamUrlMeta,
        streamUrl.isAcceptableOrUnknown(data['stream_url']!, _streamUrlMeta),
      );
    }
    if (data.containsKey('duration_secs')) {
      context.handle(
        _durationSecsMeta,
        durationSecs.isAcceptableOrUnknown(
          data['duration_secs']!,
          _durationSecsMeta,
        ),
      );
    }
    if (data.containsKey('plot')) {
      context.handle(
        _plotMeta,
        plot.isAcceptableOrUnknown(data['plot']!, _plotMeta),
      );
    }
    if (data.containsKey('still')) {
      context.handle(
        _stillMeta,
        still.isAcceptableOrUnknown(data['still']!, _stillMeta),
      );
    }
    if (data.containsKey('air_date')) {
      context.handle(
        _airDateMeta,
        airDate.isAcceptableOrUnknown(data['air_date']!, _airDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId, id};
  @override
  Episode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Episode(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      )!,
      season: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}season'],
      )!,
      episode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      containerExt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}container_ext'],
      ),
      streamUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stream_url'],
      ),
      durationSecs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_secs'],
      ),
      plot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plot'],
      ),
      still: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}still'],
      ),
      airDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}air_date'],
      ),
    );
  }

  @override
  $EpisodesTable createAlias(String alias) {
    return $EpisodesTable(attachedDatabase, alias);
  }
}

class Episode extends DataClass implements Insertable<Episode> {
  final String accountId;
  final String id;
  final String seriesId;
  final int season;
  final int episode;
  final String title;
  final String? containerExt;
  final String? streamUrl;
  final int? durationSecs;
  final String? plot;
  final String? still;
  final DateTime? airDate;
  const Episode({
    required this.accountId,
    required this.id,
    required this.seriesId,
    required this.season,
    required this.episode,
    required this.title,
    this.containerExt,
    this.streamUrl,
    this.durationSecs,
    this.plot,
    this.still,
    this.airDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    map['id'] = Variable<String>(id);
    map['series_id'] = Variable<String>(seriesId);
    map['season'] = Variable<int>(season);
    map['episode'] = Variable<int>(episode);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || containerExt != null) {
      map['container_ext'] = Variable<String>(containerExt);
    }
    if (!nullToAbsent || streamUrl != null) {
      map['stream_url'] = Variable<String>(streamUrl);
    }
    if (!nullToAbsent || durationSecs != null) {
      map['duration_secs'] = Variable<int>(durationSecs);
    }
    if (!nullToAbsent || plot != null) {
      map['plot'] = Variable<String>(plot);
    }
    if (!nullToAbsent || still != null) {
      map['still'] = Variable<String>(still);
    }
    if (!nullToAbsent || airDate != null) {
      map['air_date'] = Variable<DateTime>(airDate);
    }
    return map;
  }

  EpisodesCompanion toCompanion(bool nullToAbsent) {
    return EpisodesCompanion(
      accountId: Value(accountId),
      id: Value(id),
      seriesId: Value(seriesId),
      season: Value(season),
      episode: Value(episode),
      title: Value(title),
      containerExt: containerExt == null && nullToAbsent
          ? const Value.absent()
          : Value(containerExt),
      streamUrl: streamUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(streamUrl),
      durationSecs: durationSecs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSecs),
      plot: plot == null && nullToAbsent ? const Value.absent() : Value(plot),
      still: still == null && nullToAbsent
          ? const Value.absent()
          : Value(still),
      airDate: airDate == null && nullToAbsent
          ? const Value.absent()
          : Value(airDate),
    );
  }

  factory Episode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Episode(
      accountId: serializer.fromJson<String>(json['accountId']),
      id: serializer.fromJson<String>(json['id']),
      seriesId: serializer.fromJson<String>(json['seriesId']),
      season: serializer.fromJson<int>(json['season']),
      episode: serializer.fromJson<int>(json['episode']),
      title: serializer.fromJson<String>(json['title']),
      containerExt: serializer.fromJson<String?>(json['containerExt']),
      streamUrl: serializer.fromJson<String?>(json['streamUrl']),
      durationSecs: serializer.fromJson<int?>(json['durationSecs']),
      plot: serializer.fromJson<String?>(json['plot']),
      still: serializer.fromJson<String?>(json['still']),
      airDate: serializer.fromJson<DateTime?>(json['airDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'id': serializer.toJson<String>(id),
      'seriesId': serializer.toJson<String>(seriesId),
      'season': serializer.toJson<int>(season),
      'episode': serializer.toJson<int>(episode),
      'title': serializer.toJson<String>(title),
      'containerExt': serializer.toJson<String?>(containerExt),
      'streamUrl': serializer.toJson<String?>(streamUrl),
      'durationSecs': serializer.toJson<int?>(durationSecs),
      'plot': serializer.toJson<String?>(plot),
      'still': serializer.toJson<String?>(still),
      'airDate': serializer.toJson<DateTime?>(airDate),
    };
  }

  Episode copyWith({
    String? accountId,
    String? id,
    String? seriesId,
    int? season,
    int? episode,
    String? title,
    Value<String?> containerExt = const Value.absent(),
    Value<String?> streamUrl = const Value.absent(),
    Value<int?> durationSecs = const Value.absent(),
    Value<String?> plot = const Value.absent(),
    Value<String?> still = const Value.absent(),
    Value<DateTime?> airDate = const Value.absent(),
  }) => Episode(
    accountId: accountId ?? this.accountId,
    id: id ?? this.id,
    seriesId: seriesId ?? this.seriesId,
    season: season ?? this.season,
    episode: episode ?? this.episode,
    title: title ?? this.title,
    containerExt: containerExt.present ? containerExt.value : this.containerExt,
    streamUrl: streamUrl.present ? streamUrl.value : this.streamUrl,
    durationSecs: durationSecs.present ? durationSecs.value : this.durationSecs,
    plot: plot.present ? plot.value : this.plot,
    still: still.present ? still.value : this.still,
    airDate: airDate.present ? airDate.value : this.airDate,
  );
  Episode copyWithCompanion(EpisodesCompanion data) {
    return Episode(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      id: data.id.present ? data.id.value : this.id,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      season: data.season.present ? data.season.value : this.season,
      episode: data.episode.present ? data.episode.value : this.episode,
      title: data.title.present ? data.title.value : this.title,
      containerExt: data.containerExt.present
          ? data.containerExt.value
          : this.containerExt,
      streamUrl: data.streamUrl.present ? data.streamUrl.value : this.streamUrl,
      durationSecs: data.durationSecs.present
          ? data.durationSecs.value
          : this.durationSecs,
      plot: data.plot.present ? data.plot.value : this.plot,
      still: data.still.present ? data.still.value : this.still,
      airDate: data.airDate.present ? data.airDate.value : this.airDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Episode(')
          ..write('accountId: $accountId, ')
          ..write('id: $id, ')
          ..write('seriesId: $seriesId, ')
          ..write('season: $season, ')
          ..write('episode: $episode, ')
          ..write('title: $title, ')
          ..write('containerExt: $containerExt, ')
          ..write('streamUrl: $streamUrl, ')
          ..write('durationSecs: $durationSecs, ')
          ..write('plot: $plot, ')
          ..write('still: $still, ')
          ..write('airDate: $airDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    accountId,
    id,
    seriesId,
    season,
    episode,
    title,
    containerExt,
    streamUrl,
    durationSecs,
    plot,
    still,
    airDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Episode &&
          other.accountId == this.accountId &&
          other.id == this.id &&
          other.seriesId == this.seriesId &&
          other.season == this.season &&
          other.episode == this.episode &&
          other.title == this.title &&
          other.containerExt == this.containerExt &&
          other.streamUrl == this.streamUrl &&
          other.durationSecs == this.durationSecs &&
          other.plot == this.plot &&
          other.still == this.still &&
          other.airDate == this.airDate);
}

class EpisodesCompanion extends UpdateCompanion<Episode> {
  final Value<String> accountId;
  final Value<String> id;
  final Value<String> seriesId;
  final Value<int> season;
  final Value<int> episode;
  final Value<String> title;
  final Value<String?> containerExt;
  final Value<String?> streamUrl;
  final Value<int?> durationSecs;
  final Value<String?> plot;
  final Value<String?> still;
  final Value<DateTime?> airDate;
  final Value<int> rowid;
  const EpisodesCompanion({
    this.accountId = const Value.absent(),
    this.id = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.season = const Value.absent(),
    this.episode = const Value.absent(),
    this.title = const Value.absent(),
    this.containerExt = const Value.absent(),
    this.streamUrl = const Value.absent(),
    this.durationSecs = const Value.absent(),
    this.plot = const Value.absent(),
    this.still = const Value.absent(),
    this.airDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EpisodesCompanion.insert({
    required String accountId,
    required String id,
    required String seriesId,
    required int season,
    required int episode,
    required String title,
    this.containerExt = const Value.absent(),
    this.streamUrl = const Value.absent(),
    this.durationSecs = const Value.absent(),
    this.plot = const Value.absent(),
    this.still = const Value.absent(),
    this.airDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       id = Value(id),
       seriesId = Value(seriesId),
       season = Value(season),
       episode = Value(episode),
       title = Value(title);
  static Insertable<Episode> custom({
    Expression<String>? accountId,
    Expression<String>? id,
    Expression<String>? seriesId,
    Expression<int>? season,
    Expression<int>? episode,
    Expression<String>? title,
    Expression<String>? containerExt,
    Expression<String>? streamUrl,
    Expression<int>? durationSecs,
    Expression<String>? plot,
    Expression<String>? still,
    Expression<DateTime>? airDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (id != null) 'id': id,
      if (seriesId != null) 'series_id': seriesId,
      if (season != null) 'season': season,
      if (episode != null) 'episode': episode,
      if (title != null) 'title': title,
      if (containerExt != null) 'container_ext': containerExt,
      if (streamUrl != null) 'stream_url': streamUrl,
      if (durationSecs != null) 'duration_secs': durationSecs,
      if (plot != null) 'plot': plot,
      if (still != null) 'still': still,
      if (airDate != null) 'air_date': airDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EpisodesCompanion copyWith({
    Value<String>? accountId,
    Value<String>? id,
    Value<String>? seriesId,
    Value<int>? season,
    Value<int>? episode,
    Value<String>? title,
    Value<String?>? containerExt,
    Value<String?>? streamUrl,
    Value<int?>? durationSecs,
    Value<String?>? plot,
    Value<String?>? still,
    Value<DateTime?>? airDate,
    Value<int>? rowid,
  }) {
    return EpisodesCompanion(
      accountId: accountId ?? this.accountId,
      id: id ?? this.id,
      seriesId: seriesId ?? this.seriesId,
      season: season ?? this.season,
      episode: episode ?? this.episode,
      title: title ?? this.title,
      containerExt: containerExt ?? this.containerExt,
      streamUrl: streamUrl ?? this.streamUrl,
      durationSecs: durationSecs ?? this.durationSecs,
      plot: plot ?? this.plot,
      still: still ?? this.still,
      airDate: airDate ?? this.airDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (season.present) {
      map['season'] = Variable<int>(season.value);
    }
    if (episode.present) {
      map['episode'] = Variable<int>(episode.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (containerExt.present) {
      map['container_ext'] = Variable<String>(containerExt.value);
    }
    if (streamUrl.present) {
      map['stream_url'] = Variable<String>(streamUrl.value);
    }
    if (durationSecs.present) {
      map['duration_secs'] = Variable<int>(durationSecs.value);
    }
    if (plot.present) {
      map['plot'] = Variable<String>(plot.value);
    }
    if (still.present) {
      map['still'] = Variable<String>(still.value);
    }
    if (airDate.present) {
      map['air_date'] = Variable<DateTime>(airDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpisodesCompanion(')
          ..write('accountId: $accountId, ')
          ..write('id: $id, ')
          ..write('seriesId: $seriesId, ')
          ..write('season: $season, ')
          ..write('episode: $episode, ')
          ..write('title: $title, ')
          ..write('containerExt: $containerExt, ')
          ..write('streamUrl: $streamUrl, ')
          ..write('durationSecs: $durationSecs, ')
          ..write('plot: $plot, ')
          ..write('still: $still, ')
          ..write('airDate: $airDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, Favorite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ContentKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ContentKind>($FavoritesTable.$converterkind);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountId,
    kind,
    itemId,
    position,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<Favorite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId, kind, itemId};
  @override
  Favorite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Favorite(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      kind: $FavoritesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ContentKind, String, String> $converterkind =
      const EnumNameConverter<ContentKind>(ContentKind.values);
}

class Favorite extends DataClass implements Insertable<Favorite> {
  final String accountId;
  final ContentKind kind;
  final String itemId;
  final int position;
  final DateTime addedAt;
  const Favorite({
    required this.accountId,
    required this.kind,
    required this.itemId,
    required this.position,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    {
      map['kind'] = Variable<String>(
        $FavoritesTable.$converterkind.toSql(kind),
      );
    }
    map['item_id'] = Variable<String>(itemId);
    map['position'] = Variable<int>(position);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(
      accountId: Value(accountId),
      kind: Value(kind),
      itemId: Value(itemId),
      position: Value(position),
      addedAt: Value(addedAt),
    );
  }

  factory Favorite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Favorite(
      accountId: serializer.fromJson<String>(json['accountId']),
      kind: $FavoritesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      itemId: serializer.fromJson<String>(json['itemId']),
      position: serializer.fromJson<int>(json['position']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'kind': serializer.toJson<String>(
        $FavoritesTable.$converterkind.toJson(kind),
      ),
      'itemId': serializer.toJson<String>(itemId),
      'position': serializer.toJson<int>(position),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  Favorite copyWith({
    String? accountId,
    ContentKind? kind,
    String? itemId,
    int? position,
    DateTime? addedAt,
  }) => Favorite(
    accountId: accountId ?? this.accountId,
    kind: kind ?? this.kind,
    itemId: itemId ?? this.itemId,
    position: position ?? this.position,
    addedAt: addedAt ?? this.addedAt,
  );
  Favorite copyWithCompanion(FavoritesCompanion data) {
    return Favorite(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      kind: data.kind.present ? data.kind.value : this.kind,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      position: data.position.present ? data.position.value : this.position,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Favorite(')
          ..write('accountId: $accountId, ')
          ..write('kind: $kind, ')
          ..write('itemId: $itemId, ')
          ..write('position: $position, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(accountId, kind, itemId, position, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Favorite &&
          other.accountId == this.accountId &&
          other.kind == this.kind &&
          other.itemId == this.itemId &&
          other.position == this.position &&
          other.addedAt == this.addedAt);
}

class FavoritesCompanion extends UpdateCompanion<Favorite> {
  final Value<String> accountId;
  final Value<ContentKind> kind;
  final Value<String> itemId;
  final Value<int> position;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const FavoritesCompanion({
    this.accountId = const Value.absent(),
    this.kind = const Value.absent(),
    this.itemId = const Value.absent(),
    this.position = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoritesCompanion.insert({
    required String accountId,
    required ContentKind kind,
    required String itemId,
    required int position,
    required DateTime addedAt,
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       kind = Value(kind),
       itemId = Value(itemId),
       position = Value(position),
       addedAt = Value(addedAt);
  static Insertable<Favorite> custom({
    Expression<String>? accountId,
    Expression<String>? kind,
    Expression<String>? itemId,
    Expression<int>? position,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (kind != null) 'kind': kind,
      if (itemId != null) 'item_id': itemId,
      if (position != null) 'position': position,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoritesCompanion copyWith({
    Value<String>? accountId,
    Value<ContentKind>? kind,
    Value<String>? itemId,
    Value<int>? position,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return FavoritesCompanion(
      accountId: accountId ?? this.accountId,
      kind: kind ?? this.kind,
      itemId: itemId ?? this.itemId,
      position: position ?? this.position,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $FavoritesTable.$converterkind.toSql(kind.value),
      );
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('accountId: $accountId, ')
          ..write('kind: $kind, ')
          ..write('itemId: $itemId, ')
          ..write('position: $position, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WatchProgressEntriesTable extends WatchProgressEntries
    with TableInfo<$WatchProgressEntriesTable, WatchProgress> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchProgressEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ProgressKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ProgressKind>($WatchProgressEntriesTable.$converterkind);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountId,
    kind,
    itemId,
    seriesId,
    positionMs,
    durationMs,
    completed,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watch_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<WatchProgress> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId, kind, itemId};
  @override
  WatchProgress map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchProgress(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      kind: $WatchProgressEntriesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      ),
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WatchProgressEntriesTable createAlias(String alias) {
    return $WatchProgressEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ProgressKind, String, String> $converterkind =
      const EnumNameConverter<ProgressKind>(ProgressKind.values);
}

class WatchProgress extends DataClass implements Insertable<WatchProgress> {
  final String accountId;
  final ProgressKind kind;
  final String itemId;
  final String? seriesId;
  final int positionMs;
  final int durationMs;
  final bool completed;
  final DateTime updatedAt;
  const WatchProgress({
    required this.accountId,
    required this.kind,
    required this.itemId,
    this.seriesId,
    required this.positionMs,
    required this.durationMs,
    required this.completed,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    {
      map['kind'] = Variable<String>(
        $WatchProgressEntriesTable.$converterkind.toSql(kind),
      );
    }
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || seriesId != null) {
      map['series_id'] = Variable<String>(seriesId);
    }
    map['position_ms'] = Variable<int>(positionMs);
    map['duration_ms'] = Variable<int>(durationMs);
    map['completed'] = Variable<bool>(completed);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WatchProgressEntriesCompanion toCompanion(bool nullToAbsent) {
    return WatchProgressEntriesCompanion(
      accountId: Value(accountId),
      kind: Value(kind),
      itemId: Value(itemId),
      seriesId: seriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesId),
      positionMs: Value(positionMs),
      durationMs: Value(durationMs),
      completed: Value(completed),
      updatedAt: Value(updatedAt),
    );
  }

  factory WatchProgress.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchProgress(
      accountId: serializer.fromJson<String>(json['accountId']),
      kind: $WatchProgressEntriesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      itemId: serializer.fromJson<String>(json['itemId']),
      seriesId: serializer.fromJson<String?>(json['seriesId']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      completed: serializer.fromJson<bool>(json['completed']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'kind': serializer.toJson<String>(
        $WatchProgressEntriesTable.$converterkind.toJson(kind),
      ),
      'itemId': serializer.toJson<String>(itemId),
      'seriesId': serializer.toJson<String?>(seriesId),
      'positionMs': serializer.toJson<int>(positionMs),
      'durationMs': serializer.toJson<int>(durationMs),
      'completed': serializer.toJson<bool>(completed),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WatchProgress copyWith({
    String? accountId,
    ProgressKind? kind,
    String? itemId,
    Value<String?> seriesId = const Value.absent(),
    int? positionMs,
    int? durationMs,
    bool? completed,
    DateTime? updatedAt,
  }) => WatchProgress(
    accountId: accountId ?? this.accountId,
    kind: kind ?? this.kind,
    itemId: itemId ?? this.itemId,
    seriesId: seriesId.present ? seriesId.value : this.seriesId,
    positionMs: positionMs ?? this.positionMs,
    durationMs: durationMs ?? this.durationMs,
    completed: completed ?? this.completed,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WatchProgress copyWithCompanion(WatchProgressEntriesCompanion data) {
    return WatchProgress(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      kind: data.kind.present ? data.kind.value : this.kind,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      completed: data.completed.present ? data.completed.value : this.completed,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchProgress(')
          ..write('accountId: $accountId, ')
          ..write('kind: $kind, ')
          ..write('itemId: $itemId, ')
          ..write('seriesId: $seriesId, ')
          ..write('positionMs: $positionMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('completed: $completed, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    accountId,
    kind,
    itemId,
    seriesId,
    positionMs,
    durationMs,
    completed,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchProgress &&
          other.accountId == this.accountId &&
          other.kind == this.kind &&
          other.itemId == this.itemId &&
          other.seriesId == this.seriesId &&
          other.positionMs == this.positionMs &&
          other.durationMs == this.durationMs &&
          other.completed == this.completed &&
          other.updatedAt == this.updatedAt);
}

class WatchProgressEntriesCompanion extends UpdateCompanion<WatchProgress> {
  final Value<String> accountId;
  final Value<ProgressKind> kind;
  final Value<String> itemId;
  final Value<String?> seriesId;
  final Value<int> positionMs;
  final Value<int> durationMs;
  final Value<bool> completed;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WatchProgressEntriesCompanion({
    this.accountId = const Value.absent(),
    this.kind = const Value.absent(),
    this.itemId = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.completed = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WatchProgressEntriesCompanion.insert({
    required String accountId,
    required ProgressKind kind,
    required String itemId,
    this.seriesId = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.completed = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       kind = Value(kind),
       itemId = Value(itemId),
       updatedAt = Value(updatedAt);
  static Insertable<WatchProgress> custom({
    Expression<String>? accountId,
    Expression<String>? kind,
    Expression<String>? itemId,
    Expression<String>? seriesId,
    Expression<int>? positionMs,
    Expression<int>? durationMs,
    Expression<bool>? completed,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (kind != null) 'kind': kind,
      if (itemId != null) 'item_id': itemId,
      if (seriesId != null) 'series_id': seriesId,
      if (positionMs != null) 'position_ms': positionMs,
      if (durationMs != null) 'duration_ms': durationMs,
      if (completed != null) 'completed': completed,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WatchProgressEntriesCompanion copyWith({
    Value<String>? accountId,
    Value<ProgressKind>? kind,
    Value<String>? itemId,
    Value<String?>? seriesId,
    Value<int>? positionMs,
    Value<int>? durationMs,
    Value<bool>? completed,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WatchProgressEntriesCompanion(
      accountId: accountId ?? this.accountId,
      kind: kind ?? this.kind,
      itemId: itemId ?? this.itemId,
      seriesId: seriesId ?? this.seriesId,
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      completed: completed ?? this.completed,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $WatchProgressEntriesTable.$converterkind.toSql(kind.value),
      );
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchProgressEntriesCompanion(')
          ..write('accountId: $accountId, ')
          ..write('kind: $kind, ')
          ..write('itemId: $itemId, ')
          ..write('seriesId: $seriesId, ')
          ..write('positionMs: $positionMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('completed: $completed, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EpgProgrammesTable extends EpgProgrammes
    with TableInfo<$EpgProgrammesTable, EpgProgramme> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpgProgrammesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _channelIdMeta = const VerificationMeta(
    'channelId',
  );
  @override
  late final GeneratedColumn<String> channelId = GeneratedColumn<String>(
    'channel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMeta = const VerificationMeta('start');
  @override
  late final GeneratedColumn<DateTime> start = GeneratedColumn<DateTime>(
    'start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stopMeta = const VerificationMeta('stop');
  @override
  late final GeneratedColumn<DateTime> stop = GeneratedColumn<DateTime>(
    'stop',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
    'image',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountId,
    channelId,
    start,
    stop,
    title,
    description,
    category,
    image,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'epg_programmes';
  @override
  VerificationContext validateIntegrity(
    Insertable<EpgProgramme> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('channel_id')) {
      context.handle(
        _channelIdMeta,
        channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_channelIdMeta);
    }
    if (data.containsKey('start')) {
      context.handle(
        _startMeta,
        start.isAcceptableOrUnknown(data['start']!, _startMeta),
      );
    } else if (isInserting) {
      context.missing(_startMeta);
    }
    if (data.containsKey('stop')) {
      context.handle(
        _stopMeta,
        stop.isAcceptableOrUnknown(data['stop']!, _stopMeta),
      );
    } else if (isInserting) {
      context.missing(_stopMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('image')) {
      context.handle(
        _imageMeta,
        image.isAcceptableOrUnknown(data['image']!, _imageMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId, channelId, start};
  @override
  EpgProgramme map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EpgProgramme(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      channelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_id'],
      )!,
      start: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start'],
      )!,
      stop: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}stop'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      image: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image'],
      ),
    );
  }

  @override
  $EpgProgrammesTable createAlias(String alias) {
    return $EpgProgrammesTable(attachedDatabase, alias);
  }
}

class EpgProgramme extends DataClass implements Insertable<EpgProgramme> {
  final String accountId;
  final String channelId;
  final DateTime start;
  final DateTime stop;
  final String title;
  final String? description;
  final String? category;

  /// Programme artwork (`<programme><icon src>`), schema v2.
  final String? image;
  const EpgProgramme({
    required this.accountId,
    required this.channelId,
    required this.start,
    required this.stop,
    required this.title,
    this.description,
    this.category,
    this.image,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    map['channel_id'] = Variable<String>(channelId);
    map['start'] = Variable<DateTime>(start);
    map['stop'] = Variable<DateTime>(stop);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || image != null) {
      map['image'] = Variable<String>(image);
    }
    return map;
  }

  EpgProgrammesCompanion toCompanion(bool nullToAbsent) {
    return EpgProgrammesCompanion(
      accountId: Value(accountId),
      channelId: Value(channelId),
      start: Value(start),
      stop: Value(stop),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      image: image == null && nullToAbsent
          ? const Value.absent()
          : Value(image),
    );
  }

  factory EpgProgramme.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EpgProgramme(
      accountId: serializer.fromJson<String>(json['accountId']),
      channelId: serializer.fromJson<String>(json['channelId']),
      start: serializer.fromJson<DateTime>(json['start']),
      stop: serializer.fromJson<DateTime>(json['stop']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      category: serializer.fromJson<String?>(json['category']),
      image: serializer.fromJson<String?>(json['image']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'channelId': serializer.toJson<String>(channelId),
      'start': serializer.toJson<DateTime>(start),
      'stop': serializer.toJson<DateTime>(stop),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'category': serializer.toJson<String?>(category),
      'image': serializer.toJson<String?>(image),
    };
  }

  EpgProgramme copyWith({
    String? accountId,
    String? channelId,
    DateTime? start,
    DateTime? stop,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<String?> image = const Value.absent(),
  }) => EpgProgramme(
    accountId: accountId ?? this.accountId,
    channelId: channelId ?? this.channelId,
    start: start ?? this.start,
    stop: stop ?? this.stop,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    category: category.present ? category.value : this.category,
    image: image.present ? image.value : this.image,
  );
  EpgProgramme copyWithCompanion(EpgProgrammesCompanion data) {
    return EpgProgramme(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      start: data.start.present ? data.start.value : this.start,
      stop: data.stop.present ? data.stop.value : this.stop,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      category: data.category.present ? data.category.value : this.category,
      image: data.image.present ? data.image.value : this.image,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EpgProgramme(')
          ..write('accountId: $accountId, ')
          ..write('channelId: $channelId, ')
          ..write('start: $start, ')
          ..write('stop: $stop, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('image: $image')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    accountId,
    channelId,
    start,
    stop,
    title,
    description,
    category,
    image,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EpgProgramme &&
          other.accountId == this.accountId &&
          other.channelId == this.channelId &&
          other.start == this.start &&
          other.stop == this.stop &&
          other.title == this.title &&
          other.description == this.description &&
          other.category == this.category &&
          other.image == this.image);
}

class EpgProgrammesCompanion extends UpdateCompanion<EpgProgramme> {
  final Value<String> accountId;
  final Value<String> channelId;
  final Value<DateTime> start;
  final Value<DateTime> stop;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> category;
  final Value<String?> image;
  final Value<int> rowid;
  const EpgProgrammesCompanion({
    this.accountId = const Value.absent(),
    this.channelId = const Value.absent(),
    this.start = const Value.absent(),
    this.stop = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.image = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EpgProgrammesCompanion.insert({
    required String accountId,
    required String channelId,
    required DateTime start,
    required DateTime stop,
    required String title,
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.image = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       channelId = Value(channelId),
       start = Value(start),
       stop = Value(stop),
       title = Value(title);
  static Insertable<EpgProgramme> custom({
    Expression<String>? accountId,
    Expression<String>? channelId,
    Expression<DateTime>? start,
    Expression<DateTime>? stop,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? category,
    Expression<String>? image,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (channelId != null) 'channel_id': channelId,
      if (start != null) 'start': start,
      if (stop != null) 'stop': stop,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (image != null) 'image': image,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EpgProgrammesCompanion copyWith({
    Value<String>? accountId,
    Value<String>? channelId,
    Value<DateTime>? start,
    Value<DateTime>? stop,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? category,
    Value<String?>? image,
    Value<int>? rowid,
  }) {
    return EpgProgrammesCompanion(
      accountId: accountId ?? this.accountId,
      channelId: channelId ?? this.channelId,
      start: start ?? this.start,
      stop: stop ?? this.stop,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      image: image ?? this.image,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (channelId.present) {
      map['channel_id'] = Variable<String>(channelId.value);
    }
    if (start.present) {
      map['start'] = Variable<DateTime>(start.value);
    }
    if (stop.present) {
      map['stop'] = Variable<DateTime>(stop.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpgProgrammesCompanion(')
          ..write('accountId: $accountId, ')
          ..write('channelId: $channelId, ')
          ..write('start: $start, ')
          ..write('stop: $stop, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('image: $image, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContentLocksTable extends ContentLocks
    with TableInfo<$ContentLocksTable, ContentLock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentLocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LockKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LockKind>($ContentLocksTable.$converterkind);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [accountId, kind, itemId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_locks';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContentLock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId, kind, itemId};
  @override
  ContentLock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentLock(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      kind: $ContentLocksTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
    );
  }

  @override
  $ContentLocksTable createAlias(String alias) {
    return $ContentLocksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LockKind, String, String> $converterkind =
      const EnumNameConverter<LockKind>(LockKind.values);
}

class ContentLock extends DataClass implements Insertable<ContentLock> {
  final String accountId;
  final LockKind kind;
  final String itemId;
  const ContentLock({
    required this.accountId,
    required this.kind,
    required this.itemId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    {
      map['kind'] = Variable<String>(
        $ContentLocksTable.$converterkind.toSql(kind),
      );
    }
    map['item_id'] = Variable<String>(itemId);
    return map;
  }

  ContentLocksCompanion toCompanion(bool nullToAbsent) {
    return ContentLocksCompanion(
      accountId: Value(accountId),
      kind: Value(kind),
      itemId: Value(itemId),
    );
  }

  factory ContentLock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentLock(
      accountId: serializer.fromJson<String>(json['accountId']),
      kind: $ContentLocksTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      itemId: serializer.fromJson<String>(json['itemId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'kind': serializer.toJson<String>(
        $ContentLocksTable.$converterkind.toJson(kind),
      ),
      'itemId': serializer.toJson<String>(itemId),
    };
  }

  ContentLock copyWith({String? accountId, LockKind? kind, String? itemId}) =>
      ContentLock(
        accountId: accountId ?? this.accountId,
        kind: kind ?? this.kind,
        itemId: itemId ?? this.itemId,
      );
  ContentLock copyWithCompanion(ContentLocksCompanion data) {
    return ContentLock(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      kind: data.kind.present ? data.kind.value : this.kind,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentLock(')
          ..write('accountId: $accountId, ')
          ..write('kind: $kind, ')
          ..write('itemId: $itemId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(accountId, kind, itemId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentLock &&
          other.accountId == this.accountId &&
          other.kind == this.kind &&
          other.itemId == this.itemId);
}

class ContentLocksCompanion extends UpdateCompanion<ContentLock> {
  final Value<String> accountId;
  final Value<LockKind> kind;
  final Value<String> itemId;
  final Value<int> rowid;
  const ContentLocksCompanion({
    this.accountId = const Value.absent(),
    this.kind = const Value.absent(),
    this.itemId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContentLocksCompanion.insert({
    required String accountId,
    required LockKind kind,
    required String itemId,
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       kind = Value(kind),
       itemId = Value(itemId);
  static Insertable<ContentLock> custom({
    Expression<String>? accountId,
    Expression<String>? kind,
    Expression<String>? itemId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (kind != null) 'kind': kind,
      if (itemId != null) 'item_id': itemId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContentLocksCompanion copyWith({
    Value<String>? accountId,
    Value<LockKind>? kind,
    Value<String>? itemId,
    Value<int>? rowid,
  }) {
    return ContentLocksCompanion(
      accountId: accountId ?? this.accountId,
      kind: kind ?? this.kind,
      itemId: itemId ?? this.itemId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $ContentLocksTable.$converterkind.toSql(kind.value),
      );
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentLocksCompanion(')
          ..write('accountId: $accountId, ')
          ..write('kind: $kind, ')
          ..write('itemId: $itemId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$OrbixDatabase extends GeneratedDatabase {
  _$OrbixDatabase(QueryExecutor e) : super(e);
  $OrbixDatabaseManager get managers => $OrbixDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ChannelsTable channels = $ChannelsTable(this);
  late final $MoviesTable movies = $MoviesTable(this);
  late final $SeriesTableTable seriesTable = $SeriesTableTable(this);
  late final $EpisodesTable episodes = $EpisodesTable(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $WatchProgressEntriesTable watchProgressEntries =
      $WatchProgressEntriesTable(this);
  late final $EpgProgrammesTable epgProgrammes = $EpgProgrammesTable(this);
  late final $ContentLocksTable contentLocks = $ContentLocksTable(this);
  late final Index channelsByCategory = Index(
    'channels_by_category',
    'CREATE INDEX channels_by_category ON channels (account_id, category_id, sort_index)',
  );
  late final Index channelsByEpg = Index(
    'channels_by_epg',
    'CREATE INDEX channels_by_epg ON channels (account_id, epg_id)',
  );
  late final Index moviesByCategory = Index(
    'movies_by_category',
    'CREATE INDEX movies_by_category ON movies (account_id, category_id, sort_index)',
  );
  late final Index moviesByAdded = Index(
    'movies_by_added',
    'CREATE INDEX movies_by_added ON movies (account_id, added_at)',
  );
  late final Index seriesByCategory = Index(
    'series_by_category',
    'CREATE INDEX series_by_category ON series (account_id, category_id, sort_index)',
  );
  late final Index seriesByUpdated = Index(
    'series_by_updated',
    'CREATE INDEX series_by_updated ON series (account_id, updated_at)',
  );
  late final Index episodesBySeries = Index(
    'episodes_by_series',
    'CREATE INDEX episodes_by_series ON episodes (account_id, series_id, season, episode)',
  );
  late final Index progressByRecent = Index(
    'progress_by_recent',
    'CREATE INDEX progress_by_recent ON watch_progress (account_id, updated_at)',
  );
  late final Index epgByStop = Index(
    'epg_by_stop',
    'CREATE INDEX epg_by_stop ON epg_programmes (account_id, stop)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    categories,
    channels,
    movies,
    seriesTable,
    episodes,
    favorites,
    watchProgressEntries,
    epgProgrammes,
    contentLocks,
    channelsByCategory,
    channelsByEpg,
    moviesByCategory,
    moviesByAdded,
    seriesByCategory,
    seriesByUpdated,
    episodesBySeries,
    progressByRecent,
    epgByStop,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('categories', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('channels', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('movies', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('series', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('episodes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('favorites', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('watch_progress', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('epg_programmes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('content_locks', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String id,
  required String name,
  required AccountKind kind,
  Value<String?> displayHost,
  Value<AccountStatus> status,
  Value<DateTime?> expiresAt,
  Value<int?> maxConnections,
  Value<bool> isDefault,
  Value<int> sortOrder,
  required DateTime createdAt,
  Value<DateTime?> lastUsedAt,
  Value<DateTime?> lastSyncedAt,
  Value<DateTime?> guideUpdatedAt,
  Value<int> guideSourceCount,
  Value<int> liveCount,
  Value<int> movieCount,
  Value<int> seriesCount,
  Value<int> guideShiftMinutes,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<AccountKind> kind,
  Value<String?> displayHost,
  Value<AccountStatus> status,
  Value<DateTime?> expiresAt,
  Value<int?> maxConnections,
  Value<bool> isDefault,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime?> lastUsedAt,
  Value<DateTime?> lastSyncedAt,
  Value<DateTime?> guideUpdatedAt,
  Value<int> guideSourceCount,
  Value<int> liveCount,
  Value<int> movieCount,
  Value<int> seriesCount,
  Value<int> guideShiftMinutes,
  Value<int> rowid,
});

final class $$AccountsTableReferences
    extends BaseReferences<_$OrbixDatabase, $AccountsTable, Account> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CategoriesTable, List<MediaCategory>>
  _categoriesRefsTable(_$OrbixDatabase db) => MultiTypedResultKey.fromTable(
    db.categories,
    aliasName: 'accounts__id__categories__account_id',
  );

  $$CategoriesTableProcessedTableManager get categoriesRefs {
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_categoriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChannelsTable, List<Channel>> _channelsRefsTable(
    _$OrbixDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.channels,
    aliasName: 'accounts__id__channels__account_id',
  );

  $$ChannelsTableProcessedTableManager get channelsRefs {
    final manager = $$ChannelsTableTableManager(
      $_db,
      $_db.channels,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_channelsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MoviesTable, List<Movie>> _moviesRefsTable(
    _$OrbixDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.movies,
    aliasName: 'accounts__id__movies__account_id',
  );

  $$MoviesTableProcessedTableManager get moviesRefs {
    final manager = $$MoviesTableTableManager(
      $_db,
      $_db.movies,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_moviesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SeriesTableTable, List<Show>>
  _seriesTableRefsTable(_$OrbixDatabase db) => MultiTypedResultKey.fromTable(
    db.seriesTable,
    aliasName: 'accounts__id__series__account_id',
  );

  $$SeriesTableTableProcessedTableManager get seriesTableRefs {
    final manager = $$SeriesTableTableTableManager(
      $_db,
      $_db.seriesTable,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_seriesTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EpisodesTable, List<Episode>> _episodesRefsTable(
    _$OrbixDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.episodes,
    aliasName: 'accounts__id__episodes__account_id',
  );

  $$EpisodesTableProcessedTableManager get episodesRefs {
    final manager = $$EpisodesTableTableManager(
      $_db,
      $_db.episodes,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_episodesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FavoritesTable, List<Favorite>>
  _favoritesRefsTable(_$OrbixDatabase db) => MultiTypedResultKey.fromTable(
    db.favorites,
    aliasName: 'accounts__id__favorites__account_id',
  );

  $$FavoritesTableProcessedTableManager get favoritesRefs {
    final manager = $$FavoritesTableTableManager(
      $_db,
      $_db.favorites,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_favoritesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WatchProgressEntriesTable, List<WatchProgress>>
  _watchProgressEntriesRefsTable(_$OrbixDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.watchProgressEntries,
        aliasName: 'accounts__id__watch_progress__account_id',
      );

  $$WatchProgressEntriesTableProcessedTableManager
  get watchProgressEntriesRefs {
    final manager = $$WatchProgressEntriesTableTableManager(
      $_db,
      $_db.watchProgressEntries,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _watchProgressEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EpgProgrammesTable, List<EpgProgramme>>
  _epgProgrammesRefsTable(_$OrbixDatabase db) => MultiTypedResultKey.fromTable(
    db.epgProgrammes,
    aliasName: 'accounts__id__epg_programmes__account_id',
  );

  $$EpgProgrammesTableProcessedTableManager get epgProgrammesRefs {
    final manager = $$EpgProgrammesTableTableManager(
      $_db,
      $_db.epgProgrammes,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_epgProgrammesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ContentLocksTable, List<ContentLock>>
  _contentLocksRefsTable(_$OrbixDatabase db) => MultiTypedResultKey.fromTable(
    db.contentLocks,
    aliasName: 'accounts__id__content_locks__account_id',
  );

  $$ContentLocksTableProcessedTableManager get contentLocksRefs {
    final manager = $$ContentLocksTableTableManager(
      $_db,
      $_db.contentLocks,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_contentLocksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$OrbixDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AccountKind, AccountKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get displayHost => $composableBuilder(
    column: $table.displayHost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AccountStatus, AccountStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxConnections => $composableBuilder(
    column: $table.maxConnections,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get guideUpdatedAt => $composableBuilder(
    column: $table.guideUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get guideSourceCount => $composableBuilder(
    column: $table.guideSourceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get liveCount => $composableBuilder(
    column: $table.liveCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get movieCount => $composableBuilder(
    column: $table.movieCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seriesCount => $composableBuilder(
    column: $table.seriesCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get guideShiftMinutes => $composableBuilder(
    column: $table.guideShiftMinutes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> categoriesRefs(
    Expression<bool> Function($$CategoriesTableFilterComposer f) f,
  ) {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> channelsRefs(
    Expression<bool> Function($$ChannelsTableFilterComposer f) f,
  ) {
    final $$ChannelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.channels,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChannelsTableFilterComposer(
            $db: $db,
            $table: $db.channels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> moviesRefs(
    Expression<bool> Function($$MoviesTableFilterComposer f) f,
  ) {
    final $$MoviesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.movies,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoviesTableFilterComposer(
            $db: $db,
            $table: $db.movies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> seriesTableRefs(
    Expression<bool> Function($$SeriesTableTableFilterComposer f) f,
  ) {
    final $$SeriesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seriesTable,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesTableTableFilterComposer(
            $db: $db,
            $table: $db.seriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> episodesRefs(
    Expression<bool> Function($$EpisodesTableFilterComposer f) f,
  ) {
    final $$EpisodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableFilterComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> favoritesRefs(
    Expression<bool> Function($$FavoritesTableFilterComposer f) f,
  ) {
    final $$FavoritesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.favorites,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FavoritesTableFilterComposer(
            $db: $db,
            $table: $db.favorites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> watchProgressEntriesRefs(
    Expression<bool> Function($$WatchProgressEntriesTableFilterComposer f) f,
  ) {
    final $$WatchProgressEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.watchProgressEntries,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchProgressEntriesTableFilterComposer(
            $db: $db,
            $table: $db.watchProgressEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> epgProgrammesRefs(
    Expression<bool> Function($$EpgProgrammesTableFilterComposer f) f,
  ) {
    final $$EpgProgrammesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.epgProgrammes,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpgProgrammesTableFilterComposer(
            $db: $db,
            $table: $db.epgProgrammes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> contentLocksRefs(
    Expression<bool> Function($$ContentLocksTableFilterComposer f) f,
  ) {
    final $$ContentLocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contentLocks,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContentLocksTableFilterComposer(
            $db: $db,
            $table: $db.contentLocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$OrbixDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayHost => $composableBuilder(
    column: $table.displayHost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxConnections => $composableBuilder(
    column: $table.maxConnections,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get guideUpdatedAt => $composableBuilder(
    column: $table.guideUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get guideSourceCount => $composableBuilder(
    column: $table.guideSourceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get liveCount => $composableBuilder(
    column: $table.liveCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get movieCount => $composableBuilder(
    column: $table.movieCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seriesCount => $composableBuilder(
    column: $table.seriesCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get guideShiftMinutes => $composableBuilder(
    column: $table.guideShiftMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$OrbixDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AccountKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get displayHost => $composableBuilder(
    column: $table.displayHost,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<AccountStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<int> get maxConnections => $composableBuilder(
    column: $table.maxConnections,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get guideUpdatedAt => $composableBuilder(
    column: $table.guideUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get guideSourceCount => $composableBuilder(
    column: $table.guideSourceCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get liveCount =>
      $composableBuilder(column: $table.liveCount, builder: (column) => column);

  GeneratedColumn<int> get movieCount => $composableBuilder(
    column: $table.movieCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seriesCount => $composableBuilder(
    column: $table.seriesCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get guideShiftMinutes => $composableBuilder(
    column: $table.guideShiftMinutes,
    builder: (column) => column,
  );

  Expression<T> categoriesRefs<T extends Object>(
    Expression<T> Function($$CategoriesTableAnnotationComposer a) f,
  ) {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> channelsRefs<T extends Object>(
    Expression<T> Function($$ChannelsTableAnnotationComposer a) f,
  ) {
    final $$ChannelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.channels,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChannelsTableAnnotationComposer(
            $db: $db,
            $table: $db.channels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> moviesRefs<T extends Object>(
    Expression<T> Function($$MoviesTableAnnotationComposer a) f,
  ) {
    final $$MoviesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.movies,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoviesTableAnnotationComposer(
            $db: $db,
            $table: $db.movies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> seriesTableRefs<T extends Object>(
    Expression<T> Function($$SeriesTableTableAnnotationComposer a) f,
  ) {
    final $$SeriesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seriesTable,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.seriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> episodesRefs<T extends Object>(
    Expression<T> Function($$EpisodesTableAnnotationComposer a) f,
  ) {
    final $$EpisodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableAnnotationComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> favoritesRefs<T extends Object>(
    Expression<T> Function($$FavoritesTableAnnotationComposer a) f,
  ) {
    final $$FavoritesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.favorites,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FavoritesTableAnnotationComposer(
            $db: $db,
            $table: $db.favorites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> watchProgressEntriesRefs<T extends Object>(
    Expression<T> Function($$WatchProgressEntriesTableAnnotationComposer a) f,
  ) {
    final $$WatchProgressEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.watchProgressEntries,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WatchProgressEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.watchProgressEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> epgProgrammesRefs<T extends Object>(
    Expression<T> Function($$EpgProgrammesTableAnnotationComposer a) f,
  ) {
    final $$EpgProgrammesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.epgProgrammes,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpgProgrammesTableAnnotationComposer(
            $db: $db,
            $table: $db.epgProgrammes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> contentLocksRefs<T extends Object>(
    Expression<T> Function($$ContentLocksTableAnnotationComposer a) f,
  ) {
    final $$ContentLocksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contentLocks,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContentLocksTableAnnotationComposer(
            $db: $db,
            $table: $db.contentLocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$OrbixDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, $$AccountsTableReferences),
          Account,
          PrefetchHooks Function({
            bool categoriesRefs,
            bool channelsRefs,
            bool moviesRefs,
            bool seriesTableRefs,
            bool episodesRefs,
            bool favoritesRefs,
            bool watchProgressEntriesRefs,
            bool epgProgrammesRefs,
            bool contentLocksRefs,
          })
        > {
  $$AccountsTableTableManager(_$OrbixDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<AccountKind> kind = const Value.absent(),
                Value<String?> displayHost = const Value.absent(),
                Value<AccountStatus> status = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<int?> maxConnections = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime?> guideUpdatedAt = const Value.absent(),
                Value<int> guideSourceCount = const Value.absent(),
                Value<int> liveCount = const Value.absent(),
                Value<int> movieCount = const Value.absent(),
                Value<int> seriesCount = const Value.absent(),
                Value<int> guideShiftMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                name: name,
                kind: kind,
                displayHost: displayHost,
                status: status,
                expiresAt: expiresAt,
                maxConnections: maxConnections,
                isDefault: isDefault,
                sortOrder: sortOrder,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
                lastSyncedAt: lastSyncedAt,
                guideUpdatedAt: guideUpdatedAt,
                guideSourceCount: guideSourceCount,
                liveCount: liveCount,
                movieCount: movieCount,
                seriesCount: seriesCount,
                guideShiftMinutes: guideShiftMinutes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required AccountKind kind,
                Value<String?> displayHost = const Value.absent(),
                Value<AccountStatus> status = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<int?> maxConnections = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime?> guideUpdatedAt = const Value.absent(),
                Value<int> guideSourceCount = const Value.absent(),
                Value<int> liveCount = const Value.absent(),
                Value<int> movieCount = const Value.absent(),
                Value<int> seriesCount = const Value.absent(),
                Value<int> guideShiftMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                displayHost: displayHost,
                status: status,
                expiresAt: expiresAt,
                maxConnections: maxConnections,
                isDefault: isDefault,
                sortOrder: sortOrder,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
                lastSyncedAt: lastSyncedAt,
                guideUpdatedAt: guideUpdatedAt,
                guideSourceCount: guideSourceCount,
                liveCount: liveCount,
                movieCount: movieCount,
                seriesCount: seriesCount,
                guideShiftMinutes: guideShiftMinutes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountsTable, Account>(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoriesRefs = false,
                channelsRefs = false,
                moviesRefs = false,
                seriesTableRefs = false,
                episodesRefs = false,
                favoritesRefs = false,
                watchProgressEntriesRefs = false,
                epgProgrammesRefs = false,
                contentLocksRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (categoriesRefs) db.categories,
                    if (channelsRefs) db.channels,
                    if (moviesRefs) db.movies,
                    if (seriesTableRefs) db.seriesTable,
                    if (episodesRefs) db.episodes,
                    if (favoritesRefs) db.favorites,
                    if (watchProgressEntriesRefs) db.watchProgressEntries,
                    if (epgProgrammesRefs) db.epgProgrammes,
                    if (contentLocksRefs) db.contentLocks,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (categoriesRefs)
                        await $_getPrefetchedData<
                          Account,
                          $AccountsTable,
                          MediaCategory
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._categoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).categoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (channelsRefs)
                        await $_getPrefetchedData<
                          Account,
                          $AccountsTable,
                          Channel
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._channelsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).channelsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (moviesRefs)
                        await $_getPrefetchedData<
                          Account,
                          $AccountsTable,
                          Movie
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._moviesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).moviesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (seriesTableRefs)
                        await $_getPrefetchedData<
                          Account,
                          $AccountsTable,
                          Show
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._seriesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).seriesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (episodesRefs)
                        await $_getPrefetchedData<
                          Account,
                          $AccountsTable,
                          Episode
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._episodesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).episodesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (favoritesRefs)
                        await $_getPrefetchedData<
                          Account,
                          $AccountsTable,
                          Favorite
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._favoritesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).favoritesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (watchProgressEntriesRefs)
                        await $_getPrefetchedData<
                          Account,
                          $AccountsTable,
                          WatchProgress
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._watchProgressEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).watchProgressEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (epgProgrammesRefs)
                        await $_getPrefetchedData<
                          Account,
                          $AccountsTable,
                          EpgProgramme
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._epgProgrammesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).epgProgrammesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (contentLocksRefs)
                        await $_getPrefetchedData<
                          Account,
                          $AccountsTable,
                          ContentLock
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._contentLocksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).contentLocksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$OrbixDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, $$AccountsTableReferences),
      Account,
      PrefetchHooks Function({
        bool categoriesRefs,
        bool channelsRefs,
        bool moviesRefs,
        bool seriesTableRefs,
        bool episodesRefs,
        bool favoritesRefs,
        bool watchProgressEntriesRefs,
        bool epgProgrammesRefs,
        bool contentLocksRefs,
      })
    >;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String accountId,
  required ContentKind kind,
  required String id,
  required String name,
  required int sortIndex,
  Value<bool> isAdult,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> accountId,
  Value<ContentKind> kind,
  Value<String> id,
  Value<String> name,
  Value<int> sortIndex,
  Value<bool> isAdult,
  Value<int> rowid,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$OrbixDatabase, $CategoriesTable, MediaCategory> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$OrbixDatabase db) =>
      db.accounts.createAlias('categories__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$OrbixDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<ContentKind, ContentKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAdult => $composableBuilder(
    column: $table.isAdult,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$OrbixDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAdult => $composableBuilder(
    column: $table.isAdult,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$OrbixDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<ContentKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  GeneratedColumn<bool> get isAdult =>
      $composableBuilder(column: $table.isAdult, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$OrbixDatabase,
          $CategoriesTable,
          MediaCategory,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (MediaCategory, $$CategoriesTableReferences),
          MediaCategory,
          PrefetchHooks Function({bool accountId})
        > {
  $$CategoriesTableTableManager(_$OrbixDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<ContentKind> kind = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<bool> isAdult = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                accountId: accountId,
                kind: kind,
                id: id,
                name: name,
                sortIndex: sortIndex,
                isAdult: isAdult,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required ContentKind kind,
                required String id,
                required String name,
                required int sortIndex,
                Value<bool> isAdult = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                accountId: accountId,
                kind: kind,
                id: id,
                name: name,
                sortIndex: sortIndex,
                isAdult: isAdult,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, MediaCategory>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$CategoriesTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$CategoriesTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$OrbixDatabase,
      $CategoriesTable,
      MediaCategory,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (MediaCategory, $$CategoriesTableReferences),
      MediaCategory,
      PrefetchHooks Function({bool accountId})
    >;
typedef $$ChannelsTableCreateCompanionBuilder = ChannelsCompanion Function({
  required String accountId,
  required String id,
  required String name,
  Value<int?> number,
  Value<String?> logo,
  Value<String?> categoryId,
  Value<String?> epgId,
  Value<String?> streamUrl,
  Value<String?> headers,
  Value<int> catchupDays,
  required int sortIndex,
  Value<DateTime?> addedAt,
  Value<int> rowid,
});
typedef $$ChannelsTableUpdateCompanionBuilder = ChannelsCompanion Function({
  Value<String> accountId,
  Value<String> id,
  Value<String> name,
  Value<int?> number,
  Value<String?> logo,
  Value<String?> categoryId,
  Value<String?> epgId,
  Value<String?> streamUrl,
  Value<String?> headers,
  Value<int> catchupDays,
  Value<int> sortIndex,
  Value<DateTime?> addedAt,
  Value<int> rowid,
});

final class $$ChannelsTableReferences
    extends BaseReferences<_$OrbixDatabase, $ChannelsTable, Channel> {
  $$ChannelsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$OrbixDatabase db) =>
      db.accounts.createAlias('channels__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChannelsTableFilterComposer
    extends Composer<_$OrbixDatabase, $ChannelsTable> {
  $$ChannelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logo => $composableBuilder(
    column: $table.logo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get epgId => $composableBuilder(
    column: $table.epgId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get streamUrl => $composableBuilder(
    column: $table.streamUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headers => $composableBuilder(
    column: $table.headers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get catchupDays => $composableBuilder(
    column: $table.catchupDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChannelsTableOrderingComposer
    extends Composer<_$OrbixDatabase, $ChannelsTable> {
  $$ChannelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logo => $composableBuilder(
    column: $table.logo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get epgId => $composableBuilder(
    column: $table.epgId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get streamUrl => $composableBuilder(
    column: $table.streamUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headers => $composableBuilder(
    column: $table.headers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get catchupDays => $composableBuilder(
    column: $table.catchupDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChannelsTableAnnotationComposer
    extends Composer<_$OrbixDatabase, $ChannelsTable> {
  $$ChannelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get logo =>
      $composableBuilder(column: $table.logo, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get epgId =>
      $composableBuilder(column: $table.epgId, builder: (column) => column);

  GeneratedColumn<String> get streamUrl =>
      $composableBuilder(column: $table.streamUrl, builder: (column) => column);

  GeneratedColumn<String> get headers =>
      $composableBuilder(column: $table.headers, builder: (column) => column);

  GeneratedColumn<int> get catchupDays => $composableBuilder(
    column: $table.catchupDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChannelsTableTableManager
    extends
        RootTableManager<
          _$OrbixDatabase,
          $ChannelsTable,
          Channel,
          $$ChannelsTableFilterComposer,
          $$ChannelsTableOrderingComposer,
          $$ChannelsTableAnnotationComposer,
          $$ChannelsTableCreateCompanionBuilder,
          $$ChannelsTableUpdateCompanionBuilder,
          (Channel, $$ChannelsTableReferences),
          Channel,
          PrefetchHooks Function({bool accountId})
        > {
  $$ChannelsTableTableManager(_$OrbixDatabase db, $ChannelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChannelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChannelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChannelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> number = const Value.absent(),
                Value<String?> logo = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> epgId = const Value.absent(),
                Value<String?> streamUrl = const Value.absent(),
                Value<String?> headers = const Value.absent(),
                Value<int> catchupDays = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<DateTime?> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChannelsCompanion(
                accountId: accountId,
                id: id,
                name: name,
                number: number,
                logo: logo,
                categoryId: categoryId,
                epgId: epgId,
                streamUrl: streamUrl,
                headers: headers,
                catchupDays: catchupDays,
                sortIndex: sortIndex,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required String id,
                required String name,
                Value<int?> number = const Value.absent(),
                Value<String?> logo = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> epgId = const Value.absent(),
                Value<String?> streamUrl = const Value.absent(),
                Value<String?> headers = const Value.absent(),
                Value<int> catchupDays = const Value.absent(),
                required int sortIndex,
                Value<DateTime?> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChannelsCompanion.insert(
                accountId: accountId,
                id: id,
                name: name,
                number: number,
                logo: logo,
                categoryId: categoryId,
                epgId: epgId,
                streamUrl: streamUrl,
                headers: headers,
                catchupDays: catchupDays,
                sortIndex: sortIndex,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChannelsTable, Channel>(table),
                  $$ChannelsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$ChannelsTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$ChannelsTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChannelsTableProcessedTableManager =
    ProcessedTableManager<
      _$OrbixDatabase,
      $ChannelsTable,
      Channel,
      $$ChannelsTableFilterComposer,
      $$ChannelsTableOrderingComposer,
      $$ChannelsTableAnnotationComposer,
      $$ChannelsTableCreateCompanionBuilder,
      $$ChannelsTableUpdateCompanionBuilder,
      (Channel, $$ChannelsTableReferences),
      Channel,
      PrefetchHooks Function({bool accountId})
    >;
typedef $$MoviesTableCreateCompanionBuilder = MoviesCompanion Function({
  required String accountId,
  required String id,
  required String name,
  Value<String?> poster,
  Value<double?> rating,
  Value<int?> year,
  Value<DateTime?> addedAt,
  Value<String?> categoryId,
  Value<String?> containerExt,
  Value<String?> streamUrl,
  required int sortIndex,
  Value<int> rowid,
});
typedef $$MoviesTableUpdateCompanionBuilder = MoviesCompanion Function({
  Value<String> accountId,
  Value<String> id,
  Value<String> name,
  Value<String?> poster,
  Value<double?> rating,
  Value<int?> year,
  Value<DateTime?> addedAt,
  Value<String?> categoryId,
  Value<String?> containerExt,
  Value<String?> streamUrl,
  Value<int> sortIndex,
  Value<int> rowid,
});

final class $$MoviesTableReferences
    extends BaseReferences<_$OrbixDatabase, $MoviesTable, Movie> {
  $$MoviesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$OrbixDatabase db) =>
      db.accounts.createAlias('movies__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MoviesTableFilterComposer
    extends Composer<_$OrbixDatabase, $MoviesTable> {
  $$MoviesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get poster => $composableBuilder(
    column: $table.poster,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get containerExt => $composableBuilder(
    column: $table.containerExt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get streamUrl => $composableBuilder(
    column: $table.streamUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoviesTableOrderingComposer
    extends Composer<_$OrbixDatabase, $MoviesTable> {
  $$MoviesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get poster => $composableBuilder(
    column: $table.poster,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get containerExt => $composableBuilder(
    column: $table.containerExt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get streamUrl => $composableBuilder(
    column: $table.streamUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoviesTableAnnotationComposer
    extends Composer<_$OrbixDatabase, $MoviesTable> {
  $$MoviesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get poster =>
      $composableBuilder(column: $table.poster, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get containerExt => $composableBuilder(
    column: $table.containerExt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get streamUrl =>
      $composableBuilder(column: $table.streamUrl, builder: (column) => column);

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoviesTableTableManager
    extends
        RootTableManager<
          _$OrbixDatabase,
          $MoviesTable,
          Movie,
          $$MoviesTableFilterComposer,
          $$MoviesTableOrderingComposer,
          $$MoviesTableAnnotationComposer,
          $$MoviesTableCreateCompanionBuilder,
          $$MoviesTableUpdateCompanionBuilder,
          (Movie, $$MoviesTableReferences),
          Movie,
          PrefetchHooks Function({bool accountId})
        > {
  $$MoviesTableTableManager(_$OrbixDatabase db, $MoviesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoviesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoviesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoviesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> poster = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<DateTime?> addedAt = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> containerExt = const Value.absent(),
                Value<String?> streamUrl = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoviesCompanion(
                accountId: accountId,
                id: id,
                name: name,
                poster: poster,
                rating: rating,
                year: year,
                addedAt: addedAt,
                categoryId: categoryId,
                containerExt: containerExt,
                streamUrl: streamUrl,
                sortIndex: sortIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required String id,
                required String name,
                Value<String?> poster = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<DateTime?> addedAt = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> containerExt = const Value.absent(),
                Value<String?> streamUrl = const Value.absent(),
                required int sortIndex,
                Value<int> rowid = const Value.absent(),
              }) => MoviesCompanion.insert(
                accountId: accountId,
                id: id,
                name: name,
                poster: poster,
                rating: rating,
                year: year,
                addedAt: addedAt,
                categoryId: categoryId,
                containerExt: containerExt,
                streamUrl: streamUrl,
                sortIndex: sortIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MoviesTable, Movie>(table),
                  $$MoviesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$MoviesTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$MoviesTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MoviesTableProcessedTableManager =
    ProcessedTableManager<
      _$OrbixDatabase,
      $MoviesTable,
      Movie,
      $$MoviesTableFilterComposer,
      $$MoviesTableOrderingComposer,
      $$MoviesTableAnnotationComposer,
      $$MoviesTableCreateCompanionBuilder,
      $$MoviesTableUpdateCompanionBuilder,
      (Movie, $$MoviesTableReferences),
      Movie,
      PrefetchHooks Function({bool accountId})
    >;
typedef $$SeriesTableTableCreateCompanionBuilder =
    SeriesTableCompanion Function({
      required String accountId,
      required String id,
      required String name,
      Value<String?> cover,
      Value<String?> backdrop,
      Value<String?> plot,
      Value<double?> rating,
      Value<int?> year,
      Value<String?> genre,
      Value<DateTime?> updatedAt,
      Value<String?> categoryId,
      required int sortIndex,
      Value<int> rowid,
    });
typedef $$SeriesTableTableUpdateCompanionBuilder =
    SeriesTableCompanion Function({
      Value<String> accountId,
      Value<String> id,
      Value<String> name,
      Value<String?> cover,
      Value<String?> backdrop,
      Value<String?> plot,
      Value<double?> rating,
      Value<int?> year,
      Value<String?> genre,
      Value<DateTime?> updatedAt,
      Value<String?> categoryId,
      Value<int> sortIndex,
      Value<int> rowid,
    });

final class $$SeriesTableTableReferences
    extends BaseReferences<_$OrbixDatabase, $SeriesTableTable, Show> {
  $$SeriesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$OrbixDatabase db) =>
      db.accounts.createAlias('series__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SeriesTableTableFilterComposer
    extends Composer<_$OrbixDatabase, $SeriesTableTable> {
  $$SeriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cover => $composableBuilder(
    column: $table.cover,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backdrop => $composableBuilder(
    column: $table.backdrop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plot => $composableBuilder(
    column: $table.plot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeriesTableTableOrderingComposer
    extends Composer<_$OrbixDatabase, $SeriesTableTable> {
  $$SeriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cover => $composableBuilder(
    column: $table.cover,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backdrop => $composableBuilder(
    column: $table.backdrop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plot => $composableBuilder(
    column: $table.plot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeriesTableTableAnnotationComposer
    extends Composer<_$OrbixDatabase, $SeriesTableTable> {
  $$SeriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get cover =>
      $composableBuilder(column: $table.cover, builder: (column) => column);

  GeneratedColumn<String> get backdrop =>
      $composableBuilder(column: $table.backdrop, builder: (column) => column);

  GeneratedColumn<String> get plot =>
      $composableBuilder(column: $table.plot, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeriesTableTableTableManager
    extends
        RootTableManager<
          _$OrbixDatabase,
          $SeriesTableTable,
          Show,
          $$SeriesTableTableFilterComposer,
          $$SeriesTableTableOrderingComposer,
          $$SeriesTableTableAnnotationComposer,
          $$SeriesTableTableCreateCompanionBuilder,
          $$SeriesTableTableUpdateCompanionBuilder,
          (Show, $$SeriesTableTableReferences),
          Show,
          PrefetchHooks Function({bool accountId})
        > {
  $$SeriesTableTableTableManager(_$OrbixDatabase db, $SeriesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> cover = const Value.absent(),
                Value<String?> backdrop = const Value.absent(),
                Value<String?> plot = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesTableCompanion(
                accountId: accountId,
                id: id,
                name: name,
                cover: cover,
                backdrop: backdrop,
                plot: plot,
                rating: rating,
                year: year,
                genre: genre,
                updatedAt: updatedAt,
                categoryId: categoryId,
                sortIndex: sortIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required String id,
                required String name,
                Value<String?> cover = const Value.absent(),
                Value<String?> backdrop = const Value.absent(),
                Value<String?> plot = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                required int sortIndex,
                Value<int> rowid = const Value.absent(),
              }) => SeriesTableCompanion.insert(
                accountId: accountId,
                id: id,
                name: name,
                cover: cover,
                backdrop: backdrop,
                plot: plot,
                rating: rating,
                year: year,
                genre: genre,
                updatedAt: updatedAt,
                categoryId: categoryId,
                sortIndex: sortIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SeriesTableTable, Show>(table),
                  $$SeriesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$SeriesTableTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$SeriesTableTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SeriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$OrbixDatabase,
      $SeriesTableTable,
      Show,
      $$SeriesTableTableFilterComposer,
      $$SeriesTableTableOrderingComposer,
      $$SeriesTableTableAnnotationComposer,
      $$SeriesTableTableCreateCompanionBuilder,
      $$SeriesTableTableUpdateCompanionBuilder,
      (Show, $$SeriesTableTableReferences),
      Show,
      PrefetchHooks Function({bool accountId})
    >;
typedef $$EpisodesTableCreateCompanionBuilder = EpisodesCompanion Function({
  required String accountId,
  required String id,
  required String seriesId,
  required int season,
  required int episode,
  required String title,
  Value<String?> containerExt,
  Value<String?> streamUrl,
  Value<int?> durationSecs,
  Value<String?> plot,
  Value<String?> still,
  Value<DateTime?> airDate,
  Value<int> rowid,
});
typedef $$EpisodesTableUpdateCompanionBuilder = EpisodesCompanion Function({
  Value<String> accountId,
  Value<String> id,
  Value<String> seriesId,
  Value<int> season,
  Value<int> episode,
  Value<String> title,
  Value<String?> containerExt,
  Value<String?> streamUrl,
  Value<int?> durationSecs,
  Value<String?> plot,
  Value<String?> still,
  Value<DateTime?> airDate,
  Value<int> rowid,
});

final class $$EpisodesTableReferences
    extends BaseReferences<_$OrbixDatabase, $EpisodesTable, Episode> {
  $$EpisodesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$OrbixDatabase db) =>
      db.accounts.createAlias('episodes__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EpisodesTableFilterComposer
    extends Composer<_$OrbixDatabase, $EpisodesTable> {
  $$EpisodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get episode => $composableBuilder(
    column: $table.episode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get containerExt => $composableBuilder(
    column: $table.containerExt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get streamUrl => $composableBuilder(
    column: $table.streamUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSecs => $composableBuilder(
    column: $table.durationSecs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plot => $composableBuilder(
    column: $table.plot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get still => $composableBuilder(
    column: $table.still,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get airDate => $composableBuilder(
    column: $table.airDate,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpisodesTableOrderingComposer
    extends Composer<_$OrbixDatabase, $EpisodesTable> {
  $$EpisodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get episode => $composableBuilder(
    column: $table.episode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get containerExt => $composableBuilder(
    column: $table.containerExt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get streamUrl => $composableBuilder(
    column: $table.streamUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSecs => $composableBuilder(
    column: $table.durationSecs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plot => $composableBuilder(
    column: $table.plot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get still => $composableBuilder(
    column: $table.still,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get airDate => $composableBuilder(
    column: $table.airDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpisodesTableAnnotationComposer
    extends Composer<_$OrbixDatabase, $EpisodesTable> {
  $$EpisodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);

  GeneratedColumn<int> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<int> get episode =>
      $composableBuilder(column: $table.episode, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get containerExt => $composableBuilder(
    column: $table.containerExt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get streamUrl =>
      $composableBuilder(column: $table.streamUrl, builder: (column) => column);

  GeneratedColumn<int> get durationSecs => $composableBuilder(
    column: $table.durationSecs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plot =>
      $composableBuilder(column: $table.plot, builder: (column) => column);

  GeneratedColumn<String> get still =>
      $composableBuilder(column: $table.still, builder: (column) => column);

  GeneratedColumn<DateTime> get airDate =>
      $composableBuilder(column: $table.airDate, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpisodesTableTableManager
    extends
        RootTableManager<
          _$OrbixDatabase,
          $EpisodesTable,
          Episode,
          $$EpisodesTableFilterComposer,
          $$EpisodesTableOrderingComposer,
          $$EpisodesTableAnnotationComposer,
          $$EpisodesTableCreateCompanionBuilder,
          $$EpisodesTableUpdateCompanionBuilder,
          (Episode, $$EpisodesTableReferences),
          Episode,
          PrefetchHooks Function({bool accountId})
        > {
  $$EpisodesTableTableManager(_$OrbixDatabase db, $EpisodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpisodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EpisodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EpisodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> seriesId = const Value.absent(),
                Value<int> season = const Value.absent(),
                Value<int> episode = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> containerExt = const Value.absent(),
                Value<String?> streamUrl = const Value.absent(),
                Value<int?> durationSecs = const Value.absent(),
                Value<String?> plot = const Value.absent(),
                Value<String?> still = const Value.absent(),
                Value<DateTime?> airDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EpisodesCompanion(
                accountId: accountId,
                id: id,
                seriesId: seriesId,
                season: season,
                episode: episode,
                title: title,
                containerExt: containerExt,
                streamUrl: streamUrl,
                durationSecs: durationSecs,
                plot: plot,
                still: still,
                airDate: airDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required String id,
                required String seriesId,
                required int season,
                required int episode,
                required String title,
                Value<String?> containerExt = const Value.absent(),
                Value<String?> streamUrl = const Value.absent(),
                Value<int?> durationSecs = const Value.absent(),
                Value<String?> plot = const Value.absent(),
                Value<String?> still = const Value.absent(),
                Value<DateTime?> airDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EpisodesCompanion.insert(
                accountId: accountId,
                id: id,
                seriesId: seriesId,
                season: season,
                episode: episode,
                title: title,
                containerExt: containerExt,
                streamUrl: streamUrl,
                durationSecs: durationSecs,
                plot: plot,
                still: still,
                airDate: airDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EpisodesTable, Episode>(table),
                  $$EpisodesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$EpisodesTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$EpisodesTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EpisodesTableProcessedTableManager =
    ProcessedTableManager<
      _$OrbixDatabase,
      $EpisodesTable,
      Episode,
      $$EpisodesTableFilterComposer,
      $$EpisodesTableOrderingComposer,
      $$EpisodesTableAnnotationComposer,
      $$EpisodesTableCreateCompanionBuilder,
      $$EpisodesTableUpdateCompanionBuilder,
      (Episode, $$EpisodesTableReferences),
      Episode,
      PrefetchHooks Function({bool accountId})
    >;
typedef $$FavoritesTableCreateCompanionBuilder = FavoritesCompanion Function({
  required String accountId,
  required ContentKind kind,
  required String itemId,
  required int position,
  required DateTime addedAt,
  Value<int> rowid,
});
typedef $$FavoritesTableUpdateCompanionBuilder = FavoritesCompanion Function({
  Value<String> accountId,
  Value<ContentKind> kind,
  Value<String> itemId,
  Value<int> position,
  Value<DateTime> addedAt,
  Value<int> rowid,
});

final class $$FavoritesTableReferences
    extends BaseReferences<_$OrbixDatabase, $FavoritesTable, Favorite> {
  $$FavoritesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$OrbixDatabase db) =>
      db.accounts.createAlias('favorites__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FavoritesTableFilterComposer
    extends Composer<_$OrbixDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<ContentKind, ContentKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FavoritesTableOrderingComposer
    extends Composer<_$OrbixDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FavoritesTableAnnotationComposer
    extends Composer<_$OrbixDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<ContentKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FavoritesTableTableManager
    extends
        RootTableManager<
          _$OrbixDatabase,
          $FavoritesTable,
          Favorite,
          $$FavoritesTableFilterComposer,
          $$FavoritesTableOrderingComposer,
          $$FavoritesTableAnnotationComposer,
          $$FavoritesTableCreateCompanionBuilder,
          $$FavoritesTableUpdateCompanionBuilder,
          (Favorite, $$FavoritesTableReferences),
          Favorite,
          PrefetchHooks Function({bool accountId})
        > {
  $$FavoritesTableTableManager(_$OrbixDatabase db, $FavoritesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<ContentKind> kind = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion(
                accountId: accountId,
                kind: kind,
                itemId: itemId,
                position: position,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required ContentKind kind,
                required String itemId,
                required int position,
                required DateTime addedAt,
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion.insert(
                accountId: accountId,
                kind: kind,
                itemId: itemId,
                position: position,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FavoritesTable, Favorite>(table),
                  $$FavoritesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$FavoritesTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$FavoritesTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$OrbixDatabase,
      $FavoritesTable,
      Favorite,
      $$FavoritesTableFilterComposer,
      $$FavoritesTableOrderingComposer,
      $$FavoritesTableAnnotationComposer,
      $$FavoritesTableCreateCompanionBuilder,
      $$FavoritesTableUpdateCompanionBuilder,
      (Favorite, $$FavoritesTableReferences),
      Favorite,
      PrefetchHooks Function({bool accountId})
    >;
typedef $$WatchProgressEntriesTableCreateCompanionBuilder =
    WatchProgressEntriesCompanion Function({
      required String accountId,
      required ProgressKind kind,
      required String itemId,
      Value<String?> seriesId,
      Value<int> positionMs,
      Value<int> durationMs,
      Value<bool> completed,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$WatchProgressEntriesTableUpdateCompanionBuilder =
    WatchProgressEntriesCompanion Function({
      Value<String> accountId,
      Value<ProgressKind> kind,
      Value<String> itemId,
      Value<String?> seriesId,
      Value<int> positionMs,
      Value<int> durationMs,
      Value<bool> completed,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$WatchProgressEntriesTableReferences
    extends
        BaseReferences<
          _$OrbixDatabase,
          $WatchProgressEntriesTable,
          WatchProgress
        > {
  $$WatchProgressEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountsTable _accountIdTable(_$OrbixDatabase db) =>
      db.accounts.createAlias('watch_progress__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WatchProgressEntriesTableFilterComposer
    extends Composer<_$OrbixDatabase, $WatchProgressEntriesTable> {
  $$WatchProgressEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<ProgressKind, ProgressKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WatchProgressEntriesTableOrderingComposer
    extends Composer<_$OrbixDatabase, $WatchProgressEntriesTable> {
  $$WatchProgressEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WatchProgressEntriesTableAnnotationComposer
    extends Composer<_$OrbixDatabase, $WatchProgressEntriesTable> {
  $$WatchProgressEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<ProgressKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WatchProgressEntriesTableTableManager
    extends
        RootTableManager<
          _$OrbixDatabase,
          $WatchProgressEntriesTable,
          WatchProgress,
          $$WatchProgressEntriesTableFilterComposer,
          $$WatchProgressEntriesTableOrderingComposer,
          $$WatchProgressEntriesTableAnnotationComposer,
          $$WatchProgressEntriesTableCreateCompanionBuilder,
          $$WatchProgressEntriesTableUpdateCompanionBuilder,
          (WatchProgress, $$WatchProgressEntriesTableReferences),
          WatchProgress,
          PrefetchHooks Function({bool accountId})
        > {
  $$WatchProgressEntriesTableTableManager(
    _$OrbixDatabase db,
    $WatchProgressEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchProgressEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchProgressEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WatchProgressEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<ProgressKind> kind = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String?> seriesId = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WatchProgressEntriesCompanion(
                accountId: accountId,
                kind: kind,
                itemId: itemId,
                seriesId: seriesId,
                positionMs: positionMs,
                durationMs: durationMs,
                completed: completed,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required ProgressKind kind,
                required String itemId,
                Value<String?> seriesId = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WatchProgressEntriesCompanion.insert(
                accountId: accountId,
                kind: kind,
                itemId: itemId,
                seriesId: seriesId,
                positionMs: positionMs,
                durationMs: durationMs,
                completed: completed,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WatchProgressEntriesTable, WatchProgress>(table),
                  $$WatchProgressEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$WatchProgressEntriesTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$WatchProgressEntriesTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WatchProgressEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$OrbixDatabase,
      $WatchProgressEntriesTable,
      WatchProgress,
      $$WatchProgressEntriesTableFilterComposer,
      $$WatchProgressEntriesTableOrderingComposer,
      $$WatchProgressEntriesTableAnnotationComposer,
      $$WatchProgressEntriesTableCreateCompanionBuilder,
      $$WatchProgressEntriesTableUpdateCompanionBuilder,
      (WatchProgress, $$WatchProgressEntriesTableReferences),
      WatchProgress,
      PrefetchHooks Function({bool accountId})
    >;
typedef $$EpgProgrammesTableCreateCompanionBuilder =
    EpgProgrammesCompanion Function({
      required String accountId,
      required String channelId,
      required DateTime start,
      required DateTime stop,
      required String title,
      Value<String?> description,
      Value<String?> category,
      Value<String?> image,
      Value<int> rowid,
    });
typedef $$EpgProgrammesTableUpdateCompanionBuilder =
    EpgProgrammesCompanion Function({
      Value<String> accountId,
      Value<String> channelId,
      Value<DateTime> start,
      Value<DateTime> stop,
      Value<String> title,
      Value<String?> description,
      Value<String?> category,
      Value<String?> image,
      Value<int> rowid,
    });

final class $$EpgProgrammesTableReferences
    extends BaseReferences<_$OrbixDatabase, $EpgProgrammesTable, EpgProgramme> {
  $$EpgProgrammesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountsTable _accountIdTable(_$OrbixDatabase db) =>
      db.accounts.createAlias('epg_programmes__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EpgProgrammesTableFilterComposer
    extends Composer<_$OrbixDatabase, $EpgProgrammesTable> {
  $$EpgProgrammesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get stop => $composableBuilder(
    column: $table.stop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpgProgrammesTableOrderingComposer
    extends Composer<_$OrbixDatabase, $EpgProgrammesTable> {
  $$EpgProgrammesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get stop => $composableBuilder(
    column: $table.stop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpgProgrammesTableAnnotationComposer
    extends Composer<_$OrbixDatabase, $EpgProgrammesTable> {
  $$EpgProgrammesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get channelId =>
      $composableBuilder(column: $table.channelId, builder: (column) => column);

  GeneratedColumn<DateTime> get start =>
      $composableBuilder(column: $table.start, builder: (column) => column);

  GeneratedColumn<DateTime> get stop =>
      $composableBuilder(column: $table.stop, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpgProgrammesTableTableManager
    extends
        RootTableManager<
          _$OrbixDatabase,
          $EpgProgrammesTable,
          EpgProgramme,
          $$EpgProgrammesTableFilterComposer,
          $$EpgProgrammesTableOrderingComposer,
          $$EpgProgrammesTableAnnotationComposer,
          $$EpgProgrammesTableCreateCompanionBuilder,
          $$EpgProgrammesTableUpdateCompanionBuilder,
          (EpgProgramme, $$EpgProgrammesTableReferences),
          EpgProgramme,
          PrefetchHooks Function({bool accountId})
        > {
  $$EpgProgrammesTableTableManager(
    _$OrbixDatabase db,
    $EpgProgrammesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpgProgrammesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EpgProgrammesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EpgProgrammesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<String> channelId = const Value.absent(),
                Value<DateTime> start = const Value.absent(),
                Value<DateTime> stop = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> image = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EpgProgrammesCompanion(
                accountId: accountId,
                channelId: channelId,
                start: start,
                stop: stop,
                title: title,
                description: description,
                category: category,
                image: image,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required String channelId,
                required DateTime start,
                required DateTime stop,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> image = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EpgProgrammesCompanion.insert(
                accountId: accountId,
                channelId: channelId,
                start: start,
                stop: stop,
                title: title,
                description: description,
                category: category,
                image: image,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EpgProgrammesTable, EpgProgramme>(table),
                  $$EpgProgrammesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$EpgProgrammesTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$EpgProgrammesTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EpgProgrammesTableProcessedTableManager =
    ProcessedTableManager<
      _$OrbixDatabase,
      $EpgProgrammesTable,
      EpgProgramme,
      $$EpgProgrammesTableFilterComposer,
      $$EpgProgrammesTableOrderingComposer,
      $$EpgProgrammesTableAnnotationComposer,
      $$EpgProgrammesTableCreateCompanionBuilder,
      $$EpgProgrammesTableUpdateCompanionBuilder,
      (EpgProgramme, $$EpgProgrammesTableReferences),
      EpgProgramme,
      PrefetchHooks Function({bool accountId})
    >;
typedef $$ContentLocksTableCreateCompanionBuilder =
    ContentLocksCompanion Function({
      required String accountId,
      required LockKind kind,
      required String itemId,
      Value<int> rowid,
    });
typedef $$ContentLocksTableUpdateCompanionBuilder =
    ContentLocksCompanion Function({
      Value<String> accountId,
      Value<LockKind> kind,
      Value<String> itemId,
      Value<int> rowid,
    });

final class $$ContentLocksTableReferences
    extends BaseReferences<_$OrbixDatabase, $ContentLocksTable, ContentLock> {
  $$ContentLocksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$OrbixDatabase db) =>
      db.accounts.createAlias('content_locks__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ContentLocksTableFilterComposer
    extends Composer<_$OrbixDatabase, $ContentLocksTable> {
  $$ContentLocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<LockKind, LockKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContentLocksTableOrderingComposer
    extends Composer<_$OrbixDatabase, $ContentLocksTable> {
  $$ContentLocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContentLocksTableAnnotationComposer
    extends Composer<_$OrbixDatabase, $ContentLocksTable> {
  $$ContentLocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<LockKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContentLocksTableTableManager
    extends
        RootTableManager<
          _$OrbixDatabase,
          $ContentLocksTable,
          ContentLock,
          $$ContentLocksTableFilterComposer,
          $$ContentLocksTableOrderingComposer,
          $$ContentLocksTableAnnotationComposer,
          $$ContentLocksTableCreateCompanionBuilder,
          $$ContentLocksTableUpdateCompanionBuilder,
          (ContentLock, $$ContentLocksTableReferences),
          ContentLock,
          PrefetchHooks Function({bool accountId})
        > {
  $$ContentLocksTableTableManager(_$OrbixDatabase db, $ContentLocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentLocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContentLocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentLocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<LockKind> kind = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentLocksCompanion(
                accountId: accountId,
                kind: kind,
                itemId: itemId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required LockKind kind,
                required String itemId,
                Value<int> rowid = const Value.absent(),
              }) => ContentLocksCompanion.insert(
                accountId: accountId,
                kind: kind,
                itemId: itemId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ContentLocksTable, ContentLock>(table),
                  $$ContentLocksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$ContentLocksTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$ContentLocksTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ContentLocksTableProcessedTableManager =
    ProcessedTableManager<
      _$OrbixDatabase,
      $ContentLocksTable,
      ContentLock,
      $$ContentLocksTableFilterComposer,
      $$ContentLocksTableOrderingComposer,
      $$ContentLocksTableAnnotationComposer,
      $$ContentLocksTableCreateCompanionBuilder,
      $$ContentLocksTableUpdateCompanionBuilder,
      (ContentLock, $$ContentLocksTableReferences),
      ContentLock,
      PrefetchHooks Function({bool accountId})
    >;

class $OrbixDatabaseManager {
  final _$OrbixDatabase _db;
  $OrbixDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ChannelsTableTableManager get channels =>
      $$ChannelsTableTableManager(_db, _db.channels);
  $$MoviesTableTableManager get movies =>
      $$MoviesTableTableManager(_db, _db.movies);
  $$SeriesTableTableTableManager get seriesTable =>
      $$SeriesTableTableTableManager(_db, _db.seriesTable);
  $$EpisodesTableTableManager get episodes =>
      $$EpisodesTableTableManager(_db, _db.episodes);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db, _db.favorites);
  $$WatchProgressEntriesTableTableManager get watchProgressEntries =>
      $$WatchProgressEntriesTableTableManager(_db, _db.watchProgressEntries);
  $$EpgProgrammesTableTableManager get epgProgrammes =>
      $$EpgProgrammesTableTableManager(_db, _db.epgProgrammes);
  $$ContentLocksTableTableManager get contentLocks =>
      $$ContentLocksTableTableManager(_db, _db.contentLocks);
}
