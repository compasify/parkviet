// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_workspace_cup_labels_reprint201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosWorkspaceCupLabelsReprint201Response
    extends PosWorkspaceCupLabelsReprint201Response {
  @override
  final PosWorkspaceCupLabelsReprint201ResponseData data;

  factory _$PosWorkspaceCupLabelsReprint201Response(
          [void Function(PosWorkspaceCupLabelsReprint201ResponseBuilder)?
              updates]) =>
      (PosWorkspaceCupLabelsReprint201ResponseBuilder()..update(updates))
          ._build();

  _$PosWorkspaceCupLabelsReprint201Response._({required this.data}) : super._();
  @override
  PosWorkspaceCupLabelsReprint201Response rebuild(
          void Function(PosWorkspaceCupLabelsReprint201ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosWorkspaceCupLabelsReprint201ResponseBuilder toBuilder() =>
      PosWorkspaceCupLabelsReprint201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosWorkspaceCupLabelsReprint201Response &&
        data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PosWorkspaceCupLabelsReprint201Response')
          ..add('data', data))
        .toString();
  }
}

class PosWorkspaceCupLabelsReprint201ResponseBuilder
    implements
        Builder<PosWorkspaceCupLabelsReprint201Response,
            PosWorkspaceCupLabelsReprint201ResponseBuilder> {
  _$PosWorkspaceCupLabelsReprint201Response? _$v;

  PosWorkspaceCupLabelsReprint201ResponseDataBuilder? _data;
  PosWorkspaceCupLabelsReprint201ResponseDataBuilder get data =>
      _$this._data ??= PosWorkspaceCupLabelsReprint201ResponseDataBuilder();
  set data(PosWorkspaceCupLabelsReprint201ResponseDataBuilder? data) =>
      _$this._data = data;

  PosWorkspaceCupLabelsReprint201ResponseBuilder() {
    PosWorkspaceCupLabelsReprint201Response._defaults(this);
  }

  PosWorkspaceCupLabelsReprint201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosWorkspaceCupLabelsReprint201Response other) {
    _$v = other as _$PosWorkspaceCupLabelsReprint201Response;
  }

  @override
  void update(
      void Function(PosWorkspaceCupLabelsReprint201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosWorkspaceCupLabelsReprint201Response build() => _build();

  _$PosWorkspaceCupLabelsReprint201Response _build() {
    _$PosWorkspaceCupLabelsReprint201Response _$result;
    try {
      _$result = _$v ??
          _$PosWorkspaceCupLabelsReprint201Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosWorkspaceCupLabelsReprint201Response',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
