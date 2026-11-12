// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_snapshot_offline.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OfflineSnapshotOfflineReasonEnum
    _$offlineSnapshotOfflineReasonEnum_menuDisabled =
    const OfflineSnapshotOfflineReasonEnum._('menuDisabled');
const OfflineSnapshotOfflineReasonEnum
    _$offlineSnapshotOfflineReasonEnum_registerNotCounter =
    const OfflineSnapshotOfflineReasonEnum._('registerNotCounter');
const OfflineSnapshotOfflineReasonEnum
    _$offlineSnapshotOfflineReasonEnum_shiftClosed =
    const OfflineSnapshotOfflineReasonEnum._('shiftClosed');
const OfflineSnapshotOfflineReasonEnum
    _$offlineSnapshotOfflineReasonEnum_cashUnavailable =
    const OfflineSnapshotOfflineReasonEnum._('cashUnavailable');

OfflineSnapshotOfflineReasonEnum _$offlineSnapshotOfflineReasonEnumValueOf(
    String name) {
  switch (name) {
    case 'menuDisabled':
      return _$offlineSnapshotOfflineReasonEnum_menuDisabled;
    case 'registerNotCounter':
      return _$offlineSnapshotOfflineReasonEnum_registerNotCounter;
    case 'shiftClosed':
      return _$offlineSnapshotOfflineReasonEnum_shiftClosed;
    case 'cashUnavailable':
      return _$offlineSnapshotOfflineReasonEnum_cashUnavailable;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OfflineSnapshotOfflineReasonEnum>
    _$offlineSnapshotOfflineReasonEnumValues = BuiltSet<
        OfflineSnapshotOfflineReasonEnum>(const <OfflineSnapshotOfflineReasonEnum>[
  _$offlineSnapshotOfflineReasonEnum_menuDisabled,
  _$offlineSnapshotOfflineReasonEnum_registerNotCounter,
  _$offlineSnapshotOfflineReasonEnum_shiftClosed,
  _$offlineSnapshotOfflineReasonEnum_cashUnavailable,
]);

Serializer<OfflineSnapshotOfflineReasonEnum>
    _$offlineSnapshotOfflineReasonEnumSerializer =
    _$OfflineSnapshotOfflineReasonEnumSerializer();

class _$OfflineSnapshotOfflineReasonEnumSerializer
    implements PrimitiveSerializer<OfflineSnapshotOfflineReasonEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'menuDisabled': 'menu_disabled',
    'registerNotCounter': 'register_not_counter',
    'shiftClosed': 'shift_closed',
    'cashUnavailable': 'cash_unavailable',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'menu_disabled': 'menuDisabled',
    'register_not_counter': 'registerNotCounter',
    'shift_closed': 'shiftClosed',
    'cash_unavailable': 'cashUnavailable',
  };

  @override
  final Iterable<Type> types = const <Type>[OfflineSnapshotOfflineReasonEnum];
  @override
  final String wireName = 'OfflineSnapshotOfflineReasonEnum';

  @override
  Object serialize(
          Serializers serializers, OfflineSnapshotOfflineReasonEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OfflineSnapshotOfflineReasonEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OfflineSnapshotOfflineReasonEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OfflineSnapshotOffline extends OfflineSnapshotOffline {
  @override
  final bool allowed;
  @override
  final OfflineSnapshotOfflineReasonEnum? reason;

  factory _$OfflineSnapshotOffline(
          [void Function(OfflineSnapshotOfflineBuilder)? updates]) =>
      (OfflineSnapshotOfflineBuilder()..update(updates))._build();

  _$OfflineSnapshotOffline._({required this.allowed, this.reason}) : super._();
  @override
  OfflineSnapshotOffline rebuild(
          void Function(OfflineSnapshotOfflineBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OfflineSnapshotOfflineBuilder toBuilder() =>
      OfflineSnapshotOfflineBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OfflineSnapshotOffline &&
        allowed == other.allowed &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, allowed.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OfflineSnapshotOffline')
          ..add('allowed', allowed)
          ..add('reason', reason))
        .toString();
  }
}

class OfflineSnapshotOfflineBuilder
    implements Builder<OfflineSnapshotOffline, OfflineSnapshotOfflineBuilder> {
  _$OfflineSnapshotOffline? _$v;

  bool? _allowed;
  bool? get allowed => _$this._allowed;
  set allowed(bool? allowed) => _$this._allowed = allowed;

  OfflineSnapshotOfflineReasonEnum? _reason;
  OfflineSnapshotOfflineReasonEnum? get reason => _$this._reason;
  set reason(OfflineSnapshotOfflineReasonEnum? reason) =>
      _$this._reason = reason;

  OfflineSnapshotOfflineBuilder() {
    OfflineSnapshotOffline._defaults(this);
  }

  OfflineSnapshotOfflineBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _allowed = $v.allowed;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OfflineSnapshotOffline other) {
    _$v = other as _$OfflineSnapshotOffline;
  }

  @override
  void update(void Function(OfflineSnapshotOfflineBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OfflineSnapshotOffline build() => _build();

  _$OfflineSnapshotOffline _build() {
    final _$result = _$v ??
        _$OfflineSnapshotOffline._(
          allowed: BuiltValueNullFieldError.checkNotNull(
              allowed, r'OfflineSnapshotOffline', 'allowed'),
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
