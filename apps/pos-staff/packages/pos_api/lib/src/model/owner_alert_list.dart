//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/owner_alert.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'owner_alert_list.g.dart';

/// OwnerAlertList
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class OwnerAlertList
    implements Built<OwnerAlertList, OwnerAlertListBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<OwnerAlert> get data;

  OwnerAlertList._();

  factory OwnerAlertList([void updates(OwnerAlertListBuilder b)]) =
      _$OwnerAlertList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OwnerAlertListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OwnerAlertList> get serializer =>
      _$OwnerAlertListSerializer();
}

class _$OwnerAlertListSerializer
    implements PrimitiveSerializer<OwnerAlertList> {
  @override
  final Iterable<Type> types = const [OwnerAlertList, _$OwnerAlertList];

  @override
  final String wireName = r'OwnerAlertList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OwnerAlertList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(OwnerAlert)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OwnerAlertList object, {
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
    required OwnerAlertListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OwnerAlert)]),
          ) as BuiltList<OwnerAlert>;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OwnerAlertList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OwnerAlertListBuilder();
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
