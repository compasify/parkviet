// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_snapshot_store.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OfflineSnapshotStore extends OfflineSnapshotStore {
  @override
  final String id;
  @override
  final String? name;
  @override
  final String currency;
  @override
  final BuiltMap<String, String?> profile;

  factory _$OfflineSnapshotStore(
          [void Function(OfflineSnapshotStoreBuilder)? updates]) =>
      (OfflineSnapshotStoreBuilder()..update(updates))._build();

  _$OfflineSnapshotStore._(
      {required this.id,
      this.name,
      required this.currency,
      required this.profile})
      : super._();
  @override
  OfflineSnapshotStore rebuild(
          void Function(OfflineSnapshotStoreBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OfflineSnapshotStoreBuilder toBuilder() =>
      OfflineSnapshotStoreBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OfflineSnapshotStore &&
        id == other.id &&
        name == other.name &&
        currency == other.currency &&
        profile == other.profile;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, profile.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OfflineSnapshotStore')
          ..add('id', id)
          ..add('name', name)
          ..add('currency', currency)
          ..add('profile', profile))
        .toString();
  }
}

class OfflineSnapshotStoreBuilder
    implements Builder<OfflineSnapshotStore, OfflineSnapshotStoreBuilder> {
  _$OfflineSnapshotStore? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  MapBuilder<String, String?>? _profile;
  MapBuilder<String, String?> get profile =>
      _$this._profile ??= MapBuilder<String, String?>();
  set profile(MapBuilder<String, String?>? profile) =>
      _$this._profile = profile;

  OfflineSnapshotStoreBuilder() {
    OfflineSnapshotStore._defaults(this);
  }

  OfflineSnapshotStoreBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _currency = $v.currency;
      _profile = $v.profile.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OfflineSnapshotStore other) {
    _$v = other as _$OfflineSnapshotStore;
  }

  @override
  void update(void Function(OfflineSnapshotStoreBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OfflineSnapshotStore build() => _build();

  _$OfflineSnapshotStore _build() {
    _$OfflineSnapshotStore _$result;
    try {
      _$result = _$v ??
          _$OfflineSnapshotStore._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'OfflineSnapshotStore', 'id'),
            name: name,
            currency: BuiltValueNullFieldError.checkNotNull(
                currency, r'OfflineSnapshotStore', 'currency'),
            profile: profile.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'profile';
        profile.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OfflineSnapshotStore', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
