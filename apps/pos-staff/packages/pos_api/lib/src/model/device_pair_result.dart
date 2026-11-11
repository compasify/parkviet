//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/device.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_pair_result.g.dart';

/// DevicePairResult
///
/// Properties:
/// * [device]
/// * [token] - Send as `Authorization: Device <token>`. Shown once.
@BuiltValue()
abstract class DevicePairResult
    implements Built<DevicePairResult, DevicePairResultBuilder> {
  @BuiltValueField(wireName: r'device')
  Device get device;

  /// Send as `Authorization: Device <token>`. Shown once.
  @BuiltValueField(wireName: r'token')
  String get token;

  DevicePairResult._();

  factory DevicePairResult([void updates(DevicePairResultBuilder b)]) =
      _$DevicePairResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DevicePairResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DevicePairResult> get serializer =>
      _$DevicePairResultSerializer();
}

class _$DevicePairResultSerializer
    implements PrimitiveSerializer<DevicePairResult> {
  @override
  final Iterable<Type> types = const [DevicePairResult, _$DevicePairResult];

  @override
  final String wireName = r'DevicePairResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DevicePairResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'device';
    yield serializers.serialize(
      object.device,
      specifiedType: const FullType(Device),
    );
    yield r'token';
    yield serializers.serialize(
      object.token,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DevicePairResult object, {
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
    required DevicePairResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'device':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Device),
          ) as Device;
          result.device.replace(valueDes);
          break;
        case r'token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.token = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DevicePairResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DevicePairResultBuilder();
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
