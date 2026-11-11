// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_void_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenVoidMeta extends KitchenVoidMeta {
  @override
  final KitchenVoid kitchenVoid;

  factory _$KitchenVoidMeta([void Function(KitchenVoidMetaBuilder)? updates]) =>
      (KitchenVoidMetaBuilder()..update(updates))._build();

  _$KitchenVoidMeta._({required this.kitchenVoid}) : super._();
  @override
  KitchenVoidMeta rebuild(void Function(KitchenVoidMetaBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenVoidMetaBuilder toBuilder() => KitchenVoidMetaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenVoidMeta && kitchenVoid == other.kitchenVoid;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kitchenVoid.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenVoidMeta')
          ..add('kitchenVoid', kitchenVoid))
        .toString();
  }
}

class KitchenVoidMetaBuilder
    implements Builder<KitchenVoidMeta, KitchenVoidMetaBuilder> {
  _$KitchenVoidMeta? _$v;

  KitchenVoidBuilder? _kitchenVoid;
  KitchenVoidBuilder get kitchenVoid =>
      _$this._kitchenVoid ??= KitchenVoidBuilder();
  set kitchenVoid(KitchenVoidBuilder? kitchenVoid) =>
      _$this._kitchenVoid = kitchenVoid;

  KitchenVoidMetaBuilder() {
    KitchenVoidMeta._defaults(this);
  }

  KitchenVoidMetaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kitchenVoid = $v.kitchenVoid.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenVoidMeta other) {
    _$v = other as _$KitchenVoidMeta;
  }

  @override
  void update(void Function(KitchenVoidMetaBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenVoidMeta build() => _build();

  _$KitchenVoidMeta _build() {
    _$KitchenVoidMeta _$result;
    try {
      _$result = _$v ??
          _$KitchenVoidMeta._(
            kitchenVoid: kitchenVoid.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'kitchenVoid';
        kitchenVoid.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KitchenVoidMeta', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
