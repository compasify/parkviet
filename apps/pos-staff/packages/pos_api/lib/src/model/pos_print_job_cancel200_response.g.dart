// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_print_job_cancel200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosPrintJobCancel200Response extends PosPrintJobCancel200Response {
  @override
  final PrintJob data;

  factory _$PosPrintJobCancel200Response(
          [void Function(PosPrintJobCancel200ResponseBuilder)? updates]) =>
      (PosPrintJobCancel200ResponseBuilder()..update(updates))._build();

  _$PosPrintJobCancel200Response._({required this.data}) : super._();
  @override
  PosPrintJobCancel200Response rebuild(
          void Function(PosPrintJobCancel200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosPrintJobCancel200ResponseBuilder toBuilder() =>
      PosPrintJobCancel200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosPrintJobCancel200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosPrintJobCancel200Response')
          ..add('data', data))
        .toString();
  }
}

class PosPrintJobCancel200ResponseBuilder
    implements
        Builder<PosPrintJobCancel200Response,
            PosPrintJobCancel200ResponseBuilder> {
  _$PosPrintJobCancel200Response? _$v;

  PrintJobBuilder? _data;
  PrintJobBuilder get data => _$this._data ??= PrintJobBuilder();
  set data(PrintJobBuilder? data) => _$this._data = data;

  PosPrintJobCancel200ResponseBuilder() {
    PosPrintJobCancel200Response._defaults(this);
  }

  PosPrintJobCancel200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosPrintJobCancel200Response other) {
    _$v = other as _$PosPrintJobCancel200Response;
  }

  @override
  void update(void Function(PosPrintJobCancel200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosPrintJobCancel200Response build() => _build();

  _$PosPrintJobCancel200Response _build() {
    _$PosPrintJobCancel200Response _$result;
    try {
      _$result = _$v ??
          _$PosPrintJobCancel200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosPrintJobCancel200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
