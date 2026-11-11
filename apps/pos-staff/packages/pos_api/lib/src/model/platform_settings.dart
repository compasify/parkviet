//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/platform_setting.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'platform_settings.g.dart';

/// PlatformSettings
///
/// Properties:
/// * [moduleEnabled] - Whether `fnb.delivery_platforms` is on at the branch.
/// * [platforms]
@BuiltValue()
abstract class PlatformSettings
    implements Built<PlatformSettings, PlatformSettingsBuilder> {
  /// Whether `fnb.delivery_platforms` is on at the branch.
  @BuiltValueField(wireName: r'module_enabled')
  bool get moduleEnabled;

  @BuiltValueField(wireName: r'platforms')
  BuiltList<PlatformSetting> get platforms;

  PlatformSettings._();

  factory PlatformSettings([void updates(PlatformSettingsBuilder b)]) =
      _$PlatformSettings;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlatformSettingsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlatformSettings> get serializer =>
      _$PlatformSettingsSerializer();
}

class _$PlatformSettingsSerializer
    implements PrimitiveSerializer<PlatformSettings> {
  @override
  final Iterable<Type> types = const [PlatformSettings, _$PlatformSettings];

  @override
  final String wireName = r'PlatformSettings';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlatformSettings object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'module_enabled';
    yield serializers.serialize(
      object.moduleEnabled,
      specifiedType: const FullType(bool),
    );
    yield r'platforms';
    yield serializers.serialize(
      object.platforms,
      specifiedType: const FullType(BuiltList, [FullType(PlatformSetting)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PlatformSettings object, {
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
    required PlatformSettingsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'module_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.moduleEnabled = valueDes;
          break;
        case r'platforms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(PlatformSetting)]),
          ) as BuiltList<PlatformSetting>;
          result.platforms.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PlatformSettings deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlatformSettingsBuilder();
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
