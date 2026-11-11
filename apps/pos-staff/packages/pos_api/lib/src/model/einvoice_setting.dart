//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'einvoice_setting.g.dart';

/// EinvoiceSetting
///
/// Properties:
/// * [id]
/// * [branchId]
/// * [branchName]
/// * [provider]
/// * [status]
/// * [templateCode]
/// * [symbol]
/// * [sellerName]
/// * [sellerTaxCode]
/// * [sellerAddress]
/// * [consumerLabel]
/// * [lookupUrl]
/// * [buyerLinkHours]
/// * [credentialFields] - Names of the credential fields that are set (never their values)
/// * [updatedAt]
@BuiltValue()
abstract class EinvoiceSetting
    implements Built<EinvoiceSetting, EinvoiceSettingBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'branch_id')
  String? get branchId;

  @BuiltValueField(wireName: r'branch_name')
  String? get branchName;

  @BuiltValueField(wireName: r'provider')
  String get provider;

  @BuiltValueField(wireName: r'status')
  EinvoiceSettingStatusEnum get status;
  // enum statusEnum {  active,  disabled,  };

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

  @BuiltValueField(wireName: r'consumer_label')
  String? get consumerLabel;

  @BuiltValueField(wireName: r'lookup_url')
  String? get lookupUrl;

  @BuiltValueField(wireName: r'buyer_link_hours')
  int? get buyerLinkHours;

  /// Names of the credential fields that are set (never their values)
  @BuiltValueField(wireName: r'credential_fields')
  BuiltList<String> get credentialFields;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  EinvoiceSetting._();

  factory EinvoiceSetting([void updates(EinvoiceSettingBuilder b)]) =
      _$EinvoiceSetting;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EinvoiceSettingBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EinvoiceSetting> get serializer =>
      _$EinvoiceSettingSerializer();
}

class _$EinvoiceSettingSerializer
    implements PrimitiveSerializer<EinvoiceSetting> {
  @override
  final Iterable<Type> types = const [EinvoiceSetting, _$EinvoiceSetting];

  @override
  final String wireName = r'EinvoiceSetting';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EinvoiceSetting object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'branch_id';
    yield object.branchId == null
        ? null
        : serializers.serialize(
            object.branchId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'branch_name';
    yield object.branchName == null
        ? null
        : serializers.serialize(
            object.branchName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'provider';
    yield serializers.serialize(
      object.provider,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(EinvoiceSettingStatusEnum),
    );
    yield r'template_code';
    yield object.templateCode == null
        ? null
        : serializers.serialize(
            object.templateCode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'symbol';
    yield object.symbol == null
        ? null
        : serializers.serialize(
            object.symbol,
            specifiedType: const FullType.nullable(String),
          );
    yield r'seller_name';
    yield object.sellerName == null
        ? null
        : serializers.serialize(
            object.sellerName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'seller_tax_code';
    yield object.sellerTaxCode == null
        ? null
        : serializers.serialize(
            object.sellerTaxCode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'seller_address';
    yield object.sellerAddress == null
        ? null
        : serializers.serialize(
            object.sellerAddress,
            specifiedType: const FullType.nullable(String),
          );
    yield r'consumer_label';
    yield object.consumerLabel == null
        ? null
        : serializers.serialize(
            object.consumerLabel,
            specifiedType: const FullType.nullable(String),
          );
    yield r'lookup_url';
    yield object.lookupUrl == null
        ? null
        : serializers.serialize(
            object.lookupUrl,
            specifiedType: const FullType.nullable(String),
          );
    yield r'buyer_link_hours';
    yield object.buyerLinkHours == null
        ? null
        : serializers.serialize(
            object.buyerLinkHours,
            specifiedType: const FullType.nullable(int),
          );
    yield r'credential_fields';
    yield serializers.serialize(
      object.credentialFields,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'updated_at';
    yield object.updatedAt == null
        ? null
        : serializers.serialize(
            object.updatedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    EinvoiceSetting object, {
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
    required EinvoiceSettingBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.branchId = valueDes;
          break;
        case r'branch_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.branchName = valueDes;
          break;
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.provider = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EinvoiceSettingStatusEnum),
          ) as EinvoiceSettingStatusEnum;
          result.status = valueDes;
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
        case r'credential_fields':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.credentialFields.replace(valueDes);
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EinvoiceSetting deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EinvoiceSettingBuilder();
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

class EinvoiceSettingStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'active')
  static const EinvoiceSettingStatusEnum active =
      _$einvoiceSettingStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'disabled')
  static const EinvoiceSettingStatusEnum disabled =
      _$einvoiceSettingStatusEnum_disabled;

  static Serializer<EinvoiceSettingStatusEnum> get serializer =>
      _$einvoiceSettingStatusEnumSerializer;

  const EinvoiceSettingStatusEnum._(String name) : super(name);

  static BuiltSet<EinvoiceSettingStatusEnum> get values =>
      _$einvoiceSettingStatusEnumValues;
  static EinvoiceSettingStatusEnum valueOf(String name) =>
      _$einvoiceSettingStatusEnumValueOf(name);
}
