// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_request_resolve_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PaymentRequestResolveInputStatusEnum
    _$paymentRequestResolveInputStatusEnum_done =
    const PaymentRequestResolveInputStatusEnum._('done');
const PaymentRequestResolveInputStatusEnum
    _$paymentRequestResolveInputStatusEnum_canceled =
    const PaymentRequestResolveInputStatusEnum._('canceled');

PaymentRequestResolveInputStatusEnum
    _$paymentRequestResolveInputStatusEnumValueOf(String name) {
  switch (name) {
    case 'done':
      return _$paymentRequestResolveInputStatusEnum_done;
    case 'canceled':
      return _$paymentRequestResolveInputStatusEnum_canceled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PaymentRequestResolveInputStatusEnum>
    _$paymentRequestResolveInputStatusEnumValues = BuiltSet<
        PaymentRequestResolveInputStatusEnum>(const <PaymentRequestResolveInputStatusEnum>[
  _$paymentRequestResolveInputStatusEnum_done,
  _$paymentRequestResolveInputStatusEnum_canceled,
]);

Serializer<PaymentRequestResolveInputStatusEnum>
    _$paymentRequestResolveInputStatusEnumSerializer =
    _$PaymentRequestResolveInputStatusEnumSerializer();

class _$PaymentRequestResolveInputStatusEnumSerializer
    implements PrimitiveSerializer<PaymentRequestResolveInputStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'done': 'done',
    'canceled': 'canceled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'done': 'done',
    'canceled': 'canceled',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PaymentRequestResolveInputStatusEnum
  ];
  @override
  final String wireName = 'PaymentRequestResolveInputStatusEnum';

  @override
  Object serialize(
          Serializers serializers, PaymentRequestResolveInputStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PaymentRequestResolveInputStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PaymentRequestResolveInputStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PaymentRequestResolveInput extends PaymentRequestResolveInput {
  @override
  final PaymentRequestResolveInputStatusEnum status;

  factory _$PaymentRequestResolveInput(
          [void Function(PaymentRequestResolveInputBuilder)? updates]) =>
      (PaymentRequestResolveInputBuilder()..update(updates))._build();

  _$PaymentRequestResolveInput._({required this.status}) : super._();
  @override
  PaymentRequestResolveInput rebuild(
          void Function(PaymentRequestResolveInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentRequestResolveInputBuilder toBuilder() =>
      PaymentRequestResolveInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentRequestResolveInput && status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PaymentRequestResolveInput')
          ..add('status', status))
        .toString();
  }
}

class PaymentRequestResolveInputBuilder
    implements
        Builder<PaymentRequestResolveInput, PaymentRequestResolveInputBuilder> {
  _$PaymentRequestResolveInput? _$v;

  PaymentRequestResolveInputStatusEnum? _status;
  PaymentRequestResolveInputStatusEnum? get status => _$this._status;
  set status(PaymentRequestResolveInputStatusEnum? status) =>
      _$this._status = status;

  PaymentRequestResolveInputBuilder() {
    PaymentRequestResolveInput._defaults(this);
  }

  PaymentRequestResolveInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentRequestResolveInput other) {
    _$v = other as _$PaymentRequestResolveInput;
  }

  @override
  void update(void Function(PaymentRequestResolveInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentRequestResolveInput build() => _build();

  _$PaymentRequestResolveInput _build() {
    final _$result = _$v ??
        _$PaymentRequestResolveInput._(
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'PaymentRequestResolveInput', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
