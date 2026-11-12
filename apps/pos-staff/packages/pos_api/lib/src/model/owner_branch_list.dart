//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/owner_branch.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'owner_branch_list.g.dart';

/// OwnerBranchList
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class OwnerBranchList
    implements Built<OwnerBranchList, OwnerBranchListBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<OwnerBranch> get data;

  OwnerBranchList._();

  factory OwnerBranchList([void updates(OwnerBranchListBuilder b)]) =
      _$OwnerBranchList;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OwnerBranchListBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OwnerBranchList> get serializer =>
      _$OwnerBranchListSerializer();
}

class _$OwnerBranchListSerializer
    implements PrimitiveSerializer<OwnerBranchList> {
  @override
  final Iterable<Type> types = const [OwnerBranchList, _$OwnerBranchList];

  @override
  final String wireName = r'OwnerBranchList';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OwnerBranchList object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(OwnerBranch)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OwnerBranchList object, {
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
    required OwnerBranchListBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OwnerBranch)]),
          ) as BuiltList<OwnerBranch>;
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
  OwnerBranchList deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OwnerBranchListBuilder();
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
