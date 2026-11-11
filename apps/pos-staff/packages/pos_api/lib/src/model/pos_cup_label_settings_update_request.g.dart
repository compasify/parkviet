// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_cup_label_settings_update_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PosCupLabelSettingsUpdateRequestSizeEnum
    _$posCupLabelSettingsUpdateRequestSizeEnum_n40x30 =
    const PosCupLabelSettingsUpdateRequestSizeEnum._('n40x30');
const PosCupLabelSettingsUpdateRequestSizeEnum
    _$posCupLabelSettingsUpdateRequestSizeEnum_n50x30 =
    const PosCupLabelSettingsUpdateRequestSizeEnum._('n50x30');
const PosCupLabelSettingsUpdateRequestSizeEnum
    _$posCupLabelSettingsUpdateRequestSizeEnum_n58x40 =
    const PosCupLabelSettingsUpdateRequestSizeEnum._('n58x40');

PosCupLabelSettingsUpdateRequestSizeEnum
    _$posCupLabelSettingsUpdateRequestSizeEnumValueOf(String name) {
  switch (name) {
    case 'n40x30':
      return _$posCupLabelSettingsUpdateRequestSizeEnum_n40x30;
    case 'n50x30':
      return _$posCupLabelSettingsUpdateRequestSizeEnum_n50x30;
    case 'n58x40':
      return _$posCupLabelSettingsUpdateRequestSizeEnum_n58x40;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PosCupLabelSettingsUpdateRequestSizeEnum>
    _$posCupLabelSettingsUpdateRequestSizeEnumValues = BuiltSet<
        PosCupLabelSettingsUpdateRequestSizeEnum>(const <PosCupLabelSettingsUpdateRequestSizeEnum>[
  _$posCupLabelSettingsUpdateRequestSizeEnum_n40x30,
  _$posCupLabelSettingsUpdateRequestSizeEnum_n50x30,
  _$posCupLabelSettingsUpdateRequestSizeEnum_n58x40,
]);

const PosCupLabelSettingsUpdateRequestFieldsEnum
    _$posCupLabelSettingsUpdateRequestFieldsEnum_callNumber =
    const PosCupLabelSettingsUpdateRequestFieldsEnum._('callNumber');
const PosCupLabelSettingsUpdateRequestFieldsEnum
    _$posCupLabelSettingsUpdateRequestFieldsEnum_options =
    const PosCupLabelSettingsUpdateRequestFieldsEnum._('options');
const PosCupLabelSettingsUpdateRequestFieldsEnum
    _$posCupLabelSettingsUpdateRequestFieldsEnum_note =
    const PosCupLabelSettingsUpdateRequestFieldsEnum._('note');
const PosCupLabelSettingsUpdateRequestFieldsEnum
    _$posCupLabelSettingsUpdateRequestFieldsEnum_guestName =
    const PosCupLabelSettingsUpdateRequestFieldsEnum._('guestName');
const PosCupLabelSettingsUpdateRequestFieldsEnum
    _$posCupLabelSettingsUpdateRequestFieldsEnum_time =
    const PosCupLabelSettingsUpdateRequestFieldsEnum._('time');
const PosCupLabelSettingsUpdateRequestFieldsEnum
    _$posCupLabelSettingsUpdateRequestFieldsEnum_storeName =
    const PosCupLabelSettingsUpdateRequestFieldsEnum._('storeName');

PosCupLabelSettingsUpdateRequestFieldsEnum
    _$posCupLabelSettingsUpdateRequestFieldsEnumValueOf(String name) {
  switch (name) {
    case 'callNumber':
      return _$posCupLabelSettingsUpdateRequestFieldsEnum_callNumber;
    case 'options':
      return _$posCupLabelSettingsUpdateRequestFieldsEnum_options;
    case 'note':
      return _$posCupLabelSettingsUpdateRequestFieldsEnum_note;
    case 'guestName':
      return _$posCupLabelSettingsUpdateRequestFieldsEnum_guestName;
    case 'time':
      return _$posCupLabelSettingsUpdateRequestFieldsEnum_time;
    case 'storeName':
      return _$posCupLabelSettingsUpdateRequestFieldsEnum_storeName;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PosCupLabelSettingsUpdateRequestFieldsEnum>
    _$posCupLabelSettingsUpdateRequestFieldsEnumValues = BuiltSet<
        PosCupLabelSettingsUpdateRequestFieldsEnum>(const <PosCupLabelSettingsUpdateRequestFieldsEnum>[
  _$posCupLabelSettingsUpdateRequestFieldsEnum_callNumber,
  _$posCupLabelSettingsUpdateRequestFieldsEnum_options,
  _$posCupLabelSettingsUpdateRequestFieldsEnum_note,
  _$posCupLabelSettingsUpdateRequestFieldsEnum_guestName,
  _$posCupLabelSettingsUpdateRequestFieldsEnum_time,
  _$posCupLabelSettingsUpdateRequestFieldsEnum_storeName,
]);

Serializer<PosCupLabelSettingsUpdateRequestSizeEnum>
    _$posCupLabelSettingsUpdateRequestSizeEnumSerializer =
    _$PosCupLabelSettingsUpdateRequestSizeEnumSerializer();
Serializer<PosCupLabelSettingsUpdateRequestFieldsEnum>
    _$posCupLabelSettingsUpdateRequestFieldsEnumSerializer =
    _$PosCupLabelSettingsUpdateRequestFieldsEnumSerializer();

class _$PosCupLabelSettingsUpdateRequestSizeEnumSerializer
    implements PrimitiveSerializer<PosCupLabelSettingsUpdateRequestSizeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n40x30': '40x30',
    'n50x30': '50x30',
    'n58x40': '58x40',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '40x30': 'n40x30',
    '50x30': 'n50x30',
    '58x40': 'n58x40',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PosCupLabelSettingsUpdateRequestSizeEnum
  ];
  @override
  final String wireName = 'PosCupLabelSettingsUpdateRequestSizeEnum';

  @override
  Object serialize(Serializers serializers,
          PosCupLabelSettingsUpdateRequestSizeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PosCupLabelSettingsUpdateRequestSizeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PosCupLabelSettingsUpdateRequestSizeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PosCupLabelSettingsUpdateRequestFieldsEnumSerializer
    implements PrimitiveSerializer<PosCupLabelSettingsUpdateRequestFieldsEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'callNumber': 'call_number',
    'options': 'options',
    'note': 'note',
    'guestName': 'guest_name',
    'time': 'time',
    'storeName': 'store_name',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'call_number': 'callNumber',
    'options': 'options',
    'note': 'note',
    'guest_name': 'guestName',
    'time': 'time',
    'store_name': 'storeName',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PosCupLabelSettingsUpdateRequestFieldsEnum
  ];
  @override
  final String wireName = 'PosCupLabelSettingsUpdateRequestFieldsEnum';

  @override
  Object serialize(Serializers serializers,
          PosCupLabelSettingsUpdateRequestFieldsEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PosCupLabelSettingsUpdateRequestFieldsEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PosCupLabelSettingsUpdateRequestFieldsEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PosCupLabelSettingsUpdateRequest
    extends PosCupLabelSettingsUpdateRequest {
  @override
  final String branchId;
  @override
  final String? printerId;
  @override
  final PosCupLabelSettingsUpdateRequestSizeEnum? size;
  @override
  final BuiltList<PosCupLabelSettingsUpdateRequestFieldsEnum>? fields;
  @override
  final int? pickupMinutes;

  factory _$PosCupLabelSettingsUpdateRequest(
          [void Function(PosCupLabelSettingsUpdateRequestBuilder)? updates]) =>
      (PosCupLabelSettingsUpdateRequestBuilder()..update(updates))._build();

  _$PosCupLabelSettingsUpdateRequest._(
      {required this.branchId,
      this.printerId,
      this.size,
      this.fields,
      this.pickupMinutes})
      : super._();
  @override
  PosCupLabelSettingsUpdateRequest rebuild(
          void Function(PosCupLabelSettingsUpdateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosCupLabelSettingsUpdateRequestBuilder toBuilder() =>
      PosCupLabelSettingsUpdateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosCupLabelSettingsUpdateRequest &&
        branchId == other.branchId &&
        printerId == other.printerId &&
        size == other.size &&
        fields == other.fields &&
        pickupMinutes == other.pickupMinutes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, printerId.hashCode);
    _$hash = $jc(_$hash, size.hashCode);
    _$hash = $jc(_$hash, fields.hashCode);
    _$hash = $jc(_$hash, pickupMinutes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosCupLabelSettingsUpdateRequest')
          ..add('branchId', branchId)
          ..add('printerId', printerId)
          ..add('size', size)
          ..add('fields', fields)
          ..add('pickupMinutes', pickupMinutes))
        .toString();
  }
}

class PosCupLabelSettingsUpdateRequestBuilder
    implements
        Builder<PosCupLabelSettingsUpdateRequest,
            PosCupLabelSettingsUpdateRequestBuilder> {
  _$PosCupLabelSettingsUpdateRequest? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _printerId;
  String? get printerId => _$this._printerId;
  set printerId(String? printerId) => _$this._printerId = printerId;

  PosCupLabelSettingsUpdateRequestSizeEnum? _size;
  PosCupLabelSettingsUpdateRequestSizeEnum? get size => _$this._size;
  set size(PosCupLabelSettingsUpdateRequestSizeEnum? size) =>
      _$this._size = size;

  ListBuilder<PosCupLabelSettingsUpdateRequestFieldsEnum>? _fields;
  ListBuilder<PosCupLabelSettingsUpdateRequestFieldsEnum> get fields =>
      _$this._fields ??=
          ListBuilder<PosCupLabelSettingsUpdateRequestFieldsEnum>();
  set fields(ListBuilder<PosCupLabelSettingsUpdateRequestFieldsEnum>? fields) =>
      _$this._fields = fields;

  int? _pickupMinutes;
  int? get pickupMinutes => _$this._pickupMinutes;
  set pickupMinutes(int? pickupMinutes) =>
      _$this._pickupMinutes = pickupMinutes;

  PosCupLabelSettingsUpdateRequestBuilder() {
    PosCupLabelSettingsUpdateRequest._defaults(this);
  }

  PosCupLabelSettingsUpdateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _printerId = $v.printerId;
      _size = $v.size;
      _fields = $v.fields?.toBuilder();
      _pickupMinutes = $v.pickupMinutes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosCupLabelSettingsUpdateRequest other) {
    _$v = other as _$PosCupLabelSettingsUpdateRequest;
  }

  @override
  void update(void Function(PosCupLabelSettingsUpdateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosCupLabelSettingsUpdateRequest build() => _build();

  _$PosCupLabelSettingsUpdateRequest _build() {
    _$PosCupLabelSettingsUpdateRequest _$result;
    try {
      _$result = _$v ??
          _$PosCupLabelSettingsUpdateRequest._(
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'PosCupLabelSettingsUpdateRequest', 'branchId'),
            printerId: printerId,
            size: size,
            fields: _fields?.build(),
            pickupMinutes: pickupMinutes,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'fields';
        _fields?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosCupLabelSettingsUpdateRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
