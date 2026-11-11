// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_page_label.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PrintPageLabel extends PrintPageLabel {
  @override
  final int widthMm;
  @override
  final int heightMm;

  factory _$PrintPageLabel([void Function(PrintPageLabelBuilder)? updates]) =>
      (PrintPageLabelBuilder()..update(updates))._build();

  _$PrintPageLabel._({required this.widthMm, required this.heightMm})
      : super._();
  @override
  PrintPageLabel rebuild(void Function(PrintPageLabelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrintPageLabelBuilder toBuilder() => PrintPageLabelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrintPageLabel &&
        widthMm == other.widthMm &&
        heightMm == other.heightMm;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, widthMm.hashCode);
    _$hash = $jc(_$hash, heightMm.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrintPageLabel')
          ..add('widthMm', widthMm)
          ..add('heightMm', heightMm))
        .toString();
  }
}

class PrintPageLabelBuilder
    implements Builder<PrintPageLabel, PrintPageLabelBuilder> {
  _$PrintPageLabel? _$v;

  int? _widthMm;
  int? get widthMm => _$this._widthMm;
  set widthMm(int? widthMm) => _$this._widthMm = widthMm;

  int? _heightMm;
  int? get heightMm => _$this._heightMm;
  set heightMm(int? heightMm) => _$this._heightMm = heightMm;

  PrintPageLabelBuilder() {
    PrintPageLabel._defaults(this);
  }

  PrintPageLabelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _widthMm = $v.widthMm;
      _heightMm = $v.heightMm;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrintPageLabel other) {
    _$v = other as _$PrintPageLabel;
  }

  @override
  void update(void Function(PrintPageLabelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrintPageLabel build() => _build();

  _$PrintPageLabel _build() {
    final _$result = _$v ??
        _$PrintPageLabel._(
          widthMm: BuiltValueNullFieldError.checkNotNull(
              widthMm, r'PrintPageLabel', 'widthMm'),
          heightMm: BuiltValueNullFieldError.checkNotNull(
              heightMm, r'PrintPageLabel', 'heightMm'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
