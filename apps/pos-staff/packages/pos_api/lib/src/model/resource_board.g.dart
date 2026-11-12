// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_board.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ResourceBoard extends ResourceBoard {
  @override
  final String branchId;
  @override
  final DateTime serverNow;
  @override
  final bool outsideOperatingHours;
  @override
  final BuiltList<ResourceBoardArea> areas;
  @override
  final BuiltList<ResourceBoardTile> resources;

  factory _$ResourceBoard([void Function(ResourceBoardBuilder)? updates]) =>
      (ResourceBoardBuilder()..update(updates))._build();

  _$ResourceBoard._(
      {required this.branchId,
      required this.serverNow,
      required this.outsideOperatingHours,
      required this.areas,
      required this.resources})
      : super._();
  @override
  ResourceBoard rebuild(void Function(ResourceBoardBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResourceBoardBuilder toBuilder() => ResourceBoardBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResourceBoard &&
        branchId == other.branchId &&
        serverNow == other.serverNow &&
        outsideOperatingHours == other.outsideOperatingHours &&
        areas == other.areas &&
        resources == other.resources;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, serverNow.hashCode);
    _$hash = $jc(_$hash, outsideOperatingHours.hashCode);
    _$hash = $jc(_$hash, areas.hashCode);
    _$hash = $jc(_$hash, resources.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ResourceBoard')
          ..add('branchId', branchId)
          ..add('serverNow', serverNow)
          ..add('outsideOperatingHours', outsideOperatingHours)
          ..add('areas', areas)
          ..add('resources', resources))
        .toString();
  }
}

class ResourceBoardBuilder
    implements Builder<ResourceBoard, ResourceBoardBuilder> {
  _$ResourceBoard? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  DateTime? _serverNow;
  DateTime? get serverNow => _$this._serverNow;
  set serverNow(DateTime? serverNow) => _$this._serverNow = serverNow;

  bool? _outsideOperatingHours;
  bool? get outsideOperatingHours => _$this._outsideOperatingHours;
  set outsideOperatingHours(bool? outsideOperatingHours) =>
      _$this._outsideOperatingHours = outsideOperatingHours;

  ListBuilder<ResourceBoardArea>? _areas;
  ListBuilder<ResourceBoardArea> get areas =>
      _$this._areas ??= ListBuilder<ResourceBoardArea>();
  set areas(ListBuilder<ResourceBoardArea>? areas) => _$this._areas = areas;

  ListBuilder<ResourceBoardTile>? _resources;
  ListBuilder<ResourceBoardTile> get resources =>
      _$this._resources ??= ListBuilder<ResourceBoardTile>();
  set resources(ListBuilder<ResourceBoardTile>? resources) =>
      _$this._resources = resources;

  ResourceBoardBuilder() {
    ResourceBoard._defaults(this);
  }

  ResourceBoardBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _serverNow = $v.serverNow;
      _outsideOperatingHours = $v.outsideOperatingHours;
      _areas = $v.areas.toBuilder();
      _resources = $v.resources.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResourceBoard other) {
    _$v = other as _$ResourceBoard;
  }

  @override
  void update(void Function(ResourceBoardBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ResourceBoard build() => _build();

  _$ResourceBoard _build() {
    _$ResourceBoard _$result;
    try {
      _$result = _$v ??
          _$ResourceBoard._(
            branchId: BuiltValueNullFieldError.checkNotNull(
                branchId, r'ResourceBoard', 'branchId'),
            serverNow: BuiltValueNullFieldError.checkNotNull(
                serverNow, r'ResourceBoard', 'serverNow'),
            outsideOperatingHours: BuiltValueNullFieldError.checkNotNull(
                outsideOperatingHours,
                r'ResourceBoard',
                'outsideOperatingHours'),
            areas: areas.build(),
            resources: resources.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'areas';
        areas.build();
        _$failedField = 'resources';
        resources.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ResourceBoard', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
