// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_station_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenStationList extends KitchenStationList {
  @override
  final BuiltList<KitchenStation> data;

  factory _$KitchenStationList(
          [void Function(KitchenStationListBuilder)? updates]) =>
      (KitchenStationListBuilder()..update(updates))._build();

  _$KitchenStationList._({required this.data}) : super._();
  @override
  KitchenStationList rebuild(
          void Function(KitchenStationListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenStationListBuilder toBuilder() =>
      KitchenStationListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenStationList && data == other.data;
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
    return (newBuiltValueToStringHelper(r'KitchenStationList')
          ..add('data', data))
        .toString();
  }
}

class KitchenStationListBuilder
    implements Builder<KitchenStationList, KitchenStationListBuilder> {
  _$KitchenStationList? _$v;

  ListBuilder<KitchenStation>? _data;
  ListBuilder<KitchenStation> get data =>
      _$this._data ??= ListBuilder<KitchenStation>();
  set data(ListBuilder<KitchenStation>? data) => _$this._data = data;

  KitchenStationListBuilder() {
    KitchenStationList._defaults(this);
  }

  KitchenStationListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenStationList other) {
    _$v = other as _$KitchenStationList;
  }

  @override
  void update(void Function(KitchenStationListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenStationList build() => _build();

  _$KitchenStationList _build() {
    _$KitchenStationList _$result;
    try {
      _$result = _$v ??
          _$KitchenStationList._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KitchenStationList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
