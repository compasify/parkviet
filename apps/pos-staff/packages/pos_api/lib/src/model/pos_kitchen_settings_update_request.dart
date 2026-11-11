//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_kitchen_settings_update_request.g.dart';

/// One change per call; `void_reasons` when sent, else `kitchen_send_trigger`.
///
/// Properties:
/// * [branchId]
/// * [kitchenSendTrigger]
/// * [voidReasons]
@BuiltValue()
abstract class PosKitchenSettingsUpdateRequest
    implements
        Built<PosKitchenSettingsUpdateRequest,
            PosKitchenSettingsUpdateRequestBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'kitchen_send_trigger')
  PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum? get kitchenSendTrigger;
  // enum kitchenSendTriggerEnum {  on_complete,  manual,  };

  @BuiltValueField(wireName: r'void_reasons')
  BuiltList<String>? get voidReasons;

  PosKitchenSettingsUpdateRequest._();

  factory PosKitchenSettingsUpdateRequest(
          [void updates(PosKitchenSettingsUpdateRequestBuilder b)]) =
      _$PosKitchenSettingsUpdateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosKitchenSettingsUpdateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosKitchenSettingsUpdateRequest> get serializer =>
      _$PosKitchenSettingsUpdateRequestSerializer();
}

class _$PosKitchenSettingsUpdateRequestSerializer
    implements PrimitiveSerializer<PosKitchenSettingsUpdateRequest> {
  @override
  final Iterable<Type> types = const [
    PosKitchenSettingsUpdateRequest,
    _$PosKitchenSettingsUpdateRequest
  ];

  @override
  final String wireName = r'PosKitchenSettingsUpdateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosKitchenSettingsUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    if (object.kitchenSendTrigger != null) {
      yield r'kitchen_send_trigger';
      yield serializers.serialize(
        object.kitchenSendTrigger,
        specifiedType: const FullType(
            PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum),
      );
    }
    if (object.voidReasons != null) {
      yield r'void_reasons';
      yield serializers.serialize(
        object.voidReasons,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PosKitchenSettingsUpdateRequest object, {
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
    required PosKitchenSettingsUpdateRequestBuilder result,
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
        case r'kitchen_send_trigger':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum),
          ) as PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum?;
          if (valueDes == null) continue;
          result.kitchenSendTrigger = valueDes;
          break;
        case r'void_reasons':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.voidReasons.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosKitchenSettingsUpdateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosKitchenSettingsUpdateRequestBuilder();
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

class PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'on_complete')
  static const PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum
      onComplete =
      _$posKitchenSettingsUpdateRequestKitchenSendTriggerEnum_onComplete;
  @BuiltValueEnumConst(wireName: r'manual')
  static const PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum manual =
      _$posKitchenSettingsUpdateRequestKitchenSendTriggerEnum_manual;

  static Serializer<PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum>
      get serializer =>
          _$posKitchenSettingsUpdateRequestKitchenSendTriggerEnumSerializer;

  const PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum._(String name)
      : super(name);

  static BuiltSet<PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum>
      get values =>
          _$posKitchenSettingsUpdateRequestKitchenSendTriggerEnumValues;
  static PosKitchenSettingsUpdateRequestKitchenSendTriggerEnum valueOf(
          String name) =>
      _$posKitchenSettingsUpdateRequestKitchenSendTriggerEnumValueOf(name);
}
