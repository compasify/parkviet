//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'owner_alert.g.dart';

/// OwnerAlert
///
/// Properties:
/// * [id]
/// * [branchId]
/// * [kind]
/// * [subjectId]
/// * [details] - Minutes, counts and amounts; never a customer's name.
/// * [occurredAt]
@BuiltValue()
abstract class OwnerAlert implements Built<OwnerAlert, OwnerAlertBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'kind')
  OwnerAlertKindEnum get kind;
  // enum kindEnum {  kitchen_late,  shift_variance,  void_burst,  revenue_milestone,  print_failed,  einvoice_failed,  };

  @BuiltValueField(wireName: r'subject_id')
  String? get subjectId;

  /// Minutes, counts and amounts; never a customer's name.
  @BuiltValueField(wireName: r'details')
  BuiltMap<String, JsonObject?> get details;

  @BuiltValueField(wireName: r'occurred_at')
  DateTime get occurredAt;

  OwnerAlert._();

  factory OwnerAlert([void updates(OwnerAlertBuilder b)]) = _$OwnerAlert;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OwnerAlertBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OwnerAlert> get serializer => _$OwnerAlertSerializer();
}

class _$OwnerAlertSerializer implements PrimitiveSerializer<OwnerAlert> {
  @override
  final Iterable<Type> types = const [OwnerAlert, _$OwnerAlert];

  @override
  final String wireName = r'OwnerAlert';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OwnerAlert object, {
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
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(OwnerAlertKindEnum),
    );
    yield r'subject_id';
    yield object.subjectId == null
        ? null
        : serializers.serialize(
            object.subjectId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'details';
    yield serializers.serialize(
      object.details,
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'occurred_at';
    yield serializers.serialize(
      object.occurredAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OwnerAlert object, {
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
    required OwnerAlertBuilder result,
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
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OwnerAlertKindEnum),
          ) as OwnerAlertKindEnum;
          result.kind = valueDes;
          break;
        case r'subject_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.subjectId = valueDes;
          break;
        case r'details':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.details.replace(valueDes);
          break;
        case r'occurred_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.occurredAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OwnerAlert deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OwnerAlertBuilder();
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

class OwnerAlertKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'kitchen_late')
  static const OwnerAlertKindEnum kitchenLate =
      _$ownerAlertKindEnum_kitchenLate;
  @BuiltValueEnumConst(wireName: r'shift_variance')
  static const OwnerAlertKindEnum shiftVariance =
      _$ownerAlertKindEnum_shiftVariance;
  @BuiltValueEnumConst(wireName: r'void_burst')
  static const OwnerAlertKindEnum voidBurst = _$ownerAlertKindEnum_voidBurst;
  @BuiltValueEnumConst(wireName: r'revenue_milestone')
  static const OwnerAlertKindEnum revenueMilestone =
      _$ownerAlertKindEnum_revenueMilestone;
  @BuiltValueEnumConst(wireName: r'print_failed')
  static const OwnerAlertKindEnum printFailed =
      _$ownerAlertKindEnum_printFailed;
  @BuiltValueEnumConst(wireName: r'einvoice_failed')
  static const OwnerAlertKindEnum einvoiceFailed =
      _$ownerAlertKindEnum_einvoiceFailed;

  static Serializer<OwnerAlertKindEnum> get serializer =>
      _$ownerAlertKindEnumSerializer;

  const OwnerAlertKindEnum._(String name) : super(name);

  static BuiltSet<OwnerAlertKindEnum> get values => _$ownerAlertKindEnumValues;
  static OwnerAlertKindEnum valueOf(String name) =>
      _$ownerAlertKindEnumValueOf(name);
}
