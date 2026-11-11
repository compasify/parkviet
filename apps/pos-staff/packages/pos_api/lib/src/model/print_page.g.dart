// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PrintPageFontEnum _$printPageFontEnum_sans =
    const PrintPageFontEnum._('sans');
const PrintPageFontEnum _$printPageFontEnum_mono =
    const PrintPageFontEnum._('mono');

PrintPageFontEnum _$printPageFontEnumValueOf(String name) {
  switch (name) {
    case 'sans':
      return _$printPageFontEnum_sans;
    case 'mono':
      return _$printPageFontEnum_mono;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PrintPageFontEnum> _$printPageFontEnumValues =
    BuiltSet<PrintPageFontEnum>(const <PrintPageFontEnum>[
  _$printPageFontEnum_sans,
  _$printPageFontEnum_mono,
]);

const PrintPageFontSizeEnum _$printPageFontSizeEnum_s =
    const PrintPageFontSizeEnum._('s');
const PrintPageFontSizeEnum _$printPageFontSizeEnum_m =
    const PrintPageFontSizeEnum._('m');
const PrintPageFontSizeEnum _$printPageFontSizeEnum_l =
    const PrintPageFontSizeEnum._('l');

PrintPageFontSizeEnum _$printPageFontSizeEnumValueOf(String name) {
  switch (name) {
    case 's':
      return _$printPageFontSizeEnum_s;
    case 'm':
      return _$printPageFontSizeEnum_m;
    case 'l':
      return _$printPageFontSizeEnum_l;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PrintPageFontSizeEnum> _$printPageFontSizeEnumValues =
    BuiltSet<PrintPageFontSizeEnum>(const <PrintPageFontSizeEnum>[
  _$printPageFontSizeEnum_s,
  _$printPageFontSizeEnum_m,
  _$printPageFontSizeEnum_l,
]);

Serializer<PrintPageFontEnum> _$printPageFontEnumSerializer =
    _$PrintPageFontEnumSerializer();
Serializer<PrintPageFontSizeEnum> _$printPageFontSizeEnumSerializer =
    _$PrintPageFontSizeEnumSerializer();

class _$PrintPageFontEnumSerializer
    implements PrimitiveSerializer<PrintPageFontEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'sans': 'sans',
    'mono': 'mono',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'sans': 'sans',
    'mono': 'mono',
  };

  @override
  final Iterable<Type> types = const <Type>[PrintPageFontEnum];
  @override
  final String wireName = 'PrintPageFontEnum';

  @override
  Object serialize(Serializers serializers, PrintPageFontEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PrintPageFontEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PrintPageFontEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PrintPageFontSizeEnumSerializer
    implements PrimitiveSerializer<PrintPageFontSizeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    's': 's',
    'm': 'm',
    'l': 'l',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    's': 's',
    'm': 'm',
    'l': 'l',
  };

  @override
  final Iterable<Type> types = const <Type>[PrintPageFontSizeEnum];
  @override
  final String wireName = 'PrintPageFontSizeEnum';

  @override
  Object serialize(Serializers serializers, PrintPageFontSizeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PrintPageFontSizeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PrintPageFontSizeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PrintPage extends PrintPage {
  @override
  final num marginMm;
  @override
  final PrintPageFontEnum font;
  @override
  final PrintPageFontSizeEnum fontSize;
  @override
  final num lineSpacing;
  @override
  final int? copies;
  @override
  final PrintPageLabel? label;

  factory _$PrintPage([void Function(PrintPageBuilder)? updates]) =>
      (PrintPageBuilder()..update(updates))._build();

  _$PrintPage._(
      {required this.marginMm,
      required this.font,
      required this.fontSize,
      required this.lineSpacing,
      this.copies,
      this.label})
      : super._();
  @override
  PrintPage rebuild(void Function(PrintPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintPageBuilder toBuilder() => PrintPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintPage &&
        marginMm == other.marginMm &&
        font == other.font &&
        fontSize == other.fontSize &&
        lineSpacing == other.lineSpacing &&
        copies == other.copies &&
        label == other.label;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, marginMm.hashCode);
    _$hash = $jc(_$hash, font.hashCode);
    _$hash = $jc(_$hash, fontSize.hashCode);
    _$hash = $jc(_$hash, lineSpacing.hashCode);
    _$hash = $jc(_$hash, copies.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintPage')
          ..add('marginMm', marginMm)
          ..add('font', font)
          ..add('fontSize', fontSize)
          ..add('lineSpacing', lineSpacing)
          ..add('copies', copies)
          ..add('label', label))
        .toString();
  }
}

class PrintPageBuilder implements Builder<PrintPage, PrintPageBuilder> {
  _$PrintPage? _$v;

  num? _marginMm;
  num? get marginMm => _$this._marginMm;
  set marginMm(num? marginMm) => _$this._marginMm = marginMm;

  PrintPageFontEnum? _font;
  PrintPageFontEnum? get font => _$this._font;
  set font(PrintPageFontEnum? font) => _$this._font = font;

  PrintPageFontSizeEnum? _fontSize;
  PrintPageFontSizeEnum? get fontSize => _$this._fontSize;
  set fontSize(PrintPageFontSizeEnum? fontSize) => _$this._fontSize = fontSize;

  num? _lineSpacing;
  num? get lineSpacing => _$this._lineSpacing;
  set lineSpacing(num? lineSpacing) => _$this._lineSpacing = lineSpacing;

  int? _copies;
  int? get copies => _$this._copies;
  set copies(int? copies) => _$this._copies = copies;

  PrintPageLabelBuilder? _label;
  PrintPageLabelBuilder get label => _$this._label ??= PrintPageLabelBuilder();
  set label(PrintPageLabelBuilder? label) => _$this._label = label;

  PrintPageBuilder() {
    PrintPage._defaults(this);
  }

  PrintPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _marginMm = $v.marginMm;
      _font = $v.font;
      _fontSize = $v.fontSize;
      _lineSpacing = $v.lineSpacing;
      _copies = $v.copies;
      _label = $v.label?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintPage other) {
    _$v = other as _$PrintPage;
  }

  @override
  void update(void Function(PrintPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintPage build() => _build();

  _$PrintPage _build() {
    _$PrintPage _$result;
    try {
      _$result = _$v ??
          _$PrintPage._(
            marginMm: BuiltValueNullFieldError.checkNotNull(
                marginMm, r'PrintPage', 'marginMm'),
            font: BuiltValueNullFieldError.checkNotNull(
                font, r'PrintPage', 'font'),
            fontSize: BuiltValueNullFieldError.checkNotNull(
                fontSize, r'PrintPage', 'fontSize'),
            lineSpacing: BuiltValueNullFieldError.checkNotNull(
                lineSpacing, r'PrintPage', 'lineSpacing'),
            copies: copies,
            label: _label?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'label';
        _label?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PrintPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
