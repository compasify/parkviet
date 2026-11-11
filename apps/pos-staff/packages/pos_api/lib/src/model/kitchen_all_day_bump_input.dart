//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_all_day_bump_input.g.dart';

/// KitchenAllDayBumpInput
///
/// Properties:
/// * [branchId] - Required on the staff API.
/// * [stationIds] - The stations of the board; none for the device's own station or every station.
/// * [key]
/// * [quantity] - Units to make ready, oldest items first; an item counts whole. Defaults to 1.
@BuiltValue()
abstract class KitchenAllDayBumpInput
    implements Built<KitchenAllDayBumpInput, KitchenAllDayBumpInputBuilder> {
  /// Required on the staff API.
  @BuiltValueField(wireName: r'branch_id')
  String? get branchId;

  /// The stations of the board; none for the device's own station or every station.
  @BuiltValueField(wireName: r'station_ids')
  BuiltList<String>? get stationIds;

  @BuiltValueField(wireName: r'key')
  String get key;

  /// Units to make ready, oldest items first; an item counts whole. Defaults to 1.
  @BuiltValueField(wireName: r'quantity')
  int? get quantity;

  KitchenAllDayBumpInput._();

  factory KitchenAllDayBumpInput(
          [void updates(KitchenAllDayBumpInputBuilder b)]) =
      _$KitchenAllDayBumpInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenAllDayBumpInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenAllDayBumpInput> get serializer =>
      _$KitchenAllDayBumpInputSerializer();
}

class _$KitchenAllDayBumpInputSerializer
    implements PrimitiveSerializer<KitchenAllDayBumpInput> {
  @override
  final Iterable<Type> types = const [
    KitchenAllDayBumpInput,
    _$KitchenAllDayBumpInput
  ];

  @override
  final String wireName = r'KitchenAllDayBumpInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenAllDayBumpInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.branchId != null) {
      yield r'branch_id';
      yield serializers.serialize(
        object.branchId,
        specifiedType: const FullType(String),
      );
    }
    if (object.stationIds != null) {
      yield r'station_ids';
      yield serializers.serialize(
        object.stationIds,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    yield r'key';
    yield serializers.serialize(
      object.key,
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
    KitchenAllDayBumpInput object, {
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
    required KitchenAllDayBumpInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.branchId = valueDes;
          break;
        case r'station_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.stationIds.replace(valueDes);
          break;
        case r'key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.key = valueDes;
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
  KitchenAllDayBumpInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenAllDayBumpInputBuilder();
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
