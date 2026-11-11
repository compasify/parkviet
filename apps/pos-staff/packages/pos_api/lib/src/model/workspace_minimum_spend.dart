//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'workspace_minimum_spend.g.dart';

/// WorkspaceMinimumSpend
///
/// Properties:
/// * [minimum]
/// * [amount] - The fee \"Phụ thu mức tối thiểu\" on the bill now.
/// * [waived]
@BuiltValue()
abstract class WorkspaceMinimumSpend
    implements Built<WorkspaceMinimumSpend, WorkspaceMinimumSpendBuilder> {
  @BuiltValueField(wireName: r'minimum')
  String get minimum;

  /// The fee \"Phụ thu mức tối thiểu\" on the bill now.
  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'waived')
  bool get waived;

  WorkspaceMinimumSpend._();

  factory WorkspaceMinimumSpend(
      [void updates(WorkspaceMinimumSpendBuilder b)]) = _$WorkspaceMinimumSpend;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkspaceMinimumSpendBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkspaceMinimumSpend> get serializer =>
      _$WorkspaceMinimumSpendSerializer();
}

class _$WorkspaceMinimumSpendSerializer
    implements PrimitiveSerializer<WorkspaceMinimumSpend> {
  @override
  final Iterable<Type> types = const [
    WorkspaceMinimumSpend,
    _$WorkspaceMinimumSpend
  ];

  @override
  final String wireName = r'WorkspaceMinimumSpend';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkspaceMinimumSpend object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'minimum';
    yield serializers.serialize(
      object.minimum,
      specifiedType: const FullType(String),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'waived';
    yield serializers.serialize(
      object.waived,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkspaceMinimumSpend object, {
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
    required WorkspaceMinimumSpendBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'minimum':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.minimum = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
          break;
        case r'waived':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.waived = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WorkspaceMinimumSpend deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkspaceMinimumSpendBuilder();
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
