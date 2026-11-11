// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_ticket_list.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KitchenTicketList extends KitchenTicketList {
  @override
  final BuiltList<KitchenTicket> data;

  factory _$KitchenTicketList(
          [void Function(KitchenTicketListBuilder)? updates]) =>
      (KitchenTicketListBuilder()..update(updates))._build();

  _$KitchenTicketList._({required this.data}) : super._();
  @override
  KitchenTicketList rebuild(void Function(KitchenTicketListBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KitchenTicketListBuilder toBuilder() =>
      KitchenTicketListBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KitchenTicketList && data == other.data;
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
    return (newBuiltValueToStringHelper(r'KitchenTicketList')
          ..add('data', data))
        .toString();
  }
}

class KitchenTicketListBuilder
    implements Builder<KitchenTicketList, KitchenTicketListBuilder> {
  _$KitchenTicketList? _$v;

  ListBuilder<KitchenTicket>? _data;
  ListBuilder<KitchenTicket> get data =>
      _$this._data ??= ListBuilder<KitchenTicket>();
  set data(ListBuilder<KitchenTicket>? data) => _$this._data = data;

  KitchenTicketListBuilder() {
    KitchenTicketList._defaults(this);
  }

  KitchenTicketListBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KitchenTicketList other) {
    _$v = other as _$KitchenTicketList;
  }

  @override
  void update(void Function(KitchenTicketListBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KitchenTicketList build() => _build();

  _$KitchenTicketList _build() {
    _$KitchenTicketList _$result;
    try {
      _$result = _$v ??
          _$KitchenTicketList._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KitchenTicketList', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
