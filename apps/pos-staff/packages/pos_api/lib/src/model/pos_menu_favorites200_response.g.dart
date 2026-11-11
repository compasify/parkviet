// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_menu_favorites200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosMenuFavorites200Response extends PosMenuFavorites200Response {
  @override
  final PosMenuFavorites200ResponseData data;

  factory _$PosMenuFavorites200Response(
          [void Function(PosMenuFavorites200ResponseBuilder)? updates]) =>
      (PosMenuFavorites200ResponseBuilder()..update(updates))._build();

  _$PosMenuFavorites200Response._({required this.data}) : super._();
  @override
  PosMenuFavorites200Response rebuild(
          void Function(PosMenuFavorites200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosMenuFavorites200ResponseBuilder toBuilder() =>
      PosMenuFavorites200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosMenuFavorites200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosMenuFavorites200Response')
          ..add('data', data))
        .toString();
  }
}

class PosMenuFavorites200ResponseBuilder
    implements
        Builder<PosMenuFavorites200Response,
            PosMenuFavorites200ResponseBuilder> {
  _$PosMenuFavorites200Response? _$v;

  PosMenuFavorites200ResponseDataBuilder? _data;
  PosMenuFavorites200ResponseDataBuilder get data =>
      _$this._data ??= PosMenuFavorites200ResponseDataBuilder();
  set data(PosMenuFavorites200ResponseDataBuilder? data) => _$this._data = data;

  PosMenuFavorites200ResponseBuilder() {
    PosMenuFavorites200Response._defaults(this);
  }

  PosMenuFavorites200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosMenuFavorites200Response other) {
    _$v = other as _$PosMenuFavorites200Response;
  }

  @override
  void update(void Function(PosMenuFavorites200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosMenuFavorites200Response build() => _build();

  _$PosMenuFavorites200Response _build() {
    _$PosMenuFavorites200Response _$result;
    try {
      _$result = _$v ??
          _$PosMenuFavorites200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosMenuFavorites200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
