//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/print_job.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'checklist_outcome.g.dart';

/// ChecklistOutcome
///
/// Properties:
/// * [document]
/// * [printJob]
@BuiltValue()
abstract class ChecklistOutcome
    implements Built<ChecklistOutcome, ChecklistOutcomeBuilder> {
  @BuiltValueField(wireName: r'document')
  JsonObject get document;

  @BuiltValueField(wireName: r'print_job')
  PrintJob? get printJob;

  ChecklistOutcome._();

  factory ChecklistOutcome([void updates(ChecklistOutcomeBuilder b)]) =
      _$ChecklistOutcome;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChecklistOutcomeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChecklistOutcome> get serializer =>
      _$ChecklistOutcomeSerializer();
}

class _$ChecklistOutcomeSerializer
    implements PrimitiveSerializer<ChecklistOutcome> {
  @override
  final Iterable<Type> types = const [ChecklistOutcome, _$ChecklistOutcome];

  @override
  final String wireName = r'ChecklistOutcome';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChecklistOutcome object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'document';
    yield serializers.serialize(
      object.document,
      specifiedType: const FullType(JsonObject),
    );
    if (object.printJob != null) {
      yield r'print_job';
      yield serializers.serialize(
        object.printJob,
        specifiedType: const FullType(PrintJob),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ChecklistOutcome object, {
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
    required ChecklistOutcomeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'document':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.document = valueDes;
          break;
        case r'print_job':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(PrintJob),
          ) as PrintJob?;
          if (valueDes == null) continue;
          result.printJob.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ChecklistOutcome deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChecklistOutcomeBuilder();
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
