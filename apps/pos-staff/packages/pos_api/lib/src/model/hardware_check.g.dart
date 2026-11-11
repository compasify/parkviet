// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hardware_check.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const HardwareCheckKeyEnum _$hardwareCheckKeyEnum_receiptPrinter =
    const HardwareCheckKeyEnum._('receiptPrinter');
const HardwareCheckKeyEnum _$hardwareCheckKeyEnum_kitchenPrinter =
    const HardwareCheckKeyEnum._('kitchenPrinter');
const HardwareCheckKeyEnum _$hardwareCheckKeyEnum_cupLabelPrinter =
    const HardwareCheckKeyEnum._('cupLabelPrinter');
const HardwareCheckKeyEnum _$hardwareCheckKeyEnum_kitchenStations =
    const HardwareCheckKeyEnum._('kitchenStations');
const HardwareCheckKeyEnum _$hardwareCheckKeyEnum_printStation =
    const HardwareCheckKeyEnum._('printStation');
const HardwareCheckKeyEnum _$hardwareCheckKeyEnum_customerDisplay =
    const HardwareCheckKeyEnum._('customerDisplay');
const HardwareCheckKeyEnum _$hardwareCheckKeyEnum_server =
    const HardwareCheckKeyEnum._('server');
const HardwareCheckKeyEnum _$hardwareCheckKeyEnum_einvoice =
    const HardwareCheckKeyEnum._('einvoice');

