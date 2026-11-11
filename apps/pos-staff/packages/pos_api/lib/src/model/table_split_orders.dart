//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/workspace.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'table_split_orders.g.dart';

/// The order split, and the new order (by lines) or the new bills of the other seats (by seat).
///
/// Properties:
/// * [workspace]
/// * [newWorkspace]
/// * [newWorkspaces]
@BuiltValue()
abstract class TableSplitOrders
    implements Built<TableSplitOrders, TableSplitOrdersBuilder> {
  @BuiltValueField(wireName: r'workspace')
  Workspace get workspace;

  @BuiltValueField(wireName: r'new_workspace')
  Workspace? get newWorkspace;

  @BuiltValueField(wireName: r'new_workspaces')
  BuiltList<Workspace>? get newWorkspaces;

  TableSplitOrders._();

  factory TableSplitOrders([void updates(TableSplitOrdersBuilder b)]) =
      _$TableSplitOrders;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TableSplitOrdersBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TableSplitOrders> get serializer =>
      _$TableSplitOrdersSerializer();
}

class _$TableSplitOrdersSerializer
    implements PrimitiveSerializer<TableSplitOrders> {
  @override
  final Iterable<Type> types = const [TableSplitOrders, _$TableSplitOrders];

  @override
  final String wireName = r'TableSplitOrders';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TableSplitOrders object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'workspace';
    yield serializers.serialize(
      object.workspace,
      specifiedType: const FullType(Workspace),
    );
    if (object.newWorkspace != null) {
      yield r'new_workspace';
      yield serializers.serialize(
        object.newWorkspace,
        specifiedType: const FullType(Workspace),
      );
    }
    if (object.newWorkspaces != null) {
      yield r'new_workspaces';
      yield serializers.serialize(
        object.newWorkspaces,
        specifiedType: const FullType(BuiltList, [FullType(Workspace)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TableSplitOrders object, {
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
    required TableSplitOrdersBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'workspace':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Workspace),
          ) as Workspace;
          result.workspace.replace(valueDes);
          break;
        case r'new_workspace':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Workspace),
          ) as Workspace?;
          if (valueDes == null) continue;
          result.newWorkspace.replace(valueDes);
          break;
        case r'new_workspaces':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(Workspace)]),
          ) as BuiltList<Workspace>?;
          if (valueDes == null) continue;
          result.newWorkspaces.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TableSplitOrders deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TableSplitOrdersBuilder();
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
