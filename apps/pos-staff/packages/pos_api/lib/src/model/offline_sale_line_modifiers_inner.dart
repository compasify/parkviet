//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'offline_sale_line_modifiers_inner.g.dart';

/// OfflineSaleLineModifiersInner
///
/// Properties:
/// * [optionId]
/// * [quantity]
@BuiltValue()
abstract class OfflineSaleLineModifiersInner
    implements
        Built<OfflineSaleLineModifiersInner,
            OfflineSaleLineModifiersInnerBuilder> {
  @BuiltValueField(wireName: r'option_id')
  String get optionId;

  @BuiltValueField(wireName: r'quantity')
  int? get quantity;

  OfflineSaleLineModifiersInner._();

  factory OfflineSaleLineModifiersInner(
          [void updates(OfflineSaleLineModifiersInnerBuilder b)]) =
      _$OfflineSaleLineModifiersInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OfflineSaleLineModifiersInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OfflineSaleLineModifiersInner> get serializer =>
      _$OfflineSaleLineModifiersInnerSerializer();
}

class _$OfflineSaleLineModifiersInnerSerializer
    implements PrimitiveSerializer<OfflineSaleLineModifiersInner> {
  @override
  final Iterable<Type> types = const [
    OfflineSaleLineModifiersInner,
    _$OfflineSaleLineModifiersInner
  ];

  @override
  final String wireName = r'OfflineSaleLineModifiersInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OfflineSaleLineModifiersInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'option_id';
    yield serializers.serialize(
      object.optionId,
      specifiedType: const FullType(String),
    );
    if (object.quantity != null) {
      yield r'quantity';
      yield serializers.serialize(
        object.quantity,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OfflineSaleLineModifiersInner object, {
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
    required OfflineSaleLineModifiersInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'option_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.optionId = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.quantity = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OfflineSaleLineModifiersInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OfflineSaleLineModifiersInnerBuilder();
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
