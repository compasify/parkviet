//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/kitchen_menu_item.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_device_kitchen_menu_items200_response.g.dart';

/// PosDeviceKitchenMenuItems200Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosDeviceKitchenMenuItems200Response
    implements
        Built<PosDeviceKitchenMenuItems200Response,
            PosDeviceKitchenMenuItems200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<KitchenMenuItem> get data;

  PosDeviceKitchenMenuItems200Response._();

  factory PosDeviceKitchenMenuItems200Response(
          [void updates(PosDeviceKitchenMenuItems200ResponseBuilder b)]) =
      _$PosDeviceKitchenMenuItems200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosDeviceKitchenMenuItems200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosDeviceKitchenMenuItems200Response> get serializer =>
      _$PosDeviceKitchenMenuItems200ResponseSerializer();
}

class _$PosDeviceKitchenMenuItems200ResponseSerializer
    implements PrimitiveSerializer<PosDeviceKitchenMenuItems200Response> {
  @override
  final Iterable<Type> types = const [
    PosDeviceKitchenMenuItems200Response,
    _$PosDeviceKitchenMenuItems200Response
  ];

  @override
  final String wireName = r'PosDeviceKitchenMenuItems200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosDeviceKitchenMenuItems200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(KitchenMenuItem)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosDeviceKitchenMenuItems200Response object, {
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
    required PosDeviceKitchenMenuItems200ResponseBuilder result,
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
                const FullType(BuiltList, [FullType(KitchenMenuItem)]),
          ) as BuiltList<KitchenMenuItem>;
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
  PosDeviceKitchenMenuItems200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosDeviceKitchenMenuItems200ResponseBuilder();
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
