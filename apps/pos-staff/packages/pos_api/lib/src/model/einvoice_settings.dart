//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/einvoice_settings_providers_inner.dart';
import 'package:pos_api/src/model/einvoice_setting.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'einvoice_settings.g.dart';

/// EinvoiceSettings
///
/// Properties:
/// * [einvoiceType]
/// * [providers]
/// * [settings]
/// * [publicLink] - Whether the server has a public address for the bill QR (POS_PUBLIC_BASE_URL)
@BuiltValue()
abstract class EinvoiceSettings
    implements Built<EinvoiceSettings, EinvoiceSettingsBuilder> {
  @BuiltValueField(wireName: r'einvoice_type')
  EinvoiceSettingsEinvoiceTypeEnum get einvoiceType;
  // enum einvoiceTypeEnum {  none,  cash_register,  coded,  };

  @BuiltValueField(wireName: r'providers')
  BuiltList<EinvoiceSettingsProvidersInner> get providers;

  @BuiltValueField(wireName: r'settings')
  BuiltList<EinvoiceSetting> get settings;

  /// Whether the server has a public address for the bill QR (POS_PUBLIC_BASE_URL)
  @BuiltValueField(wireName: r'public_link')
  bool get publicLink;

  EinvoiceSettings._();

  factory EinvoiceSettings([void updates(EinvoiceSettingsBuilder b)]) =
      _$EinvoiceSettings;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EinvoiceSettingsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EinvoiceSettings> get serializer =>
      _$EinvoiceSettingsSerializer();
}

class _$EinvoiceSettingsSerializer
    implements PrimitiveSerializer<EinvoiceSettings> {
  @override
  final Iterable<Type> types = const [EinvoiceSettings, _$EinvoiceSettings];

  @override
  final String wireName = r'EinvoiceSettings';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EinvoiceSettings object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'einvoice_type';
    yield serializers.serialize(
      object.einvoiceType,
      specifiedType: const FullType(EinvoiceSettingsEinvoiceTypeEnum),
    );
    yield r'providers';
    yield serializers.serialize(
      object.providers,
      specifiedType:
          const FullType(BuiltList, [FullType(EinvoiceSettingsProvidersInner)]),
    );
    yield r'settings';
    yield serializers.serialize(
      object.settings,
      specifiedType: const FullType(BuiltList, [FullType(EinvoiceSetting)]),
    );
    yield r'public_link';
    yield serializers.serialize(
      object.publicLink,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EinvoiceSettings object, {
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
    required EinvoiceSettingsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'einvoice_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EinvoiceSettingsEinvoiceTypeEnum),
          ) as EinvoiceSettingsEinvoiceTypeEnum;
          result.einvoiceType = valueDes;
          break;
        case r'providers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(EinvoiceSettingsProvidersInner)]),
          ) as BuiltList<EinvoiceSettingsProvidersInner>;
          result.providers.replace(valueDes);
          break;
        case r'settings':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(EinvoiceSetting)]),
          ) as BuiltList<EinvoiceSetting>;
          result.settings.replace(valueDes);
          break;
        case r'public_link':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.publicLink = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EinvoiceSettings deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EinvoiceSettingsBuilder();
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

class EinvoiceSettingsEinvoiceTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'none')
  static const EinvoiceSettingsEinvoiceTypeEnum none =
      _$einvoiceSettingsEinvoiceTypeEnum_none;
  @BuiltValueEnumConst(wireName: r'cash_register')
  static const EinvoiceSettingsEinvoiceTypeEnum cashRegister =
      _$einvoiceSettingsEinvoiceTypeEnum_cashRegister;
  @BuiltValueEnumConst(wireName: r'coded')
  static const EinvoiceSettingsEinvoiceTypeEnum coded =
      _$einvoiceSettingsEinvoiceTypeEnum_coded;

  static Serializer<EinvoiceSettingsEinvoiceTypeEnum> get serializer =>
      _$einvoiceSettingsEinvoiceTypeEnumSerializer;

  const EinvoiceSettingsEinvoiceTypeEnum._(String name) : super(name);

  static BuiltSet<EinvoiceSettingsEinvoiceTypeEnum> get values =>
      _$einvoiceSettingsEinvoiceTypeEnumValues;
  static EinvoiceSettingsEinvoiceTypeEnum valueOf(String name) =>
      _$einvoiceSettingsEinvoiceTypeEnumValueOf(name);
}
