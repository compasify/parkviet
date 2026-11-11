//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/print_job.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_job_result.g.dart';

/// PrintJobResult
///
/// Properties:
/// * [printJob]
/// * [print]
/// * [receipt]
@BuiltValue()
abstract class PrintJobResult
    implements Built<PrintJobResult, PrintJobResultBuilder> {
  @BuiltValueField(wireName: r'print_job')
  PrintJob get printJob;

  @BuiltValueField(wireName: r'print')
  JsonObject? get print;

  @BuiltValueField(wireName: r'receipt')
  JsonObject? get receipt;

  PrintJobResult._();

  factory PrintJobResult([void updates(PrintJobResultBuilder b)]) =
      _$PrintJobResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintJobResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintJobResult> get serializer =>
      _$PrintJobResultSerializer();
}

class _$PrintJobResultSerializer
    implements PrimitiveSerializer<PrintJobResult> {
  @override
  final Iterable<Type> types = const [PrintJobResult, _$PrintJobResult];

  @override
  final String wireName = r'PrintJobResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintJobResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'print_job';
    yield serializers.serialize(
      object.printJob,
      specifiedType: const FullType(PrintJob),
    );
    if (object.print != null) {
      yield r'print';
      yield serializers.serialize(
        object.print,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.receipt != null) {
      yield r'receipt';
      yield serializers.serialize(
        object.receipt,
        specifiedType: const FullType(JsonObject),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PrintJobResult object, {
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
    required PrintJobResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'print_job':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrintJob),
          ) as PrintJob;
          result.printJob.replace(valueDes);
          break;
        case r'print':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.print = valueDes;
          break;
        case r'receipt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.receipt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrintJobResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintJobResultBuilder();
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
