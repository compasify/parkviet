//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'einvoice_line.g.dart';

/// EinvoiceLine
///
/// Properties:
/// * [position]
/// * [kind]
/// * [name]
/// * [sku]
/// * [unit]
/// * [quantity] - Decimal; hours with two decimals for time-billed lines
/// * [unitPrice] - As sold; tax included when `price_includes_tax`
/// * [discount]
/// * [taxRate] - Percent, e.g. \"8\" or \"10\"; null when the line carries no tax line
/// * [taxAmount]
/// * [amountBeforeTax]
/// * [amount] - Paid amount with tax
/// * [priceIncludesTax]
@BuiltValue()
abstract class EinvoiceLine
    implements Built<EinvoiceLine, EinvoiceLineBuilder> {
  @BuiltValueField(wireName: r'position')
  int get position;

  @BuiltValueField(wireName: r'kind')
  EinvoiceLineKindEnum get kind;
  // enum kindEnum {  goods,  service_charge,  fee,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'sku')
  String? get sku;

  @BuiltValueField(wireName: r'unit')
  String get unit;

  /// Decimal; hours with two decimals for time-billed lines
  @BuiltValueField(wireName: r'quantity')
  String get quantity;

  /// As sold; tax included when `price_includes_tax`
  @BuiltValueField(wireName: r'unit_price')
  String get unitPrice;

  @BuiltValueField(wireName: r'discount')
  String get discount;

  /// Percent, e.g. \"8\" or \"10\"; null when the line carries no tax line
  @BuiltValueField(wireName: r'tax_rate')
  String? get taxRate;

  @BuiltValueField(wireName: r'tax_amount')
  String get taxAmount;

  @BuiltValueField(wireName: r'amount_before_tax')
  String get amountBeforeTax;

  /// Paid amount with tax
  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'price_includes_tax')
  bool get priceIncludesTax;

  EinvoiceLine._();

  factory EinvoiceLine([void updates(EinvoiceLineBuilder b)]) = _$EinvoiceLine;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EinvoiceLineBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EinvoiceLine> get serializer => _$EinvoiceLineSerializer();
}

class _$EinvoiceLineSerializer implements PrimitiveSerializer<EinvoiceLine> {
  @override
  final Iterable<Type> types = const [EinvoiceLine, _$EinvoiceLine];

  @override
  final String wireName = r'EinvoiceLine';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EinvoiceLine object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'position';
    yield serializers.serialize(
      object.position,
      specifiedType: const FullType(int),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(EinvoiceLineKindEnum),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.sku != null) {
      yield r'sku';
      yield serializers.serialize(
        object.sku,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'unit';
    yield serializers.serialize(
      object.unit,
      specifiedType: const FullType(String),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(String),
    );
    yield r'unit_price';
    yield serializers.serialize(
      object.unitPrice,
      specifiedType: const FullType(String),
    );
    yield r'discount';
    yield serializers.serialize(
      object.discount,
      specifiedType: const FullType(String),
    );
    yield r'tax_rate';
    yield object.taxRate == null
        ? null
        : serializers.serialize(
            object.taxRate,
            specifiedType: const FullType.nullable(String),
          );
    yield r'tax_amount';
    yield serializers.serialize(
      object.taxAmount,
      specifiedType: const FullType(String),
    );
    yield r'amount_before_tax';
    yield serializers.serialize(
      object.amountBeforeTax,
      specifiedType: const FullType(String),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'price_includes_tax';
    yield serializers.serialize(
      object.priceIncludesTax,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EinvoiceLine object, {
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
    required EinvoiceLineBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.position = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EinvoiceLineKindEnum),
          ) as EinvoiceLineKindEnum;
          result.kind = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'sku':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sku = valueDes;
          break;
        case r'unit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.unit = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.quantity = valueDes;
          break;
        case r'unit_price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.unitPrice = valueDes;
          break;
        case r'discount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.discount = valueDes;
          break;
        case r'tax_rate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.taxRate = valueDes;
          break;
        case r'tax_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.taxAmount = valueDes;
          break;
        case r'amount_before_tax':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amountBeforeTax = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
          break;
        case r'price_includes_tax':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.priceIncludesTax = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EinvoiceLine deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EinvoiceLineBuilder();
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

class EinvoiceLineKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'goods')
  static const EinvoiceLineKindEnum goods = _$einvoiceLineKindEnum_goods;
  @BuiltValueEnumConst(wireName: r'service_charge')
  static const EinvoiceLineKindEnum serviceCharge =
      _$einvoiceLineKindEnum_serviceCharge;
  @BuiltValueEnumConst(wireName: r'fee')
  static const EinvoiceLineKindEnum fee = _$einvoiceLineKindEnum_fee;

  static Serializer<EinvoiceLineKindEnum> get serializer =>
      _$einvoiceLineKindEnumSerializer;

  const EinvoiceLineKindEnum._(String name) : super(name);

  static BuiltSet<EinvoiceLineKindEnum> get values =>
      _$einvoiceLineKindEnumValues;
  static EinvoiceLineKindEnum valueOf(String name) =>
      _$einvoiceLineKindEnumValueOf(name);
}
