// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_order_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const KioskOrderInputPaymentEnum _$kioskOrderInputPaymentEnum_vietqr =
    const KioskOrderInputPaymentEnum._('vietqr');
const KioskOrderInputPaymentEnum _$kioskOrderInputPaymentEnum_counter =
    const KioskOrderInputPaymentEnum._('counter');

KioskOrderInputPaymentEnum _$kioskOrderInputPaymentEnumValueOf(String name) {
  switch (name) {
    case 'vietqr':
      return _$kioskOrderInputPaymentEnum_vietqr;
    case 'counter':
      return _$kioskOrderInputPaymentEnum_counter;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<KioskOrderInputPaymentEnum> _$kioskOrderInputPaymentEnumValues =
    BuiltSet<KioskOrderInputPaymentEnum>(const <KioskOrderInputPaymentEnum>[
  _$kioskOrderInputPaymentEnum_vietqr,
  _$kioskOrderInputPaymentEnum_counter,
]);

Serializer<KioskOrderInputPaymentEnum> _$kioskOrderInputPaymentEnumSerializer =
    _$KioskOrderInputPaymentEnumSerializer();

class _$KioskOrderInputPaymentEnumSerializer
    implements PrimitiveSerializer<KioskOrderInputPaymentEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'vietqr': 'vietqr',
    'counter': 'counter',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'vietqr': 'vietqr',
    'counter': 'counter',
  };

  @override
  final Iterable<Type> types = const <Type>[KioskOrderInputPaymentEnum];
  @override
  final String wireName = 'KioskOrderInputPaymentEnum';

  @override
  Object serialize(Serializers serializers, KioskOrderInputPaymentEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  KioskOrderInputPaymentEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      KioskOrderInputPaymentEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$KioskOrderInput extends KioskOrderInput {
  @override
  final KioskOrderInputPaymentEnum payment;
  @override
  final BuiltList<KioskOrderItemInput> items;

  factory _$KioskOrderInput([void Function(KioskOrderInputBuilder)? updates]) =>
      (KioskOrderInputBuilder()..update(updates))._build();

  _$KioskOrderInput._({required this.payment, required this.items}) : super._();
  @override
  KioskOrderInput rebuild(void Function(KioskOrderInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KioskOrderInputBuilder toBuilder() => KioskOrderInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KioskOrderInput &&
        payment == other.payment &&
        items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, payment.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KioskOrderInput')
          ..add('payment', payment)
          ..add('items', items))
        .toString();
  }
}

class KioskOrderInputBuilder
    implements Builder<KioskOrderInput, KioskOrderInputBuilder> {
  _$KioskOrderInput? _$v;

  KioskOrderInputPaymentEnum? _payment;
  KioskOrderInputPaymentEnum? get payment => _$this._payment;
  set payment(KioskOrderInputPaymentEnum? payment) => _$this._payment = payment;

  ListBuilder<KioskOrderItemInput>? _items;
  ListBuilder<KioskOrderItemInput> get items =>
      _$this._items ??= ListBuilder<KioskOrderItemInput>();
  set items(ListBuilder<KioskOrderItemInput>? items) => _$this._items = items;

  KioskOrderInputBuilder() {
    KioskOrderInput._defaults(this);
  }

  KioskOrderInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _payment = $v.payment;
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KioskOrderInput other) {
    _$v = other as _$KioskOrderInput;
  }

  @override
  void update(void Function(KioskOrderInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KioskOrderInput build() => _build();

  _$KioskOrderInput _build() {
    _$KioskOrderInput _$result;
    try {
      _$result = _$v ??
          _$KioskOrderInput._(
            payment: BuiltValueNullFieldError.checkNotNull(
                payment, r'KioskOrderInput', 'payment'),
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KioskOrderInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
