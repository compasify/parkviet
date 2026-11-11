// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_send_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenSendMeta extends KitchenSendMeta {
  @override
  final BuiltList<KitchenTicket> tickets;
  @override
  final int ticketCount;

  factory _$KitchenSendMeta([void Function(KitchenSendMetaBuilder)? updates]) =>
      (KitchenSendMetaBuilder()..update(updates))._build();

  _$KitchenSendMeta._({required this.tickets, required this.ticketCount})
      : super._();
  @override
  KitchenSendMeta rebuild(void Function(KitchenSendMetaBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenSendMetaBuilder toBuilder() => KitchenSendMetaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenSendMeta &&
        tickets == other.tickets &&
        ticketCount == other.ticketCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tickets.hashCode);
    _$hash = $jc(_$hash, ticketCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KitchenSendMeta')
          ..add('tickets', tickets)
          ..add('ticketCount', ticketCount))
        .toString();
  }
}

class KitchenSendMetaBuilder
    implements Builder<KitchenSendMeta, KitchenSendMetaBuilder> {
  _$KitchenSendMeta? _$v;

  ListBuilder<KitchenTicket>? _tickets;
  ListBuilder<KitchenTicket> get tickets =>
      _$this._tickets ??= ListBuilder<KitchenTicket>();
  set tickets(ListBuilder<KitchenTicket>? tickets) => _$this._tickets = tickets;

  int? _ticketCount;
  int? get ticketCount => _$this._ticketCount;
  set ticketCount(int? ticketCount) => _$this._ticketCount = ticketCount;

  KitchenSendMetaBuilder() {
    KitchenSendMeta._defaults(this);
  }

  KitchenSendMetaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tickets = $v.tickets.toBuilder();
      _ticketCount = $v.ticketCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenSendMeta other) {
    _$v = other as _$KitchenSendMeta;
  }

  @override
  void update(void Function(KitchenSendMetaBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenSendMeta build() => _build();

  _$KitchenSendMeta _build() {
    _$KitchenSendMeta _$result;
    try {
      _$result = _$v ??
          _$KitchenSendMeta._(
            tickets: tickets.build(),
            ticketCount: BuiltValueNullFieldError.checkNotNull(
                ticketCount, r'KitchenSendMeta', 'ticketCount'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'tickets';
        tickets.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KitchenSendMeta', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
