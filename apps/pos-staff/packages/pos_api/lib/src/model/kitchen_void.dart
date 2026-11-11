//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_void.g.dart';

/// KitchenVoid
///
/// Properties:
/// * [id]
/// * [saleLineId]
/// * [name]
/// * [quantity]
/// * [reasonCode]
/// * [note]
/// * [wasted] - The kitchen had already made it.
/// * [staffId]
/// * [staffName]
/// * [approvalId]
/// * [approverId]
/// * [kitchenTicketId]
/// * [voidedAt]
@BuiltValue()
abstract class KitchenVoid implements Built<KitchenVoid, KitchenVoidBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'sale_line_id')
  String? get saleLineId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  @BuiltValueField(wireName: r'reason_code')
  String get reasonCode;

  @BuiltValueField(wireName: r'note')
  String? get note;

  /// The kitchen had already made it.
  @BuiltValueField(wireName: r'wasted')
  bool get wasted;

  @BuiltValueField(wireName: r'staff_id')
  String get staffId;

  @BuiltValueField(wireName: r'staff_name')
  String? get staffName;

  @BuiltValueField(wireName: r'approval_id')
  String? get approvalId;

  @BuiltValueField(wireName: r'approver_id')
  String? get approverId;

  @BuiltValueField(wireName: r'kitchen_ticket_id')
  String? get kitchenTicketId;

  @BuiltValueField(wireName: r'voided_at')
  DateTime get voidedAt;

  KitchenVoid._();

  factory KitchenVoid([void updates(KitchenVoidBuilder b)]) = _$KitchenVoid;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenVoidBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenVoid> get serializer => _$KitchenVoidSerializer();
}

class _$KitchenVoidSerializer implements PrimitiveSerializer<KitchenVoid> {
  @override
  final Iterable<Type> types = const [KitchenVoid, _$KitchenVoid];

  @override
  final String wireName = r'KitchenVoid';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenVoid object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'sale_line_id';
    yield object.saleLineId == null
        ? null
        : serializers.serialize(
            object.saleLineId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(String),
    );
    yield r'reason_code';
    yield serializers.serialize(
      object.reasonCode,
      specifiedType: const FullType(String),
    );
    yield r'note';
    yield object.note == null
        ? null
        : serializers.serialize(
            object.note,
            specifiedType: const FullType.nullable(String),
          );
    yield r'wasted';
    yield serializers.serialize(
      object.wasted,
      specifiedType: const FullType(bool),
    );
    yield r'staff_id';
    yield serializers.serialize(
      object.staffId,
      specifiedType: const FullType(String),
    );
    yield r'staff_name';
    yield object.staffName == null
        ? null
        : serializers.serialize(
            object.staffName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'approval_id';
    yield object.approvalId == null
        ? null
        : serializers.serialize(
            object.approvalId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'approver_id';
    yield object.approverId == null
        ? null
        : serializers.serialize(
            object.approverId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'kitchen_ticket_id';
    yield object.kitchenTicketId == null
        ? null
        : serializers.serialize(
            object.kitchenTicketId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'voided_at';
    yield serializers.serialize(
      object.voidedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenVoid object, {
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
    required KitchenVoidBuilder result,
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
        case r'sale_line_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.saleLineId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.quantity = valueDes;
          break;
        case r'reason_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reasonCode = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'wasted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.wasted = valueDes;
          break;
        case r'staff_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.staffId = valueDes;
          break;
        case r'staff_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.staffName = valueDes;
          break;
        case r'approval_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.approvalId = valueDes;
          break;
        case r'approver_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.approverId = valueDes;
          break;
        case r'kitchen_ticket_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.kitchenTicketId = valueDes;
          break;
        case r'voided_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.voidedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KitchenVoid deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenVoidBuilder();
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
