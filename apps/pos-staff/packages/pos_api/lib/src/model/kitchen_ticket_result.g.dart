// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_ticket_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenTicketResult extends KitchenTicketResult {
  @override
  final KitchenTicket data;

  factory _$KitchenTicketResult(
          [void Function(KitchenTicketResultBuilder)? updates]) =>
      (KitchenTicketResultBuilder()..update(updates))._build();

  _$KitchenTicketResult._({required this.data}) : super._();
  @override
  KitchenTicketResult rebuild(
          void Function(KitchenTicketResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenTicketResultBuilder toBuilder() =>
      KitchenTicketResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenTicketResult && data == other.data;
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
    return (newBuiltValueToStringHelper(r'KitchenTicketResult')
          ..add('data', data))
        .toString();
  }
}

class KitchenTicketResultBuilder
    implements Builder<KitchenTicketResult, KitchenTicketResultBuilder> {
  _$KitchenTicketResult? _$v;

  KitchenTicketBuilder? _data;
  KitchenTicketBuilder get data => _$this._data ??= KitchenTicketBuilder();
  set data(KitchenTicketBuilder? data) => _$this._data = data;

  KitchenTicketResultBuilder() {
    KitchenTicketResult._defaults(this);
  }

  KitchenTicketResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenTicketResult other) {
    _$v = other as _$KitchenTicketResult;
  }

  @override
  void update(void Function(KitchenTicketResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenTicketResult build() => _build();

  _$KitchenTicketResult _build() {
    _$KitchenTicketResult _$result;
    try {
      _$result = _$v ??
          _$KitchenTicketResult._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KitchenTicketResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
