//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kitchen_void.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_void_meta.g.dart';

/// KitchenVoidMeta
///
/// Properties:
/// * [kitchenVoid]
@BuiltValue()
abstract class KitchenVoidMeta
    implements Built<KitchenVoidMeta, KitchenVoidMetaBuilder> {
  @BuiltValueField(wireName: r'kitchen_void')
  KitchenVoid get kitchenVoid;

  KitchenVoidMeta._();

  factory KitchenVoidMeta([void updates(KitchenVoidMetaBuilder b)]) =
      _$KitchenVoidMeta;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenVoidMetaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenVoidMeta> get serializer =>
      _$KitchenVoidMetaSerializer();
}

class _$KitchenVoidMetaSerializer
    implements PrimitiveSerializer<KitchenVoidMeta> {
  @override
  final Iterable<Type> types = const [KitchenVoidMeta, _$KitchenVoidMeta];

  @override
  final String wireName = r'KitchenVoidMeta';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenVoidMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kitchen_void';
    yield serializers.serialize(
      object.kitchenVoid,
      specifiedType: const FullType(KitchenVoid),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenVoidMeta object, {
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
    required KitchenVoidMetaBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kitchen_void':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KitchenVoid),
          ) as KitchenVoid;
          result.kitchenVoid.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KitchenVoidMeta deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenVoidMetaBuilder();
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
