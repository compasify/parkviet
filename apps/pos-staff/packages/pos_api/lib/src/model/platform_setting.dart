//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'platform_setting.g.dart';

/// PlatformSetting
///
/// Properties:
/// * [platform]
/// * [status]
/// * [commissionRate] - Percent the platform keeps, 0 to 100.
/// * [updatedAt]
@BuiltValue()
abstract class PlatformSetting
    implements Built<PlatformSetting, PlatformSettingBuilder> {
  @BuiltValueField(wireName: r'platform')
  PlatformSettingPlatformEnum get platform;
  // enum platformEnum {  grabfood,  shopeefood,  };

  @BuiltValueField(wireName: r'status')
  PlatformSettingStatusEnum get status;
  // enum statusEnum {  active,  disabled,  };

  /// Percent the platform keeps, 0 to 100.
  @BuiltValueField(wireName: r'commission_rate')
  String get commissionRate;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  PlatformSetting._();

  factory PlatformSetting([void updates(PlatformSettingBuilder b)]) =
      _$PlatformSetting;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlatformSettingBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlatformSetting> get serializer =>
      _$PlatformSettingSerializer();
}

class _$PlatformSettingSerializer
    implements PrimitiveSerializer<PlatformSetting> {
  @override
  final Iterable<Type> types = const [PlatformSetting, _$PlatformSetting];

  @override
  final String wireName = r'PlatformSetting';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlatformSetting object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(PlatformSettingPlatformEnum),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(PlatformSettingStatusEnum),
    );
    yield r'commission_rate';
    yield serializers.serialize(
      object.commissionRate,
      specifiedType: const FullType(String),
    );
    yield r'updated_at';
    yield object.updatedAt == null
        ? null
        : serializers.serialize(
            object.updatedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    PlatformSetting object, {
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
    required PlatformSettingBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PlatformSettingPlatformEnum),
          ) as PlatformSettingPlatformEnum;
          result.platform = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PlatformSettingStatusEnum),
          ) as PlatformSettingStatusEnum;
          result.status = valueDes;
          break;
        case r'commission_rate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.commissionRate = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PlatformSetting deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlatformSettingBuilder();
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

class PlatformSettingPlatformEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'grabfood')
  static const PlatformSettingPlatformEnum grabfood =
      _$platformSettingPlatformEnum_grabfood;
  @BuiltValueEnumConst(wireName: r'shopeefood')
  static const PlatformSettingPlatformEnum shopeefood =
      _$platformSettingPlatformEnum_shopeefood;

  static Serializer<PlatformSettingPlatformEnum> get serializer =>
      _$platformSettingPlatformEnumSerializer;

  const PlatformSettingPlatformEnum._(String name) : super(name);

  static BuiltSet<PlatformSettingPlatformEnum> get values =>
      _$platformSettingPlatformEnumValues;
  static PlatformSettingPlatformEnum valueOf(String name) =>
      _$platformSettingPlatformEnumValueOf(name);
}

class PlatformSettingStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'active')
  static const PlatformSettingStatusEnum active =
      _$platformSettingStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'disabled')
  static const PlatformSettingStatusEnum disabled =
      _$platformSettingStatusEnum_disabled;

  static Serializer<PlatformSettingStatusEnum> get serializer =>
      _$platformSettingStatusEnumSerializer;

  const PlatformSettingStatusEnum._(String name) : super(name);

  static BuiltSet<PlatformSettingStatusEnum> get values =>
      _$platformSettingStatusEnumValues;
  static PlatformSettingStatusEnum valueOf(String name) =>
      _$platformSettingStatusEnumValueOf(name);
}
