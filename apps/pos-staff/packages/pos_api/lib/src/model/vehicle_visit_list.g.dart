// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_visit_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VehicleVisitList extends VehicleVisitList {
  @override
  final BuiltList<VehicleVisit> data;

  factory _$VehicleVisitList(
          [void Function(VehicleVisitListBuilder)? updates]) =>
      (VehicleVisitListBuilder()..update(updates))._build();

  _$VehicleVisitList._({required this.data}) : super._();
  @override
  VehicleVisitList rebuild(void Function(VehicleVisitListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VehicleVisitListBuilder toBuilder() =>
      VehicleVisitListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VehicleVisitList && data == other.data;
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
    return (newBuiltValueToStringHelper(r'VehicleVisitList')..add('data', data))
        .toString();
  }
}

class VehicleVisitListBuilder
    implements Builder<VehicleVisitList, VehicleVisitListBuilder> {
  _$VehicleVisitList? _$v;

  ListBuilder<VehicleVisit>? _data;
  ListBuilder<VehicleVisit> get data =>
      _$this._data ??= ListBuilder<VehicleVisit>();
  set data(ListBuilder<VehicleVisit>? data) => _$this._data = data;

  VehicleVisitListBuilder() {
    VehicleVisitList._defaults(this);
  }

  VehicleVisitListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VehicleVisitList other) {
    _$v = other as _$VehicleVisitList;
  }

  @override
  void update(void Function(VehicleVisitListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VehicleVisitList build() => _build();

  _$VehicleVisitList _build() {
    _$VehicleVisitList _$result;
    try {
      _$result = _$v ??
          _$VehicleVisitList._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'VehicleVisitList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
