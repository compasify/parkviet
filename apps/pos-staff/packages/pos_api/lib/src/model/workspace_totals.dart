//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:pos_api/src/model/workspace_totals_taxes_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'workspace_totals.g.dart';

/// WorkspaceTotals
///
/// Properties:
/// * [taxes]
@BuiltValue()
abstract class WorkspaceTotals
    implements Built<WorkspaceTotals, WorkspaceTotalsBuilder> {
  @BuiltValueField(wireName: r'taxes')
  BuiltList<WorkspaceTotalsTaxesInner> get taxes;

  WorkspaceTotals._();

  factory WorkspaceTotals([void updates(WorkspaceTotalsBuilder b)]) =
      _$WorkspaceTotals;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkspaceTotalsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkspaceTotals> get serializer =>
      _$WorkspaceTotalsSerializer();
}

class _$WorkspaceTotalsSerializer
    implements PrimitiveSerializer<WorkspaceTotals> {
  @override
  final Iterable<Type> types = const [WorkspaceTotals, _$WorkspaceTotals];

  @override
  final String wireName = r'WorkspaceTotals';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkspaceTotals object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'taxes';
    yield serializers.serialize(
      object.taxes,
      specifiedType:
          const FullType(BuiltList, [FullType(WorkspaceTotalsTaxesInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkspaceTotals object, {
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
    required WorkspaceTotalsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'taxes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(WorkspaceTotalsTaxesInner)]),
          ) as BuiltList<WorkspaceTotalsTaxesInner>;
          result.taxes.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WorkspaceTotals deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkspaceTotalsBuilder();
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
