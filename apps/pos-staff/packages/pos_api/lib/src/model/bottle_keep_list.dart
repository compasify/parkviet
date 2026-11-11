//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/bottle_keep.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bottle_keep_list.g.dart';

/// BottleKeepList
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class BottleKeepList
    implements Built<BottleKeepList, BottleKeepListBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<BottleKeep> get data;

  BottleKeepList._();

  factory BottleKeepList([void updates(BottleKeepListBuilder b)]) =
      _$BottleKeepList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BottleKeepListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BottleKeepList> get serializer =>
      _$BottleKeepListSerializer();
}

class _$BottleKeepListSerializer
    implements PrimitiveSerializer<BottleKeepList> {
  @override
  final Iterable<Type> types = const [BottleKeepList, _$BottleKeepList];

  @override
  final String wireName = r'BottleKeepList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BottleKeepList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(BottleKeep)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BottleKeepList object, {
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
    required BottleKeepListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BottleKeep)]),
          ) as BuiltList<BottleKeep>;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BottleKeepList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BottleKeepListBuilder();
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
