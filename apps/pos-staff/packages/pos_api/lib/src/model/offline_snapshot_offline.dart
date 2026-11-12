//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'offline_snapshot_offline.g.dart';

/// OfflineSnapshotOffline
///
/// Properties:
/// * [allowed]
/// * [reason]
@BuiltValue()
abstract class OfflineSnapshotOffline
    implements Built<OfflineSnapshotOffline, OfflineSnapshotOfflineBuilder> {
  @BuiltValueField(wireName: r'allowed')
  bool get allowed;

  @BuiltValueField(wireName: r'reason')
  OfflineSnapshotOfflineReasonEnum? get reason;
  // enum reasonEnum {  menu_disabled,  register_not_counter,  shift_closed,  cash_unavailable,  ,  };

  OfflineSnapshotOffline._();

  factory OfflineSnapshotOffline(
          [void updates(OfflineSnapshotOfflineBuilder b)]) =
      _$OfflineSnapshotOffline;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OfflineSnapshotOfflineBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OfflineSnapshotOffline> get serializer =>
      _$OfflineSnapshotOfflineSerializer();
}

class _$OfflineSnapshotOfflineSerializer
    implements PrimitiveSerializer<OfflineSnapshotOffline> {
  @override
  final Iterable<Type> types = const [
    OfflineSnapshotOffline,
    _$OfflineSnapshotOffline
  ];

  @override
  final String wireName = r'OfflineSnapshotOffline';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OfflineSnapshotOffline object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'allowed';
    yield serializers.serialize(
      object.allowed,
      specifiedType: const FullType(bool),
    );
    yield r'reason';
    yield object.reason == null
        ? null
        : serializers.serialize(
            object.reason,
            specifiedType:
                const FullType.nullable(OfflineSnapshotOfflineReasonEnum),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    OfflineSnapshotOffline object, {
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
    required OfflineSnapshotOfflineBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'allowed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.allowed = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(OfflineSnapshotOfflineReasonEnum),
          ) as OfflineSnapshotOfflineReasonEnum?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OfflineSnapshotOffline deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OfflineSnapshotOfflineBuilder();
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

class OfflineSnapshotOfflineReasonEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'menu_disabled')
  static const OfflineSnapshotOfflineReasonEnum menuDisabled =
      _$offlineSnapshotOfflineReasonEnum_menuDisabled;
  @BuiltValueEnumConst(wireName: r'register_not_counter')
  static const OfflineSnapshotOfflineReasonEnum registerNotCounter =
      _$offlineSnapshotOfflineReasonEnum_registerNotCounter;
  @BuiltValueEnumConst(wireName: r'shift_closed')
  static const OfflineSnapshotOfflineReasonEnum shiftClosed =
      _$offlineSnapshotOfflineReasonEnum_shiftClosed;
  @BuiltValueEnumConst(wireName: r'cash_unavailable')
  static const OfflineSnapshotOfflineReasonEnum cashUnavailable =
      _$offlineSnapshotOfflineReasonEnum_cashUnavailable;

  static Serializer<OfflineSnapshotOfflineReasonEnum> get serializer =>
      _$offlineSnapshotOfflineReasonEnumSerializer;

  const OfflineSnapshotOfflineReasonEnum._(String name) : super(name);

  static BuiltSet<OfflineSnapshotOfflineReasonEnum> get values =>
      _$offlineSnapshotOfflineReasonEnumValues;
  static OfflineSnapshotOfflineReasonEnum valueOf(String name) =>
      _$offlineSnapshotOfflineReasonEnumValueOf(name);
}
