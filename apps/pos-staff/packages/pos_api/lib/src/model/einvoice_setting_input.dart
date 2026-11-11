//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'einvoice_setting_input.g.dart';

/// EinvoiceSettingInput
///
/// Properties:
/// * [provider] - A registered provider key
/// * [credentials] - Write-only provider fields; replaces the stored ones
/// * [templateCode]
/// * [symbol]
/// * [sellerName]
/// * [sellerTaxCode]
/// * [sellerAddress]
/// * [consumerLabel] - Printed for a buyer without details; default \"Bán cho người tiêu dùng\"
/// * [lookupUrl]
/// * [buyerLinkHours] - Lifetime of the bill QR link; null keeps it until the end of the business day
/// * [status]
@BuiltValue()
abstract class EinvoiceSettingInput
    implements Built<EinvoiceSettingInput, EinvoiceSettingInputBuilder> {
  /// A registered provider key
  @BuiltValueField(wireName: r'provider')
  String? get provider;

  /// Write-only provider fields; replaces the stored ones
  @BuiltValueField(wireName: r'credentials')
  BuiltMap<String, String>? get credentials;

  @BuiltValueField(wireName: r'template_code')
  String? get templateCode;

  @BuiltValueField(wireName: r'symbol')
  String? get symbol;

  @BuiltValueField(wireName: r'seller_name')
  String? get sellerName;

  @BuiltValueField(wireName: r'seller_tax_code')
  String? get sellerTaxCode;

  @BuiltValueField(wireName: r'seller_address')
  String? get sellerAddress;

  /// Printed for a buyer without details; default \"Bán cho người tiêu dùng\"
  @BuiltValueField(wireName: r'consumer_label')
  String? get consumerLabel;

  @BuiltValueField(wireName: r'lookup_url')
  String? get lookupUrl;

  /// Lifetime of the bill QR link; null keeps it until the end of the business day
  @BuiltValueField(wireName: r'buyer_link_hours')
  int? get buyerLinkHours;

  @BuiltValueField(wireName: r'status')
  EinvoiceSettingInputStatusEnum? get status;
  // enum statusEnum {  active,  disabled,  };

  EinvoiceSettingInput._();

  factory EinvoiceSettingInput([void updates(EinvoiceSettingInputBuilder b)]) =
      _$EinvoiceSettingInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EinvoiceSettingInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EinvoiceSettingInput> get serializer =>
      _$EinvoiceSettingInputSerializer();
}

class _$EinvoiceSettingInputSerializer
    implements PrimitiveSerializer<EinvoiceSettingInput> {
  @override
  final Iterable<Type> types = const [
    EinvoiceSettingInput,
    _$EinvoiceSettingInput
  ];

  @override
  final String wireName = r'EinvoiceSettingInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EinvoiceSettingInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.provider != null) {
      yield r'provider';
      yield serializers.serialize(
        object.provider,
        specifiedType: const FullType(String),
      );
    }
    if (object.credentials != null) {
      yield r'credentials';
      yield serializers.serialize(
        object.credentials,
        specifiedType:
            const FullType(BuiltMap, [FullType(String), FullType(String)]),
      );
    }
    if (object.templateCode != null) {
      yield r'template_code';
      yield serializers.serialize(
        object.templateCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.symbol != null) {
      yield r'symbol';
      yield serializers.serialize(
        object.symbol,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.sellerName != null) {
      yield r'seller_name';
      yield serializers.serialize(
        object.sellerName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.sellerTaxCode != null) {
      yield r'seller_tax_code';
      yield serializers.serialize(
        object.sellerTaxCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.sellerAddress != null) {
      yield r'seller_address';
      yield serializers.serialize(
        object.sellerAddress,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.consumerLabel != null) {
      yield r'consumer_label';
      yield serializers.serialize(
        object.consumerLabel,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.lookupUrl != null) {
      yield r'lookup_url';
      yield serializers.serialize(
        object.lookupUrl,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.buyerLinkHours != null) {
      yield r'buyer_link_hours';
      yield serializers.serialize(
        object.buyerLinkHours,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(EinvoiceSettingInputStatusEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    EinvoiceSettingInput object, {
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
    required EinvoiceSettingInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.provider = valueDes;
          break;
        case r'credentials':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>?;
          if (valueDes == null) continue;
          result.credentials.replace(valueDes);
          break;
        case r'template_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.templateCode = valueDes;
          break;
        case r'symbol':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.symbol = valueDes;
          break;
        case r'seller_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sellerName = valueDes;
          break;
        case r'seller_tax_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sellerTaxCode = valueDes;
          break;
        case r'seller_address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sellerAddress = valueDes;
          break;
        case r'consumer_label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.consumerLabel = valueDes;
          break;
        case r'lookup_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lookupUrl = valueDes;
          break;
        case r'buyer_link_hours':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.buyerLinkHours = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(EinvoiceSettingInputStatusEnum),
          ) as EinvoiceSettingInputStatusEnum?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EinvoiceSettingInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EinvoiceSettingInputBuilder();
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

class EinvoiceSettingInputStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'active')
  static const EinvoiceSettingInputStatusEnum active =
      _$einvoiceSettingInputStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'disabled')
  static const EinvoiceSettingInputStatusEnum disabled =
      _$einvoiceSettingInputStatusEnum_disabled;

  static Serializer<EinvoiceSettingInputStatusEnum> get serializer =>
      _$einvoiceSettingInputStatusEnumSerializer;

  const EinvoiceSettingInputStatusEnum._(String name) : super(name);

  static BuiltSet<EinvoiceSettingInputStatusEnum> get values =>
      _$einvoiceSettingInputStatusEnumValues;
  static EinvoiceSettingInputStatusEnum valueOf(String name) =>
      _$einvoiceSettingInputStatusEnumValueOf(name);
}
