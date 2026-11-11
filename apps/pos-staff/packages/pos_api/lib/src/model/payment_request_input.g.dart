// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_request_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PaymentRequestInput extends PaymentRequestInput {
  @override
  final String? note;

  factory _$PaymentRequestInput(
          [void Function(PaymentRequestInputBuilder)? updates]) =>
      (PaymentRequestInputBuilder()..update(updates))._build();

  _$PaymentRequestInput._({this.note}) : super._();
  @override
  PaymentRequestInput rebuild(
          void Function(PaymentRequestInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentRequestInputBuilder toBuilder() =>
      PaymentRequestInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentRequestInput && note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PaymentRequestInput')
          ..add('note', note))
        .toString();
  }
}

class PaymentRequestInputBuilder
    implements Builder<PaymentRequestInput, PaymentRequestInputBuilder> {
  _$PaymentRequestInput? _$v;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  PaymentRequestInputBuilder() {
    PaymentRequestInput._defaults(this);
  }

  PaymentRequestInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentRequestInput other) {
    _$v = other as _$PaymentRequestInput;
  }

  @override
  void update(void Function(PaymentRequestInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentRequestInput build() => _build();

  _$PaymentRequestInput _build() {
    final _$result = _$v ??
        _$PaymentRequestInput._(
          note: note,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
