// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_kitchen_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LineKitchenStatus extends LineKitchenStatus {
  @override
  final String? new_;
  @override
  final String? preparing;
  @override
  final String? ready;
  @override
  final String? served;

  factory _$LineKitchenStatus(
          [void Function(LineKitchenStatusBuilder)? updates]) =>
      (LineKitchenStatusBuilder()..update(updates))._build();

  _$LineKitchenStatus._({this.new_, this.preparing, this.ready, this.served})
      : super._();
  @override
  LineKitchenStatus rebuild(void Function(LineKitchenStatusBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LineKitchenStatusBuilder toBuilder() =>
      LineKitchenStatusBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LineKitchenStatus &&
        new_ == other.new_ &&
        preparing == other.preparing &&
        ready == other.ready &&
        served == other.served;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, new_.hashCode);
    _$hash = $jc(_$hash, preparing.hashCode);
    _$hash = $jc(_$hash, ready.hashCode);
    _$hash = $jc(_$hash, served.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LineKitchenStatus')
          ..add('new_', new_)
          ..add('preparing', preparing)
          ..add('ready', ready)
          ..add('served', served))
        .toString();
  }
}

class LineKitchenStatusBuilder
    implements Builder<LineKitchenStatus, LineKitchenStatusBuilder> {
  _$LineKitchenStatus? _$v;

  String? _new_;
  String? get new_ => _$this._new_;
  set new_(String? new_) => _$this._new_ = new_;

  String? _preparing;
  String? get preparing => _$this._preparing;
  set preparing(String? preparing) => _$this._preparing = preparing;

  String? _ready;
  String? get ready => _$this._ready;
  set ready(String? ready) => _$this._ready = ready;

  String? _served;
  String? get served => _$this._served;
  set served(String? served) => _$this._served = served;

  LineKitchenStatusBuilder() {
    LineKitchenStatus._defaults(this);
  }

  LineKitchenStatusBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _new_ = $v.new_;
      _preparing = $v.preparing;
      _ready = $v.ready;
      _served = $v.served;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LineKitchenStatus other) {
    _$v = other as _$LineKitchenStatus;
  }

  @override
  void update(void Function(LineKitchenStatusBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LineKitchenStatus build() => _build();

  _$LineKitchenStatus _build() {
    final _$result = _$v ??
        _$LineKitchenStatus._(
          new_: new_,
          preparing: preparing,
          ready: ready,
          served: served,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
