// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context_store.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ContextStore extends ContextStore {
  @override
  final String id;
  @override
  final String currency;

  factory _$ContextStore([void Function(ContextStoreBuilder)? updates]) =>
      (ContextStoreBuilder()..update(updates))._build();

  _$ContextStore._({required this.id, required this.currency}) : super._();
  @override
  ContextStore rebuild(void Function(ContextStoreBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ContextStoreBuilder toBuilder() => ContextStoreBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ContextStore &&
        id == other.id &&
        currency == other.currency;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ContextStore')
          ..add('id', id)
          ..add('currency', currency))
        .toString();
  }
}

class ContextStoreBuilder
    implements Builder<ContextStore, ContextStoreBuilder> {
  _$ContextStore? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  ContextStoreBuilder() {
    ContextStore._defaults(this);
  }

  ContextStoreBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _currency = $v.currency;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ContextStore other) {
    _$v = other as _$ContextStore;
  }

  @override
  void update(void Function(ContextStoreBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ContextStore build() => _build();

  _$ContextStore _build() {
    final _$result = _$v ??
        _$ContextStore._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'ContextStore', 'id'),
          currency: BuiltValueNullFieldError.checkNotNull(
              currency, r'ContextStore', 'currency'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
