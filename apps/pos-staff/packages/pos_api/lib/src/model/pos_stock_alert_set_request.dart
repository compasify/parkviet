//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_stock_alert_set_request.g.dart';

/// PosStockAlertSetRequest
///
/// Properties:
/// * [branchId]
/// * [variantId]
/// * [minQuantity]
@BuiltValue()
abstract class PosStockAlertSetRequest
    implements Built<PosStockAlertSetRequest, PosStockAlertSetRequestBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'variant_id')
  String get variantId;

  @BuiltValueField(wireName: r'min_quantity')
  int? get minQuantity;

  PosStockAlertSetRequest._();

  factory PosStockAlertSetRequest(
          [void updates(PosStockAlertSetRequestBuilder b)]) =
      _$PosStockAlertSetRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosStockAlertSetRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosStockAlertSetRequest> get serializer =>
      _$PosStockAlertSetRequestSerializer();
}

class _$PosStockAlertSetRequestSerializer
    implements PrimitiveSerializer<PosStockAlertSetRequest> {
  @override
  final Iterable<Type> types = const [
    PosStockAlertSetRequest,
    _$PosStockAlertSetRequest
  ];

  @override
  final String wireName = r'PosStockAlertSetRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosStockAlertSetRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    if (object.minQuantity != null) {
      yield r'min_quantity';
      yield serializers.serialize(
        object.minQuantity,
        specifiedType: const FullType.nullable(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PosStockAlertSetRequest object, {
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
    required PosStockAlertSetRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'min_quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.minQuantity = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosStockAlertSetRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosStockAlertSetRequestBuilder();
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
