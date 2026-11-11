//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_einvoice_retry200_response_data.g.dart';

/// PosEinvoiceRetry200ResponseData
///
/// Properties:
/// * [queued]
/// * [skipped]
@BuiltValue()
abstract class PosEinvoiceRetry200ResponseData
    implements
        Built<PosEinvoiceRetry200ResponseData,
            PosEinvoiceRetry200ResponseDataBuilder> {
  @BuiltValueField(wireName: r'queued')
  BuiltList<String> get queued;

  @BuiltValueField(wireName: r'skipped')
  int get skipped;

  PosEinvoiceRetry200ResponseData._();

  factory PosEinvoiceRetry200ResponseData(
          [void updates(PosEinvoiceRetry200ResponseDataBuilder b)]) =
      _$PosEinvoiceRetry200ResponseData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosEinvoiceRetry200ResponseDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosEinvoiceRetry200ResponseData> get serializer =>
      _$PosEinvoiceRetry200ResponseDataSerializer();
}

class _$PosEinvoiceRetry200ResponseDataSerializer
    implements PrimitiveSerializer<PosEinvoiceRetry200ResponseData> {
  @override
  final Iterable<Type> types = const [
    PosEinvoiceRetry200ResponseData,
    _$PosEinvoiceRetry200ResponseData
  ];

  @override
  final String wireName = r'PosEinvoiceRetry200ResponseData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosEinvoiceRetry200ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'queued';
    yield serializers.serialize(
      object.queued,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'skipped';
    yield serializers.serialize(
      object.skipped,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosEinvoiceRetry200ResponseData object, {
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
    required PosEinvoiceRetry200ResponseDataBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'queued':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.queued.replace(valueDes);
          break;
        case r'skipped':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.skipped = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosEinvoiceRetry200ResponseData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosEinvoiceRetry200ResponseDataBuilder();
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
