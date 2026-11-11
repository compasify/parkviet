//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'einvoice_totals_taxes_inner.g.dart';

/// EinvoiceTotalsTaxesInner
///
/// Properties:
/// * [taxRate]
/// * [amountBeforeTax]
/// * [taxAmount]
@BuiltValue()
abstract class EinvoiceTotalsTaxesInner
    implements
        Built<EinvoiceTotalsTaxesInner, EinvoiceTotalsTaxesInnerBuilder> {
  @BuiltValueField(wireName: r'tax_rate')
  String? get taxRate;

  @BuiltValueField(wireName: r'amount_before_tax')
  String get amountBeforeTax;

  @BuiltValueField(wireName: r'tax_amount')
  String get taxAmount;

  EinvoiceTotalsTaxesInner._();

  factory EinvoiceTotalsTaxesInner(
          [void updates(EinvoiceTotalsTaxesInnerBuilder b)]) =
      _$EinvoiceTotalsTaxesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EinvoiceTotalsTaxesInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EinvoiceTotalsTaxesInner> get serializer =>
      _$EinvoiceTotalsTaxesInnerSerializer();
}

class _$EinvoiceTotalsTaxesInnerSerializer
    implements PrimitiveSerializer<EinvoiceTotalsTaxesInner> {
  @override
  final Iterable<Type> types = const [
    EinvoiceTotalsTaxesInner,
    _$EinvoiceTotalsTaxesInner
  ];

  @override
  final String wireName = r'EinvoiceTotalsTaxesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EinvoiceTotalsTaxesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'tax_rate';
    yield object.taxRate == null
        ? null
        : serializers.serialize(
            object.taxRate,
            specifiedType: const FullType.nullable(String),
          );
    yield r'amount_before_tax';
    yield serializers.serialize(
      object.amountBeforeTax,
      specifiedType: const FullType(String),
    );
    yield r'tax_amount';
    yield serializers.serialize(
      object.taxAmount,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EinvoiceTotalsTaxesInner object, {
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
    required EinvoiceTotalsTaxesInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'tax_rate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.taxRate = valueDes;
          break;
        case r'amount_before_tax':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amountBeforeTax = valueDes;
          break;
        case r'tax_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.taxAmount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EinvoiceTotalsTaxesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EinvoiceTotalsTaxesInnerBuilder();
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
