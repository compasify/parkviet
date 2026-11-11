// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ready_feed_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReadyFeedResult extends ReadyFeedResult {
  @override
  final ReadyFeed data;

  factory _$ReadyFeedResult([void Function(ReadyFeedResultBuilder)? updates]) =>
      (ReadyFeedResultBuilder()..update(updates))._build();

  _$ReadyFeedResult._({required this.data}) : super._();
  @override
  ReadyFeedResult rebuild(void Function(ReadyFeedResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReadyFeedResultBuilder toBuilder() => ReadyFeedResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReadyFeedResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'ReadyFeedResult')..add('data', data))
        .toString();
  }
}

class ReadyFeedResultBuilder
    implements Builder<ReadyFeedResult, ReadyFeedResultBuilder> {
  _$ReadyFeedResult? _$v;

  ReadyFeedBuilder? _data;
  ReadyFeedBuilder get data => _$this._data ??= ReadyFeedBuilder();
  set data(ReadyFeedBuilder? data) => _$this._data = data;

  ReadyFeedResultBuilder() {
    ReadyFeedResult._defaults(this);
  }

  ReadyFeedResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReadyFeedResult other) {
    _$v = other as _$ReadyFeedResult;
  }

  @override
  void update(void Function(ReadyFeedResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReadyFeedResult build() => _build();

  _$ReadyFeedResult _build() {
    _$ReadyFeedResult _$result;
    try {
      _$result = _$v ??
          _$ReadyFeedResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ReadyFeedResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
