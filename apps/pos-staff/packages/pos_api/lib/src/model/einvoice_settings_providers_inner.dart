//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'einvoice_settings_providers_inner.g.dart';

/// EinvoiceSettingsProvidersInner
///
/// Properties:
/// * [key]
/// * [label]
/// * [sandbox]
/// * [credentialFields]
/// * [taxCodeLookup]
@BuiltValue()
abstract class EinvoiceSettingsProvidersInner
    implements
        Built<EinvoiceSettingsProvidersInner,
            EinvoiceSettingsProvidersInnerBuilder> {
  @BuiltValueField(wireName: r'key')
  String get key;

  @BuiltValueField(wireName: r'label')
  String get label;

  @BuiltValueField(wireName: r'sandbox')
  bool get sandbox;

  @BuiltValueField(wireName: r'credential_fields')
  BuiltList<String> get credentialFields;

  @BuiltValueField(wireName: r'tax_code_lookup')
  bool get taxCodeLookup;

  EinvoiceSettingsProvidersInner._();

  factory EinvoiceSettingsProvidersInner(
          [void updates(EinvoiceSettingsProvidersInnerBuilder b)]) =
      _$EinvoiceSettingsProvidersInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EinvoiceSettingsProvidersInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EinvoiceSettingsProvidersInner> get serializer =>
      _$EinvoiceSettingsProvidersInnerSerializer();
}

class _$EinvoiceSettingsProvidersInnerSerializer
    implements PrimitiveSerializer<EinvoiceSettingsProvidersInner> {
  @override
  final Iterable<Type> types = const [
    EinvoiceSettingsProvidersInner,
    _$EinvoiceSettingsProvidersInner
  ];

  @override
  final String wireName = r'EinvoiceSettingsProvidersInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EinvoiceSettingsProvidersInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'key';
    yield serializers.serialize(
      object.key,
      specifiedType: const FullType(String),
    );
    yield r'label';
    yield serializers.serialize(
      object.label,
      specifiedType: const FullType(String),
    );
    yield r'sandbox';
    yield serializers.serialize(
      object.sandbox,
      specifiedType: const FullType(bool),
    );
    yield r'credential_fields';
    yield serializers.serialize(
      object.credentialFields,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'tax_code_lookup';
    yield serializers.serialize(
      object.taxCodeLookup,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EinvoiceSettingsProvidersInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EinvoiceSettingsProvidersInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.key = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.label = valueDes;
          break;
        case r'sandbox':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.sandbox = valueDes;
          break;
        case r'credential_fields':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.credentialFields.replace(valueDes);
          break;
        case r'tax_code_lookup':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.taxCodeLookup = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EinvoiceSettingsProvidersInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EinvoiceSettingsProvidersInnerBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
