// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_print_jobs200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosPrintJobs200Response extends PosPrintJobs200Response {
  @override
  final BuiltList<PrintJob> data;

  factory _$PosPrintJobs200Response(
          [void Function(PosPrintJobs200ResponseBuilder)? updates]) =>
      (PosPrintJobs200ResponseBuilder()..update(updates))._build();

  _$PosPrintJobs200Response._({required this.data}) : super._();
  @override
  PosPrintJobs200Response rebuild(
          void Function(PosPrintJobs200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosPrintJobs200ResponseBuilder toBuilder() =>
      PosPrintJobs200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosPrintJobs200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosPrintJobs200Response')
          ..add('data', data))
        .toString();
  }
}

class PosPrintJobs200ResponseBuilder
    implements
        Builder<PosPrintJobs200Response, PosPrintJobs200ResponseBuilder> {
  _$PosPrintJobs200Response? _$v;

  ListBuilder<PrintJob>? _data;
  ListBuilder<PrintJob> get data => _$this._data ??= ListBuilder<PrintJob>();
  set data(ListBuilder<PrintJob>? data) => _$this._data = data;

  PosPrintJobs200ResponseBuilder() {
    PosPrintJobs200Response._defaults(this);
  }

  PosPrintJobs200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosPrintJobs200Response other) {
    _$v = other as _$PosPrintJobs200Response;
  }

  @override
  void update(void Function(PosPrintJobs200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosPrintJobs200Response build() => _build();

  _$PosPrintJobs200Response _build() {
    _$PosPrintJobs200Response _$result;
    try {
      _$result = _$v ??
          _$PosPrintJobs200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosPrintJobs200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
