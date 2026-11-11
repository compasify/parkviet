//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'checklist_input.g.dart';

/// ChecklistInput
///
/// Properties:
/// * [printerId] - A printer of the branch set up for `checklist`; without it nothing is queued.
@BuiltValue()
abstract class ChecklistInput
    implements Built<ChecklistInput, ChecklistInputBuilder> {
  /// A printer of the branch set up for `checklist`; without it nothing is queued.
  @BuiltValueField(wireName: r'printer_id')
  String? get printerId;

  ChecklistInput._();

  factory ChecklistInput([void updates(ChecklistInputBuilder b)]) =
      _$ChecklistInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChecklistInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChecklistInput> get serializer =>
      _$ChecklistInputSerializer();
}

class _$ChecklistInputSerializer
    implements PrimitiveSerializer<ChecklistInput> {
  @override
  final Iterable<Type> types = const [ChecklistInput, _$ChecklistInput];

  @override
  final String wireName = r'ChecklistInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChecklistInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.printerId != null) {
      yield r'printer_id';
      yield serializers.serialize(
        object.printerId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ChecklistInput object, {
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
    required ChecklistInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  ChecklistInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChecklistInputBuilder();
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
