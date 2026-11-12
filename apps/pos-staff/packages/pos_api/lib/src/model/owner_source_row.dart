//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'owner_source_row.g.dart';

/// OwnerSourceRow
///
/// Properties:
/// * [orderSource]
/// * [orders]
/// * [salesTotal]
/// * [owed]
@BuiltValue()
abstract class OwnerSourceRow
    implements Built<OwnerSourceRow, OwnerSourceRowBuilder> {
  @BuiltValueField(wireName: r'order_source')
  String get orderSource;

  @BuiltValueField(wireName: r'orders')
  int get orders;

  @BuiltValueField(wireName: r'sales_total')
  String get salesTotal;

  @BuiltValueField(wireName: r'owed')
  String get owed;

  OwnerSourceRow._();

  factory OwnerSourceRow([void updates(OwnerSourceRowBuilder b)]) =
      _$OwnerSourceRow;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OwnerSourceRowBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OwnerSourceRow> get serializer =>
      _$OwnerSourceRowSerializer();
}

class _$OwnerSourceRowSerializer
    implements PrimitiveSerializer<OwnerSourceRow> {
  @override
  final Iterable<Type> types = const [OwnerSourceRow, _$OwnerSourceRow];

  @override
  final String wireName = r'OwnerSourceRow';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OwnerSourceRow object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'order_source';
    yield serializers.serialize(
      object.orderSource,
      specifiedType: const FullType(String),
    );
    yield r'orders';
    yield serializers.serialize(
      object.orders,
      specifiedType: const FullType(int),
    );
    yield r'sales_total';
    yield serializers.serialize(
      object.salesTotal,
      specifiedType: const FullType(String),
    );
    yield r'owed';
    yield serializers.serialize(
      object.owed,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OwnerSourceRow object, {
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
    required OwnerSourceRowBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'order_source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.orderSource = valueDes;
          break;
        case r'orders':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.orders = valueDes;
          break;
        case r'sales_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.salesTotal = valueDes;
          break;
        case r'owed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.owed = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OwnerSourceRow deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OwnerSourceRowBuilder();
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
