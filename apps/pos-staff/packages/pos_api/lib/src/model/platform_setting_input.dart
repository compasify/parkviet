//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'platform_setting_input.g.dart';

/// PlatformSettingInput
///
/// Properties:
/// * [branchId]
/// * [platform]
/// * [status]
/// * [commissionRate]
@BuiltValue()
abstract class PlatformSettingInput
    implements Built<PlatformSettingInput, PlatformSettingInputBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'platform')
  PlatformSettingInputPlatformEnum get platform;
  // enum platformEnum {  grabfood,  shopeefood,  };

  @BuiltValueField(wireName: r'status')
  PlatformSettingInputStatusEnum get status;
  // enum statusEnum {  active,  disabled,  };

  @BuiltValueField(wireName: r'commission_rate')
  String get commissionRate;

  PlatformSettingInput._();

  factory PlatformSettingInput([void updates(PlatformSettingInputBuilder b)]) =
      _$PlatformSettingInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlatformSettingInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlatformSettingInput> get serializer =>
      _$PlatformSettingInputSerializer();
}

class _$PlatformSettingInputSerializer
    implements PrimitiveSerializer<PlatformSettingInput> {
  @override
  final Iterable<Type> types = const [
    PlatformSettingInput,
    _$PlatformSettingInput
  ];

  @override
  final String wireName = r'PlatformSettingInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlatformSettingInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(PlatformSettingInputPlatformEnum),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(PlatformSettingInputStatusEnum),
    );
    yield r'commission_rate';
    yield serializers.serialize(
      object.commissionRate,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PlatformSettingInput object, {
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
    required PlatformSettingInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PlatformSettingInputPlatformEnum),
          ) as PlatformSettingInputPlatformEnum;
          result.platform = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PlatformSettingInputStatusEnum),
          ) as PlatformSettingInputStatusEnum;
          result.status = valueDes;
          break;
        case r'commission_rate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.commissionRate = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PlatformSettingInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlatformSettingInputBuilder();
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

class PlatformSettingInputPlatformEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'grabfood')
  static const PlatformSettingInputPlatformEnum grabfood =
      _$platformSettingInputPlatformEnum_grabfood;
  @BuiltValueEnumConst(wireName: r'shopeefood')
  static const PlatformSettingInputPlatformEnum shopeefood =
      _$platformSettingInputPlatformEnum_shopeefood;

  static Serializer<PlatformSettingInputPlatformEnum> get serializer =>
      _$platformSettingInputPlatformEnumSerializer;

  const PlatformSettingInputPlatformEnum._(String name) : super(name);

  static BuiltSet<PlatformSettingInputPlatformEnum> get values =>
      _$platformSettingInputPlatformEnumValues;
  static PlatformSettingInputPlatformEnum valueOf(String name) =>
      _$platformSettingInputPlatformEnumValueOf(name);
}

class PlatformSettingInputStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'active')
  static const PlatformSettingInputStatusEnum active =
      _$platformSettingInputStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'disabled')
  static const PlatformSettingInputStatusEnum disabled =
      _$platformSettingInputStatusEnum_disabled;

  static Serializer<PlatformSettingInputStatusEnum> get serializer =>
      _$platformSettingInputStatusEnumSerializer;

  const PlatformSettingInputStatusEnum._(String name) : super(name);

  static BuiltSet<PlatformSettingInputStatusEnum> get values =>
      _$platformSettingInputStatusEnumValues;
  static PlatformSettingInputStatusEnum valueOf(String name) =>
      _$platformSettingInputStatusEnumValueOf(name);
}
