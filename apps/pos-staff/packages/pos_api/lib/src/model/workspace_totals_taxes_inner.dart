//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'workspace_totals_taxes_inner.g.dart';

/// WorkspaceTotalsTaxesInner
///
/// Properties:
/// * [rate]
/// * [label]
/// * [amount]
@BuiltValue()
abstract class WorkspaceTotalsTaxesInner
    implements
        Built<WorkspaceTotalsTaxesInner, WorkspaceTotalsTaxesInnerBuilder> {
  @BuiltValueField(wireName: r'rate')
  String get rate;

  @BuiltValueField(wireName: r'label')
  String get label;

  @BuiltValueField(wireName: r'amount')
  String get amount;

  WorkspaceTotalsTaxesInner._();

  factory WorkspaceTotalsTaxesInner(
          [void updates(WorkspaceTotalsTaxesInnerBuilder b)]) =
      _$WorkspaceTotalsTaxesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkspaceTotalsTaxesInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkspaceTotalsTaxesInner> get serializer =>
      _$WorkspaceTotalsTaxesInnerSerializer();
}

class _$WorkspaceTotalsTaxesInnerSerializer
    implements PrimitiveSerializer<WorkspaceTotalsTaxesInner> {
  @override
  final Iterable<Type> types = const [
    WorkspaceTotalsTaxesInner,
    _$WorkspaceTotalsTaxesInner
  ];

  @override
  final String wireName = r'WorkspaceTotalsTaxesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkspaceTotalsTaxesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'rate';
    yield serializers.serialize(
      object.rate,
      specifiedType: const FullType(String),
    );
    yield r'label';
    yield serializers.serialize(
      object.label,
      specifiedType: const FullType(String),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkspaceTotalsTaxesInner object, {
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
    required WorkspaceTotalsTaxesInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'rate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rate = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.label = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WorkspaceTotalsTaxesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkspaceTotalsTaxesInnerBuilder();
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
