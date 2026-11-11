//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/einvoice_totals_taxes_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'einvoice_totals.g.dart';

/// EinvoiceTotals
///
/// Properties:
/// * [amountBeforeTax]
/// * [taxAmount]
/// * [discountTotal]
/// * [total]
/// * [taxes]
@BuiltValue()
abstract class EinvoiceTotals
    implements Built<EinvoiceTotals, EinvoiceTotalsBuilder> {
  @BuiltValueField(wireName: r'amount_before_tax')
  String? get amountBeforeTax;

  @BuiltValueField(wireName: r'tax_amount')
  String? get taxAmount;

  @BuiltValueField(wireName: r'discount_total')
  String? get discountTotal;

  @BuiltValueField(wireName: r'total')
  String? get total;

  @BuiltValueField(wireName: r'taxes')
  BuiltList<EinvoiceTotalsTaxesInner>? get taxes;

  EinvoiceTotals._();

  factory EinvoiceTotals([void updates(EinvoiceTotalsBuilder b)]) =
      _$EinvoiceTotals;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EinvoiceTotalsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EinvoiceTotals> get serializer =>
      _$EinvoiceTotalsSerializer();
}

class _$EinvoiceTotalsSerializer
    implements PrimitiveSerializer<EinvoiceTotals> {
  @override
  final Iterable<Type> types = const [EinvoiceTotals, _$EinvoiceTotals];

  @override
  final String wireName = r'EinvoiceTotals';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EinvoiceTotals object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.amountBeforeTax != null) {
      yield r'amount_before_tax';
      yield serializers.serialize(
        object.amountBeforeTax,
        specifiedType: const FullType(String),
      );
    }
    if (object.taxAmount != null) {
      yield r'tax_amount';
      yield serializers.serialize(
        object.taxAmount,
        specifiedType: const FullType(String),
      );
    }
    if (object.discountTotal != null) {
      yield r'discount_total';
      yield serializers.serialize(
        object.discountTotal,
        specifiedType: const FullType(String),
      );
    }
    if (object.total != null) {
      yield r'total';
      yield serializers.serialize(
        object.total,
        specifiedType: const FullType(String),
      );
    }
    if (object.taxes != null) {
      yield r'taxes';
      yield serializers.serialize(
        object.taxes,
        specifiedType:
            const FullType(BuiltList, [FullType(EinvoiceTotalsTaxesInner)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    EinvoiceTotals object, {
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
    required EinvoiceTotalsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'amount_before_tax':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.amountBeforeTax = valueDes;
          break;
        case r'tax_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.taxAmount = valueDes;
          break;
        case r'discount_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.discountTotal = valueDes;
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.total = valueDes;
          break;
        case r'taxes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltList, [FullType(EinvoiceTotalsTaxesInner)]),
          ) as BuiltList<EinvoiceTotalsTaxesInner>?;
          if (valueDes == null) continue;
          result.taxes.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EinvoiceTotals deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EinvoiceTotalsBuilder();
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
