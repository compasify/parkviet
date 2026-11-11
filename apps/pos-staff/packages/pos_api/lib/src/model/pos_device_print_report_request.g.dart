// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_device_print_report_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PosDevicePrintReportRequestStatusEnum
    _$posDevicePrintReportRequestStatusEnum_printed =
    const PosDevicePrintReportRequestStatusEnum._('printed');
const PosDevicePrintReportRequestStatusEnum
    _$posDevicePrintReportRequestStatusEnum_failed =
    const PosDevicePrintReportRequestStatusEnum._('failed');

PosDevicePrintReportRequestStatusEnum
    _$posDevicePrintReportRequestStatusEnumValueOf(String name) {
  switch (name) {
    case 'printed':
      return _$posDevicePrintReportRequestStatusEnum_printed;
    case 'failed':
      return _$posDevicePrintReportRequestStatusEnum_failed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PosDevicePrintReportRequestStatusEnum>
    _$posDevicePrintReportRequestStatusEnumValues = BuiltSet<
        PosDevicePrintReportRequestStatusEnum>(const <PosDevicePrintReportRequestStatusEnum>[
  _$posDevicePrintReportRequestStatusEnum_printed,
  _$posDevicePrintReportRequestStatusEnum_failed,
]);

Serializer<PosDevicePrintReportRequestStatusEnum>
    _$posDevicePrintReportRequestStatusEnumSerializer =
    _$PosDevicePrintReportRequestStatusEnumSerializer();

class _$PosDevicePrintReportRequestStatusEnumSerializer
    implements PrimitiveSerializer<PosDevicePrintReportRequestStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'printed': 'printed',
    'failed': 'failed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'printed': 'printed',
    'failed': 'failed',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PosDevicePrintReportRequestStatusEnum
  ];
  @override
  final String wireName = 'PosDevicePrintReportRequestStatusEnum';

  @override
  Object serialize(
          Serializers serializers, PosDevicePrintReportRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PosDevicePrintReportRequestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PosDevicePrintReportRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PosDevicePrintReportRequest extends PosDevicePrintReportRequest {
  @override
  final int attempt;
  @override
  final PosDevicePrintReportRequestStatusEnum status;
  @override
  final String? error;

  factory _$PosDevicePrintReportRequest(
          [void Function(PosDevicePrintReportRequestBuilder)? updates]) =>
      (PosDevicePrintReportRequestBuilder()..update(updates))._build();

  _$PosDevicePrintReportRequest._(
      {required this.attempt, required this.status, this.error})
      : super._();
  @override
  PosDevicePrintReportRequest rebuild(
          void Function(PosDevicePrintReportRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosDevicePrintReportRequestBuilder toBuilder() =>
      PosDevicePrintReportRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosDevicePrintReportRequest &&
        attempt == other.attempt &&
        status == other.status &&
        error == other.error;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, attempt.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosDevicePrintReportRequest')
          ..add('attempt', attempt)
          ..add('status', status)
          ..add('error', error))
        .toString();
  }
}

class PosDevicePrintReportRequestBuilder
    implements
        Builder<PosDevicePrintReportRequest,
            PosDevicePrintReportRequestBuilder> {
  _$PosDevicePrintReportRequest? _$v;

  int? _attempt;
  int? get attempt => _$this._attempt;
  set attempt(int? attempt) => _$this._attempt = attempt;

  PosDevicePrintReportRequestStatusEnum? _status;
  PosDevicePrintReportRequestStatusEnum? get status => _$this._status;
  set status(PosDevicePrintReportRequestStatusEnum? status) =>
      _$this._status = status;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  PosDevicePrintReportRequestBuilder() {
    PosDevicePrintReportRequest._defaults(this);
  }

  PosDevicePrintReportRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _attempt = $v.attempt;
      _status = $v.status;
      _error = $v.error;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosDevicePrintReportRequest other) {
    _$v = other as _$PosDevicePrintReportRequest;
  }

  @override
  void update(void Function(PosDevicePrintReportRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosDevicePrintReportRequest build() => _build();

  _$PosDevicePrintReportRequest _build() {
    final _$result = _$v ??
        _$PosDevicePrintReportRequest._(
          attempt: BuiltValueNullFieldError.checkNotNull(
              attempt, r'PosDevicePrintReportRequest', 'attempt'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'PosDevicePrintReportRequest', 'status'),
          error: error,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
