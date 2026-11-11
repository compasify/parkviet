//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/buffet_tier.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'buffet_tier_list.g.dart';

/// BuffetTierList
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class BuffetTierList
    implements Built<BuffetTierList, BuffetTierListBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<BuffetTier> get data;

  BuffetTierList._();

  factory BuffetTierList([void updates(BuffetTierListBuilder b)]) =
      _$BuffetTierList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BuffetTierListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BuffetTierList> get serializer =>
      _$BuffetTierListSerializer();
}

class _$BuffetTierListSerializer
    implements PrimitiveSerializer<BuffetTierList> {
  @override
  final Iterable<Type> types = const [BuffetTierList, _$BuffetTierList];

  @override
  final String wireName = r'BuffetTierList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BuffetTierList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(BuffetTier)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BuffetTierList object, {
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
    required BuffetTierListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BuffetTier)]),
          ) as BuiltList<BuffetTier>;
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
  BuffetTierList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BuffetTierListBuilder();
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
