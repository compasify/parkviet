// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'append_items_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AppendItemsMeta extends AppendItemsMeta {
  @override
  final BuiltList<String> saleLineIds;

  factory _$AppendItemsMeta([void Function(AppendItemsMetaBuilder)? updates]) =>
      (AppendItemsMetaBuilder()..update(updates))._build();

  _$AppendItemsMeta._({required this.saleLineIds}) : super._();
  @override
  AppendItemsMeta rebuild(void Function(AppendItemsMetaBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AppendItemsMetaBuilder toBuilder() => AppendItemsMetaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AppendItemsMeta && saleLineIds == other.saleLineIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, saleLineIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AppendItemsMeta')
          ..add('saleLineIds', saleLineIds))
        .toString();
  }
}

class AppendItemsMetaBuilder
    implements Builder<AppendItemsMeta, AppendItemsMetaBuilder> {
  _$AppendItemsMeta? _$v;

  ListBuilder<String>? _saleLineIds;
  ListBuilder<String> get saleLineIds =>
      _$this._saleLineIds ??= ListBuilder<String>();
  set saleLineIds(ListBuilder<String>? saleLineIds) =>
      _$this._saleLineIds = saleLineIds;

  AppendItemsMetaBuilder() {
    AppendItemsMeta._defaults(this);
  }

  AppendItemsMetaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _saleLineIds = $v.saleLineIds.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AppendItemsMeta other) {
    _$v = other as _$AppendItemsMeta;
  }

  @override
  void update(void Function(AppendItemsMetaBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AppendItemsMeta build() => _build();

  _$AppendItemsMeta _build() {
    _$AppendItemsMeta _$result;
    try {
      _$result = _$v ??
          _$AppendItemsMeta._(
            saleLineIds: saleLineIds.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'saleLineIds';
        saleLineIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AppendItemsMeta', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
