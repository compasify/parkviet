//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/modifier_group.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_modifier_groups200_response.g.dart';

/// PosModifierGroups200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosModifierGroups200Response
    implements
        Built<PosModifierGroups200Response,
            PosModifierGroups200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<ModifierGroup> get data;

  PosModifierGroups200Response._();

  factory PosModifierGroups200Response(
          [void updates(PosModifierGroups200ResponseBuilder b)]) =
      _$PosModifierGroups200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosModifierGroups200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosModifierGroups200Response> get serializer =>
      _$PosModifierGroups200ResponseSerializer();
}

class _$PosModifierGroups200ResponseSerializer
    implements PrimitiveSerializer<PosModifierGroups200Response> {
  @override
  final Iterable<Type> types = const [
    PosModifierGroups200Response,
    _$PosModifierGroups200Response
  ];

  @override
  final String wireName = r'PosModifierGroups200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosModifierGroups200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(ModifierGroup)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosModifierGroups200Response object, {
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
    required PosModifierGroups200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ModifierGroup)]),
          ) as BuiltList<ModifierGroup>;
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
  PosModifierGroups200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosModifierGroups200ResponseBuilder();
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
