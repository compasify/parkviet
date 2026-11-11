// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_receipt_print_void_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PosReceiptPrintVoidRequestReasonEnum
    _$posReceiptPrintVoidRequestReasonEnum_mixedContent =
    const PosReceiptPrintVoidRequestReasonEnum._('mixedContent');
const PosReceiptPrintVoidRequestReasonEnum
    _$posReceiptPrintVoidRequestReasonEnum_noAddress =
    const PosReceiptPrintVoidRequestReasonEnum._('noAddress');
const PosReceiptPrintVoidRequestReasonEnum
    _$posReceiptPrintVoidRequestReasonEnum_printerError =
    const PosReceiptPrintVoidRequestReasonEnum._('printerError');
const PosReceiptPrintVoidRequestReasonEnum
    _$posReceiptPrintVoidRequestReasonEnum_notSent =
    const PosReceiptPrintVoidRequestReasonEnum._('notSent');

PosReceiptPrintVoidRequestReasonEnum
    _$posReceiptPrintVoidRequestReasonEnumValueOf(String name) {
  switch (name) {
    case 'mixedContent':
      return _$posReceiptPrintVoidRequestReasonEnum_mixedContent;
    case 'noAddress':
      return _$posReceiptPrintVoidRequestReasonEnum_noAddress;
    case 'printerError':
      return _$posReceiptPrintVoidRequestReasonEnum_printerError;
    case 'notSent':
      return _$posReceiptPrintVoidRequestReasonEnum_notSent;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PosReceiptPrintVoidRequestReasonEnum>
    _$posReceiptPrintVoidRequestReasonEnumValues = BuiltSet<
        PosReceiptPrintVoidRequestReasonEnum>(const <PosReceiptPrintVoidRequestReasonEnum>[
  _$posReceiptPrintVoidRequestReasonEnum_mixedContent,
  _$posReceiptPrintVoidRequestReasonEnum_noAddress,
  _$posReceiptPrintVoidRequestReasonEnum_printerError,
  _$posReceiptPrintVoidRequestReasonEnum_notSent,
]);

Serializer<PosReceiptPrintVoidRequestReasonEnum>
    _$posReceiptPrintVoidRequestReasonEnumSerializer =
    _$PosReceiptPrintVoidRequestReasonEnumSerializer();

class _$PosReceiptPrintVoidRequestReasonEnumSerializer
    implements PrimitiveSerializer<PosReceiptPrintVoidRequestReasonEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'mixedContent': 'mixed_content',
    'noAddress': 'no_address',
    'printerError': 'printer_error',
    'notSent': 'not_sent',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'mixed_content': 'mixedContent',
    'no_address': 'noAddress',
    'printer_error': 'printerError',
    'not_sent': 'notSent',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PosReceiptPrintVoidRequestReasonEnum
  ];
  @override
  final String wireName = 'PosReceiptPrintVoidRequestReasonEnum';

  @override
  Object serialize(
          Serializers serializers, PosReceiptPrintVoidRequestReasonEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PosReceiptPrintVoidRequestReasonEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PosReceiptPrintVoidRequestReasonEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PosReceiptPrintVoidRequest extends PosReceiptPrintVoidRequest {
  @override
  final PosReceiptPrintVoidRequestReasonEnum reason;

  factory _$PosReceiptPrintVoidRequest(
          [void Function(PosReceiptPrintVoidRequestBuilder)? updates]) =>
      (PosReceiptPrintVoidRequestBuilder()..update(updates))._build();

  _$PosReceiptPrintVoidRequest._({required this.reason}) : super._();
  @override
  PosReceiptPrintVoidRequest rebuild(
          void Function(PosReceiptPrintVoidRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosReceiptPrintVoidRequestBuilder toBuilder() =>
      PosReceiptPrintVoidRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosReceiptPrintVoidRequest && reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosReceiptPrintVoidRequest')
          ..add('reason', reason))
        .toString();
  }
}

class PosReceiptPrintVoidRequestBuilder
    implements
        Builder<PosReceiptPrintVoidRequest, PosReceiptPrintVoidRequestBuilder> {
  _$PosReceiptPrintVoidRequest? _$v;

  PosReceiptPrintVoidRequestReasonEnum? _reason;
  PosReceiptPrintVoidRequestReasonEnum? get reason => _$this._reason;
  set reason(PosReceiptPrintVoidRequestReasonEnum? reason) =>
      _$this._reason = reason;

  PosReceiptPrintVoidRequestBuilder() {
    PosReceiptPrintVoidRequest._defaults(this);
  }

  PosReceiptPrintVoidRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosReceiptPrintVoidRequest other) {
    _$v = other as _$PosReceiptPrintVoidRequest;
  }

  @override
  void update(void Function(PosReceiptPrintVoidRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosReceiptPrintVoidRequest build() => _build();

  _$PosReceiptPrintVoidRequest _build() {
    final _$result = _$v ??
        _$PosReceiptPrintVoidRequest._(
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'PosReceiptPrintVoidRequest', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
