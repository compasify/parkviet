//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/kitchen_station_input.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_kitchen_station_create_request.g.dart';

/// PosKitchenStationCreateRequest
///
/// Properties:
/// * [name]
/// * [kind]
/// * [printerId]
/// * [expoStationId] - An `expo` station of the same branch; null hands nothing to a pass.
/// * [kdsEnabled]
/// * [isDefault]
/// * [warnAfterMinutes]
/// * [lateAfterMinutes]
/// * [position]
/// * [active]
/// * [branchId]
@BuiltValue()
abstract class PosKitchenStationCreateRequest
    implements
        KitchenStationInput,
        Built<PosKitchenStationCreateRequest,
            PosKitchenStationCreateRequestBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  PosKitchenStationCreateRequest._();

  factory PosKitchenStationCreateRequest(
          [void updates(PosKitchenStationCreateRequestBuilder b)]) =
      _$PosKitchenStationCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosKitchenStationCreateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosKitchenStationCreateRequest> get serializer =>
      _$PosKitchenStationCreateRequestSerializer();
}

class _$PosKitchenStationCreateRequestSerializer
    implements PrimitiveSerializer<PosKitchenStationCreateRequest> {
  @override
  final Iterable<Type> types = const [
    PosKitchenStationCreateRequest,
    _$PosKitchenStationCreateRequest
  ];

  @override
  final String wireName = r'PosKitchenStationCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosKitchenStationCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    if (object.isDefault != null) {
      yield r'is_default';
      yield serializers.serialize(
        object.isDefault,
        specifiedType: const FullType(bool),
      );
    }
    if (object.warnAfterMinutes != null) {
      yield r'warn_after_minutes';
      yield serializers.serialize(
        object.warnAfterMinutes,
        specifiedType: const FullType(int),
      );
    }
    if (object.kind != null) {
      yield r'kind';
      yield serializers.serialize(
        object.kind,
        specifiedType: const FullType(KitchenStationInputKindEnum),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.printerId != null) {
      yield r'printer_id';
      yield serializers.serialize(
        object.printerId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.active != null) {
      yield r'active';
      yield serializers.serialize(
        object.active,
        specifiedType: const FullType(bool),
      );
    }
    if (object.kdsEnabled != null) {
      yield r'kds_enabled';
      yield serializers.serialize(
        object.kdsEnabled,
        specifiedType: const FullType(bool),
      );
    }
    if (object.position != null) {
      yield r'position';
      yield serializers.serialize(
        object.position,
        specifiedType: const FullType(int),
      );
    }
    if (object.expoStationId != null) {
      yield r'expo_station_id';
      yield serializers.serialize(
        object.expoStationId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.lateAfterMinutes != null) {
      yield r'late_after_minutes';
      yield serializers.serialize(
        object.lateAfterMinutes,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PosKitchenStationCreateRequest object, {
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
    required PosKitchenStationCreateRequestBuilder result,
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
        case r'is_default':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.isDefault = valueDes;
          break;
        case r'warn_after_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.warnAfterMinutes = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(KitchenStationInputKindEnum),
          ) as KitchenStationInputKindEnum?;
          if (valueDes == null) continue;
          result.kind = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'printer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.printerId = valueDes;
          break;
        case r'active':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.active = valueDes;
          break;
        case r'kds_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.kdsEnabled = valueDes;
          break;
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.position = valueDes;
          break;
        case r'expo_station_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.expoStationId = valueDes;
          break;
        case r'late_after_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.lateAfterMinutes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosKitchenStationCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosKitchenStationCreateRequestBuilder();
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

class PosKitchenStationCreateRequestKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'prep')
  static const PosKitchenStationCreateRequestKindEnum prep =
      _$posKitchenStationCreateRequestKindEnum_prep;
  @BuiltValueEnumConst(wireName: r'bar')
  static const PosKitchenStationCreateRequestKindEnum bar =
      _$posKitchenStationCreateRequestKindEnum_bar;
  @BuiltValueEnumConst(wireName: r'expo')
  static const PosKitchenStationCreateRequestKindEnum expo =
      _$posKitchenStationCreateRequestKindEnum_expo;

  static Serializer<PosKitchenStationCreateRequestKindEnum> get serializer =>
      _$posKitchenStationCreateRequestKindEnumSerializer;

  const PosKitchenStationCreateRequestKindEnum._(String name) : super(name);

  static BuiltSet<PosKitchenStationCreateRequestKindEnum> get values =>
      _$posKitchenStationCreateRequestKindEnumValues;
  static PosKitchenStationCreateRequestKindEnum valueOf(String name) =>
      _$posKitchenStationCreateRequestKindEnumValueOf(name);
}
