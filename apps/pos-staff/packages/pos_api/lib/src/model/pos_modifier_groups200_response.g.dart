// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_modifier_groups200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosModifierGroups200Response extends PosModifierGroups200Response {
  @override
  final BuiltList<ModifierGroup> data;

  factory _$PosModifierGroups200Response(
          [void Function(PosModifierGroups200ResponseBuilder)? updates]) =>
      (PosModifierGroups200ResponseBuilder()..update(updates))._build();

  _$PosModifierGroups200Response._({required this.data}) : super._();
  @override
  PosModifierGroups200Response rebuild(
          void Function(PosModifierGroups200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosModifierGroups200ResponseBuilder toBuilder() =>
      PosModifierGroups200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosModifierGroups200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'PosModifierGroups200Response')
          ..add('data', data))
        .toString();
  }
}

class PosModifierGroups200ResponseBuilder
    implements
        Builder<PosModifierGroups200Response,
            PosModifierGroups200ResponseBuilder> {
  _$PosModifierGroups200Response? _$v;

  ListBuilder<ModifierGroup>? _data;
  ListBuilder<ModifierGroup> get data =>
      _$this._data ??= ListBuilder<ModifierGroup>();
  set data(ListBuilder<ModifierGroup>? data) => _$this._data = data;

  PosModifierGroups200ResponseBuilder() {
    PosModifierGroups200Response._defaults(this);
  }

  PosModifierGroups200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosModifierGroups200Response other) {
    _$v = other as _$PosModifierGroups200Response;
  }

  @override
  void update(void Function(PosModifierGroups200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosModifierGroups200Response build() => _build();

  _$PosModifierGroups200Response _build() {
    _$PosModifierGroups200Response _$result;
    try {
      _$result = _$v ??
          _$PosModifierGroups200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosModifierGroups200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
