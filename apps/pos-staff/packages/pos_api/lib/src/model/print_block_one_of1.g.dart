// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_block_one_of1.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PrintBlockOneOf1AlignEnum _$printBlockOneOf1AlignEnum_left =
    const PrintBlockOneOf1AlignEnum._('left');
const PrintBlockOneOf1AlignEnum _$printBlockOneOf1AlignEnum_center =
    const PrintBlockOneOf1AlignEnum._('center');
const PrintBlockOneOf1AlignEnum _$printBlockOneOf1AlignEnum_right =
    const PrintBlockOneOf1AlignEnum._('right');

PrintBlockOneOf1AlignEnum _$printBlockOneOf1AlignEnumValueOf(String name) {
  switch (name) {
    case 'left':
      return _$printBlockOneOf1AlignEnum_left;
    case 'center':
      return _$printBlockOneOf1AlignEnum_center;
    case 'right':
      return _$printBlockOneOf1AlignEnum_right;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PrintBlockOneOf1AlignEnum> _$printBlockOneOf1AlignEnumValues =
    BuiltSet<PrintBlockOneOf1AlignEnum>(const <PrintBlockOneOf1AlignEnum>[
  _$printBlockOneOf1AlignEnum_left,
  _$printBlockOneOf1AlignEnum_center,
  _$printBlockOneOf1AlignEnum_right,
]);

Serializer<PrintBlockOneOf1AlignEnum> _$printBlockOneOf1AlignEnumSerializer =
    _$PrintBlockOneOf1AlignEnumSerializer();

class _$PrintBlockOneOf1AlignEnumSerializer
    implements PrimitiveSerializer<PrintBlockOneOf1AlignEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'left': 'left',
    'center': 'center',
    'right': 'right',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'left': 'left',
    'center': 'center',
    'right': 'right',
  };

  @override
  final Iterable<Type> types = const <Type>[PrintBlockOneOf1AlignEnum];
  @override
  final String wireName = 'PrintBlockOneOf1AlignEnum';

  @override
  Object serialize(Serializers serializers, PrintBlockOneOf1AlignEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PrintBlockOneOf1AlignEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PrintBlockOneOf1AlignEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PrintBlockOneOf1 extends PrintBlockOneOf1 {
  @override
  final JsonObject? kind;
  @override
  final String src;
  @override
  final String alt;
  @override
  final num widthPct;
  @override
  final PrintBlockOneOf1AlignEnum align;
  @override
  final bool monochrome;

  factory _$PrintBlockOneOf1(
          [void Function(PrintBlockOneOf1Builder)? updates]) =>
      (PrintBlockOneOf1Builder()..update(updates))._build();

  _$PrintBlockOneOf1._(
      {this.kind,
      required this.src,
      required this.alt,
      required this.widthPct,
      required this.align,
      required this.monochrome})
      : super._();
  @override
  PrintBlockOneOf1 rebuild(void Function(PrintBlockOneOf1Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintBlockOneOf1Builder toBuilder() =>
      PrintBlockOneOf1Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintBlockOneOf1 &&
        kind == other.kind &&
        src == other.src &&
        alt == other.alt &&
        widthPct == other.widthPct &&
        align == other.align &&
        monochrome == other.monochrome;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, src.hashCode);
    _$hash = $jc(_$hash, alt.hashCode);
    _$hash = $jc(_$hash, widthPct.hashCode);
    _$hash = $jc(_$hash, align.hashCode);
    _$hash = $jc(_$hash, monochrome.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintBlockOneOf1')
          ..add('kind', kind)
          ..add('src', src)
          ..add('alt', alt)
          ..add('widthPct', widthPct)
          ..add('align', align)
          ..add('monochrome', monochrome))
        .toString();
  }
}

class PrintBlockOneOf1Builder
    implements Builder<PrintBlockOneOf1, PrintBlockOneOf1Builder> {
  _$PrintBlockOneOf1? _$v;

  JsonObject? _kind;
  JsonObject? get kind => _$this._kind;
  set kind(JsonObject? kind) => _$this._kind = kind;

  String? _src;
  String? get src => _$this._src;
  set src(String? src) => _$this._src = src;

  String? _alt;
  String? get alt => _$this._alt;
  set alt(String? alt) => _$this._alt = alt;

  num? _widthPct;
  num? get widthPct => _$this._widthPct;
  set widthPct(num? widthPct) => _$this._widthPct = widthPct;

  PrintBlockOneOf1AlignEnum? _align;
  PrintBlockOneOf1AlignEnum? get align => _$this._align;
  set align(PrintBlockOneOf1AlignEnum? align) => _$this._align = align;

  bool? _monochrome;
  bool? get monochrome => _$this._monochrome;
  set monochrome(bool? monochrome) => _$this._monochrome = monochrome;

  PrintBlockOneOf1Builder() {
    PrintBlockOneOf1._defaults(this);
  }

  PrintBlockOneOf1Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _src = $v.src;
      _alt = $v.alt;
      _widthPct = $v.widthPct;
      _align = $v.align;
      _monochrome = $v.monochrome;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintBlockOneOf1 other) {
    _$v = other as _$PrintBlockOneOf1;
  }

  @override
  void update(void Function(PrintBlockOneOf1Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintBlockOneOf1 build() => _build();

  _$PrintBlockOneOf1 _build() {
    final _$result = _$v ??
        _$PrintBlockOneOf1._(
          kind: kind,
          src: BuiltValueNullFieldError.checkNotNull(
              src, r'PrintBlockOneOf1', 'src'),
          alt: BuiltValueNullFieldError.checkNotNull(
              alt, r'PrintBlockOneOf1', 'alt'),
          widthPct: BuiltValueNullFieldError.checkNotNull(
              widthPct, r'PrintBlockOneOf1', 'widthPct'),
          align: BuiltValueNullFieldError.checkNotNull(
              align, r'PrintBlockOneOf1', 'align'),
          monochrome: BuiltValueNullFieldError.checkNotNull(
              monochrome, r'PrintBlockOneOf1', 'monochrome'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
