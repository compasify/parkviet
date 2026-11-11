//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'workspace_drink_credit.g.dart';

/// WorkspaceDrinkCredit
///
/// Properties:
/// * [total]
/// * [used]
/// * [remaining]
@BuiltValue()
abstract class WorkspaceDrinkCredit
    implements Built<WorkspaceDrinkCredit, WorkspaceDrinkCreditBuilder> {
  @BuiltValueField(wireName: r'total')
  String get total;

  @BuiltValueField(wireName: r'used')
  String get used;

  @BuiltValueField(wireName: r'remaining')
  String get remaining;

  WorkspaceDrinkCredit._();

  factory WorkspaceDrinkCredit([void updates(WorkspaceDrinkCreditBuilder b)]) =
      _$WorkspaceDrinkCredit;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkspaceDrinkCreditBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkspaceDrinkCredit> get serializer =>
      _$WorkspaceDrinkCreditSerializer();
}

class _$WorkspaceDrinkCreditSerializer
    implements PrimitiveSerializer<WorkspaceDrinkCredit> {
  @override
  final Iterable<Type> types = const [
    WorkspaceDrinkCredit,
    _$WorkspaceDrinkCredit
  ];

  @override
  final String wireName = r'WorkspaceDrinkCredit';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkspaceDrinkCredit object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(String),
    );
    yield r'used';
    yield serializers.serialize(
      object.used,
      specifiedType: const FullType(String),
    );
    yield r'remaining';
    yield serializers.serialize(
      object.remaining,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkspaceDrinkCredit object, {
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
    required WorkspaceDrinkCreditBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.total = valueDes;
          break;
        case r'used':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.used = valueDes;
          break;
        case r'remaining':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.remaining = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WorkspaceDrinkCredit deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkspaceDrinkCreditBuilder();
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
