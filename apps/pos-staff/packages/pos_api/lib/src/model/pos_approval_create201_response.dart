//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/approval.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_approval_create201_response.g.dart';

/// PosApprovalCreate201Response
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PosApprovalCreate201Response
    implements
        Built<PosApprovalCreate201Response,
            PosApprovalCreate201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Approval get data;

  PosApprovalCreate201Response._();

  factory PosApprovalCreate201Response(
          [void updates(PosApprovalCreate201ResponseBuilder b)]) =
      _$PosApprovalCreate201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosApprovalCreate201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosApprovalCreate201Response> get serializer =>
      _$PosApprovalCreate201ResponseSerializer();
}

class _$PosApprovalCreate201ResponseSerializer
    implements PrimitiveSerializer<PosApprovalCreate201Response> {
  @override
  final Iterable<Type> types = const [
    PosApprovalCreate201Response,
    _$PosApprovalCreate201Response
  ];

  @override
  final String wireName = r'PosApprovalCreate201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosApprovalCreate201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Approval),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PosApprovalCreate201Response object, {
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
    required PosApprovalCreate201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Approval),
          ) as Approval;
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
  PosApprovalCreate201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosApprovalCreate201ResponseBuilder();
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
