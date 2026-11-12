//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'table_code_issue_input.g.dart';

/// TableCodeIssueInput
///
/// Properties:
/// * [resourceId]
/// * [printerId]
@BuiltValue()
abstract class TableCodeIssueInput
    implements Built<TableCodeIssueInput, TableCodeIssueInputBuilder> {
  @BuiltValueField(wireName: r'resource_id')
  String get resourceId;

  @BuiltValueField(wireName: r'printer_id')
  String? get printerId;

  TableCodeIssueInput._();

  factory TableCodeIssueInput([void updates(TableCodeIssueInputBuilder b)]) =
      _$TableCodeIssueInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TableCodeIssueInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TableCodeIssueInput> get serializer =>
      _$TableCodeIssueInputSerializer();
}

class _$TableCodeIssueInputSerializer
    implements PrimitiveSerializer<TableCodeIssueInput> {
  @override
  final Iterable<Type> types = const [
    TableCodeIssueInput,
    _$TableCodeIssueInput
  ];

  @override
  final String wireName = r'TableCodeIssueInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TableCodeIssueInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'resource_id';
    yield serializers.serialize(
      object.resourceId,
      specifiedType: const FullType(String),
    );
    if (object.printerId != null) {
      yield r'printer_id';
      yield serializers.serialize(
        object.printerId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TableCodeIssueInput object, {
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
    required TableCodeIssueInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'resource_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.resourceId = valueDes;
          break;
        case r'printer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.printerId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TableCodeIssueInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TableCodeIssueInputBuilder();
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
