// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_kitchen_send201_response_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosKitchenSend201ResponseMeta extends PosKitchenSend201ResponseMeta {
  @override
  final BuiltList<KitchenTicket> tickets;

  factory _$PosKitchenSend201ResponseMeta(
          [void Function(PosKitchenSend201ResponseMetaBuilder)? updates]) =>
      (PosKitchenSend201ResponseMetaBuilder()..update(updates))._build();

  _$PosKitchenSend201ResponseMeta._({required this.tickets}) : super._();
  @override
  PosKitchenSend201ResponseMeta rebuild(
          void Function(PosKitchenSend201ResponseMetaBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosKitchenSend201ResponseMetaBuilder toBuilder() =>
      PosKitchenSend201ResponseMetaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosKitchenSend201ResponseMeta && tickets == other.tickets;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tickets.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosKitchenSend201ResponseMeta')
          ..add('tickets', tickets))
        .toString();
  }
}

class PosKitchenSend201ResponseMetaBuilder
    implements
        Builder<PosKitchenSend201ResponseMeta,
            PosKitchenSend201ResponseMetaBuilder> {
  _$PosKitchenSend201ResponseMeta? _$v;

  ListBuilder<KitchenTicket>? _tickets;
  ListBuilder<KitchenTicket> get tickets =>
      _$this._tickets ??= ListBuilder<KitchenTicket>();
  set tickets(ListBuilder<KitchenTicket>? tickets) => _$this._tickets = tickets;

  PosKitchenSend201ResponseMetaBuilder() {
    PosKitchenSend201ResponseMeta._defaults(this);
  }

  PosKitchenSend201ResponseMetaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tickets = $v.tickets.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosKitchenSend201ResponseMeta other) {
    _$v = other as _$PosKitchenSend201ResponseMeta;
  }

  @override
  void update(void Function(PosKitchenSend201ResponseMetaBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosKitchenSend201ResponseMeta build() => _build();

  _$PosKitchenSend201ResponseMeta _build() {
    _$PosKitchenSend201ResponseMeta _$result;
    try {
      _$result = _$v ??
          _$PosKitchenSend201ResponseMeta._(
            tickets: tickets.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'tickets';
        tickets.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosKitchenSend201ResponseMeta', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
