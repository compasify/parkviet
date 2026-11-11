// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_print_job_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PosPrintJobCreateRequestKindEnum
    _$posPrintJobCreateRequestKindEnum_receipt =
    const PosPrintJobCreateRequestKindEnum._('receipt');
const PosPrintJobCreateRequestKindEnum
    _$posPrintJobCreateRequestKindEnum_prebill =
    const PosPrintJobCreateRequestKindEnum._('prebill');

PosPrintJobCreateRequestKindEnum _$posPrintJobCreateRequestKindEnumValueOf(
    String name) {
  switch (name) {
    case 'receipt':
      return _$posPrintJobCreateRequestKindEnum_receipt;
    case 'prebill':
      return _$posPrintJobCreateRequestKindEnum_prebill;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PosPrintJobCreateRequestKindEnum>
    _$posPrintJobCreateRequestKindEnumValues = BuiltSet<
        PosPrintJobCreateRequestKindEnum>(const <PosPrintJobCreateRequestKindEnum>[
  _$posPrintJobCreateRequestKindEnum_receipt,
  _$posPrintJobCreateRequestKindEnum_prebill,
]);

Serializer<PosPrintJobCreateRequestKindEnum>
    _$posPrintJobCreateRequestKindEnumSerializer =
    _$PosPrintJobCreateRequestKindEnumSerializer();

class _$PosPrintJobCreateRequestKindEnumSerializer
    implements PrimitiveSerializer<PosPrintJobCreateRequestKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'receipt': 'receipt',
    'prebill': 'prebill',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'receipt': 'receipt',
    'prebill': 'prebill',
  };

  @override
  final Iterable<Type> types = const <Type>[PosPrintJobCreateRequestKindEnum];
  @override
  final String wireName = 'PosPrintJobCreateRequestKindEnum';

  @override
  Object serialize(
          Serializers serializers, PosPrintJobCreateRequestKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PosPrintJobCreateRequestKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PosPrintJobCreateRequestKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PosPrintJobCreateRequest extends PosPrintJobCreateRequest {
  @override
  final PosPrintJobCreateRequestKindEnum kind;
  @override
  final String printerId;
  @override
  final String? receiptId;
  @override
  final String? workspaceId;
  @override
  final String? receiptTemplateId;
  @override
  final String? templateVersion;
  @override
  final String? paper;

  factory _$PosPrintJobCreateRequest(
          [void Function(PosPrintJobCreateRequestBuilder)? updates]) =>
      (PosPrintJobCreateRequestBuilder()..update(updates))._build();

  _$PosPrintJobCreateRequest._(
      {required this.kind,
      required this.printerId,
      this.receiptId,
      this.workspaceId,
      this.receiptTemplateId,
      this.templateVersion,
      this.paper})
      : super._();
  @override
  PosPrintJobCreateRequest rebuild(
          void Function(PosPrintJobCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosPrintJobCreateRequestBuilder toBuilder() =>
      PosPrintJobCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosPrintJobCreateRequest &&
        kind == other.kind &&
        printerId == other.printerId &&
        receiptId == other.receiptId &&
        workspaceId == other.workspaceId &&
        receiptTemplateId == other.receiptTemplateId &&
        templateVersion == other.templateVersion &&
        paper == other.paper;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, printerId.hashCode);
    _$hash = $jc(_$hash, receiptId.hashCode);
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, receiptTemplateId.hashCode);
    _$hash = $jc(_$hash, templateVersion.hashCode);
    _$hash = $jc(_$hash, paper.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosPrintJobCreateRequest')
          ..add('kind', kind)
          ..add('printerId', printerId)
          ..add('receiptId', receiptId)
          ..add('workspaceId', workspaceId)
          ..add('receiptTemplateId', receiptTemplateId)
          ..add('templateVersion', templateVersion)
          ..add('paper', paper))
        .toString();
  }
}

class PosPrintJobCreateRequestBuilder
    implements
        Builder<PosPrintJobCreateRequest, PosPrintJobCreateRequestBuilder> {
  _$PosPrintJobCreateRequest? _$v;

  PosPrintJobCreateRequestKindEnum? _kind;
  PosPrintJobCreateRequestKindEnum? get kind => _$this._kind;
  set kind(PosPrintJobCreateRequestKindEnum? kind) => _$this._kind = kind;

  String? _printerId;
  String? get printerId => _$this._printerId;
  set printerId(String? printerId) => _$this._printerId = printerId;

  String? _receiptId;
  String? get receiptId => _$this._receiptId;
  set receiptId(String? receiptId) => _$this._receiptId = receiptId;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  String? _receiptTemplateId;
  String? get receiptTemplateId => _$this._receiptTemplateId;
  set receiptTemplateId(String? receiptTemplateId) =>
      _$this._receiptTemplateId = receiptTemplateId;

  String? _templateVersion;
  String? get templateVersion => _$this._templateVersion;
  set templateVersion(String? templateVersion) =>
      _$this._templateVersion = templateVersion;

  String? _paper;
  String? get paper => _$this._paper;
  set paper(String? paper) => _$this._paper = paper;

  PosPrintJobCreateRequestBuilder() {
    PosPrintJobCreateRequest._defaults(this);
  }

  PosPrintJobCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _printerId = $v.printerId;
      _receiptId = $v.receiptId;
      _workspaceId = $v.workspaceId;
      _receiptTemplateId = $v.receiptTemplateId;
      _templateVersion = $v.templateVersion;
      _paper = $v.paper;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosPrintJobCreateRequest other) {
    _$v = other as _$PosPrintJobCreateRequest;
  }

  @override
  void update(void Function(PosPrintJobCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosPrintJobCreateRequest build() => _build();

  _$PosPrintJobCreateRequest _build() {
    final _$result = _$v ??
        _$PosPrintJobCreateRequest._(
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'PosPrintJobCreateRequest', 'kind'),
          printerId: BuiltValueNullFieldError.checkNotNull(
              printerId, r'PosPrintJobCreateRequest', 'printerId'),
          receiptId: receiptId,
          workspaceId: workspaceId,
          receiptTemplateId: receiptTemplateId,
          templateVersion: templateVersion,
          paper: paper,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
