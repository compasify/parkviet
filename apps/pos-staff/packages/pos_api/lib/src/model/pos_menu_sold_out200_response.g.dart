// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_menu_sold_out200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosMenuSoldOut200Response extends PosMenuSoldOut200Response {
  @override
  final MenuAvailability data;

  factory _$PosMenuSoldOut200Response(
          [void Function(PosMenuSoldOut200ResponseBuilder)? updates]) =>
      (PosMenuSoldOut200ResponseBuilder()..update(updates))._build();

  _$PosMenuSoldOut200Response._({required this.data}) : super._();
  @override
  PosMenuSoldOut200Response rebuild(
          void Function(PosMenuSoldOut200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosMenuSoldOut200ResponseBuilder toBuilder() =>
      PosMenuSoldOut200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosMenuSoldOut200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosMenuSoldOut200Response')
          ..add('data', data))
        .toString();
  }
}

class PosMenuSoldOut200ResponseBuilder
    implements
        Builder<PosMenuSoldOut200Response, PosMenuSoldOut200ResponseBuilder> {
  _$PosMenuSoldOut200Response? _$v;

  MenuAvailabilityBuilder? _data;
  MenuAvailabilityBuilder get data =>
      _$this._data ??= MenuAvailabilityBuilder();
  set data(MenuAvailabilityBuilder? data) => _$this._data = data;

  PosMenuSoldOut200ResponseBuilder() {
    PosMenuSoldOut200Response._defaults(this);
  }

  PosMenuSoldOut200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosMenuSoldOut200Response other) {
    _$v = other as _$PosMenuSoldOut200Response;
  }

  @override
  void update(void Function(PosMenuSoldOut200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosMenuSoldOut200Response build() => _build();

  _$PosMenuSoldOut200Response _build() {
    _$PosMenuSoldOut200Response _$result;
    try {
      _$result = _$v ??
          _$PosMenuSoldOut200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosMenuSoldOut200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
