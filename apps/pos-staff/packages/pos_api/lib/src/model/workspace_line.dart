//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/line_component.dart';
import 'package:pos_api/src/model/line_kitchen_status.dart';
import 'package:pos_api/src/model/line_modifier.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/staff_ref.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'workspace_line.g.dart';

/// WorkspaceLine
///
/// Properties:
/// * [id]
/// * [variantId]
/// * [name]
/// * [quantity]
/// * [price]
/// * [amount]
/// * [saleLineId]
/// * [kind]
/// * [unitPrice]
/// * [note]
/// * [modifiers]
/// * [components]
/// * [kitchenSentQuantity] - How much of the line the kitchen has been told about. The line goes lower only by a kitchen void.
/// * [pendingKitchenQuantity] - What the next kitchen send would send of a menu line.
/// * [rowVersion] - Moves on every change of the line; unsent-line edits send it back.
/// * [addedBy] - Who added the line.
/// * [kitchenStatus] - Table orders only, how far the kitchen got with what was sent of the line.
@BuiltValue()
abstract class WorkspaceLine
    implements Built<WorkspaceLine, WorkspaceLineBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'variant_id')
  String get variantId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  @BuiltValueField(wireName: r'price')
  String get price;

  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'sale_line_id')
  String? get saleLineId;

  @BuiltValueField(wireName: r'kind')
  WorkspaceLineKindEnum? get kind;
  // enum kindEnum {  ordinary,  measured,  tracked,  menu,  timed,  cover,  };

  @BuiltValueField(wireName: r'unit_price')
  String? get unitPrice;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'modifiers')
  BuiltList<LineModifier>? get modifiers;

  @BuiltValueField(wireName: r'components')
  BuiltList<LineComponent>? get components;

  /// How much of the line the kitchen has been told about. The line goes lower only by a kitchen void.
  @BuiltValueField(wireName: r'kitchen_sent_quantity')
  String? get kitchenSentQuantity;

  /// What the next kitchen send would send of a menu line.
  @BuiltValueField(wireName: r'pending_kitchen_quantity')
  String? get pendingKitchenQuantity;

  /// Moves on every change of the line; unsent-line edits send it back.
  @BuiltValueField(wireName: r'row_version')
  int? get rowVersion;

  /// Who added the line.
  @BuiltValueField(wireName: r'added_by')
  StaffRef? get addedBy;

  /// Table orders only, how far the kitchen got with what was sent of the line.
  @BuiltValueField(wireName: r'kitchen_status')
  LineKitchenStatus? get kitchenStatus;

  WorkspaceLine._();

  factory WorkspaceLine([void updates(WorkspaceLineBuilder b)]) =
      _$WorkspaceLine;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkspaceLineBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkspaceLine> get serializer =>
      _$WorkspaceLineSerializer();
}

class _$WorkspaceLineSerializer implements PrimitiveSerializer<WorkspaceLine> {
  @override
  final Iterable<Type> types = const [WorkspaceLine, _$WorkspaceLine];

