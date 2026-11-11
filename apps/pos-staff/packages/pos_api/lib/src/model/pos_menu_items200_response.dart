//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/menu_item_config.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/menu_items_meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_menu_items200_response.g.dart';

/// PosMenuItems200Response
///
/// Properties:
/// * [data]
/// * [meta]
@BuiltValue()
abstract class PosMenuItems200Response
    implements Built<PosMenuItems200Response, PosMenuItems200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<MenuItemConfig> get data;

  @BuiltValueField(wireName: r'meta')
  MenuItemsMeta get meta;

  PosMenuItems200Response._();

  factory PosMenuItems200Response(
          [void updates(PosMenuItems200ResponseBuilder b)]) =
      _$PosMenuItems200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosMenuItems200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosMenuItems200Response> get serializer =>
      _$PosMenuItems200ResponseSerializer();
}

class _$PosMenuItems200ResponseSerializer
    implements PrimitiveSerializer<PosMenuItems200Response> {
  @override
  final Iterable<Type> types = const [
    PosMenuItems200Response,
    _$PosMenuItems200Response
  ];

  @override
  final String wireName = r'PosMenuItems200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosMenuItems200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(MenuItemConfig)]),
    );
    yield r'meta';
    yield serializers.serialize(
      object.meta,
      specifiedType: const FullType(MenuItemsMeta),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosMenuItems200Response object, {
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
    required PosMenuItems200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(MenuItemConfig)]),
          ) as BuiltList<MenuItemConfig>;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MenuItemsMeta),
          ) as MenuItemsMeta;
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
  PosMenuItems200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosMenuItems200ResponseBuilder();
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
