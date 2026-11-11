// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_send_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenSendSummary extends KitchenSendSummary {
  @override
  final String id;
  @override
  final int sequence;
  @override
  final DateTime sentAt;
  @override
  final String? staffId;
  @override
  final String? staffName;
  @override
  final String? deviceId;

  factory _$KitchenSendSummary(
          [void Function(KitchenSendSummaryBuilder)? updates]) =>
      (KitchenSendSummaryBuilder()..update(updates))._build();

  _$KitchenSendSummary._(
      {required this.id,
      required this.sequence,
      required this.sentAt,
      this.staffId,
      this.staffName,
      this.deviceId})
      : super._();
  @override
  KitchenSendSummary rebuild(
          void Function(KitchenSendSummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenSendSummaryBuilder toBuilder() =>
      KitchenSendSummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenSendSummary &&
        id == other.id &&
        sequence == other.sequence &&
        sentAt == other.sentAt &&
        staffId == other.staffId &&
        staffName == other.staffName &&
        deviceId == other.deviceId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, sequence.hashCode);
    _$hash = $jc(_$hash, sentAt.hashCode);
    _$hash = $jc(_$hash, staffId.hashCode);
    _$hash = $jc(_$hash, staffName.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenSendSummary')
          ..add('id', id)
          ..add('sequence', sequence)
          ..add('sentAt', sentAt)
          ..add('staffId', staffId)
          ..add('staffName', staffName)
          ..add('deviceId', deviceId))
        .toString();
  }
}

class KitchenSendSummaryBuilder
    implements Builder<KitchenSendSummary, KitchenSendSummaryBuilder> {
  _$KitchenSendSummary? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _sequence;
  int? get sequence => _$this._sequence;
  set sequence(int? sequence) => _$this._sequence = sequence;

  DateTime? _sentAt;
  DateTime? get sentAt => _$this._sentAt;
  set sentAt(DateTime? sentAt) => _$this._sentAt = sentAt;

  String? _staffId;
  String? get staffId => _$this._staffId;
  set staffId(String? staffId) => _$this._staffId = staffId;

  String? _staffName;
  String? get staffName => _$this._staffName;
  set staffName(String? staffName) => _$this._staffName = staffName;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  KitchenSendSummaryBuilder() {
    KitchenSendSummary._defaults(this);
  }

  KitchenSendSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _sequence = $v.sequence;
      _sentAt = $v.sentAt;
      _staffId = $v.staffId;
      _staffName = $v.staffName;
      _deviceId = $v.deviceId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenSendSummary other) {
    _$v = other as _$KitchenSendSummary;
  }

  @override
  void update(void Function(KitchenSendSummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenSendSummary build() => _build();

  _$KitchenSendSummary _build() {
    final _$result = _$v ??
        _$KitchenSendSummary._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'KitchenSendSummary', 'id'),
          sequence: BuiltValueNullFieldError.checkNotNull(
              sequence, r'KitchenSendSummary', 'sequence'),
          sentAt: BuiltValueNullFieldError.checkNotNull(
              sentAt, r'KitchenSendSummary', 'sentAt'),
          staffId: staffId,
          staffName: staffName,
          deviceId: deviceId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
