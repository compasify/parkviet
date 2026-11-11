//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'resource_manual_status_input.g.dart';

/// ResourceManualStatusInput
///
/// Properties:
/// * [manualStatus]
@BuiltValue()
abstract class ResourceManualStatusInput
    implements
        Built<ResourceManualStatusInput, ResourceManualStatusInputBuilder> {
  @BuiltValueField(wireName: r'manual_status')
  ResourceManualStatusInputManualStatusEnum get manualStatus;
  // enum manualStatusEnum {  available,  cleaning,  out_of_service,  };

  ResourceManualStatusInput._();

  factory ResourceManualStatusInput(
          [void updates(ResourceManualStatusInputBuilder b)]) =
      _$ResourceManualStatusInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResourceManualStatusInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResourceManualStatusInput> get serializer =>
      _$ResourceManualStatusInputSerializer();
}

class _$ResourceManualStatusInputSerializer
    implements PrimitiveSerializer<ResourceManualStatusInput> {
  @override
  final Iterable<Type> types = const [
    ResourceManualStatusInput,
    _$ResourceManualStatusInput
  ];

  @override
  final String wireName = r'ResourceManualStatusInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResourceManualStatusInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'manual_status';
    yield serializers.serialize(
      object.manualStatus,
      specifiedType: const FullType(ResourceManualStatusInputManualStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ResourceManualStatusInput object, {
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
    required ResourceManualStatusInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'manual_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(ResourceManualStatusInputManualStatusEnum),
          ) as ResourceManualStatusInputManualStatusEnum;
          result.manualStatus = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ResourceManualStatusInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResourceManualStatusInputBuilder();
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

class ResourceManualStatusInputManualStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'available')
  static const ResourceManualStatusInputManualStatusEnum available =
      _$resourceManualStatusInputManualStatusEnum_available;
  @BuiltValueEnumConst(wireName: r'cleaning')
  static const ResourceManualStatusInputManualStatusEnum cleaning =
      _$resourceManualStatusInputManualStatusEnum_cleaning;
  @BuiltValueEnumConst(wireName: r'out_of_service')
  static const ResourceManualStatusInputManualStatusEnum outOfService =
      _$resourceManualStatusInputManualStatusEnum_outOfService;

  static Serializer<ResourceManualStatusInputManualStatusEnum> get serializer =>
      _$resourceManualStatusInputManualStatusEnumSerializer;

  const ResourceManualStatusInputManualStatusEnum._(String name) : super(name);

  static BuiltSet<ResourceManualStatusInputManualStatusEnum> get values =>
      _$resourceManualStatusInputManualStatusEnumValues;
  static ResourceManualStatusInputManualStatusEnum valueOf(String name) =>
      _$resourceManualStatusInputManualStatusEnumValueOf(name);
}
