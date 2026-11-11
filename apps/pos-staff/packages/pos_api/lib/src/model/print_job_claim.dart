//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/print_job_claim_printer.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_job_claim.g.dart';

/// PrintJobClaim
///
/// Properties:
/// * [id]
/// * [kind]
/// * [attempt] - Send it back with the report.
/// * [claimExpiresAt]
/// * [printer]
/// * [document]
@BuiltValue()
abstract class PrintJobClaim
    implements Built<PrintJobClaim, PrintJobClaimBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'kind')
  String get kind;

  /// Send it back with the report.
  @BuiltValueField(wireName: r'attempt')
  int get attempt;

  @BuiltValueField(wireName: r'claim_expires_at')
  String get claimExpiresAt;

  @BuiltValueField(wireName: r'printer')
  PrintJobClaimPrinter get printer;

  @BuiltValueField(wireName: r'document')
  JsonObject get document;

  PrintJobClaim._();

  factory PrintJobClaim([void updates(PrintJobClaimBuilder b)]) =
      _$PrintJobClaim;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintJobClaimBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintJobClaim> get serializer =>
      _$PrintJobClaimSerializer();
}

class _$PrintJobClaimSerializer implements PrimitiveSerializer<PrintJobClaim> {
  @override
  final Iterable<Type> types = const [PrintJobClaim, _$PrintJobClaim];

  @override
  final String wireName = r'PrintJobClaim';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintJobClaim object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(String),
    );
    yield r'attempt';
    yield serializers.serialize(
      object.attempt,
      specifiedType: const FullType(int),
    );
    yield r'claim_expires_at';
    yield serializers.serialize(
      object.claimExpiresAt,
      specifiedType: const FullType(String),
    );
    yield r'printer';
    yield serializers.serialize(
      object.printer,
      specifiedType: const FullType(PrintJobClaimPrinter),
    );
    yield r'document';
    yield serializers.serialize(
      object.document,
      specifiedType: const FullType(JsonObject),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PrintJobClaim object, {
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
    required PrintJobClaimBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.kind = valueDes;
          break;
        case r'attempt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.attempt = valueDes;
          break;
        case r'claim_expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.claimExpiresAt = valueDes;
          break;
        case r'printer':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrintJobClaimPrinter),
          ) as PrintJobClaimPrinter;
          result.printer.replace(valueDes);
          break;
        case r'document':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.document = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrintJobClaim deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintJobClaimBuilder();
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
