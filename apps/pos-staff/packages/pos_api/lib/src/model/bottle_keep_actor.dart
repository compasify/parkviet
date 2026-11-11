//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bottle_keep_actor.g.dart';

/// BottleKeepActor
///
/// Properties:
/// * [id]
/// * [name]
@BuiltValue()
abstract class BottleKeepActor
    implements Built<BottleKeepActor, BottleKeepActorBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  BottleKeepActor._();

  factory BottleKeepActor([void updates(BottleKeepActorBuilder b)]) =
      _$BottleKeepActor;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BottleKeepActorBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BottleKeepActor> get serializer =>
      _$BottleKeepActorSerializer();
}

class _$BottleKeepActorSerializer
    implements PrimitiveSerializer<BottleKeepActor> {
  @override
  final Iterable<Type> types = const [BottleKeepActor, _$BottleKeepActor];

  @override
  final String wireName = r'BottleKeepActor';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BottleKeepActor object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BottleKeepActor object, {
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
    required BottleKeepActorBuilder result,
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
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BottleKeepActor deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BottleKeepActorBuilder();
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
