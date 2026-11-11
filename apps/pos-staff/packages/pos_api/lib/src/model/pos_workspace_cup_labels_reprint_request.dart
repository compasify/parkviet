//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pos_workspace_cup_labels_reprint_request.g.dart';

/// PosWorkspaceCupLabelsReprintRequest
///
/// Properties:
/// * [saleLineId]
@BuiltValue()
abstract class PosWorkspaceCupLabelsReprintRequest
    implements
        Built<PosWorkspaceCupLabelsReprintRequest,
            PosWorkspaceCupLabelsReprintRequestBuilder> {
  @BuiltValueField(wireName: r'sale_line_id')
  String? get saleLineId;

  PosWorkspaceCupLabelsReprintRequest._();

  factory PosWorkspaceCupLabelsReprintRequest(
          [void updates(PosWorkspaceCupLabelsReprintRequestBuilder b)]) =
      _$PosWorkspaceCupLabelsReprintRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PosWorkspaceCupLabelsReprintRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PosWorkspaceCupLabelsReprintRequest> get serializer =>
      _$PosWorkspaceCupLabelsReprintRequestSerializer();
}

class _$PosWorkspaceCupLabelsReprintRequestSerializer
    implements PrimitiveSerializer<PosWorkspaceCupLabelsReprintRequest> {
  @override
  final Iterable<Type> types = const [
    PosWorkspaceCupLabelsReprintRequest,
    _$PosWorkspaceCupLabelsReprintRequest
  ];

  @override
  final String wireName = r'PosWorkspaceCupLabelsReprintRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PosWorkspaceCupLabelsReprintRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.saleLineId != null) {
      yield r'sale_line_id';
      yield serializers.serialize(
        object.saleLineId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PosWorkspaceCupLabelsReprintRequest object, {
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
    required PosWorkspaceCupLabelsReprintRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sale_line_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.saleLineId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PosWorkspaceCupLabelsReprintRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PosWorkspaceCupLabelsReprintRequestBuilder();
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
