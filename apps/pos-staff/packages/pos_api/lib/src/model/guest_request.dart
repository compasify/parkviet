//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'guest_request.g.dart';

/// GuestRequest
///
/// Properties:
/// * [id]
/// * [branchId]
/// * [resourceId]
/// * [tableName]
/// * [areaId]
/// * [workspaceId]
/// * [kind]
/// * [status]
/// * [handledByName]
/// * [handledAt]
/// * [createdAt]
@BuiltValue()
abstract class GuestRequest
    implements Built<GuestRequest, GuestRequestBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'resource_id')
  String get resourceId;

  @BuiltValueField(wireName: r'table_name')
  String get tableName;

  @BuiltValueField(wireName: r'area_id')
  String? get areaId;

  @BuiltValueField(wireName: r'workspace_id')
  String? get workspaceId;

  @BuiltValueField(wireName: r'kind')
  GuestRequestKindEnum get kind;
  // enum kindEnum {  call_staff,  request_bill,  };

  @BuiltValueField(wireName: r'status')
  GuestRequestStatusEnum get status;
  // enum statusEnum {  open,  done,  };

  @BuiltValueField(wireName: r'handled_by_name')
  String? get handledByName;

  @BuiltValueField(wireName: r'handled_at')
  DateTime? get handledAt;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  GuestRequest._();

  factory GuestRequest([void updates(GuestRequestBuilder b)]) = _$GuestRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GuestRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GuestRequest> get serializer => _$GuestRequestSerializer();
}

class _$GuestRequestSerializer implements PrimitiveSerializer<GuestRequest> {
  @override
  final Iterable<Type> types = const [GuestRequest, _$GuestRequest];

  @override
  final String wireName = r'GuestRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GuestRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'resource_id';
    yield serializers.serialize(
      object.resourceId,
      specifiedType: const FullType(String),
    );
    yield r'table_name';
    yield serializers.serialize(
      object.tableName,
      specifiedType: const FullType(String),
    );
    yield r'area_id';
    yield object.areaId == null
        ? null
        : serializers.serialize(
            object.areaId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'workspace_id';
    yield object.workspaceId == null
        ? null
        : serializers.serialize(
            object.workspaceId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(GuestRequestKindEnum),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(GuestRequestStatusEnum),
    );
    yield r'handled_by_name';
    yield object.handledByName == null
        ? null
        : serializers.serialize(
            object.handledByName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'handled_at';
    yield object.handledAt == null
        ? null
        : serializers.serialize(
            object.handledAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GuestRequest object, {
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
    required GuestRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'resource_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.resourceId = valueDes;
          break;
        case r'table_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tableName = valueDes;
          break;
        case r'area_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.areaId = valueDes;
          break;
        case r'workspace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.workspaceId = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GuestRequestKindEnum),
          ) as GuestRequestKindEnum;
          result.kind = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GuestRequestStatusEnum),
          ) as GuestRequestStatusEnum;
          result.status = valueDes;
          break;
        case r'handled_by_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.handledByName = valueDes;
          break;
        case r'handled_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.handledAt = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GuestRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GuestRequestBuilder();
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

class GuestRequestKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'call_staff')
  static const GuestRequestKindEnum callStaff =
      _$guestRequestKindEnum_callStaff;
  @BuiltValueEnumConst(wireName: r'request_bill')
  static const GuestRequestKindEnum requestBill =
      _$guestRequestKindEnum_requestBill;

  static Serializer<GuestRequestKindEnum> get serializer =>
      _$guestRequestKindEnumSerializer;

  const GuestRequestKindEnum._(String name) : super(name);

  static BuiltSet<GuestRequestKindEnum> get values =>
      _$guestRequestKindEnumValues;
  static GuestRequestKindEnum valueOf(String name) =>
      _$guestRequestKindEnumValueOf(name);
}

class GuestRequestStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'open')
  static const GuestRequestStatusEnum open = _$guestRequestStatusEnum_open;
  @BuiltValueEnumConst(wireName: r'done')
  static const GuestRequestStatusEnum done = _$guestRequestStatusEnum_done;

  static Serializer<GuestRequestStatusEnum> get serializer =>
      _$guestRequestStatusEnumSerializer;

  const GuestRequestStatusEnum._(String name) : super(name);

  static BuiltSet<GuestRequestStatusEnum> get values =>
      _$guestRequestStatusEnumValues;
  static GuestRequestStatusEnum valueOf(String name) =>
      _$guestRequestStatusEnumValueOf(name);
}
