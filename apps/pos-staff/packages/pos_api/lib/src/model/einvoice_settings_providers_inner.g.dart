// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'einvoice_settings_providers_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EinvoiceSettingsProvidersInner extends EinvoiceSettingsProvidersInner {
  @override
  final String key;
  @override
  final String label;
  @override
  final bool sandbox;
  @override
  final BuiltList<String> credentialFields;
  @override
  final bool taxCodeLookup;

  factory _$EinvoiceSettingsProvidersInner(
          [void Function(EinvoiceSettingsProvidersInnerBuilder)? updates]) =>
      (EinvoiceSettingsProvidersInnerBuilder()..update(updates))._build();

  _$EinvoiceSettingsProvidersInner._(
      {required this.key,
      required this.label,
      required this.sandbox,
      required this.credentialFields,
      required this.taxCodeLookup})
      : super._();
  @override
  EinvoiceSettingsProvidersInner rebuild(
          void Function(EinvoiceSettingsProvidersInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EinvoiceSettingsProvidersInnerBuilder toBuilder() =>
      EinvoiceSettingsProvidersInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EinvoiceSettingsProvidersInner &&
        key == other.key &&
        label == other.label &&
        sandbox == other.sandbox &&
        credentialFields == other.credentialFields &&
        taxCodeLookup == other.taxCodeLookup;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, sandbox.hashCode);
    _$hash = $jc(_$hash, credentialFields.hashCode);
    _$hash = $jc(_$hash, taxCodeLookup.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EinvoiceSettingsProvidersInner')
          ..add('key', key)
          ..add('label', label)
          ..add('sandbox', sandbox)
          ..add('credentialFields', credentialFields)
          ..add('taxCodeLookup', taxCodeLookup))
        .toString();
  }
}

class EinvoiceSettingsProvidersInnerBuilder
    implements
        Builder<EinvoiceSettingsProvidersInner,
            EinvoiceSettingsProvidersInnerBuilder> {
  _$EinvoiceSettingsProvidersInner? _$v;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  bool? _sandbox;
  bool? get sandbox => _$this._sandbox;
  set sandbox(bool? sandbox) => _$this._sandbox = sandbox;

  ListBuilder<String>? _credentialFields;
  ListBuilder<String> get credentialFields =>
      _$this._credentialFields ??= ListBuilder<String>();
  set credentialFields(ListBuilder<String>? credentialFields) =>
      _$this._credentialFields = credentialFields;

  bool? _taxCodeLookup;
  bool? get taxCodeLookup => _$this._taxCodeLookup;
  set taxCodeLookup(bool? taxCodeLookup) =>
      _$this._taxCodeLookup = taxCodeLookup;

  EinvoiceSettingsProvidersInnerBuilder() {
    EinvoiceSettingsProvidersInner._defaults(this);
  }

  EinvoiceSettingsProvidersInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _label = $v.label;
      _sandbox = $v.sandbox;
      _credentialFields = $v.credentialFields.toBuilder();
      _taxCodeLookup = $v.taxCodeLookup;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EinvoiceSettingsProvidersInner other) {
    _$v = other as _$EinvoiceSettingsProvidersInner;
  }

  @override
  void update(void Function(EinvoiceSettingsProvidersInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EinvoiceSettingsProvidersInner build() => _build();

  _$EinvoiceSettingsProvidersInner _build() {
    _$EinvoiceSettingsProvidersInner _$result;
    try {
      _$result = _$v ??
          _$EinvoiceSettingsProvidersInner._(
            key: BuiltValueNullFieldError.checkNotNull(
                key, r'EinvoiceSettingsProvidersInner', 'key'),
            label: BuiltValueNullFieldError.checkNotNull(
                label, r'EinvoiceSettingsProvidersInner', 'label'),
            sandbox: BuiltValueNullFieldError.checkNotNull(
                sandbox, r'EinvoiceSettingsProvidersInner', 'sandbox'),
            credentialFields: credentialFields.build(),
            taxCodeLookup: BuiltValueNullFieldError.checkNotNull(taxCodeLookup,
                r'EinvoiceSettingsProvidersInner', 'taxCodeLookup'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'credentialFields';
        credentialFields.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'EinvoiceSettingsProvidersInner', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
