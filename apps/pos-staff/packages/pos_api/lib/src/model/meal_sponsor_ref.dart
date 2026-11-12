//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'meal_sponsor_ref.g.dart';

/// MealSponsorRef
///
/// Properties:
/// * [id]
/// * [name]
@BuiltValue()
abstract class MealSponsorRef
    implements Built<MealSponsorRef, MealSponsorRefBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  MealSponsorRef._();

  factory MealSponsorRef([void updates(MealSponsorRefBuilder b)]) =
      _$MealSponsorRef;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MealSponsorRefBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MealSponsorRef> get serializer =>
      _$MealSponsorRefSerializer();
}

class _$MealSponsorRefSerializer
    implements PrimitiveSerializer<MealSponsorRef> {
  @override
  final Iterable<Type> types = const [MealSponsorRef, _$MealSponsorRef];

  @override
  final String wireName = r'MealSponsorRef';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MealSponsorRef object, {
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
    MealSponsorRef object, {
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
    required MealSponsorRefBuilder result,
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
  MealSponsorRef deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MealSponsorRefBuilder();
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
