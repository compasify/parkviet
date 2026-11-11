// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_printer_stations200_response_data_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosPrinterStations200ResponseDataInner
    extends PosPrinterStations200ResponseDataInner {
  @override
  final String id;
  @override
  final String name;

  factory _$PosPrinterStations200ResponseDataInner(
          [void Function(PosPrinterStations200ResponseDataInnerBuilder)?
              updates]) =>
      (PosPrinterStations200ResponseDataInnerBuilder()..update(updates))
          ._build();

  _$PosPrinterStations200ResponseDataInner._(
      {required this.id, required this.name})
      : super._();
  @override
  PosPrinterStations200ResponseDataInner rebuild(
          void Function(PosPrinterStations200ResponseDataInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosPrinterStations200ResponseDataInnerBuilder toBuilder() =>
      PosPrinterStations200ResponseDataInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosPrinterStations200ResponseDataInner &&
        id == other.id &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PosPrinterStations200ResponseDataInner')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class PosPrinterStations200ResponseDataInnerBuilder
    implements
        Builder<PosPrinterStations200ResponseDataInner,
            PosPrinterStations200ResponseDataInnerBuilder> {
  _$PosPrinterStations200ResponseDataInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  PosPrinterStations200ResponseDataInnerBuilder() {
    PosPrinterStations200ResponseDataInner._defaults(this);
  }

  PosPrinterStations200ResponseDataInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosPrinterStations200ResponseDataInner other) {
    _$v = other as _$PosPrinterStations200ResponseDataInner;
  }

  @override
  void update(
      void Function(PosPrinterStations200ResponseDataInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosPrinterStations200ResponseDataInner build() => _build();

  _$PosPrinterStations200ResponseDataInner _build() {
    final _$result = _$v ??
        _$PosPrinterStations200ResponseDataInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'PosPrinterStations200ResponseDataInner', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'PosPrinterStations200ResponseDataInner', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
