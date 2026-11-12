//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'timed_quote_line.g.dart';

/// One time band of a quote, at one price.
///
/// Properties:
/// * [kind] - `rate` at the plan's price, `package` the prepaid package at its price, `card` paid by the minutes card (its money moves when the clock stops), `bonus` free minutes of a promotion at 0.
/// * [promotionId] - The timed promotion that gave a `bonus` line.
/// * [segmentId]
/// * [startsAt]
/// * [endsAt]
/// * [dayType] - weekday, weekend or holiday.
/// * [label]
/// * [pricePerHour]
/// * [surchargePercent]
/// * [minutes]
/// * [amount]
@BuiltValue()
abstract class TimedQuoteLine
    implements Built<TimedQuoteLine, TimedQuoteLineBuilder> {
  /// `rate` at the plan's price, `package` the prepaid package at its price, `card` paid by the minutes card (its money moves when the clock stops), `bonus` free minutes of a promotion at 0.
  @BuiltValueField(wireName: r'kind')
  TimedQuoteLineKindEnum get kind;
  // enum kindEnum {  rate,  package,  card,  bonus,  };

  /// The timed promotion that gave a `bonus` line.
  @BuiltValueField(wireName: r'promotion_id')
  String? get promotionId;

  @BuiltValueField(wireName: r'segment_id')
  String? get segmentId;

  @BuiltValueField(wireName: r'starts_at')
  DateTime get startsAt;

  @BuiltValueField(wireName: r'ends_at')
  DateTime get endsAt;

  /// weekday, weekend or holiday.
  @BuiltValueField(wireName: r'day_type')
  String? get dayType;

  @BuiltValueField(wireName: r'label')
  String? get label;

  @BuiltValueField(wireName: r'price_per_hour')
  String get pricePerHour;

  @BuiltValueField(wireName: r'surcharge_percent')
  String get surchargePercent;

  @BuiltValueField(wireName: r'minutes')
  int get minutes;

  @BuiltValueField(wireName: r'amount')
  String get amount;

  TimedQuoteLine._();

  factory TimedQuoteLine([void updates(TimedQuoteLineBuilder b)]) =
      _$TimedQuoteLine;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TimedQuoteLineBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TimedQuoteLine> get serializer =>
      _$TimedQuoteLineSerializer();
}

class _$TimedQuoteLineSerializer
    implements PrimitiveSerializer<TimedQuoteLine> {
  @override
  final Iterable<Type> types = const [TimedQuoteLine, _$TimedQuoteLine];

  @override
  final String wireName = r'TimedQuoteLine';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TimedQuoteLine object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(TimedQuoteLineKindEnum),
    );
    yield r'promotion_id';
    yield object.promotionId == null
        ? null
        : serializers.serialize(
            object.promotionId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'segment_id';
    yield object.segmentId == null
        ? null
        : serializers.serialize(
            object.segmentId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'starts_at';
    yield serializers.serialize(
      object.startsAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'ends_at';
    yield serializers.serialize(
      object.endsAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'day_type';
    yield object.dayType == null
        ? null
        : serializers.serialize(
            object.dayType,
            specifiedType: const FullType.nullable(String),
          );
    yield r'label';
    yield object.label == null
        ? null
        : serializers.serialize(
            object.label,
            specifiedType: const FullType.nullable(String),
          );
    yield r'price_per_hour';
    yield serializers.serialize(
      object.pricePerHour,
      specifiedType: const FullType(String),
    );
    yield r'surcharge_percent';
    yield serializers.serialize(
      object.surchargePercent,
      specifiedType: const FullType(String),
    );
    yield r'minutes';
    yield serializers.serialize(
      object.minutes,
      specifiedType: const FullType(int),
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
    TimedQuoteLine object, {
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
    required TimedQuoteLineBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TimedQuoteLineKindEnum),
          ) as TimedQuoteLineKindEnum;
          result.kind = valueDes;
          break;
        case r'promotion_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.promotionId = valueDes;
          break;
        case r'segment_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.segmentId = valueDes;
          break;
        case r'starts_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startsAt = valueDes;
          break;
        case r'ends_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.endsAt = valueDes;
          break;
        case r'day_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.dayType = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.label = valueDes;
          break;
        case r'price_per_hour':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pricePerHour = valueDes;
          break;
        case r'surcharge_percent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.surchargePercent = valueDes;
          break;
        case r'minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.minutes = valueDes;
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
  TimedQuoteLine deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TimedQuoteLineBuilder();
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

/// `rate` at the plan's price, `package` the prepaid package at its price, `card` paid by the minutes card (its money moves when the clock stops), `bonus` free minutes of a promotion at 0.
class TimedQuoteLineKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'rate')
  static const TimedQuoteLineKindEnum rate = _$timedQuoteLineKindEnum_rate;
  @BuiltValueEnumConst(wireName: r'package')
  static const TimedQuoteLineKindEnum package =
      _$timedQuoteLineKindEnum_package;
  @BuiltValueEnumConst(wireName: r'card')
  static const TimedQuoteLineKindEnum card = _$timedQuoteLineKindEnum_card;
  @BuiltValueEnumConst(wireName: r'bonus')
  static const TimedQuoteLineKindEnum bonus = _$timedQuoteLineKindEnum_bonus;

  static Serializer<TimedQuoteLineKindEnum> get serializer =>
      _$timedQuoteLineKindEnumSerializer;

  const TimedQuoteLineKindEnum._(String name) : super(name);

  static BuiltSet<TimedQuoteLineKindEnum> get values =>
      _$timedQuoteLineKindEnumValues;
  static TimedQuoteLineKindEnum valueOf(String name) =>
      _$timedQuoteLineKindEnumValueOf(name);
}
