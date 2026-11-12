//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/offline_sale_line_modifiers_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'offline_sale_line.g.dart';

/// OfflineSaleLine
///
/// Properties:
/// * [variantId]
/// * [quantity]
/// * [unitPrice] - The unit price the counter showed, options included; only compared, never charged.
/// * [name]
/// * [note]
/// * [modifiers]
@BuiltValue()
abstract class OfflineSaleLine
    implements Built<OfflineSaleLine, OfflineSaleLineBuilder> {
  @BuiltValueField(wireName: r'variant_id')
  String get variantId;

  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  /// The unit price the counter showed, options included; only compared, never charged.
  @BuiltValueField(wireName: r'unit_price')
  String get unitPrice;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'modifiers')
  BuiltList<OfflineSaleLineModifiersInner>? get modifiers;

  OfflineSaleLine._();

  factory OfflineSaleLine([void updates(OfflineSaleLineBuilder b)]) =
      _$OfflineSaleLine;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OfflineSaleLineBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OfflineSaleLine> get serializer =>
      _$OfflineSaleLineSerializer();
}

class _$OfflineSaleLineSerializer
    implements PrimitiveSerializer<OfflineSaleLine> {
  @override
  final Iterable<Type> types = const [OfflineSaleLine, _$OfflineSaleLine];

  @override
  final String wireName = r'OfflineSaleLine';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OfflineSaleLine object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'variant_id';
    yield serializers.serialize(
      object.variantId,
      specifiedType: const FullType(String),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(int),
    );
    yield r'unit_price';
    yield serializers.serialize(
      object.unitPrice,
      specifiedType: const FullType(String),
    );
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.modifiers != null) {
      yield r'modifiers';
      yield serializers.serialize(
        object.modifiers,
        specifiedType: const FullType(
            BuiltList, [FullType(OfflineSaleLineModifiersInner)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OfflineSaleLine object, {
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
    required OfflineSaleLineBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'variant_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.variantId = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.quantity = valueDes;
          break;
        case r'unit_price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.unitPrice = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'modifiers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltList, [FullType(OfflineSaleLineModifiersInner)]),
          ) as BuiltList<OfflineSaleLineModifiersInner>?;
          if (valueDes == null) continue;
          result.modifiers.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OfflineSaleLine deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OfflineSaleLineBuilder();
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
