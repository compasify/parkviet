//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/owner_open_unit.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'owner_open_unit_list.g.dart';

/// OwnerOpenUnitList
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class OwnerOpenUnitList
    implements Built<OwnerOpenUnitList, OwnerOpenUnitListBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<OwnerOpenUnit> get data;

  OwnerOpenUnitList._();

  factory OwnerOpenUnitList([void updates(OwnerOpenUnitListBuilder b)]) =
      _$OwnerOpenUnitList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OwnerOpenUnitListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OwnerOpenUnitList> get serializer =>
      _$OwnerOpenUnitListSerializer();
}

class _$OwnerOpenUnitListSerializer
    implements PrimitiveSerializer<OwnerOpenUnitList> {
  @override
  final Iterable<Type> types = const [OwnerOpenUnitList, _$OwnerOpenUnitList];

  @override
  final String wireName = r'OwnerOpenUnitList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OwnerOpenUnitList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(OwnerOpenUnit)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OwnerOpenUnitList object, {
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
    required OwnerOpenUnitListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OwnerOpenUnit)]),
          ) as BuiltList<OwnerOpenUnit>;
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
  OwnerOpenUnitList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OwnerOpenUnitListBuilder();
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
