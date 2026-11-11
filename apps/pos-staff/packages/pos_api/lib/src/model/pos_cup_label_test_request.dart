//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_cup_label_test_request.g.dart';

/// PosCupLabelTestRequest
///
/// Properties:
/// * [branchId]
@BuiltValue()
abstract class PosCupLabelTestRequest
    implements Built<PosCupLabelTestRequest, PosCupLabelTestRequestBuilder> {
  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  PosCupLabelTestRequest._();

  factory PosCupLabelTestRequest(
          [void updates(PosCupLabelTestRequestBuilder b)]) =
      _$PosCupLabelTestRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosCupLabelTestRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosCupLabelTestRequest> get serializer =>
      _$PosCupLabelTestRequestSerializer();
}

class _$PosCupLabelTestRequestSerializer
    implements PrimitiveSerializer<PosCupLabelTestRequest> {
  @override
  final Iterable<Type> types = const [
    PosCupLabelTestRequest,
    _$PosCupLabelTestRequest
  ];

  @override
  final String wireName = r'PosCupLabelTestRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosCupLabelTestRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosCupLabelTestRequest object, {
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
    required PosCupLabelTestRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosCupLabelTestRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosCupLabelTestRequestBuilder();
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
