//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/print_job.dart';
import 'package:pos_api/src/model/workspace_prebill.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'prebill_outcome.g.dart';

/// PrebillOutcome
///
/// Properties:
/// * [prebill]
/// * [document]
/// * [printJob]
@BuiltValue()
abstract class PrebillOutcome
    implements Built<PrebillOutcome, PrebillOutcomeBuilder> {
  @BuiltValueField(wireName: r'prebill')
  WorkspacePrebill get prebill;

  @BuiltValueField(wireName: r'document')
  JsonObject? get document;

  @BuiltValueField(wireName: r'print_job')
  PrintJob? get printJob;

  PrebillOutcome._();

  factory PrebillOutcome([void updates(PrebillOutcomeBuilder b)]) =
      _$PrebillOutcome;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrebillOutcomeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrebillOutcome> get serializer =>
      _$PrebillOutcomeSerializer();
}

class _$PrebillOutcomeSerializer
    implements PrimitiveSerializer<PrebillOutcome> {
  @override
  final Iterable<Type> types = const [PrebillOutcome, _$PrebillOutcome];

  @override
  final String wireName = r'PrebillOutcome';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrebillOutcome object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'prebill';
    yield serializers.serialize(
      object.prebill,
      specifiedType: const FullType(WorkspacePrebill),
    );
    if (object.document != null) {
      yield r'document';
      yield serializers.serialize(
        object.document,
        specifiedType: const FullType(JsonObject),
      );
    }
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
    PrebillOutcome object, {
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
    required PrebillOutcomeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'prebill':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WorkspacePrebill),
          ) as WorkspacePrebill;
          result.prebill.replace(valueDes);
          break;
        case r'document':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
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
  PrebillOutcome deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrebillOutcomeBuilder();
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
