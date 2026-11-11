// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_kitchen_settings_update_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum
    _$posKitchenSettingsUpdateRequestKitchenSendTriggerEnum_onComplete =
    const PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum._('onComplete');
const PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum
    _$posKitchenSettingsUpdateRequestKitchenSendTriggerEnum_manual =
    const PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum._('manual');

PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum
    _$posKitchenSettingsUpdateRequestKitchenSendTriggerEnumValueOf(
        String name) {
  switch (name) {
    case 'onComplete':
      return _$posKitchenSettingsUpdateRequestKitchenSendTriggerEnum_onComplete;
    case 'manual':
      return _$posKitchenSettingsUpdateRequestKitchenSendTriggerEnum_manual;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum>
    _$posKitchenSettingsUpdateRequestKitchenSendTriggerEnumValues = BuiltSet<
        PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum>(const <PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum>[
  _$posKitchenSettingsUpdateRequestKitchenSendTriggerEnum_onComplete,
  _$posKitchenSettingsUpdateRequestKitchenSendTriggerEnum_manual,
]);

Serializer<PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum>
    _$posKitchenSettingsUpdateRequestKitchenSendTriggerEnumSerializer =
    _$PosKitchenSettingsUpdateRequestKitchenSendTriggerEnumSerializer();

class _$PosKitchenSettingsUpdateRequestKitchenSendTriggerEnumSerializer
    implements
        PrimitiveSerializer<
            PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'onComplete': 'on_complete',
    'manual': 'manual',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'on_complete': 'onComplete',
    'manual': 'manual',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum
  ];
  @override
  final String wireName =
      'PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum';

  @override
  Object serialize(Serializers serializers,
          PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PosKitchenSettingsUpdateRequest
    extends PosKitchenSettingsUpdateRequest {
  @override
  final String branchId;
  @override
  final PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum?
      kitchenSendTrigger;
  @override
  final BuiltList<String>? voidReasons;

  factory _$PosKitchenSettingsUpdateRequest(
          [void Function(PosKitchenSettingsUpdateRequestBuilder)? updates]) =>
      (PosKitchenSettingsUpdateRequestBuilder()..update(updates))._build();

  _$PosKitchenSettingsUpdateRequest._(
      {required this.branchId, this.kitchenSendTrigger, this.voidReasons})
      : super._();
  @override
  PosKitchenSettingsUpdateRequest rebuild(
          void Function(PosKitchenSettingsUpdateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosKitchenSettingsUpdateRequestBuilder toBuilder() =>
      PosKitchenSettingsUpdateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosKitchenSettingsUpdateRequest &&
        branchId == other.branchId &&
        kitchenSendTrigger == other.kitchenSendTrigger &&
        voidReasons == other.voidReasons;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, kitchenSendTrigger.hashCode);
    _$hash = $jc(_$hash, voidReasons.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosKitchenSettingsUpdateRequest')
          ..add('branchId', branchId)
          ..add('kitchenSendTrigger', kitchenSendTrigger)
          ..add('voidReasons', voidReasons))
        .toString();
  }
}

class PosKitchenSettingsUpdateRequestBuilder
    implements
        Builder<PosKitchenSettingsUpdateRequest,
            PosKitchenSettingsUpdateRequestBuilder> {
  _$PosKitchenSettingsUpdateRequest? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum? _kitchenSendTrigger;
  PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum?
      get kitchenSendTrigger => _$this._kitchenSendTrigger;
  set kitchenSendTrigger(
          PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum?
              kitchenSendTrigger) =>
      _$this._kitchenSendTrigger = kitchenSendTrigger;

  ListBuilder<String>? _voidReasons;
  ListBuilder<String> get voidReasons =>
      _$this._voidReasons ??= ListBuilder<String>();
  set voidReasons(ListBuilder<String>? voidReasons) =>
      _$this._voidReasons = voidReasons;

  PosKitchenSettingsUpdateRequestBuilder() {
    PosKitchenSettingsUpdateRequest._defaults(this);
  }

  PosKitchenSettingsUpdateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _kitchenSendTrigger = $v.kitchenSendTrigger;
      _voidReasons = $v.voidReasons?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosKitchenSettingsUpdateRequest other) {
    _$v = other as _$PosKitchenSettingsUpdateRequest;
  }

  @override
  void update(void Function(PosKitchenSettingsUpdateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosKitchenSettingsUpdateRequest build() => _build();

  _$PosKitchenSettingsUpdateRequest _build() {
    _$PosKitchenSettingsUpdateRequest _$result;
    try {
      _$result = _$v ??
          _$PosKitchenSettingsUpdateRequest._(
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'PosKitchenSettingsUpdateRequest', 'branchId'),
            kitchenSendTrigger: kitchenSendTrigger,
            voidReasons: _voidReasons?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'voidReasons';
        _voidReasons?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosKitchenSettingsUpdateRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
