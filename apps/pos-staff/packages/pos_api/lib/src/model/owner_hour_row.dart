//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'owner_hour_row.g.dart';

/// OwnerHourRow
///
/// Properties:
/// * [hour]
/// * [orders]
/// * [salesTotal]
@BuiltValue()
abstract class OwnerHourRow
    implements Built<OwnerHourRow, OwnerHourRowBuilder> {
  @BuiltValueField(wireName: r'hour')
  int get hour;

  @BuiltValueField(wireName: r'orders')
  int get orders;

  @BuiltValueField(wireName: r'sales_total')
  String get salesTotal;

  OwnerHourRow._();

  factory OwnerHourRow([void updates(OwnerHourRowBuilder b)]) = _$OwnerHourRow;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OwnerHourRowBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OwnerHourRow> get serializer => _$OwnerHourRowSerializer();
}

class _$OwnerHourRowSerializer implements PrimitiveSerializer<OwnerHourRow> {
  @override
  final Iterable<Type> types = const [OwnerHourRow, _$OwnerHourRow];

  @override
  final String wireName = r'OwnerHourRow';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OwnerHourRow object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'hour';
    yield serializers.serialize(
      object.hour,
      specifiedType: const FullType(int),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    OwnerHourRow object, {
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
    required OwnerHourRowBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'hour':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.hour = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OwnerHourRow deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OwnerHourRowBuilder();
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
