//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/timed_quote_line.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'timed_quote.g.dart';

/// The price of a clock: up to `as_of` on the server's clock while it runs (`final` false), as billed once stopped.
///
/// Properties:
/// * [asOf]
/// * [final_]
/// * [playedMinutes]
/// * [billedMinutes]
/// * [amount]
/// * [lines]
@BuiltValue()
abstract class TimedQuote implements Built<TimedQuote, TimedQuoteBuilder> {
  @BuiltValueField(wireName: r'as_of')
  DateTime get asOf;

  @BuiltValueField(wireName: r'final')
  bool get final_;

  @BuiltValueField(wireName: r'played_minutes')
  int get playedMinutes;

  @BuiltValueField(wireName: r'billed_minutes')
  int get billedMinutes;

  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'lines')
  BuiltList<TimedQuoteLine> get lines;

  TimedQuote._();

  factory TimedQuote([void updates(TimedQuoteBuilder b)]) = _$TimedQuote;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TimedQuoteBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TimedQuote> get serializer => _$TimedQuoteSerializer();
}

class _$TimedQuoteSerializer implements PrimitiveSerializer<TimedQuote> {
  @override
  final Iterable<Type> types = const [TimedQuote, _$TimedQuote];

  @override
  final String wireName = r'TimedQuote';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TimedQuote object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'as_of';
    yield serializers.serialize(
      object.asOf,
      specifiedType: const FullType(DateTime),
    );
    yield r'final';
    yield serializers.serialize(
      object.final_,
      specifiedType: const FullType(bool),
    );
    yield r'played_minutes';
    yield serializers.serialize(
      object.playedMinutes,
      specifiedType: const FullType(int),
    );
    yield r'billed_minutes';
    yield serializers.serialize(
      object.billedMinutes,
      specifiedType: const FullType(int),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'lines';
    yield serializers.serialize(
      object.lines,
      specifiedType: const FullType(BuiltList, [FullType(TimedQuoteLine)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TimedQuote object, {
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
    required TimedQuoteBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'as_of':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.asOf = valueDes;
          break;
        case r'final':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.final_ = valueDes;
          break;
        case r'played_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.playedMinutes = valueDes;
          break;
        case r'billed_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.billedMinutes = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
          break;
        case r'lines':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(TimedQuoteLine)]),
          ) as BuiltList<TimedQuoteLine>;
          result.lines.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TimedQuote deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TimedQuoteBuilder();
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
