//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kitchen_void_meta.dart';
import 'package:pos_api/src/model/workspace.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_void_result.g.dart';

/// KitchenVoidResult
///
/// Properties:
/// * [data]
/// * [meta]
@BuiltValue()
abstract class KitchenVoidResult
    implements Built<KitchenVoidResult, KitchenVoidResultBuilder> {
  @BuiltValueField(wireName: r'data')
  Workspace get data;

  @BuiltValueField(wireName: r'meta')
  KitchenVoidMeta get meta;

  KitchenVoidResult._();

  factory KitchenVoidResult([void updates(KitchenVoidResultBuilder b)]) =
      _$KitchenVoidResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenVoidResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenVoidResult> get serializer =>
      _$KitchenVoidResultSerializer();
}

class _$KitchenVoidResultSerializer
    implements PrimitiveSerializer<KitchenVoidResult> {
  @override
  final Iterable<Type> types = const [KitchenVoidResult, _$KitchenVoidResult];

  @override
  final String wireName = r'KitchenVoidResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenVoidResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Workspace),
    );
    yield r'meta';
    yield serializers.serialize(
      object.meta,
      specifiedType: const FullType(KitchenVoidMeta),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenVoidResult object, {
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
    required KitchenVoidResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Workspace),
          ) as Workspace;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KitchenVoidMeta),
          ) as KitchenVoidMeta;
          result.meta.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KitchenVoidResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenVoidResultBuilder();
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
