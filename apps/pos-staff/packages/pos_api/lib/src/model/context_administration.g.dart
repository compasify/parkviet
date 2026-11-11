// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context_administration.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ContextAdministration extends ContextAdministration {
  @override
  final bool read;
  @override
  final bool write;

  factory _$ContextAdministration(
          [void Function(ContextAdministrationBuilder)? updates]) =>
      (ContextAdministrationBuilder()..update(updates))._build();

  _$ContextAdministration._({required this.read, required this.write})
      : super._();
  @override
  ContextAdministration rebuild(
          void Function(ContextAdministrationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ContextAdministrationBuilder toBuilder() =>
      ContextAdministrationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ContextAdministration &&
        read == other.read &&
        write == other.write;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, read.hashCode);
    _$hash = $jc(_$hash, write.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ContextAdministration')
          ..add('read', read)
          ..add('write', write))
        .toString();
  }
}

class ContextAdministrationBuilder
    implements Builder<ContextAdministration, ContextAdministrationBuilder> {
  _$ContextAdministration? _$v;

  bool? _read;
  bool? get read => _$this._read;
  set read(bool? read) => _$this._read = read;

  bool? _write;
  bool? get write => _$this._write;
  set write(bool? write) => _$this._write = write;

  ContextAdministrationBuilder() {
    ContextAdministration._defaults(this);
  }

  ContextAdministrationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _read = $v.read;
      _write = $v.write;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ContextAdministration other) {
    _$v = other as _$ContextAdministration;
  }

  @override
  void update(void Function(ContextAdministrationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ContextAdministration build() => _build();

  _$ContextAdministration _build() {
    final _$result = _$v ??
        _$ContextAdministration._(
          read: BuiltValueNullFieldError.checkNotNull(
              read, r'ContextAdministration', 'read'),
          write: BuiltValueNullFieldError.checkNotNull(
              write, r'ContextAdministration', 'write'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
