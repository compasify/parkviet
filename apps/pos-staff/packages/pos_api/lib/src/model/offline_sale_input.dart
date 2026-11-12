//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/offline_sale_line.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'offline_sale_input.g.dart';

/// OfflineSaleInput
///
/// Properties:
/// * [offlineId]
/// * [provisionalNumber]
/// * [registerId]
/// * [shiftId]
/// * [clientSoldAt]
/// * [clientNow] - The counter's clock when it sends; not part of the replayed command.
/// * [total] - The total the counter collected.
/// * [handedAmount] - The cash the customer handed, at least the total.
/// * [lines]
@BuiltValue()
abstract class OfflineSaleInput
    implements Built<OfflineSaleInput, OfflineSaleInputBuilder> {
  @BuiltValueField(wireName: r'offline_id')
  String get offlineId;

  @BuiltValueField(wireName: r'provisional_number')
  String get provisionalNumber;

  @BuiltValueField(wireName: r'register_id')
  String get registerId;

  @BuiltValueField(wireName: r'shift_id')
  String get shiftId;

  @BuiltValueField(wireName: r'client_sold_at')
  DateTime get clientSoldAt;

  /// The counter's clock when it sends; not part of the replayed command.
  @BuiltValueField(wireName: r'client_now')
  DateTime? get clientNow;

  /// The total the counter collected.
  @BuiltValueField(wireName: r'total')
  String get total;

  /// The cash the customer handed, at least the total.
  @BuiltValueField(wireName: r'handed_amount')
  String get handedAmount;

  @BuiltValueField(wireName: r'lines')
  BuiltList<OfflineSaleLine> get lines;

  OfflineSaleInput._();

  factory OfflineSaleInput([void updates(OfflineSaleInputBuilder b)]) =
      _$OfflineSaleInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OfflineSaleInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OfflineSaleInput> get serializer =>
      _$OfflineSaleInputSerializer();
}

class _$OfflineSaleInputSerializer
    implements PrimitiveSerializer<OfflineSaleInput> {
  @override
  final Iterable<Type> types = const [OfflineSaleInput, _$OfflineSaleInput];

  @override
  final String wireName = r'OfflineSaleInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OfflineSaleInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'offline_id';
    yield serializers.serialize(
      object.offlineId,
      specifiedType: const FullType(String),
    );
    yield r'provisional_number';
    yield serializers.serialize(
      object.provisionalNumber,
      specifiedType: const FullType(String),
    );
    yield r'register_id';
    yield serializers.serialize(
      object.registerId,
      specifiedType: const FullType(String),
    );
    yield r'shift_id';
    yield serializers.serialize(
      object.shiftId,
      specifiedType: const FullType(String),
    );
    yield r'client_sold_at';
    yield serializers.serialize(
      object.clientSoldAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.clientNow != null) {
      yield r'client_now';
      yield serializers.serialize(
        object.clientNow,
        specifiedType: const FullType(DateTime),
      );
    }
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(String),
    );
    yield r'handed_amount';
    yield serializers.serialize(
      object.handedAmount,
      specifiedType: const FullType(String),
    );
    yield r'lines';
    yield serializers.serialize(
      object.lines,
      specifiedType: const FullType(BuiltList, [FullType(OfflineSaleLine)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OfflineSaleInput object, {
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
    required OfflineSaleInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'offline_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.offlineId = valueDes;
          break;
        case r'provisional_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.provisionalNumber = valueDes;
          break;
        case r'register_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.registerId = valueDes;
          break;
        case r'shift_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.shiftId = valueDes;
          break;
        case r'client_sold_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.clientSoldAt = valueDes;
          break;
        case r'client_now':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.clientNow = valueDes;
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.total = valueDes;
          break;
        case r'handed_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.handedAmount = valueDes;
          break;
        case r'lines':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(OfflineSaleLine)]),
          ) as BuiltList<OfflineSaleLine>;
          result.lines.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OfflineSaleInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OfflineSaleInputBuilder();
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
