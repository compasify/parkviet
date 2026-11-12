// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_sale_resolve_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OfflineSaleResolveInputModeEnum
    _$offlineSaleResolveInputModeEnum_acceptCollected =
    const OfflineSaleResolveInputModeEnum._('acceptCollected');
const OfflineSaleResolveInputModeEnum
    _$offlineSaleResolveInputModeEnum_currentPrice =
    const OfflineSaleResolveInputModeEnum._('currentPrice');
const OfflineSaleResolveInputModeEnum _$offlineSaleResolveInputModeEnum_edited =
    const OfflineSaleResolveInputModeEnum._('edited');

OfflineSaleResolveInputModeEnum _$offlineSaleResolveInputModeEnumValueOf(
    String name) {
  switch (name) {
    case 'acceptCollected':
      return _$offlineSaleResolveInputModeEnum_acceptCollected;
    case 'currentPrice':
      return _$offlineSaleResolveInputModeEnum_currentPrice;
    case 'edited':
      return _$offlineSaleResolveInputModeEnum_edited;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OfflineSaleResolveInputModeEnum>
    _$offlineSaleResolveInputModeEnumValues = BuiltSet<
        OfflineSaleResolveInputModeEnum>(const <OfflineSaleResolveInputModeEnum>[
  _$offlineSaleResolveInputModeEnum_acceptCollected,
  _$offlineSaleResolveInputModeEnum_currentPrice,
  _$offlineSaleResolveInputModeEnum_edited,
]);

Serializer<OfflineSaleResolveInputModeEnum>
    _$offlineSaleResolveInputModeEnumSerializer =
    _$OfflineSaleResolveInputModeEnumSerializer();

class _$OfflineSaleResolveInputModeEnumSerializer
    implements PrimitiveSerializer<OfflineSaleResolveInputModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'acceptCollected': 'accept_collected',
    'currentPrice': 'current_price',
    'edited': 'edited',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'accept_collected': 'acceptCollected',
    'current_price': 'currentPrice',
    'edited': 'edited',
  };

  @override
  final Iterable<Type> types = const <Type>[OfflineSaleResolveInputModeEnum];
  @override
  final String wireName = 'OfflineSaleResolveInputModeEnum';

  @override
  Object serialize(
          Serializers serializers, OfflineSaleResolveInputModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OfflineSaleResolveInputModeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OfflineSaleResolveInputModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OfflineSaleResolveInput extends OfflineSaleResolveInput {
  @override
  final OfflineSaleResolveInputModeEnum mode;
  @override
  final String? approvalId;
  @override
  final String? handedAmount;
  @override
  final BuiltList<OfflineSaleLine>? lines;
  @override
  final String? note;

  factory _$OfflineSaleResolveInput(
          [void Function(OfflineSaleResolveInputBuilder)? updates]) =>
      (OfflineSaleResolveInputBuilder()..update(updates))._build();

  _$OfflineSaleResolveInput._(
      {required this.mode,
      this.approvalId,
      this.handedAmount,
      this.lines,
      this.note})
      : super._();
  @override
  OfflineSaleResolveInput rebuild(
          void Function(OfflineSaleResolveInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OfflineSaleResolveInputBuilder toBuilder() =>
      OfflineSaleResolveInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OfflineSaleResolveInput &&
        mode == other.mode &&
        approvalId == other.approvalId &&
        handedAmount == other.handedAmount &&
        lines == other.lines &&
        note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, mode.hashCode);
    _$hash = $jc(_$hash, approvalId.hashCode);
    _$hash = $jc(_$hash, handedAmount.hashCode);
    _$hash = $jc(_$hash, lines.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OfflineSaleResolveInput')
          ..add('mode', mode)
          ..add('approvalId', approvalId)
          ..add('handedAmount', handedAmount)
          ..add('lines', lines)
          ..add('note', note))
        .toString();
  }
}

class OfflineSaleResolveInputBuilder
    implements
        Builder<OfflineSaleResolveInput, OfflineSaleResolveInputBuilder> {
  _$OfflineSaleResolveInput? _$v;

  OfflineSaleResolveInputModeEnum? _mode;
  OfflineSaleResolveInputModeEnum? get mode => _$this._mode;
  set mode(OfflineSaleResolveInputModeEnum? mode) => _$this._mode = mode;

  String? _approvalId;
  String? get approvalId => _$this._approvalId;
  set approvalId(String? approvalId) => _$this._approvalId = approvalId;

  String? _handedAmount;
  String? get handedAmount => _$this._handedAmount;
  set handedAmount(String? handedAmount) => _$this._handedAmount = handedAmount;

  ListBuilder<OfflineSaleLine>? _lines;
  ListBuilder<OfflineSaleLine> get lines =>
      _$this._lines ??= ListBuilder<OfflineSaleLine>();
  set lines(ListBuilder<OfflineSaleLine>? lines) => _$this._lines = lines;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  OfflineSaleResolveInputBuilder() {
    OfflineSaleResolveInput._defaults(this);
  }

  OfflineSaleResolveInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mode = $v.mode;
      _approvalId = $v.approvalId;
      _handedAmount = $v.handedAmount;
      _lines = $v.lines?.toBuilder();
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OfflineSaleResolveInput other) {
    _$v = other as _$OfflineSaleResolveInput;
  }

  @override
  void update(void Function(OfflineSaleResolveInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OfflineSaleResolveInput build() => _build();

  _$OfflineSaleResolveInput _build() {
    _$OfflineSaleResolveInput _$result;
    try {
      _$result = _$v ??
          _$OfflineSaleResolveInput._(
            mode: BuiltValueNullFieldError.checkNotNull(
                mode, r'OfflineSaleResolveInput', 'mode'),
            approvalId: approvalId,
            handedAmount: handedAmount,
            lines: _lines?.build(),
            note: note,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'lines';
        _lines?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OfflineSaleResolveInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
