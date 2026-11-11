//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'einvoice_sample.g.dart';

/// EinvoiceSample
///
/// Properties:
/// * [provider]
/// * [templateCode]
/// * [symbol]
/// * [number]
/// * [cqtCode]
/// * [lookupCode]
@BuiltValue()
abstract class EinvoiceSample
    implements Built<EinvoiceSample, EinvoiceSampleBuilder> {
  @BuiltValueField(wireName: r'provider')
  String get provider;

  @BuiltValueField(wireName: r'template_code')
  String? get templateCode;

  @BuiltValueField(wireName: r'symbol')
  String? get symbol;

  @BuiltValueField(wireName: r'number')
  String? get number;

  @BuiltValueField(wireName: r'cqt_code')
  String? get cqtCode;

  @BuiltValueField(wireName: r'lookup_code')
  String? get lookupCode;

  EinvoiceSample._();

  factory EinvoiceSample([void updates(EinvoiceSampleBuilder b)]) =
      _$EinvoiceSample;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EinvoiceSampleBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EinvoiceSample> get serializer =>
      _$EinvoiceSampleSerializer();
}

class _$EinvoiceSampleSerializer
    implements PrimitiveSerializer<EinvoiceSample> {
  @override
  final Iterable<Type> types = const [EinvoiceSample, _$EinvoiceSample];

  @override
  final String wireName = r'EinvoiceSample';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EinvoiceSample object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'provider';
    yield serializers.serialize(
      object.provider,
      specifiedType: const FullType(String),
    );
    if (object.templateCode != null) {
      yield r'template_code';
      yield serializers.serialize(
        object.templateCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'symbol';
    yield object.symbol == null
        ? null
        : serializers.serialize(
            object.symbol,
            specifiedType: const FullType.nullable(String),
          );
    yield r'number';
    yield object.number == null
        ? null
        : serializers.serialize(
            object.number,
            specifiedType: const FullType.nullable(String),
          );
    if (object.cqtCode != null) {
      yield r'cqt_code';
      yield serializers.serialize(
        object.cqtCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'lookup_code';
    yield object.lookupCode == null
        ? null
        : serializers.serialize(
            object.lookupCode,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    EinvoiceSample object, {
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
    required EinvoiceSampleBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.provider = valueDes;
          break;
        case r'template_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.templateCode = valueDes;
          break;
        case r'symbol':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.symbol = valueDes;
          break;
        case r'number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.number = valueDes;
          break;
        case r'cqt_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.cqtCode = valueDes;
          break;
        case r'lookup_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lookupCode = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EinvoiceSample deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EinvoiceSampleBuilder();
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
