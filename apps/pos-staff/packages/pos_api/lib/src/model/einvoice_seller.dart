//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'einvoice_seller.g.dart';

/// EinvoiceSeller
///
/// Properties:
/// * [name]
/// * [taxCode]
/// * [address]
/// * [outletCode]
/// * [outletName]
@BuiltValue()
abstract class EinvoiceSeller
    implements Built<EinvoiceSeller, EinvoiceSellerBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'tax_code')
  String? get taxCode;

  @BuiltValueField(wireName: r'address')
  String? get address;

  @BuiltValueField(wireName: r'outlet_code')
  String? get outletCode;

  @BuiltValueField(wireName: r'outlet_name')
  String? get outletName;

  EinvoiceSeller._();

  factory EinvoiceSeller([void updates(EinvoiceSellerBuilder b)]) =
      _$EinvoiceSeller;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EinvoiceSellerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EinvoiceSeller> get serializer =>
      _$EinvoiceSellerSerializer();
}

class _$EinvoiceSellerSerializer
    implements PrimitiveSerializer<EinvoiceSeller> {
  @override
  final Iterable<Type> types = const [EinvoiceSeller, _$EinvoiceSeller];

  @override
  final String wireName = r'EinvoiceSeller';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EinvoiceSeller object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.taxCode != null) {
      yield r'tax_code';
      yield serializers.serialize(
        object.taxCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.address != null) {
      yield r'address';
      yield serializers.serialize(
        object.address,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.outletCode != null) {
      yield r'outlet_code';
      yield serializers.serialize(
        object.outletCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.outletName != null) {
      yield r'outlet_name';
      yield serializers.serialize(
        object.outletName,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    EinvoiceSeller object, {
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
    required EinvoiceSellerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'tax_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.taxCode = valueDes;
          break;
        case r'address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.address = valueDes;
          break;
        case r'outlet_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.outletCode = valueDes;
          break;
        case r'outlet_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.outletName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EinvoiceSeller deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EinvoiceSellerBuilder();
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
