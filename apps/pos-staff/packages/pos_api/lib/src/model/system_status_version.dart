//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'system_status_version.g.dart';

/// SystemStatusVersion
///
/// Properties:
/// * [app] - PARKVIET_VERSION baked into the image, `development` otherwise
/// * [spree]
/// * [rails]
@BuiltValue()
abstract class SystemStatusVersion
    implements Built<SystemStatusVersion, SystemStatusVersionBuilder> {
  /// PARKVIET_VERSION baked into the image, `development` otherwise
  @BuiltValueField(wireName: r'app')
  String get app;

  @BuiltValueField(wireName: r'spree')
  String get spree;

  @BuiltValueField(wireName: r'rails')
  String get rails;

  SystemStatusVersion._();

  factory SystemStatusVersion([void updates(SystemStatusVersionBuilder b)]) =
      _$SystemStatusVersion;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SystemStatusVersionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SystemStatusVersion> get serializer =>
      _$SystemStatusVersionSerializer();
}

class _$SystemStatusVersionSerializer
    implements PrimitiveSerializer<SystemStatusVersion> {
  @override
  final Iterable<Type> types = const [
    SystemStatusVersion,
    _$SystemStatusVersion
  ];

  @override
  final String wireName = r'SystemStatusVersion';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SystemStatusVersion object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'app';
    yield serializers.serialize(
      object.app,
      specifiedType: const FullType(String),
    );
    yield r'spree';
    yield serializers.serialize(
      object.spree,
      specifiedType: const FullType(String),
    );
    yield r'rails';
    yield serializers.serialize(
      object.rails,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SystemStatusVersion object, {
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
    required SystemStatusVersionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'app':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.app = valueDes;
          break;
        case r'spree':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.spree = valueDes;
          break;
        case r'rails':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rails = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SystemStatusVersion deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SystemStatusVersionBuilder();
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
