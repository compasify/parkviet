//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/owner_today.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'owner_today_result.g.dart';

/// OwnerTodayResult
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class OwnerTodayResult
    implements Built<OwnerTodayResult, OwnerTodayResultBuilder> {
  @BuiltValueField(wireName: r'data')
  OwnerToday get data;

  OwnerTodayResult._();

  factory OwnerTodayResult([void updates(OwnerTodayResultBuilder b)]) =
      _$OwnerTodayResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OwnerTodayResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OwnerTodayResult> get serializer =>
      _$OwnerTodayResultSerializer();
}

class _$OwnerTodayResultSerializer
    implements PrimitiveSerializer<OwnerTodayResult> {
  @override
  final Iterable<Type> types = const [OwnerTodayResult, _$OwnerTodayResult];

  @override
  final String wireName = r'OwnerTodayResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OwnerTodayResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(OwnerToday),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OwnerTodayResult object, {
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
    required OwnerTodayResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OwnerToday),
          ) as OwnerToday;
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
  OwnerTodayResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OwnerTodayResultBuilder();
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
