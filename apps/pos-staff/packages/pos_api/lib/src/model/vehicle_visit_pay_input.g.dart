// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_visit_pay_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const VehicleVisitPayInputPayoutMethodEnum
    _$vehicleVisitPayInputPayoutMethodEnum_cash =
    const VehicleVisitPayInputPayoutMethodEnum._('cash');
const VehicleVisitPayInputPayoutMethodEnum
    _$vehicleVisitPayInputPayoutMethodEnum_transfer =
    const VehicleVisitPayInputPayoutMethodEnum._('transfer');

VehicleVisitPayInputPayoutMethodEnum
    _$vehicleVisitPayInputPayoutMethodEnumValueOf(String name) {
  switch (name) {
    case 'cash':
      return _$vehicleVisitPayInputPayoutMethodEnum_cash;
    case 'transfer':
      return _$vehicleVisitPayInputPayoutMethodEnum_transfer;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<VehicleVisitPayInputPayoutMethodEnum>
    _$vehicleVisitPayInputPayoutMethodEnumValues = BuiltSet<
        VehicleVisitPayInputPayoutMethodEnum>(const <VehicleVisitPayInputPayoutMethodEnum>[
  _$vehicleVisitPayInputPayoutMethodEnum_cash,
  _$vehicleVisitPayInputPayoutMethodEnum_transfer,
]);

Serializer<VehicleVisitPayInputPayoutMethodEnum>
    _$vehicleVisitPayInputPayoutMethodEnumSerializer =
    _$VehicleVisitPayInputPayoutMethodEnumSerializer();

class _$VehicleVisitPayInputPayoutMethodEnumSerializer
    implements PrimitiveSerializer<VehicleVisitPayInputPayoutMethodEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'cash': 'cash',
    'transfer': 'transfer',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'cash': 'cash',
    'transfer': 'transfer',
  };

  @override
  final Iterable<Type> types = const <Type>[
    VehicleVisitPayInputPayoutMethodEnum
  ];
  @override
  final String wireName = 'VehicleVisitPayInputPayoutMethodEnum';

  @override
  Object serialize(
          Serializers serializers, VehicleVisitPayInputPayoutMethodEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  VehicleVisitPayInputPayoutMethodEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      VehicleVisitPayInputPayoutMethodEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$VehicleVisitPayInput extends VehicleVisitPayInput {
  @override
  final VehicleVisitPayInputPayoutMethodEnum payoutMethod;
  @override
  final String? transferReference;

  factory _$VehicleVisitPayInput(
          [void Function(VehicleVisitPayInputBuilder)? updates]) =>
      (VehicleVisitPayInputBuilder()..update(updates))._build();

  _$VehicleVisitPayInput._({required this.payoutMethod, this.transferReference})
      : super._();
  @override
  VehicleVisitPayInput rebuild(
          void Function(VehicleVisitPayInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VehicleVisitPayInputBuilder toBuilder() =>
      VehicleVisitPayInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VehicleVisitPayInput &&
        payoutMethod == other.payoutMethod &&
        transferReference == other.transferReference;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, payoutMethod.hashCode);
    _$hash = $jc(_$hash, transferReference.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VehicleVisitPayInput')
          ..add('payoutMethod', payoutMethod)
          ..add('transferReference', transferReference))
        .toString();
  }
}

class VehicleVisitPayInputBuilder
    implements Builder<VehicleVisitPayInput, VehicleVisitPayInputBuilder> {
  _$VehicleVisitPayInput? _$v;

  VehicleVisitPayInputPayoutMethodEnum? _payoutMethod;
  VehicleVisitPayInputPayoutMethodEnum? get payoutMethod =>
      _$this._payoutMethod;
  set payoutMethod(VehicleVisitPayInputPayoutMethodEnum? payoutMethod) =>
      _$this._payoutMethod = payoutMethod;

  String? _transferReference;
  String? get transferReference => _$this._transferReference;
  set transferReference(String? transferReference) =>
      _$this._transferReference = transferReference;

  VehicleVisitPayInputBuilder() {
    VehicleVisitPayInput._defaults(this);
  }

  VehicleVisitPayInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _payoutMethod = $v.payoutMethod;
      _transferReference = $v.transferReference;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VehicleVisitPayInput other) {
    _$v = other as _$VehicleVisitPayInput;
  }

  @override
  void update(void Function(VehicleVisitPayInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VehicleVisitPayInput build() => _build();

  _$VehicleVisitPayInput _build() {
    final _$result = _$v ??
        _$VehicleVisitPayInput._(
          payoutMethod: BuiltValueNullFieldError.checkNotNull(
              payoutMethod, r'VehicleVisitPayInput', 'payoutMethod'),
          transferReference: transferReference,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
