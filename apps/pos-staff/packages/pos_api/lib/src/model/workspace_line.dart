//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/line_component.dart';
import 'package:pos_api/src/model/line_modifier.dart';
import 'package:built_collection/built_collection.dart';
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
