// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_workspace_cup_labels_reprint201_response_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosWorkspaceCupLabelsReprint201ResponseData
    extends PosWorkspaceCupLabelsReprint201ResponseData {
  @override
  final BuiltList<PrintJob> jobs;

  factory _$PosWorkspaceCupLabelsReprint201ResponseData(
          [void Function(PosWorkspaceCupLabelsReprint201ResponseDataBuilder)?
              updates]) =>
      (PosWorkspaceCupLabelsReprint201ResponseDataBuilder()..update(updates))
          ._build();

  _$PosWorkspaceCupLabelsReprint201ResponseData._({required this.jobs})
      : super._();
  @override
  PosWorkspaceCupLabelsReprint201ResponseData rebuild(
          void Function(PosWorkspaceCupLabelsReprint201ResponseDataBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosWorkspaceCupLabelsReprint201ResponseDataBuilder toBuilder() =>
      PosWorkspaceCupLabelsReprint201ResponseDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosWorkspaceCupLabelsReprint201ResponseData &&
        jobs == other.jobs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, jobs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PosWorkspaceCupLabelsReprint201ResponseData')
          ..add('jobs', jobs))
        .toString();
  }
}

class PosWorkspaceCupLabelsReprint201ResponseDataBuilder
    implements
        Builder<PosWorkspaceCupLabelsReprint201ResponseData,
            PosWorkspaceCupLabelsReprint201ResponseDataBuilder> {
  _$PosWorkspaceCupLabelsReprint201ResponseData? _$v;

  ListBuilder<PrintJob>? _jobs;
  ListBuilder<PrintJob> get jobs => _$this._jobs ??= ListBuilder<PrintJob>();
  set jobs(ListBuilder<PrintJob>? jobs) => _$this._jobs = jobs;

  PosWorkspaceCupLabelsReprint201ResponseDataBuilder() {
    PosWorkspaceCupLabelsReprint201ResponseData._defaults(this);
  }

  PosWorkspaceCupLabelsReprint201ResponseDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _jobs = $v.jobs.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosWorkspaceCupLabelsReprint201ResponseData other) {
    _$v = other as _$PosWorkspaceCupLabelsReprint201ResponseData;
  }

  @override
  void update(
      void Function(PosWorkspaceCupLabelsReprint201ResponseDataBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PosWorkspaceCupLabelsReprint201ResponseData build() => _build();

  _$PosWorkspaceCupLabelsReprint201ResponseData _build() {
    _$PosWorkspaceCupLabelsReprint201ResponseData _$result;
    try {
      _$result = _$v ??
          _$PosWorkspaceCupLabelsReprint201ResponseData._(
            jobs: jobs.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'jobs';
        jobs.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosWorkspaceCupLabelsReprint201ResponseData',
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
