//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/platform_setting.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'platform_setting_result.g.dart';

/// PlatformSettingResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PlatformSettingResult
    implements Built<PlatformSettingResult, PlatformSettingResultBuilder> {
  @BuiltValueField(wireName: r'data')
  PlatformSetting get data;

  PlatformSettingResult._();

  factory PlatformSettingResult(
      [void updates(PlatformSettingResultBuilder b)]) = _$PlatformSettingResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlatformSettingResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlatformSettingResult> get serializer =>
      _$PlatformSettingResultSerializer();
}

class _$PlatformSettingResultSerializer
    implements PrimitiveSerializer<PlatformSettingResult> {
  @override
  final Iterable<Type> types = const [
    PlatformSettingResult,
    _$PlatformSettingResult
  ];

  @override
  final String wireName = r'PlatformSettingResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlatformSettingResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PlatformSetting),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PlatformSettingResult object, {
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
    required PlatformSettingResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PlatformSetting),
          ) as PlatformSetting;
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
  PlatformSettingResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlatformSettingResultBuilder();
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
