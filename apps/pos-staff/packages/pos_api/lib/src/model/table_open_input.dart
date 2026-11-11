//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'table_open_input.g.dart';

/// TableOpenInput
///
/// Properties:
/// * [branchId]
/// * [editorId]
/// * [guestCount]
/// * [addOrder] - Open another order beside the table's open one.
@BuiltValue()
abstract class TableOpenInput
    implements Built<TableOpenInput, TableOpenInputBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'editor_id')
  String get editorId;

  @BuiltValueField(wireName: r'guest_count')
  int? get guestCount;

  /// Open another order beside the table's open one.
  @BuiltValueField(wireName: r'add_order')
  bool? get addOrder;

  TableOpenInput._();

  factory TableOpenInput([void updates(TableOpenInputBuilder b)]) =
      _$TableOpenInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TableOpenInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TableOpenInput> get serializer =>
      _$TableOpenInputSerializer();
}

class _$TableOpenInputSerializer
    implements PrimitiveSerializer<TableOpenInput> {
  @override
  final Iterable<Type> types = const [TableOpenInput, _$TableOpenInput];

  @override
  final String wireName = r'TableOpenInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TableOpenInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'editor_id';
    yield serializers.serialize(
      object.editorId,
      specifiedType: const FullType(String),
    );
    if (object.guestCount != null) {
      yield r'guest_count';
      yield serializers.serialize(
        object.guestCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.addOrder != null) {
      yield r'add_order';
      yield serializers.serialize(
        object.addOrder,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TableOpenInput object, {
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
    required TableOpenInputBuilder result,
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
        case r'editor_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.editorId = valueDes;
          break;
        case r'guest_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.guestCount = valueDes;
          break;
        case r'add_order':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.addOrder = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TableOpenInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TableOpenInputBuilder();
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
