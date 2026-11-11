// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_cup_label_settings200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosCupLabelSettings200Response extends PosCupLabelSettings200Response {
  @override
  final CupLabelSettings data;

  factory _$PosCupLabelSettings200Response(
          [void Function(PosCupLabelSettings200ResponseBuilder)? updates]) =>
      (PosCupLabelSettings200ResponseBuilder()..update(updates))._build();

  _$PosCupLabelSettings200Response._({required this.data}) : super._();
  @override
  PosCupLabelSettings200Response rebuild(
          void Function(PosCupLabelSettings200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosCupLabelSettings200ResponseBuilder toBuilder() =>
      PosCupLabelSettings200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosCupLabelSettings200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosCupLabelSettings200Response')
          ..add('data', data))
        .toString();
  }
}

class PosCupLabelSettings200ResponseBuilder
    implements
        Builder<PosCupLabelSettings200Response,
            PosCupLabelSettings200ResponseBuilder> {
  _$PosCupLabelSettings200Response? _$v;

  CupLabelSettingsBuilder? _data;
  CupLabelSettingsBuilder get data =>
      _$this._data ??= CupLabelSettingsBuilder();
  set data(CupLabelSettingsBuilder? data) => _$this._data = data;

  PosCupLabelSettings200ResponseBuilder() {
    PosCupLabelSettings200Response._defaults(this);
  }

  PosCupLabelSettings200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosCupLabelSettings200Response other) {
    _$v = other as _$PosCupLabelSettings200Response;
  }

  @override
  void update(void Function(PosCupLabelSettings200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosCupLabelSettings200Response build() => _build();

  _$PosCupLabelSettings200Response _build() {
    _$PosCupLabelSettings200Response _$result;
    try {
      _$result = _$v ??
          _$PosCupLabelSettings200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosCupLabelSettings200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
