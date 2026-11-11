//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'hardware_einvoice.g.dart';

/// HardwareEinvoice
///
/// Properties:
/// * [type]
/// * [provider]
/// * [configured]
/// * [missingFields]
@BuiltValue()
abstract class HardwareEinvoice
    implements Built<HardwareEinvoice, HardwareEinvoiceBuilder> {
  @BuiltValueField(wireName: r'type')
  HardwareEinvoiceTypeEnum get type;
  // enum typeEnum {  none,  cash_register,  coded,  };

  @BuiltValueField(wireName: r'provider')
  String get provider;

  @BuiltValueField(wireName: r'configured')
  bool get configured;

  @BuiltValueField(wireName: r'missing_fields')
  BuiltList<String> get missingFields;

  HardwareEinvoice._();

  factory HardwareEinvoice([void updates(HardwareEinvoiceBuilder b)]) =
      _$HardwareEinvoice;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HardwareEinvoiceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HardwareEinvoice> get serializer =>
      _$HardwareEinvoiceSerializer();
}

class _$HardwareEinvoiceSerializer
    implements PrimitiveSerializer<HardwareEinvoice> {
  @override
  final Iterable<Type> types = const [HardwareEinvoice, _$HardwareEinvoice];

  @override
  final String wireName = r'HardwareEinvoice';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HardwareEinvoice object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(HardwareEinvoiceTypeEnum),
    );
    yield r'provider';
    yield serializers.serialize(
      object.provider,
      specifiedType: const FullType(String),
    );
    yield r'configured';
    yield serializers.serialize(
      object.configured,
      specifiedType: const FullType(bool),
    );
    yield r'missing_fields';
    yield serializers.serialize(
      object.missingFields,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    HardwareEinvoice object, {
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
    required HardwareEinvoiceBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HardwareEinvoiceTypeEnum),
          ) as HardwareEinvoiceTypeEnum;
          result.type = valueDes;
          break;
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.provider = valueDes;
          break;
        case r'configured':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.configured = valueDes;
          break;
        case r'missing_fields':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.missingFields.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  HardwareEinvoice deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HardwareEinvoiceBuilder();
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

class HardwareEinvoiceTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'none')
  static const HardwareEinvoiceTypeEnum none = _$hardwareEinvoiceTypeEnum_none;
  @BuiltValueEnumConst(wireName: r'cash_register')
  static const HardwareEinvoiceTypeEnum cashRegister =
      _$hardwareEinvoiceTypeEnum_cashRegister;
  @BuiltValueEnumConst(wireName: r'coded')
  static const HardwareEinvoiceTypeEnum coded =
      _$hardwareEinvoiceTypeEnum_coded;

  static Serializer<HardwareEinvoiceTypeEnum> get serializer =>
      _$hardwareEinvoiceTypeEnumSerializer;

  const HardwareEinvoiceTypeEnum._(String name) : super(name);

  static BuiltSet<HardwareEinvoiceTypeEnum> get values =>
      _$hardwareEinvoiceTypeEnumValues;
  static HardwareEinvoiceTypeEnum valueOf(String name) =>
      _$hardwareEinvoiceTypeEnumValueOf(name);
}
