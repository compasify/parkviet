// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_device_pair201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosDevicePair201Response extends PosDevicePair201Response {
  @override
  final DevicePairResult data;

  factory _$PosDevicePair201Response(
          [void Function(PosDevicePair201ResponseBuilder)? updates]) =>
      (PosDevicePair201ResponseBuilder()..update(updates))._build();

  _$PosDevicePair201Response._({required this.data}) : super._();
  @override
  PosDevicePair201Response rebuild(
          void Function(PosDevicePair201ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosDevicePair201ResponseBuilder toBuilder() =>
      PosDevicePair201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosDevicePair201Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosDevicePair201Response')
          ..add('data', data))
        .toString();
  }
}

class PosDevicePair201ResponseBuilder
    implements
        Builder<PosDevicePair201Response, PosDevicePair201ResponseBuilder> {
  _$PosDevicePair201Response? _$v;

  DevicePairResultBuilder? _data;
  DevicePairResultBuilder get data =>
      _$this._data ??= DevicePairResultBuilder();
  set data(DevicePairResultBuilder? data) => _$this._data = data;

  PosDevicePair201ResponseBuilder() {
    PosDevicePair201Response._defaults(this);
  }

  PosDevicePair201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosDevicePair201Response other) {
    _$v = other as _$PosDevicePair201Response;
  }

  @override
  void update(void Function(PosDevicePair201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosDevicePair201Response build() => _build();

  _$PosDevicePair201Response _build() {
    _$PosDevicePair201Response _$result;
    try {
      _$result = _$v ??
          _$PosDevicePair201Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosDevicePair201Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
