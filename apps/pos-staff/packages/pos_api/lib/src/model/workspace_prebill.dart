//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'workspace_prebill.g.dart';

/// WorkspacePrebill
///
/// Properties:
/// * [id]
/// * [sequence] - 1 for the first pre-bill, 2 and up for reprints.
/// * [revision]
/// * [status]
/// * [total]
/// * [currency]
/// * [staffId]
/// * [approvalId]
/// * [printedAt]
/// * [stale] - The order changed after this pre-bill; on the order's latest pre-bill only.
@BuiltValue()
abstract class WorkspacePrebill
    implements Built<WorkspacePrebill, WorkspacePrebillBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  /// 1 for the first pre-bill, 2 and up for reprints.
  @BuiltValueField(wireName: r'sequence')
  int get sequence;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'status')
  WorkspacePrebillStatusEnum get status;
  // enum statusEnum {  current,  superseded,  canceled,  };

  @BuiltValueField(wireName: r'total')
  String get total;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'staff_id')
  String get staffId;

  @BuiltValueField(wireName: r'approval_id')
  String? get approvalId;

  @BuiltValueField(wireName: r'printed_at')
  DateTime get printedAt;

  /// The order changed after this pre-bill; on the order's latest pre-bill only.
  @BuiltValueField(wireName: r'stale')
  bool? get stale;

  WorkspacePrebill._();

  factory WorkspacePrebill([void updates(WorkspacePrebillBuilder b)]) =
      _$WorkspacePrebill;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkspacePrebillBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkspacePrebill> get serializer =>
      _$WorkspacePrebillSerializer();
}

class _$WorkspacePrebillSerializer
    implements PrimitiveSerializer<WorkspacePrebill> {
  @override
  final Iterable<Type> types = const [WorkspacePrebill, _$WorkspacePrebill];

  @override
  final String wireName = r'WorkspacePrebill';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkspacePrebill object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'sequence';
    yield serializers.serialize(
      object.sequence,
      specifiedType: const FullType(int),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(WorkspacePrebillStatusEnum),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(String),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'staff_id';
    yield serializers.serialize(
      object.staffId,
      specifiedType: const FullType(String),
    );
    yield r'approval_id';
    yield object.approvalId == null
        ? null
        : serializers.serialize(
            object.approvalId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'printed_at';
    yield serializers.serialize(
      object.printedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.stale != null) {
      yield r'stale';
      yield serializers.serialize(
        object.stale,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkspacePrebill object, {
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
    required WorkspacePrebillBuilder result,
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
        case r'sequence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sequence = valueDes;
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WorkspacePrebillStatusEnum),
          ) as WorkspacePrebillStatusEnum;
          result.status = valueDes;
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.total = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'staff_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.staffId = valueDes;
          break;
        case r'approval_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.approvalId = valueDes;
          break;
        case r'printed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.printedAt = valueDes;
          break;
        case r'stale':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.stale = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WorkspacePrebill deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkspacePrebillBuilder();
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

class WorkspacePrebillStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'current')
  static const WorkspacePrebillStatusEnum current =
      _$workspacePrebillStatusEnum_current;
  @BuiltValueEnumConst(wireName: r'superseded')
  static const WorkspacePrebillStatusEnum superseded =
      _$workspacePrebillStatusEnum_superseded;
  @BuiltValueEnumConst(wireName: r'canceled')
  static const WorkspacePrebillStatusEnum canceled =
      _$workspacePrebillStatusEnum_canceled;

  static Serializer<WorkspacePrebillStatusEnum> get serializer =>
      _$workspacePrebillStatusEnumSerializer;

  const WorkspacePrebillStatusEnum._(String name) : super(name);

  static BuiltSet<WorkspacePrebillStatusEnum> get values =>
      _$workspacePrebillStatusEnumValues;
  static WorkspacePrebillStatusEnum valueOf(String name) =>
      _$workspacePrebillStatusEnumValueOf(name);
}
