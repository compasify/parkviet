// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_einvoice_settings_save_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum
    _$posEinvoiceSettingsSaveRequestEinvoiceTypeEnum_none =
    const PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum._('none');
const PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum
    _$posEinvoiceSettingsSaveRequestEinvoiceTypeEnum_cashRegister =
    const PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum._('cashRegister');
const PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum
    _$posEinvoiceSettingsSaveRequestEinvoiceTypeEnum_coded =
    const PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum._('coded');

PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum
    _$posEinvoiceSettingsSaveRequestEinvoiceTypeEnumValueOf(String name) {
  switch (name) {
    case 'none':
      return _$posEinvoiceSettingsSaveRequestEinvoiceTypeEnum_none;
    case 'cashRegister':
      return _$posEinvoiceSettingsSaveRequestEinvoiceTypeEnum_cashRegister;
    case 'coded':
      return _$posEinvoiceSettingsSaveRequestEinvoiceTypeEnum_coded;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum>
    _$posEinvoiceSettingsSaveRequestEinvoiceTypeEnumValues = BuiltSet<
        PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum>(const <PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum>[
  _$posEinvoiceSettingsSaveRequestEinvoiceTypeEnum_none,
  _$posEinvoiceSettingsSaveRequestEinvoiceTypeEnum_cashRegister,
  _$posEinvoiceSettingsSaveRequestEinvoiceTypeEnum_coded,
]);

Serializer<PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum>
    _$posEinvoiceSettingsSaveRequestEinvoiceTypeEnumSerializer =
    _$PosEinvoiceSettingsSaveRequestEinvoiceTypeEnumSerializer();

class _$PosEinvoiceSettingsSaveRequestEinvoiceTypeEnumSerializer
    implements
        PrimitiveSerializer<PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'none': 'none',
    'cashRegister': 'cash_register',
    'coded': 'coded',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'none': 'none',
    'cash_register': 'cashRegister',
    'coded': 'coded',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum
  ];
  @override
  final String wireName = 'PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PosEinvoiceSettingsSaveRequest extends PosEinvoiceSettingsSaveRequest {
  @override
  final PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum? einvoiceType;
  @override
  final String? branchId;
  @override
  final EinvoiceSettingInput? setting;

  factory _$PosEinvoiceSettingsSaveRequest(
          [void Function(PosEinvoiceSettingsSaveRequestBuilder)? updates]) =>
      (PosEinvoiceSettingsSaveRequestBuilder()..update(updates))._build();

  _$PosEinvoiceSettingsSaveRequest._(
      {this.einvoiceType, this.branchId, this.setting})
      : super._();
  @override
  PosEinvoiceSettingsSaveRequest rebuild(
          void Function(PosEinvoiceSettingsSaveRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosEinvoiceSettingsSaveRequestBuilder toBuilder() =>
      PosEinvoiceSettingsSaveRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosEinvoiceSettingsSaveRequest &&
        einvoiceType == other.einvoiceType &&
        branchId == other.branchId &&
        setting == other.setting;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, einvoiceType.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, setting.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosEinvoiceSettingsSaveRequest')
          ..add('einvoiceType', einvoiceType)
          ..add('branchId', branchId)
          ..add('setting', setting))
        .toString();
  }
}

class PosEinvoiceSettingsSaveRequestBuilder
    implements
        Builder<PosEinvoiceSettingsSaveRequest,
            PosEinvoiceSettingsSaveRequestBuilder> {
  _$PosEinvoiceSettingsSaveRequest? _$v;

  PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum? _einvoiceType;
  PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum? get einvoiceType =>
      _$this._einvoiceType;
  set einvoiceType(
          PosEinvoiceSettingsSaveRequestEinvoiceTypeEnum? einvoiceType) =>
      _$this._einvoiceType = einvoiceType;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  EinvoiceSettingInputBuilder? _setting;
  EinvoiceSettingInputBuilder get setting =>
      _$this._setting ??= EinvoiceSettingInputBuilder();
  set setting(EinvoiceSettingInputBuilder? setting) =>
      _$this._setting = setting;

  PosEinvoiceSettingsSaveRequestBuilder() {
    PosEinvoiceSettingsSaveRequest._defaults(this);
  }

  PosEinvoiceSettingsSaveRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _einvoiceType = $v.einvoiceType;
      _branchId = $v.branchId;
      _setting = $v.setting?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosEinvoiceSettingsSaveRequest other) {
    _$v = other as _$PosEinvoiceSettingsSaveRequest;
  }

  @override
  void update(void Function(PosEinvoiceSettingsSaveRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosEinvoiceSettingsSaveRequest build() => _build();

  _$PosEinvoiceSettingsSaveRequest _build() {
    _$PosEinvoiceSettingsSaveRequest _$result;
    try {
      _$result = _$v ??
          _$PosEinvoiceSettingsSaveRequest._(
            einvoiceType: einvoiceType,
            branchId: branchId,
            setting: _setting?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'setting';
        _setting?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosEinvoiceSettingsSaveRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
