//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tax_row.g.dart';

/// TaxRow
///
/// Properties:
/// * [rate]
/// * [label]
/// * [amount]
@BuiltValue()
abstract class TaxRow implements Built<TaxRow, TaxRowBuilder> {
  @BuiltValueField(wireName: r'rate')
  String get rate;

  @BuiltValueField(wireName: r'label')
  String get label;

  @BuiltValueField(wireName: r'amount')
  String get amount;

  TaxRow._();

  factory TaxRow([void updates(TaxRowBuilder b)]) = _$TaxRow;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TaxRowBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TaxRow> get serializer => _$TaxRowSerializer();
}

class _$TaxRowSerializer implements PrimitiveSerializer<TaxRow> {
  @override
  final Iterable<Type> types = const [TaxRow, _$TaxRow];

  @override
  final String wireName = r'TaxRow';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TaxRow object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'rate';
    yield serializers.serialize(
      object.rate,
      specifiedType: const FullType(String),
    );
    yield r'label';
    yield serializers.serialize(
      object.label,
      specifiedType: const FullType(String),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TaxRow object, {
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
    required TaxRowBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'rate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rate = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.label = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TaxRow deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TaxRowBuilder();
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
