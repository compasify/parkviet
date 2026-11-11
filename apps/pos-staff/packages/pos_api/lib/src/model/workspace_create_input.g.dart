// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_create_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const WorkspaceCreateInputServiceModeEnum
    _$workspaceCreateInputServiceModeEnum_counter =
    const WorkspaceCreateInputServiceModeEnum._('counter');
const WorkspaceCreateInputServiceModeEnum
    _$workspaceCreateInputServiceModeEnum_tab =
    const WorkspaceCreateInputServiceModeEnum._('tab');

WorkspaceCreateInputServiceModeEnum
    _$workspaceCreateInputServiceModeEnumValueOf(String name) {
  switch (name) {
    case 'counter':
      return _$workspaceCreateInputServiceModeEnum_counter;
    case 'tab':
      return _$workspaceCreateInputServiceModeEnum_tab;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<WorkspaceCreateInputServiceModeEnum>
    _$workspaceCreateInputServiceModeEnumValues = BuiltSet<
        WorkspaceCreateInputServiceModeEnum>(const <WorkspaceCreateInputServiceModeEnum>[
  _$workspaceCreateInputServiceModeEnum_counter,
  _$workspaceCreateInputServiceModeEnum_tab,
]);

Serializer<WorkspaceCreateInputServiceModeEnum>
    _$workspaceCreateInputServiceModeEnumSerializer =
    _$WorkspaceCreateInputServiceModeEnumSerializer();

class _$WorkspaceCreateInputServiceModeEnumSerializer
    implements PrimitiveSerializer<WorkspaceCreateInputServiceModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'counter': 'counter',
    'tab': 'tab',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'counter': 'counter',
    'tab': 'tab',
  };

  @override
  final Iterable<Type> types = const <Type>[
    WorkspaceCreateInputServiceModeEnum
  ];
  @override
  final String wireName = 'WorkspaceCreateInputServiceModeEnum';

  @override
  Object serialize(
          Serializers serializers, WorkspaceCreateInputServiceModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  WorkspaceCreateInputServiceModeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      WorkspaceCreateInputServiceModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$WorkspaceCreateInput extends WorkspaceCreateInput {
  @override
  final String? registerId;
  @override
  final String? branchId;
  @override
  final String? editorId;
  @override
  final WorkspaceCreateInputServiceModeEnum? serviceMode;
  @override
  final String? tabName;

  factory _$WorkspaceCreateInput(
          [void Function(WorkspaceCreateInputBuilder)? updates]) =>
      (WorkspaceCreateInputBuilder()..update(updates))._build();

  _$WorkspaceCreateInput._(
      {this.registerId,
      this.branchId,
      this.editorId,
      this.serviceMode,
      this.tabName})
      : super._();
  @override
  WorkspaceCreateInput rebuild(
          void Function(WorkspaceCreateInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkspaceCreateInputBuilder toBuilder() =>
      WorkspaceCreateInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkspaceCreateInput &&
        registerId == other.registerId &&
        branchId == other.branchId &&
        editorId == other.editorId &&
        serviceMode == other.serviceMode &&
        tabName == other.tabName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, registerId.hashCode);
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jc(_$hash, editorId.hashCode);
    _$hash = $jc(_$hash, serviceMode.hashCode);
    _$hash = $jc(_$hash, tabName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkspaceCreateInput')
          ..add('registerId', registerId)
          ..add('branchId', branchId)
          ..add('editorId', editorId)
          ..add('serviceMode', serviceMode)
          ..add('tabName', tabName))
        .toString();
  }
}

class WorkspaceCreateInputBuilder
    implements Builder<WorkspaceCreateInput, WorkspaceCreateInputBuilder> {
  _$WorkspaceCreateInput? _$v;

  String? _registerId;
  String? get registerId => _$this._registerId;
  set registerId(String? registerId) => _$this._registerId = registerId;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  String? _editorId;
  String? get editorId => _$this._editorId;
  set editorId(String? editorId) => _$this._editorId = editorId;

  WorkspaceCreateInputServiceModeEnum? _serviceMode;
  WorkspaceCreateInputServiceModeEnum? get serviceMode => _$this._serviceMode;
  set serviceMode(WorkspaceCreateInputServiceModeEnum? serviceMode) =>
      _$this._serviceMode = serviceMode;

  String? _tabName;
  String? get tabName => _$this._tabName;
  set tabName(String? tabName) => _$this._tabName = tabName;

  WorkspaceCreateInputBuilder() {
    WorkspaceCreateInput._defaults(this);
  }

  WorkspaceCreateInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _registerId = $v.registerId;
      _branchId = $v.branchId;
      _editorId = $v.editorId;
      _serviceMode = $v.serviceMode;
      _tabName = $v.tabName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkspaceCreateInput other) {
    _$v = other as _$WorkspaceCreateInput;
  }

  @override
  void update(void Function(WorkspaceCreateInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkspaceCreateInput build() => _build();

  _$WorkspaceCreateInput _build() {
    final _$result = _$v ??
        _$WorkspaceCreateInput._(
          registerId: registerId,
          branchId: branchId,
          editorId: editorId,
          serviceMode: serviceMode,
          tabName: tabName,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
