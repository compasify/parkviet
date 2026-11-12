//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kiosk_menu_variant.g.dart';

/// KioskMenuVariant
///
/// Properties:
/// * [id]
/// * [name]
/// * [price]
/// * [priceLabel]
@BuiltValue()
abstract class KioskMenuVariant
    implements Built<KioskMenuVariant, KioskMenuVariantBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'price')
  String get price;

  @BuiltValueField(wireName: r'price_label')
  String? get priceLabel;

  KioskMenuVariant._();

  factory KioskMenuVariant([void updates(KioskMenuVariantBuilder b)]) =
      _$KioskMenuVariant;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KioskMenuVariantBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KioskMenuVariant> get serializer =>
      _$KioskMenuVariantSerializer();
}

class _$KioskMenuVariantSerializer
    implements PrimitiveSerializer<KioskMenuVariant> {
  @override
  final Iterable<Type> types = const [KioskMenuVariant, _$KioskMenuVariant];

  @override
  final String wireName = r'KioskMenuVariant';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KioskMenuVariant object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield object.name == null
        ? null
        : serializers.serialize(
            object.name,
            specifiedType: const FullType.nullable(String),
          );
    yield r'price';
    yield serializers.serialize(
      object.price,
      specifiedType: const FullType(String),
    );
    yield r'price_label';
    yield object.priceLabel == null
        ? null
        : serializers.serialize(
            object.priceLabel,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    KioskMenuVariant object, {
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
    required KioskMenuVariantBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.price = valueDes;
          break;
        case r'price_label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.priceLabel = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KioskMenuVariant deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KioskMenuVariantBuilder();
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
