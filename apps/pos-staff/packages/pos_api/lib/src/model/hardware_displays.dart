//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'hardware_displays.g.dart';

/// HardwareDisplays
///
/// Properties:
/// * [live] - Customer displays paired and not expired.
@BuiltValue()
abstract class HardwareDisplays
    implements Built<HardwareDisplays, HardwareDisplaysBuilder> {
  /// Customer displays paired and not expired.
  @BuiltValueField(wireName: r'live')
  int get live;

  HardwareDisplays._();

  factory HardwareDisplays([void updates(HardwareDisplaysBuilder b)]) =
      _$HardwareDisplays;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HardwareDisplaysBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HardwareDisplays> get serializer =>
      _$HardwareDisplaysSerializer();
}

class _$HardwareDisplaysSerializer
    implements PrimitiveSerializer<HardwareDisplays> {
  @override
  final Iterable<Type> types = const [HardwareDisplays, _$HardwareDisplays];

  @override
  final String wireName = r'HardwareDisplays';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HardwareDisplays object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'live';
    yield serializers.serialize(
      object.live,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    HardwareDisplays object, {
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
    required HardwareDisplaysBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'live':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.live = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  HardwareDisplays deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HardwareDisplaysBuilder();
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
