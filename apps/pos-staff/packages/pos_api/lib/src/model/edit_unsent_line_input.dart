//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'edit_unsent_line_input.g.dart';

/// EditUnsentLineInput
///
/// Properties:
/// * [rowVersion]
/// * [quantity]
@BuiltValue()
abstract class EditUnsentLineInput
    implements Built<EditUnsentLineInput, EditUnsentLineInputBuilder> {
  @BuiltValueField(wireName: r'row_version')
  int get rowVersion;

  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  EditUnsentLineInput._();

  factory EditUnsentLineInput([void updates(EditUnsentLineInputBuilder b)]) =
      _$EditUnsentLineInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EditUnsentLineInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EditUnsentLineInput> get serializer =>
      _$EditUnsentLineInputSerializer();
}

class _$EditUnsentLineInputSerializer
    implements PrimitiveSerializer<EditUnsentLineInput> {
  @override
  final Iterable<Type> types = const [
    EditUnsentLineInput,
    _$EditUnsentLineInput
  ];

  @override
  final String wireName = r'EditUnsentLineInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EditUnsentLineInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'row_version';
    yield serializers.serialize(
      object.rowVersion,
      specifiedType: const FullType(int),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EditUnsentLineInput object, {
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
    required EditUnsentLineInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'row_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.rowVersion = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.quantity = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EditUnsentLineInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EditUnsentLineInputBuilder();
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