HardwareCheckKeyEnum _$hardwareCheckKeyEnumValueOf(String name) {
  switch (name) {
    case 'receiptPrinter':
      return _$hardwareCheckKeyEnum_receiptPrinter;
    case 'kitchenPrinter':
      return _$hardwareCheckKeyEnum_kitchenPrinter;
    case 'cupLabelPrinter':
      return _$hardwareCheckKeyEnum_cupLabelPrinter;
    case 'kitchenStations':
      return _$hardwareCheckKeyEnum_kitchenStations;
    case 'printStation':
      return _$hardwareCheckKeyEnum_printStation;
    case 'customerDisplay':
      return _$hardwareCheckKeyEnum_customerDisplay;
    case 'server':
      return _$hardwareCheckKeyEnum_server;
    case 'einvoice':
      return _$hardwareCheckKeyEnum_einvoice;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<HardwareCheckKeyEnum> _$hardwareCheckKeyEnumValues =
    BuiltSet<HardwareCheckKeyEnum>(const <HardwareCheckKeyEnum>[
  _$hardwareCheckKeyEnum_receiptPrinter,
  _$hardwareCheckKeyEnum_kitchenPrinter,
  _$hardwareCheckKeyEnum_cupLabelPrinter,
  _$hardwareCheckKeyEnum_kitchenStations,
  _$hardwareCheckKeyEnum_printStation,
  _$hardwareCheckKeyEnum_customerDisplay,
  _$hardwareCheckKeyEnum_server,
  _$hardwareCheckKeyEnum_einvoice,
]);

const HardwareCheckStatusEnum _$hardwareCheckStatusEnum_ok =
    const HardwareCheckStatusEnum._('ok');
const HardwareCheckStatusEnum _$hardwareCheckStatusEnum_attention =
    const HardwareCheckStatusEnum._('attention');
const HardwareCheckStatusEnum _$hardwareCheckStatusEnum_notNeeded =
    const HardwareCheckStatusEnum._('notNeeded');

HardwareCheckStatusEnum _$hardwareCheckStatusEnumValueOf(String name) {
  switch (name) {
    case 'ok':
      return _$hardwareCheckStatusEnum_ok;
    case 'attention':
      return _$hardwareCheckStatusEnum_attention;
    case 'notNeeded':
      return _$hardwareCheckStatusEnum_notNeeded;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<HardwareCheckStatusEnum> _$hardwareCheckStatusEnumValues =
    BuiltSet<HardwareCheckStatusEnum>(const <HardwareCheckStatusEnum>[
  _$hardwareCheckStatusEnum_ok,
  _$hardwareCheckStatusEnum_attention,
  _$hardwareCheckStatusEnum_notNeeded,
]);

Serializer<HardwareCheckKeyEnum> _$hardwareCheckKeyEnumSerializer =
    _$HardwareCheckKeyEnumSerializer();
Serializer<HardwareCheckStatusEnum> _$hardwareCheckStatusEnumSerializer =
    _$HardwareCheckStatusEnumSerializer();

class _$HardwareCheckKeyEnumSerializer
    implements PrimitiveSerializer<HardwareCheckKeyEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'receiptPrinter': 'receipt_printer',
    'kitchenPrinter': 'kitchen_printer',
    'cupLabelPrinter': 'cup_label_printer',
    'kitchenStations': 'kitchen_stations',
    'printStation': 'print_station',
    'customerDisplay': 'customer_display',
    'server': 'server',
    'einvoice': 'einvoice',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'receipt_printer': 'receiptPrinter',
    'kitchen_printer': 'kitchenPrinter',
    'cup_label_printer': 'cupLabelPrinter',
    'kitchen_stations': 'kitchenStations',
    'print_station': 'printStation',
    'customer_display': 'customerDisplay',
    'server': 'server',
    'einvoice': 'einvoice',
  };

  @override
  final Iterable<Type> types = const <Type>[HardwareCheckKeyEnum];
  @override
  final String wireName = 'HardwareCheckKeyEnum';

  @override
  Object serialize(Serializers serializers, HardwareCheckKeyEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  HardwareCheckKeyEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      HardwareCheckKeyEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$HardwareCheckStatusEnumSerializer
    implements PrimitiveSerializer<HardwareCheckStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ok': 'ok',
    'attention': 'attention',
    'notNeeded': 'not_needed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ok': 'ok',
    'attention': 'attention',
    'not_needed': 'notNeeded',
  };

  @override
  final Iterable<Type> types = const <Type>[HardwareCheckStatusEnum];
  @override
  final String wireName = 'HardwareCheckStatusEnum';

  @override
  Object serialize(Serializers serializers, HardwareCheckStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  HardwareCheckStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      HardwareCheckStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$HardwareCheck extends HardwareCheck {
  @override
  final HardwareCheckKeyEnum key;
  @override
  final HardwareCheckStatusEnum status;

  factory _$HardwareCheck([void Function(HardwareCheckBuilder)? updates]) =>
      (HardwareCheckBuilder()..update(updates))._build();

  _$HardwareCheck._({required this.key, required this.status}) : super._();
  @override
  HardwareCheck rebuild(void Function(HardwareCheckBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HardwareCheckBuilder toBuilder() => HardwareCheckBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HardwareCheck && key == other.key && status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HardwareCheck')
          ..add('key', key)
          ..add('status', status))
        .toString();
  }
}

class HardwareCheckBuilder
    implements Builder<HardwareCheck, HardwareCheckBuilder> {
  _$HardwareCheck? _$v;

  HardwareCheckKeyEnum? _key;
  HardwareCheckKeyEnum? get key => _$this._key;
  set key(HardwareCheckKeyEnum? key) => _$this._key = key;

  HardwareCheckStatusEnum? _status;
  HardwareCheckStatusEnum? get status => _$this._status;
  set status(HardwareCheckStatusEnum? status) => _$this._status = status;

  HardwareCheckBuilder() {
    HardwareCheck._defaults(this);
  }

  HardwareCheckBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HardwareCheck other) {
    _$v = other as _$HardwareCheck;
  }

  @override
  void update(void Function(HardwareCheckBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HardwareCheck build() => _build();

  _$HardwareCheck _build() {
    final _$result = _$v ??
        _$HardwareCheck._(
          key: BuiltValueNullFieldError.checkNotNull(
              key, r'HardwareCheck', 'key'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'HardwareCheck', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
