// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_history.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenHistory extends KitchenHistory {
  @override
  final String workspaceId;
  @override
  final BuiltList<KitchenHistoryEntry> entries;

  factory _$KitchenHistory([void Function(KitchenHistoryBuilder)? updates]) =>
      (KitchenHistoryBuilder()..update(updates))._build();

  _$KitchenHistory._({required this.workspaceId, required this.entries})
      : super._();
  @override
  KitchenHistory rebuild(void Function(KitchenHistoryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenHistoryBuilder toBuilder() => KitchenHistoryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenHistory &&
        workspaceId == other.workspaceId &&
        entries == other.entries;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, entries.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenHistory')
          ..add('workspaceId', workspaceId)
          ..add('entries', entries))
        .toString();
  }
}

class KitchenHistoryBuilder
    implements Builder<KitchenHistory, KitchenHistoryBuilder> {
  _$KitchenHistory? _$v;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  ListBuilder<KitchenHistoryEntry>? _entries;
  ListBuilder<KitchenHistoryEntry> get entries =>
      _$this._entries ??= ListBuilder<KitchenHistoryEntry>();
  set entries(ListBuilder<KitchenHistoryEntry>? entries) =>
      _$this._entries = entries;

  KitchenHistoryBuilder() {
    KitchenHistory._defaults(this);
  }

  KitchenHistoryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _workspaceId = $v.workspaceId;
      _entries = $v.entries.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenHistory other) {
    _$v = other as _$KitchenHistory;
  }

  @override
  void update(void Function(KitchenHistoryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenHistory build() => _build();

  _$KitchenHistory _build() {
    _$KitchenHistory _$result;
    try {
      _$result = _$v ??
          _$KitchenHistory._(
            workspaceId: BuiltValueNullFieldError.checkNotNull(
                workspaceId, r'KitchenHistory', 'workspaceId'),
            entries: entries.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'entries';
        entries.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KitchenHistory', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
