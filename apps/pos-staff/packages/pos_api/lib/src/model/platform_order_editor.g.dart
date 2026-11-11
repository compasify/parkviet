// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_order_editor.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlatformOrderEditor extends PlatformOrderEditor {
  @override
  final String editorId;

  factory _$PlatformOrderEditor(
          [void Function(PlatformOrderEditorBuilder)? updates]) =>
      (PlatformOrderEditorBuilder()..update(updates))._build();

  _$PlatformOrderEditor._({required this.editorId}) : super._();
  @override
  PlatformOrderEditor rebuild(
          void Function(PlatformOrderEditorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlatformOrderEditorBuilder toBuilder() =>
      PlatformOrderEditorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlatformOrderEditor && editorId == other.editorId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, editorId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlatformOrderEditor')
          ..add('editorId', editorId))
        .toString();
  }
}

class PlatformOrderEditorBuilder
    implements Builder<PlatformOrderEditor, PlatformOrderEditorBuilder> {
  _$PlatformOrderEditor? _$v;

  String? _editorId;
  String? get editorId => _$this._editorId;
  set editorId(String? editorId) => _$this._editorId = editorId;

  PlatformOrderEditorBuilder() {
    PlatformOrderEditor._defaults(this);
  }

  PlatformOrderEditorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _editorId = $v.editorId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlatformOrderEditor other) {
    _$v = other as _$PlatformOrderEditor;
  }

  @override
  void update(void Function(PlatformOrderEditorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlatformOrderEditor build() => _build();

  _$PlatformOrderEditor _build() {
    final _$result = _$v ??
        _$PlatformOrderEditor._(
          editorId: BuiltValueNullFieldError.checkNotNull(
              editorId, r'PlatformOrderEditor', 'editorId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
