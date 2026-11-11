// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PaymentRequestStatusEnum _$paymentRequestStatusEnum_open =
    const PaymentRequestStatusEnum._('open');
const PaymentRequestStatusEnum _$paymentRequestStatusEnum_done =
    const PaymentRequestStatusEnum._('done');
const PaymentRequestStatusEnum _$paymentRequestStatusEnum_canceled =
    const PaymentRequestStatusEnum._('canceled');

PaymentRequestStatusEnum _$paymentRequestStatusEnumValueOf(String name) {
  switch (name) {
    case 'open':
      return _$paymentRequestStatusEnum_open;
    case 'done':
      return _$paymentRequestStatusEnum_done;
    case 'canceled':
      return _$paymentRequestStatusEnum_canceled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PaymentRequestStatusEnum> _$paymentRequestStatusEnumValues =
    BuiltSet<PaymentRequestStatusEnum>(const <PaymentRequestStatusEnum>[
  _$paymentRequestStatusEnum_open,
  _$paymentRequestStatusEnum_done,
  _$paymentRequestStatusEnum_canceled,
]);

Serializer<PaymentRequestStatusEnum> _$paymentRequestStatusEnumSerializer =
    _$PaymentRequestStatusEnumSerializer();

class _$PaymentRequestStatusEnumSerializer
    implements PrimitiveSerializer<PaymentRequestStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'open': 'open',
    'done': 'done',
    'canceled': 'canceled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'open': 'open',
    'done': 'done',
    'canceled': 'canceled',
  };

  @override
  final Iterable<Type> types = const <Type>[PaymentRequestStatusEnum];
  @override
  final String wireName = 'PaymentRequestStatusEnum';

  @override
  Object serialize(Serializers serializers, PaymentRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PaymentRequestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PaymentRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PaymentRequest extends PaymentRequest {
  @override
  final String id;
  @override
  final PaymentRequestStatusEnum status;
  @override
  final String? note;
  @override
  final String requestedById;
  @override
  final DateTime requestedAt;
  @override
  final DateTime? resolvedAt;

  factory _$PaymentRequest([void Function(PaymentRequestBuilder)? updates]) =>
      (PaymentRequestBuilder()..update(updates))._build();

  _$PaymentRequest._(
      {required this.id,
      required this.status,
      this.note,
      required this.requestedById,
      required this.requestedAt,
      this.resolvedAt})
      : super._();
  @override
  PaymentRequest rebuild(void Function(PaymentRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentRequestBuilder toBuilder() => PaymentRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentRequest &&
        id == other.id &&
        status == other.status &&
        note == other.note &&
        requestedById == other.requestedById &&
        requestedAt == other.requestedAt &&
        resolvedAt == other.resolvedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, requestedById.hashCode);
    _$hash = $jc(_$hash, requestedAt.hashCode);
    _$hash = $jc(_$hash, resolvedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PaymentRequest')
          ..add('id', id)
          ..add('status', status)
          ..add('note', note)
          ..add('requestedById', requestedById)
          ..add('requestedAt', requestedAt)
          ..add('resolvedAt', resolvedAt))
        .toString();
  }
}

class PaymentRequestBuilder
    implements Builder<PaymentRequest, PaymentRequestBuilder> {
  _$PaymentRequest? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  PaymentRequestStatusEnum? _status;
  PaymentRequestStatusEnum? get status => _$this._status;
  set status(PaymentRequestStatusEnum? status) => _$this._status = status;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  String? _requestedById;
  String? get requestedById => _$this._requestedById;
  set requestedById(String? requestedById) =>
      _$this._requestedById = requestedById;

  DateTime? _requestedAt;
  DateTime? get requestedAt => _$this._requestedAt;
  set requestedAt(DateTime? requestedAt) => _$this._requestedAt = requestedAt;

  DateTime? _resolvedAt;
  DateTime? get resolvedAt => _$this._resolvedAt;
  set resolvedAt(DateTime? resolvedAt) => _$this._resolvedAt = resolvedAt;

  PaymentRequestBuilder() {
    PaymentRequest._defaults(this);
  }

  PaymentRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _status = $v.status;
      _note = $v.note;
      _requestedById = $v.requestedById;
      _requestedAt = $v.requestedAt;
      _resolvedAt = $v.resolvedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentRequest other) {
    _$v = other as _$PaymentRequest;
  }

  @override
  void update(void Function(PaymentRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentRequest build() => _build();

  _$PaymentRequest _build() {
    final _$result = _$v ??
        _$PaymentRequest._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'PaymentRequest', 'id'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'PaymentRequest', 'status'),
          note: note,
          requestedById: BuiltValueNullFieldError.checkNotNull(
              requestedById, r'PaymentRequest', 'requestedById'),
          requestedAt: BuiltValueNullFieldError.checkNotNull(
              requestedAt, r'PaymentRequest', 'requestedAt'),
          resolvedAt: resolvedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
