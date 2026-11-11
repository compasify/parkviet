//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/checklist_outcome.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'checklist_result.g.dart';

/// ChecklistResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class ChecklistResult
    implements Built<ChecklistResult, ChecklistResultBuilder> {
  @BuiltValueField(wireName: r'data')
  ChecklistOutcome get data;

  ChecklistResult._();

  factory ChecklistResult([void updates(ChecklistResultBuilder b)]) =
      _$ChecklistResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChecklistResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChecklistResult> get serializer =>
      _$ChecklistResultSerializer();
}

class _$ChecklistResultSerializer
    implements PrimitiveSerializer<ChecklistResult> {
  @override
  final Iterable<Type> types = const [ChecklistResult, _$ChecklistResult];

  @override
  final String wireName = r'ChecklistResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChecklistResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(ChecklistOutcome),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ChecklistResult object, {
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
    required ChecklistResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ChecklistOutcome),
          ) as ChecklistOutcome;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ChecklistResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChecklistResultBuilder();
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
