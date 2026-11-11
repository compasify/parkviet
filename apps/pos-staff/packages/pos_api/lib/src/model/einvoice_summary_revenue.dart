//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'einvoice_summary_revenue.g.dart';

/// EinvoiceSummaryRevenue
///
/// Properties:
/// * [year]
/// * [total]
/// * [threshold]
/// * [share]
/// * [level]
@BuiltValue()
abstract class EinvoiceSummaryRevenue
    implements Built<EinvoiceSummaryRevenue, EinvoiceSummaryRevenueBuilder> {
  @BuiltValueField(wireName: r'year')
  int get year;

  @BuiltValueField(wireName: r'total')
  String get total;

  @BuiltValueField(wireName: r'threshold')
  String get threshold;

  @BuiltValueField(wireName: r'share')
  String get share;

  @BuiltValueField(wireName: r'level')
  EinvoiceSummaryRevenueLevelEnum get level;
  // enum levelEnum {  ok,  warning,  reached,  };

  EinvoiceSummaryRevenue._();

  factory EinvoiceSummaryRevenue(
          [void updates(EinvoiceSummaryRevenueBuilder b)]) =
      _$EinvoiceSummaryRevenue;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EinvoiceSummaryRevenueBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EinvoiceSummaryRevenue> get serializer =>
      _$EinvoiceSummaryRevenueSerializer();
}

class _$EinvoiceSummaryRevenueSerializer
    implements PrimitiveSerializer<EinvoiceSummaryRevenue> {
  @override
  final Iterable<Type> types = const [
    EinvoiceSummaryRevenue,
    _$EinvoiceSummaryRevenue
  ];

  @override
  final String wireName = r'EinvoiceSummaryRevenue';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EinvoiceSummaryRevenue object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'year';
    yield serializers.serialize(
      object.year,
      specifiedType: const FullType(int),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(String),
    );
    yield r'threshold';
    yield serializers.serialize(
      object.threshold,
      specifiedType: const FullType(String),
    );
    yield r'share';
    yield serializers.serialize(
      object.share,
      specifiedType: const FullType(String),
    );
    yield r'level';
    yield serializers.serialize(
      object.level,
      specifiedType: const FullType(EinvoiceSummaryRevenueLevelEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EinvoiceSummaryRevenue object, {
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
    required EinvoiceSummaryRevenueBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'year':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.year = valueDes;
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.total = valueDes;
          break;
        case r'threshold':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.threshold = valueDes;
          break;
        case r'share':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.share = valueDes;
          break;
        case r'level':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EinvoiceSummaryRevenueLevelEnum),
          ) as EinvoiceSummaryRevenueLevelEnum;
          result.level = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EinvoiceSummaryRevenue deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EinvoiceSummaryRevenueBuilder();
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

class EinvoiceSummaryRevenueLevelEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ok')
  static const EinvoiceSummaryRevenueLevelEnum ok =
      _$einvoiceSummaryRevenueLevelEnum_ok;
  @BuiltValueEnumConst(wireName: r'warning')
  static const EinvoiceSummaryRevenueLevelEnum warning =
      _$einvoiceSummaryRevenueLevelEnum_warning;
  @BuiltValueEnumConst(wireName: r'reached')
  static const EinvoiceSummaryRevenueLevelEnum reached =
      _$einvoiceSummaryRevenueLevelEnum_reached;

  static Serializer<EinvoiceSummaryRevenueLevelEnum> get serializer =>
      _$einvoiceSummaryRevenueLevelEnumSerializer;

  const EinvoiceSummaryRevenueLevelEnum._(String name) : super(name);

  static BuiltSet<EinvoiceSummaryRevenueLevelEnum> get values =>
      _$einvoiceSummaryRevenueLevelEnumValues;
  static EinvoiceSummaryRevenueLevelEnum valueOf(String name) =>
      _$einvoiceSummaryRevenueLevelEnumValueOf(name);
}
