//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_job_reprint.g.dart';

/// Listed pre-bills of open orders only. What the reader may do about reprinting.
///
/// Properties:
/// * [workspaceRevision]
/// * [approvalId] - A usable approval the reader can spend on this order.
/// * [requesterId] - Who an approval would be granted to.
/// * [canApprove]
@BuiltValue()
abstract class PrintJobReprint
    implements Built<PrintJobReprint, PrintJobReprintBuilder> {
  @BuiltValueField(wireName: r'workspace_revision')
  int get workspaceRevision;

  /// A usable approval the reader can spend on this order.
  @BuiltValueField(wireName: r'approval_id')
  String? get approvalId;

  /// Who an approval would be granted to.
  @BuiltValueField(wireName: r'requester_id')
  String? get requesterId;

  @BuiltValueField(wireName: r'can_approve')
  bool get canApprove;

  PrintJobReprint._();

  factory PrintJobReprint([void updates(PrintJobReprintBuilder b)]) =
      _$PrintJobReprint;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintJobReprintBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintJobReprint> get serializer =>
      _$PrintJobReprintSerializer();
}

class _$PrintJobReprintSerializer
    implements PrimitiveSerializer<PrintJobReprint> {
  @override
  final Iterable<Type> types = const [PrintJobReprint, _$PrintJobReprint];

  @override
  final String wireName = r'PrintJobReprint';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintJobReprint object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'workspace_revision';
    yield serializers.serialize(
      object.workspaceRevision,
      specifiedType: const FullType(int),
    );
    yield r'approval_id';
    yield object.approvalId == null
        ? null
        : serializers.serialize(
            object.approvalId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'requester_id';
    yield object.requesterId == null
        ? null
        : serializers.serialize(
            object.requesterId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'can_approve';
    yield serializers.serialize(
      object.canApprove,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PrintJobReprint object, {
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
    required PrintJobReprintBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'workspace_revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.workspaceRevision = valueDes;
          break;
        case r'approval_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.approvalId = valueDes;
          break;
        case r'requester_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.requesterId = valueDes;
          break;
        case r'can_approve':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.canApprove = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrintJobReprint deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintJobReprintBuilder();
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
