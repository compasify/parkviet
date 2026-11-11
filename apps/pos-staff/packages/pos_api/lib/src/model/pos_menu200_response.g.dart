// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_menu200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosMenu200Response extends PosMenu200Response {
  @override
  final Menu data;

  factory _$PosMenu200Response(
          [void Function(PosMenu200ResponseBuilder)? updates]) =>
      (PosMenu200ResponseBuilder()..update(updates))._build();

  _$PosMenu200Response._({required this.data}) : super._();
  @override
  PosMenu200Response rebuild(
          void Function(PosMenu200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosMenu200ResponseBuilder toBuilder() =>
      PosMenu200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosMenu200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosMenu200Response')
          ..add('data', data))
        .toString();
  }
}

class PosMenu200ResponseBuilder
    implements Builder<PosMenu200Response, PosMenu200ResponseBuilder> {
  _$PosMenu200Response? _$v;

  MenuBuilder? _data;
  MenuBuilder get data => _$this._data ??= MenuBuilder();
  set data(MenuBuilder? data) => _$this._data = data;

  PosMenu200ResponseBuilder() {
    PosMenu200Response._defaults(this);
  }

  PosMenu200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosMenu200Response other) {
    _$v = other as _$PosMenu200Response;
  }

  @override
  void update(void Function(PosMenu200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosMenu200Response build() => _build();

  _$PosMenu200Response _build() {
    _$PosMenu200Response _$result;
    try {
      _$result = _$v ??
          _$PosMenu200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosMenu200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
