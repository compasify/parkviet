// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prebill_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PrebillInputUnmaskEnum _$prebillInputUnmaskEnum_true_ =
    const PrebillInputUnmaskEnum._('true_');
const PrebillInputUnmaskEnum _$prebillInputUnmaskEnum_false_ =
    const PrebillInputUnmaskEnum._('false_');

PrebillInputUnmaskEnum _$prebillInputUnmaskEnumValueOf(String name) {
  switch (name) {
    case 'true_':
      return _$prebillInputUnmaskEnum_true_;
    case 'false_':
      return _$prebillInputUnmaskEnum_false_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PrebillInputUnmaskEnum> _$prebillInputUnmaskEnumValues =
    BuiltSet<PrebillInputUnmaskEnum>(const <PrebillInputUnmaskEnum>[
  _$prebillInputUnmaskEnum_true_,
  _$prebillInputUnmaskEnum_false_,
]);

Serializer<PrebillInputUnmaskEnum> _$prebillInputUnmaskEnumSerializer =
    _$PrebillInputUnmaskEnumSerializer();

class _$PrebillInputUnmaskEnumSerializer
    implements PrimitiveSerializer<PrebillInputUnmaskEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'true_': 'true',
    'false_': 'false',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'true': 'true_',
    'false': 'false_',
  };

  @override
  final Iterable<Type> types = const <Type>[PrebillInputUnmaskEnum];
  @override
  final String wireName = 'PrebillInputUnmaskEnum';

  @override
  Object serialize(Serializers serializers, PrebillInputUnmaskEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PrebillInputUnmaskEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PrebillInputUnmaskEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PrebillInput extends PrebillInput {
  @override
  final String? approvalId;
  @override
  final String? printerId;
  @override
  final String? receiptTemplateId;
  @override
  final PrebillInputUnmaskEnum? unmask;

  factory _$PrebillInput([void Function(PrebillInputBuilder)? updates]) =>
      (PrebillInputBuilder()..update(updates))._build();

  _$PrebillInput._(
      {this.approvalId, this.printerId, this.receiptTemplateId, this.unmask})
      : super._();
  @override
  PrebillInput rebuild(void Function(PrebillInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrebillInputBuilder toBuilder() => PrebillInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrebillInput &&
        approvalId == other.approvalId &&
        printerId == other.printerId &&
        receiptTemplateId == other.receiptTemplateId &&
        unmask == other.unmask;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, approvalId.hashCode);
    _$hash = $jc(_$hash, printerId.hashCode);
    _$hash = $jc(_$hash, receiptTemplateId.hashCode);
    _$hash = $jc(_$hash, unmask.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrebillInput')
          ..add('approvalId', approvalId)
          ..add('printerId', printerId)
          ..add('receiptTemplateId', receiptTemplateId)
          ..add('unmask', unmask))
        .toString();
  }
}

class PrebillInputBuilder
    implements Builder<PrebillInput, PrebillInputBuilder> {
  _$PrebillInput? _$v;

  String? _approvalId;
  String? get approvalId => _$this._approvalId;
  set approvalId(String? approvalId) => _$this._approvalId = approvalId;

  String? _printerId;
  String? get printerId => _$this._printerId;
  set printerId(String? printerId) => _$this._printerId = printerId;

  String? _receiptTemplateId;
  String? get receiptTemplateId => _$this._receiptTemplateId;
  set receiptTemplateId(String? receiptTemplateId) =>
      _$this._receiptTemplateId = receiptTemplateId;

  PrebillInputUnmaskEnum? _unmask;
  PrebillInputUnmaskEnum? get unmask => _$this._unmask;
  set unmask(PrebillInputUnmaskEnum? unmask) => _$this._unmask = unmask;

  PrebillInputBuilder() {
    PrebillInput._defaults(this);
  }

  PrebillInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _approvalId = $v.approvalId;
      _printerId = $v.printerId;
      _receiptTemplateId = $v.receiptTemplateId;
      _unmask = $v.unmask;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrebillInput other) {
    _$v = other as _$PrebillInput;
  }

  @override
  void update(void Function(PrebillInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrebillInput build() => _build();

  _$PrebillInput _build() {
    final _$result = _$v ??
        _$PrebillInput._(
          approvalId: approvalId,
          printerId: printerId,
          receiptTemplateId: receiptTemplateId,
          unmask: unmask,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
