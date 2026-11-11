//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/platform_settings.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'platform_settings_result.g.dart';

/// PlatformSettingsResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PlatformSettingsResult
    implements Built<PlatformSettingsResult, PlatformSettingsResultBuilder> {
  @BuiltValueField(wireName: r'data')
  PlatformSettings get data;

  PlatformSettingsResult._();

  factory PlatformSettingsResult(
          [void updates(PlatformSettingsResultBuilder b)]) =
      _$PlatformSettingsResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlatformSettingsResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlatformSettingsResult> get serializer =>
      _$PlatformSettingsResultSerializer();
}

class _$PlatformSettingsResultSerializer
    implements PrimitiveSerializer<PlatformSettingsResult> {
  @override
  final Iterable<Type> types = const [
    PlatformSettingsResult,
    _$PlatformSettingsResult
  ];

  @override
  final String wireName = r'PlatformSettingsResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlatformSettingsResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PlatformSettings),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PlatformSettingsResult object, {
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
    required PlatformSettingsResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PlatformSettings),
          ) as PlatformSettings;
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
  PlatformSettingsResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlatformSettingsResultBuilder();
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