  @override
  final String wireName = r'WorkspaceLine';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkspaceLine object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'variant_id';
    yield serializers.serialize(
      object.variantId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(int),
    );
    yield r'price';
    yield serializers.serialize(
      object.price,
      specifiedType: const FullType(String),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'sale_line_id';
    yield object.saleLineId == null
        ? null
        : serializers.serialize(
            object.saleLineId,
            specifiedType: const FullType.nullable(String),
          );
    if (object.kind != null) {
      yield r'kind';
      yield serializers.serialize(
        object.kind,
        specifiedType: const FullType(WorkspaceLineKindEnum),
      );
    }
    if (object.unitPrice != null) {
      yield r'unit_price';
      yield serializers.serialize(
        object.unitPrice,
        specifiedType: const FullType(String),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.modifiers != null) {
      yield r'modifiers';
      yield serializers.serialize(
        object.modifiers,
        specifiedType: const FullType(BuiltList, [FullType(LineModifier)]),
      );
    }
    if (object.components != null) {
      yield r'components';
      yield serializers.serialize(
        object.components,
        specifiedType: const FullType(BuiltList, [FullType(LineComponent)]),
      );
    }
    if (object.kitchenSentQuantity != null) {
      yield r'kitchen_sent_quantity';
      yield serializers.serialize(
        object.kitchenSentQuantity,
        specifiedType: const FullType(String),
      );
    }
    if (object.pendingKitchenQuantity != null) {
      yield r'pending_kitchen_quantity';
      yield serializers.serialize(
        object.pendingKitchenQuantity,
        specifiedType: const FullType(String),
      );
    }
    if (object.rowVersion != null) {
      yield r'row_version';
      yield serializers.serialize(
        object.rowVersion,
        specifiedType: const FullType(int),
      );
    }
    if (object.addedBy != null) {
      yield r'added_by';
      yield serializers.serialize(
        object.addedBy,
        specifiedType: const FullType.nullable(StaffRef),
      );
    }
    if (object.kitchenStatus != null) {
      yield r'kitchen_status';
      yield serializers.serialize(
        object.kitchenStatus,
        specifiedType: const FullType(LineKitchenStatus),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkspaceLine object, {
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
    required WorkspaceLineBuilder result,
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
        case r'variant_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.variantId = valueDes;
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
            specifiedType: const FullType(int),
          ) as int;
          result.quantity = valueDes;
          break;
        case r'price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.price = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
          break;
        case r'sale_line_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.saleLineId = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(WorkspaceLineKindEnum),
          ) as WorkspaceLineKindEnum?;
          if (valueDes == null) continue;
          result.kind = valueDes;
          break;
        case r'unit_price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.unitPrice = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'modifiers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(LineModifier)]),
          ) as BuiltList<LineModifier>?;
          if (valueDes == null) continue;
          result.modifiers.replace(valueDes);
          break;
        case r'components':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(LineComponent)]),
          ) as BuiltList<LineComponent>?;
          if (valueDes == null) continue;
          result.components.replace(valueDes);
          break;
        case r'kitchen_sent_quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.kitchenSentQuantity = valueDes;
          break;
        case r'pending_kitchen_quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.pendingKitchenQuantity = valueDes;
          break;
        case r'row_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.rowVersion = valueDes;
          break;
        case r'added_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(StaffRef),
          ) as StaffRef?;
          if (valueDes == null) continue;
          result.addedBy.replace(valueDes);
          break;
        case r'kitchen_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(LineKitchenStatus),
          ) as LineKitchenStatus?;
          if (valueDes == null) continue;
          result.kitchenStatus.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WorkspaceLine deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkspaceLineBuilder();
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

class WorkspaceLineKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ordinary')
  static const WorkspaceLineKindEnum ordinary =
      _$workspaceLineKindEnum_ordinary;
  @BuiltValueEnumConst(wireName: r'measured')
  static const WorkspaceLineKindEnum measured =
      _$workspaceLineKindEnum_measured;
  @BuiltValueEnumConst(wireName: r'tracked')
  static const WorkspaceLineKindEnum tracked = _$workspaceLineKindEnum_tracked;
  @BuiltValueEnumConst(wireName: r'menu')
  static const WorkspaceLineKindEnum menu = _$workspaceLineKindEnum_menu;
  @BuiltValueEnumConst(wireName: r'timed')
  static const WorkspaceLineKindEnum timed = _$workspaceLineKindEnum_timed;
  @BuiltValueEnumConst(wireName: r'cover')
  static const WorkspaceLineKindEnum cover = _$workspaceLineKindEnum_cover;

  static Serializer<WorkspaceLineKindEnum> get serializer =>
      _$workspaceLineKindEnumSerializer;

  const WorkspaceLineKindEnum._(String name) : super(name);

  static BuiltSet<WorkspaceLineKindEnum> get values =>
      _$workspaceLineKindEnumValues;
  static WorkspaceLineKindEnum valueOf(String name) =>
      _$workspaceLineKindEnumValueOf(name);
}
