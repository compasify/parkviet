//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'approval_revision.g.dart';

/// ApprovalRevision
@BuiltValue()
abstract class ApprovalRevision
    implements Built<ApprovalRevision, ApprovalRevisionBuilder> {
  /// Any Of [String], [int]
  AnyOf get anyOf;

  ApprovalRevision._();

  factory ApprovalRevision([void updates(ApprovalRevisionBuilder b)]) =
      _$ApprovalRevision;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ApprovalRevisionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ApprovalRevision> get serializer =>
      _$ApprovalRevisionSerializer();
}

class _$ApprovalRevisionSerializer
    implements PrimitiveSerializer<ApprovalRevision> {
  @override
  final Iterable<Type> types = const [ApprovalRevision, _$ApprovalRevision];

  @override
  final String wireName = r'ApprovalRevision';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ApprovalRevision object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    ApprovalRevision object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.types.map((type) => FullType(type)).toList()))!;
  }

  @override
  ApprovalRevision deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ApprovalRevisionBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(String),
      FullType(int),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}
