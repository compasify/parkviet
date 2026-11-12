// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_offline_snapshot200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosOfflineSnapshot200Response extends PosOfflineSnapshot200Response {
  @override
  final OfflineSnapshot data;

  factory _$PosOfflineSnapshot200Response(
          [void Function(PosOfflineSnapshot200ResponseBuilder)? updates]) =>
      (PosOfflineSnapshot200ResponseBuilder()..update(updates))._build();

  _$PosOfflineSnapshot200Response._({required this.data}) : super._();
  @override
  PosOfflineSnapshot200Response rebuild(
          void Function(PosOfflineSnapshot200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosOfflineSnapshot200ResponseBuilder toBuilder() =>
      PosOfflineSnapshot200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosOfflineSnapshot200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosOfflineSnapshot200Response')
          ..add('data', data))
        .toString();
  }
}

class PosOfflineSnapshot200ResponseBuilder
    implements
        Builder<PosOfflineSnapshot200Response,
            PosOfflineSnapshot200ResponseBuilder> {
  _$PosOfflineSnapshot200Response? _$v;

  OfflineSnapshotBuilder? _data;
  OfflineSnapshotBuilder get data => _$this._data ??= OfflineSnapshotBuilder();
  set data(OfflineSnapshotBuilder? data) => _$this._data = data;

  PosOfflineSnapshot200ResponseBuilder() {
    PosOfflineSnapshot200Response._defaults(this);
  }

  PosOfflineSnapshot200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosOfflineSnapshot200Response other) {
    _$v = other as _$PosOfflineSnapshot200Response;
  }

  @override
  void update(void Function(PosOfflineSnapshot200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosOfflineSnapshot200Response build() => _build();

  _$PosOfflineSnapshot200Response _build() {
    _$PosOfflineSnapshot200Response _$result;
    try {
      _$result = _$v ??
          _$PosOfflineSnapshot200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosOfflineSnapshot200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
