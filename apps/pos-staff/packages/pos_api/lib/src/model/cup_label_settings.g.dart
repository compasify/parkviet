// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cup_label_settings.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CupLabelSettingsSizeEnum _$cupLabelSettingsSizeEnum_n40x30 =
    const CupLabelSettingsSizeEnum._('n40x30');
const CupLabelSettingsSizeEnum _$cupLabelSettingsSizeEnum_n50x30 =
    const CupLabelSettingsSizeEnum._('n50x30');
const CupLabelSettingsSizeEnum _$cupLabelSettingsSizeEnum_n58x40 =
    const CupLabelSettingsSizeEnum._('n58x40');

CupLabelSettingsSizeEnum _$cupLabelSettingsSizeEnumValueOf(String name) {
  switch (name) {
    case 'n40x30':
      return _$cupLabelSettingsSizeEnum_n40x30;
    case 'n50x30':
      return _$cupLabelSettingsSizeEnum_n50x30;
    case 'n58x40':
      return _$cupLabelSettingsSizeEnum_n58x40;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CupLabelSettingsSizeEnum> _$cupLabelSettingsSizeEnumValues =
    BuiltSet<CupLabelSettingsSizeEnum>(const <CupLabelSettingsSizeEnum>[
  _$cupLabelSettingsSizeEnum_n40x30,
  _$cupLabelSettingsSizeEnum_n50x30,
  _$cupLabelSettingsSizeEnum_n58x40,
]);

const CupLabelSettingsFieldsEnum _$cupLabelSettingsFieldsEnum_callNumber =
    const CupLabelSettingsFieldsEnum._('callNumber');
const CupLabelSettingsFieldsEnum _$cupLabelSettingsFieldsEnum_options =
    const CupLabelSettingsFieldsEnum._('options');
const CupLabelSettingsFieldsEnum _$cupLabelSettingsFieldsEnum_note =
    const CupLabelSettingsFieldsEnum._('note');
const CupLabelSettingsFieldsEnum _$cupLabelSettingsFieldsEnum_guestName =
    const CupLabelSettingsFieldsEnum._('guestName');
const CupLabelSettingsFieldsEnum _$cupLabelSettingsFieldsEnum_time =
    const CupLabelSettingsFieldsEnum._('time');
const CupLabelSettingsFieldsEnum _$cupLabelSettingsFieldsEnum_storeName =
    const CupLabelSettingsFieldsEnum._('storeName');

CupLabelSettingsFieldsEnum _$cupLabelSettingsFieldsEnumValueOf(String name) {
  switch (name) {
    case 'callNumber':
      return _$cupLabelSettingsFieldsEnum_callNumber;
    case 'options':
      return _$cupLabelSettingsFieldsEnum_options;
    case 'note':
      return _$cupLabelSettingsFieldsEnum_note;
    case 'guestName':
      return _$cupLabelSettingsFieldsEnum_guestName;
    case 'time':
      return _$cupLabelSettingsFieldsEnum_time;
    case 'storeName':
      return _$cupLabelSettingsFieldsEnum_storeName;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CupLabelSettingsFieldsEnum> _$cupLabelSettingsFieldsEnumValues =
    BuiltSet<CupLabelSettingsFieldsEnum>(const <CupLabelSettingsFieldsEnum>[
  _$cupLabelSettingsFieldsEnum_callNumber,
  _$cupLabelSettingsFieldsEnum_options,
  _$cupLabelSettingsFieldsEnum_note,
  _$cupLabelSettingsFieldsEnum_guestName,
  _$cupLabelSettingsFieldsEnum_time,
  _$cupLabelSettingsFieldsEnum_storeName,
]);

Serializer<CupLabelSettingsSizeEnum> _$cupLabelSettingsSizeEnumSerializer =
    _$CupLabelSettingsSizeEnumSerializer();
Serializer<CupLabelSettingsFieldsEnum> _$cupLabelSettingsFieldsEnumSerializer =
    _$CupLabelSettingsFieldsEnumSerializer();

class _$CupLabelSettingsSizeEnumSerializer
    implements PrimitiveSerializer<CupLabelSettingsSizeEnum> {
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
  final Iterable<Type> types = const <Type>[CupLabelSettingsSizeEnum];
  @override
  final String wireName = 'CupLabelSettingsSizeEnum';

  @override
  Object serialize(Serializers serializers, CupLabelSettingsSizeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CupLabelSettingsSizeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CupLabelSettingsSizeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CupLabelSettingsFieldsEnumSerializer
    implements PrimitiveSerializer<CupLabelSettingsFieldsEnum> {
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
  final Iterable<Type> types = const <Type>[CupLabelSettingsFieldsEnum];
  @override
  final String wireName = 'CupLabelSettingsFieldsEnum';

  @override
  Object serialize(Serializers serializers, CupLabelSettingsFieldsEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CupLabelSettingsFieldsEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CupLabelSettingsFieldsEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CupLabelSettings extends CupLabelSettings {
  @override
  final String branchId;
  @override
  final String? printerId;
  @override
  final CupLabelSettingsSizeEnum size;
  @override
  final BuiltList<CupLabelSettingsFieldsEnum> fields;
  @override
  final int pickupMinutes;
  @override
  final bool moduleEnabled;
  @override
  final BuiltList<String> sizes;
  @override
  final BuiltList<String> availableFields;

  factory _$CupLabelSettings(
          [void Function(CupLabelSettingsBuilder)? updates]) =>
      (CupLabelSettingsBuilder()..update(updates))._build();

  _$CupLabelSettings._(
      {required this.branchId,
      this.printerId,
      required this.size,
      required this.fields,
      required this.pickupMinutes,
      required this.moduleEnabled,
      required this.sizes,
      required this.availableFields})
      : super._();
  @override
  CupLabelSettings rebuild(void Function(CupLabelSettingsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CupLabelSettingsBuilder toBuilder() =>
      CupLabelSettingsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CupLabelSettings &&
        branchId == other.branchId &&
        printerId == other.printerId &&
        size == other.size &&
        fields == other.fields &&
        pickupMinutes == other.pickupMinutes &&
        moduleEnabled == other.moduleEnabled &&
        sizes == other.sizes &&
        availableFields == other.availableFields;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, printerId.hashCode);
    _$hash = $jc(_$hash, size.hashCode);
    _$hash = $jc(_$hash, fields.hashCode);
    _$hash = $jc(_$hash, pickupMinutes.hashCode);
    _$hash = $jc(_$hash, moduleEnabled.hashCode);
    _$hash = $jc(_$hash, sizes.hashCode);
    _$hash = $jc(_$hash, availableFields.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CupLabelSettings')
          ..add('branchId', branchId)
          ..add('printerId', printerId)
          ..add('size', size)
          ..add('fields', fields)
          ..add('pickupMinutes', pickupMinutes)
          ..add('moduleEnabled', moduleEnabled)
          ..add('sizes', sizes)
          ..add('availableFields', availableFields))
        .toString();
  }
}

class CupLabelSettingsBuilder
    implements Builder<CupLabelSettings, CupLabelSettingsBuilder> {
  _$CupLabelSettings? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _printerId;
  String? get printerId => _$this._printerId;
  set printerId(String? printerId) => _$this._printerId = printerId;

  CupLabelSettingsSizeEnum? _size;
  CupLabelSettingsSizeEnum? get size => _$this._size;
  set size(CupLabelSettingsSizeEnum? size) => _$this._size = size;

  ListBuilder<CupLabelSettingsFieldsEnum>? _fields;
  ListBuilder<CupLabelSettingsFieldsEnum> get fields =>
      _$this._fields ??= ListBuilder<CupLabelSettingsFieldsEnum>();
  set fields(ListBuilder<CupLabelSettingsFieldsEnum>? fields) =>
      _$this._fields = fields;

  int? _pickupMinutes;
  int? get pickupMinutes => _$this._pickupMinutes;
  set pickupMinutes(int? pickupMinutes) =>
      _$this._pickupMinutes = pickupMinutes;

  bool? _moduleEnabled;
  bool? get moduleEnabled => _$this._moduleEnabled;
  set moduleEnabled(bool? moduleEnabled) =>
      _$this._moduleEnabled = moduleEnabled;

  ListBuilder<String>? _sizes;
  ListBuilder<String> get sizes => _$this._sizes ??= ListBuilder<String>();
  set sizes(ListBuilder<String>? sizes) => _$this._sizes = sizes;

  ListBuilder<String>? _availableFields;
  ListBuilder<String> get availableFields =>
      _$this._availableFields ??= ListBuilder<String>();
  set availableFields(ListBuilder<String>? availableFields) =>
      _$this._availableFields = availableFields;

  CupLabelSettingsBuilder() {
    CupLabelSettings._defaults(this);
  }

  CupLabelSettingsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _printerId = $v.printerId;
      _size = $v.size;
      _fields = $v.fields.toBuilder();
      _pickupMinutes = $v.pickupMinutes;
      _moduleEnabled = $v.moduleEnabled;
      _sizes = $v.sizes.toBuilder();
      _availableFields = $v.availableFields.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CupLabelSettings other) {
    _$v = other as _$CupLabelSettings;
  }

  @override
  void update(void Function(CupLabelSettingsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CupLabelSettings build() => _build();

  _$CupLabelSettings _build() {
    _$CupLabelSettings _$result;
    try {
      _$result = _$v ??
          _$CupLabelSettings._(
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'CupLabelSettings', 'branchId'),
            printerId: printerId,
            size: BuiltValueNullFieldError.checkNotNull(
                size, r'CupLabelSettings', 'size'),
            fields: fields.build(),
            pickupMinutes: BuiltValueNullFieldError.checkNotNull(
                pickupMinutes, r'CupLabelSettings', 'pickupMinutes'),
            moduleEnabled: BuiltValueNullFieldError.checkNotNull(
                moduleEnabled, r'CupLabelSettings', 'moduleEnabled'),
            sizes: sizes.build(),
            availableFields: availableFields.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'fields';
        fields.build();

        _$failedField = 'sizes';
        sizes.build();
        _$failedField = 'availableFields';
        availableFields.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CupLabelSettings', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
