//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kitchen_station.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_station_result.g.dart';

/// KitchenStationResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class KitchenStationResult
    implements Built<KitchenStationResult, KitchenStationResultBuilder> {
  @BuiltValueField(wireName: r'data')
  KitchenStation get data;

  KitchenStationResult._();

  factory KitchenStationResult([void updates(KitchenStationResultBuilder b)]) =
      _$KitchenStationResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenStationResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenStationResult> get serializer =>
      _$KitchenStationResultSerializer();
}

class _$KitchenStationResultSerializer
    implements PrimitiveSerializer<KitchenStationResult> {
  @override
  final Iterable<Type> types = const [
    KitchenStationResult,
    _$KitchenStationResult
  ];

  @override
  final String wireName = r'KitchenStationResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenStationResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(KitchenStation),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenStationResult object, {
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
    required KitchenStationResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(KitchenStation),
          ) as KitchenStation;
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
  KitchenStationResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenStationResultBuilder();
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
