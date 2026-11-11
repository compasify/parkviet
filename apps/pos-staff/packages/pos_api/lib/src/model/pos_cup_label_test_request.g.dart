// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_cup_label_test_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PosCupLabelTestRequest extends PosCupLabelTestRequest {
  @override
  final String branchId;

  factory _$PosCupLabelTestRequest(
          [void Function(PosCupLabelTestRequestBuilder)? updates]) =>
      (PosCupLabelTestRequestBuilder()..update(updates))._build();

  _$PosCupLabelTestRequest._({required this.branchId}) : super._();
  @override
  PosCupLabelTestRequest rebuild(
          void Function(PosCupLabelTestRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PosCupLabelTestRequestBuilder toBuilder() =>
      PosCupLabelTestRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PosCupLabelTestRequest && branchId == other.branchId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, branchId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PosCupLabelTestRequest')
          ..add('branchId', branchId))
        .toString();
  }
}

class PosCupLabelTestRequestBuilder
    implements Builder<PosCupLabelTestRequest, PosCupLabelTestRequestBuilder> {
  _$PosCupLabelTestRequest? _$v;

  String? _branchId;
  String? get branchId => _$this._branchId;
  set branchId(String? branchId) => _$this._branchId = branchId;

  PosCupLabelTestRequestBuilder() {
    PosCupLabelTestRequest._defaults(this);
  }

  PosCupLabelTestRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _branchId = $v.branchId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PosCupLabelTestRequest other) {
    _$v = other as _$PosCupLabelTestRequest;
  }

  @override
  void update(void Function(PosCupLabelTestRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PosCupLabelTestRequest build() => _build();

  _$PosCupLabelTestRequest _build() {
    final _$result = _$v ??
        _$PosCupLabelTestRequest._(
          branchId: BuiltValueNullFieldError.checkNotNull(
              branchId, r'PosCupLabelTestRequest', 'branchId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
