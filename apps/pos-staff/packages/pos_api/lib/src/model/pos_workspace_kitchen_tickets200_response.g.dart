// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_workspace_kitchen_tickets200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosWorkspaceKitchenTickets200Response
    extends PosWorkspaceKitchenTickets200Response {
  @override
  final BuiltList<KitchenTicket> data;

  factory _$PosWorkspaceKitchenTickets200Response(
          [void Function(PosWorkspaceKitchenTickets200ResponseBuilder)?
              updates]) =>
      (PosWorkspaceKitchenTickets200ResponseBuilder()..update(updates))
          ._build();

  _$PosWorkspaceKitchenTickets200Response._({required this.data}) : super._();
  @override
  PosWorkspaceKitchenTickets200Response rebuild(
          void Function(PosWorkspaceKitchenTickets200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosWorkspaceKitchenTickets200ResponseBuilder toBuilder() =>
      PosWorkspaceKitchenTickets200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosWorkspaceKitchenTickets200Response && data == other.data;
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
            r'PosWorkspaceKitchenTickets200Response')
          ..add('data', data))
        .toString();
  }
}

class PosWorkspaceKitchenTickets200ResponseBuilder
    implements
        Builder<PosWorkspaceKitchenTickets200Response,
            PosWorkspaceKitchenTickets200ResponseBuilder> {
  _$PosWorkspaceKitchenTickets200Response? _$v;

  ListBuilder<KitchenTicket>? _data;
  ListBuilder<KitchenTicket> get data =>
      _$this._data ??= ListBuilder<KitchenTicket>();
  set data(ListBuilder<KitchenTicket>? data) => _$this._data = data;

  PosWorkspaceKitchenTickets200ResponseBuilder() {
    PosWorkspaceKitchenTickets200Response._defaults(this);
  }

  PosWorkspaceKitchenTickets200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosWorkspaceKitchenTickets200Response other) {
    _$v = other as _$PosWorkspaceKitchenTickets200Response;
  }

  @override
  void update(
      void Function(PosWorkspaceKitchenTickets200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosWorkspaceKitchenTickets200Response build() => _build();

  _$PosWorkspaceKitchenTickets200Response _build() {
    _$PosWorkspaceKitchenTickets200Response _$result;
    try {
      _$result = _$v ??
          _$PosWorkspaceKitchenTickets200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PosWorkspaceKitchenTickets200Response',
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
