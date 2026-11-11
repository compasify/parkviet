//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kitchen_send_summary.g.dart';

/// One kitchen send of an order that told the kitchen something.
///
/// Properties:
/// * [id]
/// * [sequence]
/// * [sentAt]
/// * [staffId]
/// * [staffName]
/// * [deviceId]
@BuiltValue()
abstract class KitchenSendSummary
    implements Built<KitchenSendSummary, KitchenSendSummaryBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'sequence')
  int get sequence;

  @BuiltValueField(wireName: r'sent_at')
  DateTime get sentAt;

  @BuiltValueField(wireName: r'staff_id')
  String? get staffId;

  @BuiltValueField(wireName: r'staff_name')
  String? get staffName;

  @BuiltValueField(wireName: r'device_id')
  String? get deviceId;

  KitchenSendSummary._();

  factory KitchenSendSummary([void updates(KitchenSendSummaryBuilder b)]) =
      _$KitchenSendSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KitchenSendSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KitchenSendSummary> get serializer =>
      _$KitchenSendSummarySerializer();
}

class _$KitchenSendSummarySerializer
    implements PrimitiveSerializer<KitchenSendSummary> {
  @override
  final Iterable<Type> types = const [KitchenSendSummary, _$KitchenSendSummary];

  @override
  final String wireName = r'KitchenSendSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KitchenSendSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'sequence';
    yield serializers.serialize(
      object.sequence,
      specifiedType: const FullType(int),
    );
    yield r'sent_at';
    yield serializers.serialize(
      object.sentAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'staff_id';
    yield object.staffId == null
        ? null
        : serializers.serialize(
            object.staffId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'staff_name';
    yield object.staffName == null
        ? null
        : serializers.serialize(
            object.staffName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'device_id';
    yield object.deviceId == null
        ? null
        : serializers.serialize(
            object.deviceId,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    KitchenSendSummary object, {
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
    required KitchenSendSummaryBuilder result,
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
        case r'sequence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sequence = valueDes;
          break;
        case r'sent_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.sentAt = valueDes;
          break;
        case r'staff_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.staffId = valueDes;
          break;
        case r'staff_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.staffName = valueDes;
          break;
        case r'device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.deviceId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KitchenSendSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KitchenSendSummaryBuilder();
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
