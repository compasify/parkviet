//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_device_pair_request.g.dart';

/// PosDevicePairRequest
///
/// Properties:
/// * [code]
/// * [platform]
/// * [name]
/// * [appVersion]
@BuiltValue()
abstract class PosDevicePairRequest
    implements Built<PosDevicePairRequest, PosDevicePairRequestBuilder> {
  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'platform')
  PosDevicePairRequestPlatformEnum get platform;
  // enum platformEnum {  android,  ios,  web,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'app_version')
  String? get appVersion;

  PosDevicePairRequest._();

  factory PosDevicePairRequest([void updates(PosDevicePairRequestBuilder b)]) =
      _$PosDevicePairRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosDevicePairRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosDevicePairRequest> get serializer =>
      _$PosDevicePairRequestSerializer();
}

class _$PosDevicePairRequestSerializer
    implements PrimitiveSerializer<PosDevicePairRequest> {
  @override
  final Iterable<Type> types = const [
    PosDevicePairRequest,
    _$PosDevicePairRequest
  ];

  @override
  final String wireName = r'PosDevicePairRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosDevicePairRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(PosDevicePairRequestPlatformEnum),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.appVersion != null) {
      yield r'app_version';
      yield serializers.serialize(
        object.appVersion,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PosDevicePairRequest object, {
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
    required PosDevicePairRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PosDevicePairRequestPlatformEnum),
          ) as PosDevicePairRequestPlatformEnum;
          result.platform = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'app_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.appVersion = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosDevicePairRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosDevicePairRequestBuilder();
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

class PosDevicePairRequestPlatformEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'android')
  static const PosDevicePairRequestPlatformEnum android =
      _$posDevicePairRequestPlatformEnum_android;
  @BuiltValueEnumConst(wireName: r'ios')
  static const PosDevicePairRequestPlatformEnum ios =
      _$posDevicePairRequestPlatformEnum_ios;
  @BuiltValueEnumConst(wireName: r'web')
  static const PosDevicePairRequestPlatformEnum web =
      _$posDevicePairRequestPlatformEnum_web;

  static Serializer<PosDevicePairRequestPlatformEnum> get serializer =>
      _$posDevicePairRequestPlatformEnumSerializer;

  const PosDevicePairRequestPlatformEnum._(String name) : super(name);

  static BuiltSet<PosDevicePairRequestPlatformEnum> get values =>
      _$posDevicePairRequestPlatformEnumValues;
  static PosDevicePairRequestPlatformEnum valueOf(String name) =>
      _$posDevicePairRequestPlatformEnumValueOf(name);
}
