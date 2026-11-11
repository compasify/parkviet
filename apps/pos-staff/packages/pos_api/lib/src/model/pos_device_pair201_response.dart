//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/device_pair_result.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_device_pair201_response.g.dart';

/// PosDevicePair201Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosDevicePair201Response
    implements
        Built<PosDevicePair201Response, PosDevicePair201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DevicePairResult get data;

  PosDevicePair201Response._();

  factory PosDevicePair201Response(
          [void updates(PosDevicePair201ResponseBuilder b)]) =
      _$PosDevicePair201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosDevicePair201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosDevicePair201Response> get serializer =>
      _$PosDevicePair201ResponseSerializer();
}

class _$PosDevicePair201ResponseSerializer
    implements PrimitiveSerializer<PosDevicePair201Response> {
  @override
  final Iterable<Type> types = const [
    PosDevicePair201Response,
    _$PosDevicePair201Response
  ];

  @override
  final String wireName = r'PosDevicePair201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosDevicePair201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(DevicePairResult),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosDevicePair201Response object, {
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
    required PosDevicePair201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DevicePairResult),
          ) as DevicePairResult;
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
  PosDevicePair201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosDevicePair201ResponseBuilder();
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
