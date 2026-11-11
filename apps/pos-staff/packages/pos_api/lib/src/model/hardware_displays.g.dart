// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hardware_displays.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$HardwareDisplays extends HardwareDisplays {
  @override
  final int live;

  factory _$HardwareDisplays(
          [void Function(HardwareDisplaysBuilder)? updates]) =>
      (HardwareDisplaysBuilder()..update(updates))._build();

  _$HardwareDisplays._({required this.live}) : super._();
  @override
  HardwareDisplays rebuild(void Function(HardwareDisplaysBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HardwareDisplaysBuilder toBuilder() =>
      HardwareDisplaysBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HardwareDisplays && live == other.live;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, live.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HardwareDisplays')..add('live', live))
        .toString();
  }
}

class HardwareDisplaysBuilder
    implements Builder<HardwareDisplays, HardwareDisplaysBuilder> {
  _$HardwareDisplays? _$v;

  int? _live;
  int? get live => _$this._live;
  set live(int? live) => _$this._live = live;

  HardwareDisplaysBuilder() {
    HardwareDisplays._defaults(this);
  }

  HardwareDisplaysBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _live = $v.live;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HardwareDisplays other) {
    _$v = other as _$HardwareDisplays;
  }

  @override
  void update(void Function(HardwareDisplaysBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HardwareDisplays build() => _build();

  _$HardwareDisplays _build() {
    final _$result = _$v ??
        _$HardwareDisplays._(
          live: BuiltValueNullFieldError.checkNotNull(
              live, r'HardwareDisplays', 'live'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
