// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_alert_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OwnerAlertList extends OwnerAlertList {
  @override
  final BuiltList<OwnerAlert> data;

  factory _$OwnerAlertList([void Function(OwnerAlertListBuilder)? updates]) =>
      (OwnerAlertListBuilder()..update(updates))._build();

  _$OwnerAlertList._({required this.data}) : super._();
  @override
  OwnerAlertList rebuild(void Function(OwnerAlertListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OwnerAlertListBuilder toBuilder() => OwnerAlertListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OwnerAlertList && data == other.data;
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
    return (newBuiltValueToStringHelper(r'OwnerAlertList')..add('data', data))
        .toString();
  }
}

class OwnerAlertListBuilder
    implements Builder<OwnerAlertList, OwnerAlertListBuilder> {
  _$OwnerAlertList? _$v;

  ListBuilder<OwnerAlert>? _data;
  ListBuilder<OwnerAlert> get data =>
      _$this._data ??= ListBuilder<OwnerAlert>();
  set data(ListBuilder<OwnerAlert>? data) => _$this._data = data;

  OwnerAlertListBuilder() {
    OwnerAlertList._defaults(this);
  }

  OwnerAlertListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OwnerAlertList other) {
    _$v = other as _$OwnerAlertList;
  }

  @override
  void update(void Function(OwnerAlertListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OwnerAlertList build() => _build();

  _$OwnerAlertList _build() {
    _$OwnerAlertList _$result;
    try {
      _$result = _$v ??
          _$OwnerAlertList._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OwnerAlertList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
