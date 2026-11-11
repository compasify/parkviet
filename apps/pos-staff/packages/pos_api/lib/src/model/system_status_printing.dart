//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'system_status_printing.g.dart';

/// SystemStatusPrinting
///
/// Properties:
/// * [pending]
/// * [oldestPendingAgeSeconds]
/// * [failedLast24h]
/// * [failedWindowHours]
@BuiltValue()
abstract class SystemStatusPrinting
    implements Built<SystemStatusPrinting, SystemStatusPrintingBuilder> {
  @BuiltValueField(wireName: r'pending')
  int get pending;

  @BuiltValueField(wireName: r'oldest_pending_age_seconds')
  int? get oldestPendingAgeSeconds;

  @BuiltValueField(wireName: r'failed_last_24h')
  int get failedLast24h;

  @BuiltValueField(wireName: r'failed_window_hours')
  int get failedWindowHours;

  SystemStatusPrinting._();

  factory SystemStatusPrinting([void updates(SystemStatusPrintingBuilder b)]) =
      _$SystemStatusPrinting;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SystemStatusPrintingBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SystemStatusPrinting> get serializer =>
      _$SystemStatusPrintingSerializer();
}

class _$SystemStatusPrintingSerializer
    implements PrimitiveSerializer<SystemStatusPrinting> {
  @override
  final Iterable<Type> types = const [
    SystemStatusPrinting,
    _$SystemStatusPrinting
  ];

  @override
  final String wireName = r'SystemStatusPrinting';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SystemStatusPrinting object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'pending';
    yield serializers.serialize(
      object.pending,
      specifiedType: const FullType(int),
    );
    yield r'oldest_pending_age_seconds';
    yield object.oldestPendingAgeSeconds == null
        ? null
        : serializers.serialize(
            object.oldestPendingAgeSeconds,
            specifiedType: const FullType.nullable(int),
          );
    yield r'failed_last_24h';
    yield serializers.serialize(
      object.failedLast24h,
      specifiedType: const FullType(int),
    );
    yield r'failed_window_hours';
    yield serializers.serialize(
      object.failedWindowHours,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SystemStatusPrinting object, {
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
    required SystemStatusPrintingBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'pending':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pending = valueDes;
          break;
        case r'oldest_pending_age_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.oldestPendingAgeSeconds = valueDes;
          break;
        case r'failed_last_24h':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.failedLast24h = valueDes;
          break;
        case r'failed_window_hours':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.failedWindowHours = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SystemStatusPrinting deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SystemStatusPrintingBuilder();
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
