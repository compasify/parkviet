//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/menu_category.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_menu_categories200_response.g.dart';

/// PosMenuCategories200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosMenuCategories200Response
    implements
        Built<PosMenuCategories200Response,
            PosMenuCategories200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<MenuCategory> get data;

  PosMenuCategories200Response._();

  factory PosMenuCategories200Response(
          [void updates(PosMenuCategories200ResponseBuilder b)]) =
      _$PosMenuCategories200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosMenuCategories200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosMenuCategories200Response> get serializer =>
      _$PosMenuCategories200ResponseSerializer();
}

class _$PosMenuCategories200ResponseSerializer
    implements PrimitiveSerializer<PosMenuCategories200Response> {
  @override
  final Iterable<Type> types = const [
    PosMenuCategories200Response,
    _$PosMenuCategories200Response
  ];

  @override
  final String wireName = r'PosMenuCategories200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosMenuCategories200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(MenuCategory)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosMenuCategories200Response object, {
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
    required PosMenuCategories200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MenuCategory)]),
          ) as BuiltList<MenuCategory>;
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
  PosMenuCategories200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosMenuCategories200ResponseBuilder();
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
