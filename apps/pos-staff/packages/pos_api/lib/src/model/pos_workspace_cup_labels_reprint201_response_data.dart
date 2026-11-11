//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/print_job.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_workspace_cup_labels_reprint201_response_data.g.dart';

/// PosWorkspaceCupLabelsReprint201ResponseData
///
/// Properties:
/// * [jobs]
@BuiltValue()
abstract class PosWorkspaceCupLabelsReprint201ResponseData
    implements
        Built<PosWorkspaceCupLabelsReprint201ResponseData,
            PosWorkspaceCupLabelsReprint201ResponseDataBuilder> {
  @BuiltValueField(wireName: r'jobs')
  BuiltList<PrintJob> get jobs;

  PosWorkspaceCupLabelsReprint201ResponseData._();

  factory PosWorkspaceCupLabelsReprint201ResponseData(
          [void updates(
              PosWorkspaceCupLabelsReprint201ResponseDataBuilder b)]) =
      _$PosWorkspaceCupLabelsReprint201ResponseData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosWorkspaceCupLabelsReprint201ResponseDataBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosWorkspaceCupLabelsReprint201ResponseData>
      get serializer =>
          _$PosWorkspaceCupLabelsReprint201ResponseDataSerializer();
}

class _$PosWorkspaceCupLabelsReprint201ResponseDataSerializer
    implements
        PrimitiveSerializer<PosWorkspaceCupLabelsReprint201ResponseData> {
  @override
  final Iterable<Type> types = const [
    PosWorkspaceCupLabelsReprint201ResponseData,
    _$PosWorkspaceCupLabelsReprint201ResponseData
  ];

  @override
  final String wireName = r'PosWorkspaceCupLabelsReprint201ResponseData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosWorkspaceCupLabelsReprint201ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'jobs';
    yield serializers.serialize(
      object.jobs,
      specifiedType: const FullType(BuiltList, [FullType(PrintJob)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosWorkspaceCupLabelsReprint201ResponseData object, {
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
    required PosWorkspaceCupLabelsReprint201ResponseDataBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'jobs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(PrintJob)]),
          ) as BuiltList<PrintJob>;
          result.jobs.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosWorkspaceCupLabelsReprint201ResponseData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosWorkspaceCupLabelsReprint201ResponseDataBuilder();
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
