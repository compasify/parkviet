// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_pins.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TablePins extends TablePins {
  @override
  final BuiltList<String> pinned;
  @override
  final BuiltList<String> serving;

  factory _$TablePins([void Function(TablePinsBuilder)? updates]) =>
      (TablePinsBuilder()..update(updates))._build();

  _$TablePins._({required this.pinned, required this.serving}) : super._();
  @override
  TablePins rebuild(void Function(TablePinsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TablePinsBuilder toBuilder() => TablePinsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TablePins &&
        pinned == other.pinned &&
        serving == other.serving;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pinned.hashCode);
    _$hash = $jc(_$hash, serving.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TablePins')
          ..add('pinned', pinned)
          ..add('serving', serving))
        .toString();
  }
}

class TablePinsBuilder implements Builder<TablePins, TablePinsBuilder> {
  _$TablePins? _$v;

  ListBuilder<String>? _pinned;
  ListBuilder<String> get pinned => _$this._pinned ??= ListBuilder<String>();
  set pinned(ListBuilder<String>? pinned) => _$this._pinned = pinned;

  ListBuilder<String>? _serving;
  ListBuilder<String> get serving => _$this._serving ??= ListBuilder<String>();
  set serving(ListBuilder<String>? serving) => _$this._serving = serving;

  TablePinsBuilder() {
    TablePins._defaults(this);
  }

  TablePinsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _pinned = $v.pinned.toBuilder();
      _serving = $v.serving.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TablePins other) {
    _$v = other as _$TablePins;
  }

  @override
  void update(void Function(TablePinsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TablePins build() => _build();

  _$TablePins _build() {
    _$TablePins _$result;
    try {
      _$result = _$v ??
          _$TablePins._(
            pinned: pinned.build(),
            serving: serving.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'pinned';
        pinned.build();
        _$failedField = 'serving';
        serving.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TablePins', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
