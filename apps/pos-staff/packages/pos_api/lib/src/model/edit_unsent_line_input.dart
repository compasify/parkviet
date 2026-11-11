//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'edit_unsent_line_input.g.dart';

/// At least one of the fields. A sent line may still change its seat; quantity, course and hold only change on what was not sent.
///
/// Properties:
/// * [rowVersion]
/// * [quantity]
/// * [course]
/// * [seat]
/// * [hold]
@BuiltValue()
abstract class EditUnsentLineInput
    implements Built<EditUnsentLineInput, EditUnsentLineInputBuilder> {
  @BuiltValueField(wireName: r'row_version')
  int get rowVersion;

  @BuiltValueField(wireName: r'quantity')
  int? get quantity;

  @BuiltValueField(wireName: r'course')
  int? get course;

  @BuiltValueField(wireName: r'seat')
  int? get seat;

  @BuiltValueField(wireName: r'hold')
  bool? get hold;

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
    if (object.quantity != null) {
      yield r'quantity';
      yield serializers.serialize(
        object.quantity,
        specifiedType: const FullType(int),
      );
    }
    if (object.course != null) {
      yield r'course';
      yield serializers.serialize(
        object.course,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.seat != null) {
      yield r'seat';
      yield serializers.serialize(
        object.seat,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.hold != null) {
      yield r'hold';
      yield serializers.serialize(
        object.hold,
        specifiedType: const FullType(bool),
      );
    }
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
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.quantity = valueDes;
          break;
        case r'course':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.course = valueDes;
          break;
        case r'seat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.seat = valueDes;
          break;
        case r'hold':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.hold = valueDes;
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
