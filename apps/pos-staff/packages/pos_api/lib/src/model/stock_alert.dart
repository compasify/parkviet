//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'stock_alert.g.dart';

/// StockAlert
///
/// Properties:
/// * [id]
/// * [branchId]
/// * [variantId]
/// * [name]
/// * [sku]
/// * [optionsText]
/// * [baseUnit]
/// * [minQuantity]
/// * [onHand]
/// * [low]
@BuiltValue()
abstract class StockAlert implements Built<StockAlert, StockAlertBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'variant_id')
  String get variantId;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'sku')
  String? get sku;

  @BuiltValueField(wireName: r'options_text')
  String? get optionsText;

  @BuiltValueField(wireName: r'base_unit')
  String get baseUnit;

  @BuiltValueField(wireName: r'min_quantity')
  int get minQuantity;

  @BuiltValueField(wireName: r'on_hand')
  int get onHand;

  @BuiltValueField(wireName: r'low')
  bool get low;

  StockAlert._();

  factory StockAlert([void updates(StockAlertBuilder b)]) = _$StockAlert;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StockAlertBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StockAlert> get serializer => _$StockAlertSerializer();
}

class _$StockAlertSerializer implements PrimitiveSerializer<StockAlert> {
  @override
  final Iterable<Type> types = const [StockAlert, _$StockAlert];

  @override
  final String wireName = r'StockAlert';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StockAlert object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'variant_id';
    yield serializers.serialize(
      object.variantId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield object.name == null
        ? null
        : serializers.serialize(
            object.name,
            specifiedType: const FullType.nullable(String),
          );
    yield r'sku';
    yield object.sku == null
        ? null
        : serializers.serialize(
            object.sku,
            specifiedType: const FullType.nullable(String),
          );
    yield r'options_text';
    yield object.optionsText == null
        ? null
        : serializers.serialize(
            object.optionsText,
            specifiedType: const FullType.nullable(String),
          );
    yield r'base_unit';
    yield serializers.serialize(
      object.baseUnit,
      specifiedType: const FullType(String),
    );
    yield r'min_quantity';
    yield serializers.serialize(
      object.minQuantity,
      specifiedType: const FullType(int),
    );
    yield r'on_hand';
    yield serializers.serialize(
      object.onHand,
      specifiedType: const FullType(int),
    );
    yield r'low';
    yield serializers.serialize(
      object.low,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StockAlert object, {
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
    required StockAlertBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'variant_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.variantId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
        case r'options_text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.optionsText = valueDes;
          break;
        case r'base_unit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.baseUnit = valueDes;
          break;
        case r'min_quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.minQuantity = valueDes;
          break;
        case r'on_hand':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.onHand = valueDes;
          break;
        case r'low':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.low = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StockAlert deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StockAlertBuilder();
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
