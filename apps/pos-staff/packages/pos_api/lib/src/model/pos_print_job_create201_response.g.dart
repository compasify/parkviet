// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_print_job_create201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosPrintJobCreate201Response extends PosPrintJobCreate201Response {
  @override
  final PrintJobResult data;

  factory _$PosPrintJobCreate201Response(
          [void Function(PosPrintJobCreate201ResponseBuilder)? updates]) =>
      (PosPrintJobCreate201ResponseBuilder()..update(updates))._build();

  _$PosPrintJobCreate201Response._({required this.data}) : super._();
  @override
  PosPrintJobCreate201Response rebuild(
          void Function(PosPrintJobCreate201ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosPrintJobCreate201ResponseBuilder toBuilder() =>
      PosPrintJobCreate201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosPrintJobCreate201Response && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosPrintJobCreate201Response')
          ..add('data', data))
        .toString();
  }
}

class PosPrintJobCreate201ResponseBuilder
    implements
        Builder<PosPrintJobCreate201Response,
            PosPrintJobCreate201ResponseBuilder> {
  _$PosPrintJobCreate201Response? _$v;

  PrintJobResultBuilder? _data;
  PrintJobResultBuilder get data => _$this._data ??= PrintJobResultBuilder();
  set data(PrintJobResultBuilder? data) => _$this._data = data;

  PosPrintJobCreate201ResponseBuilder() {
    PosPrintJobCreate201Response._defaults(this);
  }

  PosPrintJobCreate201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosPrintJobCreate201Response other) {
    _$v = other as _$PosPrintJobCreate201Response;
  }

  @override
  void update(void Function(PosPrintJobCreate201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosPrintJobCreate201Response build() => _build();

  _$PosPrintJobCreate201Response _build() {
    _$PosPrintJobCreate201Response _$result;
    try {
      _$result = _$v ??
          _$PosPrintJobCreate201Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosPrintJobCreate201Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
