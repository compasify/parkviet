//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/einvoice_summary_revenue.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'einvoice_summary.g.dart';

/// EinvoiceSummary
///
/// Properties:
/// * [einvoiceType]
/// * [outstanding]
/// * [counts]
/// * [oldestOutstandingAt]
/// * [revenue]
@BuiltValue()
abstract class EinvoiceSummary
    implements Built<EinvoiceSummary, EinvoiceSummaryBuilder> {
  @BuiltValueField(wireName: r'einvoice_type')
  EinvoiceSummaryEinvoiceTypeEnum get einvoiceType;
  // enum einvoiceTypeEnum {  none,  cash_register,  coded,  };

  @BuiltValueField(wireName: r'outstanding')
  int get outstanding;

  @BuiltValueField(wireName: r'counts')
  BuiltMap<String, int> get counts;

  @BuiltValueField(wireName: r'oldest_outstanding_at')
  DateTime? get oldestOutstandingAt;

  @BuiltValueField(wireName: r'revenue')
  EinvoiceSummaryRevenue get revenue;

  EinvoiceSummary._();

  factory EinvoiceSummary([void updates(EinvoiceSummaryBuilder b)]) =
      _$EinvoiceSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EinvoiceSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EinvoiceSummary> get serializer =>
      _$EinvoiceSummarySerializer();
}

class _$EinvoiceSummarySerializer
    implements PrimitiveSerializer<EinvoiceSummary> {
  @override
  final Iterable<Type> types = const [EinvoiceSummary, _$EinvoiceSummary];

  @override
  final String wireName = r'EinvoiceSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EinvoiceSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'einvoice_type';
    yield serializers.serialize(
      object.einvoiceType,
      specifiedType: const FullType(EinvoiceSummaryEinvoiceTypeEnum),
    );
    yield r'outstanding';
    yield serializers.serialize(
      object.outstanding,
      specifiedType: const FullType(int),
    );
    yield r'counts';
    yield serializers.serialize(
      object.counts,
      specifiedType:
          const FullType(BuiltMap, [FullType(String), FullType(int)]),
    );
    yield r'oldest_outstanding_at';
    yield object.oldestOutstandingAt == null
        ? null
        : serializers.serialize(
            object.oldestOutstandingAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'revenue';
    yield serializers.serialize(
      object.revenue,
      specifiedType: const FullType(EinvoiceSummaryRevenue),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EinvoiceSummary object, {
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
    required EinvoiceSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'einvoice_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EinvoiceSummaryEinvoiceTypeEnum),
          ) as EinvoiceSummaryEinvoiceTypeEnum;
          result.einvoiceType = valueDes;
          break;
        case r'outstanding':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.outstanding = valueDes;
          break;
        case r'counts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltMap, [FullType(String), FullType(int)]),
          ) as BuiltMap<String, int>;
          result.counts.replace(valueDes);
          break;
        case r'oldest_outstanding_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.oldestOutstandingAt = valueDes;
          break;
        case r'revenue':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EinvoiceSummaryRevenue),
          ) as EinvoiceSummaryRevenue;
          result.revenue.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EinvoiceSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EinvoiceSummaryBuilder();
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

class EinvoiceSummaryEinvoiceTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'none')
  static const EinvoiceSummaryEinvoiceTypeEnum none =
      _$einvoiceSummaryEinvoiceTypeEnum_none;
  @BuiltValueEnumConst(wireName: r'cash_register')
  static const EinvoiceSummaryEinvoiceTypeEnum cashRegister =
      _$einvoiceSummaryEinvoiceTypeEnum_cashRegister;
  @BuiltValueEnumConst(wireName: r'coded')
  static const EinvoiceSummaryEinvoiceTypeEnum coded =
      _$einvoiceSummaryEinvoiceTypeEnum_coded;

  static Serializer<EinvoiceSummaryEinvoiceTypeEnum> get serializer =>
      _$einvoiceSummaryEinvoiceTypeEnumSerializer;

  const EinvoiceSummaryEinvoiceTypeEnum._(String name) : super(name);

  static BuiltSet<EinvoiceSummaryEinvoiceTypeEnum> get values =>
      _$einvoiceSummaryEinvoiceTypeEnumValues;
  static EinvoiceSummaryEinvoiceTypeEnum valueOf(String name) =>
      _$einvoiceSummaryEinvoiceTypeEnumValueOf(name);
}
