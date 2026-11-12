// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timed_session_command.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TimedSessionCommandWarningsEnum
    _$timedSessionCommandWarningsEnum_outsideOperatingHours =
    const TimedSessionCommandWarningsEnum._('outsideOperatingHours');

TimedSessionCommandWarningsEnum _$timedSessionCommandWarningsEnumValueOf(
    String name) {
  switch (name) {
    case 'outsideOperatingHours':
      return _$timedSessionCommandWarningsEnum_outsideOperatingHours;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TimedSessionCommandWarningsEnum>
    _$timedSessionCommandWarningsEnumValues = BuiltSet<
        TimedSessionCommandWarningsEnum>(const <TimedSessionCommandWarningsEnum>[
  _$timedSessionCommandWarningsEnum_outsideOperatingHours,
]);

Serializer<TimedSessionCommandWarningsEnum>
    _$timedSessionCommandWarningsEnumSerializer =
    _$TimedSessionCommandWarningsEnumSerializer();

class _$TimedSessionCommandWarningsEnumSerializer
    implements PrimitiveSerializer<TimedSessionCommandWarningsEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'outsideOperatingHours': 'outside_operating_hours',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'outside_operating_hours': 'outsideOperatingHours',
  };

  @override
  final Iterable<Type> types = const <Type>[TimedSessionCommandWarningsEnum];
  @override
  final String wireName = 'TimedSessionCommandWarningsEnum';

  @override
  Object serialize(
          Serializers serializers, TimedSessionCommandWarningsEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TimedSessionCommandWarningsEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TimedSessionCommandWarningsEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TimedSessionCommand extends TimedSessionCommand {
  @override
  final BuiltList<TimedSessionCommandWarningsEnum>? warnings;
  @override
  final Workspace workspace;
  @override
  final TimedSession timedSession;

  factory _$TimedSessionCommand(
          [void Function(TimedSessionCommandBuilder)? updates]) =>
      (TimedSessionCommandBuilder()..update(updates))._build();

  _$TimedSessionCommand._(
      {this.warnings, required this.workspace, required this.timedSession})
      : super._();
  @override
  TimedSessionCommand rebuild(
          void Function(TimedSessionCommandBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TimedSessionCommandBuilder toBuilder() =>
      TimedSessionCommandBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TimedSessionCommand &&
        warnings == other.warnings &&
        workspace == other.workspace &&
        timedSession == other.timedSession;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, warnings.hashCode);
    _$hash = $jc(_$hash, workspace.hashCode);
    _$hash = $jc(_$hash, timedSession.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TimedSessionCommand')
          ..add('warnings', warnings)
          ..add('workspace', workspace)
          ..add('timedSession', timedSession))
        .toString();
  }
}

class TimedSessionCommandBuilder
    implements Builder<TimedSessionCommand, TimedSessionCommandBuilder> {
  _$TimedSessionCommand? _$v;

  ListBuilder<TimedSessionCommandWarningsEnum>? _warnings;
  ListBuilder<TimedSessionCommandWarningsEnum> get warnings =>
      _$this._warnings ??= ListBuilder<TimedSessionCommandWarningsEnum>();
  set warnings(ListBuilder<TimedSessionCommandWarningsEnum>? warnings) =>
      _$this._warnings = warnings;

  WorkspaceBuilder? _workspace;
  WorkspaceBuilder get workspace => _$this._workspace ??= WorkspaceBuilder();
  set workspace(WorkspaceBuilder? workspace) => _$this._workspace = workspace;

  TimedSessionBuilder? _timedSession;
  TimedSessionBuilder get timedSession =>
      _$this._timedSession ??= TimedSessionBuilder();
  set timedSession(TimedSessionBuilder? timedSession) =>
      _$this._timedSession = timedSession;

  TimedSessionCommandBuilder() {
    TimedSessionCommand._defaults(this);
  }

  TimedSessionCommandBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _warnings = $v.warnings?.toBuilder();
      _workspace = $v.workspace.toBuilder();
      _timedSession = $v.timedSession.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TimedSessionCommand other) {
    _$v = other as _$TimedSessionCommand;
  }

  @override
  void update(void Function(TimedSessionCommandBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TimedSessionCommand build() => _build();

  _$TimedSessionCommand _build() {
    _$TimedSessionCommand _$result;
    try {
      _$result = _$v ??
          _$TimedSessionCommand._(
            warnings: _warnings?.build(),
            workspace: workspace.build(),
            timedSession: timedSession.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'warnings';
        _warnings?.build();
        _$failedField = 'workspace';
        workspace.build();
        _$failedField = 'timedSession';
        timedSession.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TimedSessionCommand', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
