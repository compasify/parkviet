// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_board.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenBoard extends KitchenBoard {
  @override
  final String branchId;
  @override
  final KitchenStation? station;
  @override
  final BuiltList<KitchenStation> stations;
  @override
  final String? serviceMode;
  @override
  final DateTime serverNow;
  @override
  final BuiltList<KitchenTicket> open;
  @override
  final BuiltList<KitchenTicket> done;
  @override
  final BuiltList<KitchenAllDayRow> allDay;
  @override
  final BuiltList<KitchenExpoOrder> expo;

  factory _$KitchenBoard([void Function(KitchenBoardBuilder)? updates]) =>
      (KitchenBoardBuilder()..update(updates))._build();

  _$KitchenBoard._(
      {required this.branchId,
      this.station,
      required this.stations,
      this.serviceMode,
      required this.serverNow,
      required this.open,
      required this.done,
      required this.allDay,
      required this.expo})
      : super._();
  @override
  KitchenBoard rebuild(void Function(KitchenBoardBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenBoardBuilder toBuilder() => KitchenBoardBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenBoard &&
        branchId == other.branchId &&
        station == other.station &&
        stations == other.stations &&
        serviceMode == other.serviceMode &&
        serverNow == other.serverNow &&
        open == other.open &&
        done == other.done &&
        allDay == other.allDay &&
        expo == other.expo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, station.hashCode);
    _$hash = $jc(_$hash, stations.hashCode);
    _$hash = $jc(_$hash, serviceMode.hashCode);
    _$hash = $jc(_$hash, serverNow.hashCode);
    _$hash = $jc(_$hash, open.hashCode);
    _$hash = $jc(_$hash, done.hashCode);
    _$hash = $jc(_$hash, allDay.hashCode);
    _$hash = $jc(_$hash, expo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenBoard')
          ..add('branchId', branchId)
          ..add('station', station)
          ..add('stations', stations)
          ..add('serviceMode', serviceMode)
          ..add('serverNow', serverNow)
          ..add('open', open)
          ..add('done', done)
          ..add('allDay', allDay)
          ..add('expo', expo))
        .toString();
  }
}

class KitchenBoardBuilder
    implements Builder<KitchenBoard, KitchenBoardBuilder> {
  _$KitchenBoard? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  KitchenStationBuilder? _station;
  KitchenStationBuilder get station =>
      _$this._station ??= KitchenStationBuilder();
  set station(KitchenStationBuilder? station) => _$this._station = station;

  ListBuilder<KitchenStation>? _stations;
  ListBuilder<KitchenStation> get stations =>
      _$this._stations ??= ListBuilder<KitchenStation>();
  set stations(ListBuilder<KitchenStation>? stations) =>
      _$this._stations = stations;

  String? _serviceMode;
  String? get serviceMode => _$this._serviceMode;
  set serviceMode(String? serviceMode) => _$this._serviceMode = serviceMode;

  DateTime? _serverNow;
  DateTime? get serverNow => _$this._serverNow;
  set serverNow(DateTime? serverNow) => _$this._serverNow = serverNow;

  ListBuilder<KitchenTicket>? _open;
  ListBuilder<KitchenTicket> get open =>
      _$this._open ??= ListBuilder<KitchenTicket>();
  set open(ListBuilder<KitchenTicket>? open) => _$this._open = open;

  ListBuilder<KitchenTicket>? _done;
  ListBuilder<KitchenTicket> get done =>
      _$this._done ??= ListBuilder<KitchenTicket>();
  set done(ListBuilder<KitchenTicket>? done) => _$this._done = done;

  ListBuilder<KitchenAllDayRow>? _allDay;
  ListBuilder<KitchenAllDayRow> get allDay =>
      _$this._allDay ??= ListBuilder<KitchenAllDayRow>();
  set allDay(ListBuilder<KitchenAllDayRow>? allDay) => _$this._allDay = allDay;

  ListBuilder<KitchenExpoOrder>? _expo;
  ListBuilder<KitchenExpoOrder> get expo =>
      _$this._expo ??= ListBuilder<KitchenExpoOrder>();
  set expo(ListBuilder<KitchenExpoOrder>? expo) => _$this._expo = expo;

  KitchenBoardBuilder() {
    KitchenBoard._defaults(this);
  }

  KitchenBoardBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _station = $v.station?.toBuilder();
      _stations = $v.stations.toBuilder();
      _serviceMode = $v.serviceMode;
      _serverNow = $v.serverNow;
      _open = $v.open.toBuilder();
      _done = $v.done.toBuilder();
      _allDay = $v.allDay.toBuilder();
      _expo = $v.expo.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenBoard other) {
    _$v = other as _$KitchenBoard;
  }

  @override
  void update(void Function(KitchenBoardBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenBoard build() => _build();

  _$KitchenBoard _build() {
    _$KitchenBoard _$result;
    try {
      _$result = _$v ??
          _$KitchenBoard._(
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'KitchenBoard', 'branchId'),
            station: _station?.build(),
            stations: stations.build(),
            serviceMode: serviceMode,
            serverNow: BuiltValueNullFieldError.checkNotNull(
                serverNow, r'KitchenBoard', 'serverNow'),
            open: open.build(),
            done: done.build(),
            allDay: allDay.build(),
            expo: expo.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'station';
        _station?.build();
        _$failedField = 'stations';
        stations.build();

        _$failedField = 'open';
        open.build();
        _$failedField = 'done';
        done.build();
        _$failedField = 'allDay';
        allDay.build();
        _$failedField = 'expo';
        expo.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KitchenBoard', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
