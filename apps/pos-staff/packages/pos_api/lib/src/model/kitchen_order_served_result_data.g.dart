// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_order_served_result_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenOrderServedResultData extends KitchenOrderServedResultData {
  @override
  final String workspaceId;
  @override
  final BuiltList<KitchenTicket> tickets;

  factory _$KitchenOrderServedResultData(
          [void Function(KitchenOrderServedResultDataBuilder)? updates]) =>
      (KitchenOrderServedResultDataBuilder()..update(updates))._build();

  _$KitchenOrderServedResultData._(
      {required this.workspaceId, required this.tickets})
      : super._();
  @override
  KitchenOrderServedResultData rebuild(
          void Function(KitchenOrderServedResultDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenOrderServedResultDataBuilder toBuilder() =>
      KitchenOrderServedResultDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenOrderServedResultData &&
        workspaceId == other.workspaceId &&
        tickets == other.tickets;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, tickets.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenOrderServedResultData')
          ..add('workspaceId', workspaceId)
          ..add('tickets', tickets))
        .toString();
  }
}

class KitchenOrderServedResultDataBuilder
    implements
        Builder<KitchenOrderServedResultData,
            KitchenOrderServedResultDataBuilder> {
  _$KitchenOrderServedResultData? _$v;

  String? _workspaceId;
  String? get workspaceId => _$this._workspaceId;
  set workspaceId(String? workspaceId) => _$this._workspaceId = workspaceId;

  ListBuilder<KitchenTicket>? _tickets;
  ListBuilder<KitchenTicket> get tickets =>
      _$this._tickets ??= ListBuilder<KitchenTicket>();
  set tickets(ListBuilder<KitchenTicket>? tickets) => _$this._tickets = tickets;

  KitchenOrderServedResultDataBuilder() {
    KitchenOrderServedResultData._defaults(this);
  }

  KitchenOrderServedResultDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _workspaceId = $v.workspaceId;
      _tickets = $v.tickets.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenOrderServedResultData other) {
    _$v = other as _$KitchenOrderServedResultData;
  }

  @override
  void update(void Function(KitchenOrderServedResultDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenOrderServedResultData build() => _build();

  _$KitchenOrderServedResultData _build() {
    _$KitchenOrderServedResultData _$result;
    try {
      _$result = _$v ??
          _$KitchenOrderServedResultData._(
            workspaceId: BuiltValueNullFieldError.checkNotNull(
                workspaceId, r'KitchenOrderServedResultData', 'workspaceId'),
            tickets: tickets.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'tickets';
        tickets.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KitchenOrderServedResultData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
