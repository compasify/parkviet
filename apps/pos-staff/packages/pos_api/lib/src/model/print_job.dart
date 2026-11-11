//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/print_job_reprint.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'print_job.g.dart';

/// The queue view; a job's document goes only to its print station.
///
/// Properties:
/// * [id]
/// * [branchId]
/// * [printerId]
/// * [printerName]
/// * [kind]
/// * [status]
/// * [attempts]
/// * [label]
/// * [lastError]
/// * [copyOfId]
/// * [createdAt]
/// * [printedAt]
/// * [workspaceId] - The order of a pre-bill.
/// * [sourceRevision] - The order's revision when the pre-bill was built.
/// * [printerAvailable] - False when the printer is disabled or its print station is revoked, so a waiting job is stuck.
/// * [reprinted] - A reprint of this job exists and was not canceled.
/// * [reprint]
@BuiltValue()
abstract class PrintJob implements Built<PrintJob, PrintJobBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'printer_id')
  String get printerId;

  @BuiltValueField(wireName: r'printer_name')
  String get printerName;

  @BuiltValueField(wireName: r'kind')
  PrintJobKindEnum get kind;
  // enum kindEnum {  receipt,  prebill,  kitchen_ticket,  void_ticket,  cup_label,  checklist,  table_qr,  test,  };

  @BuiltValueField(wireName: r'status')
  PrintJobStatusEnum get status;
  // enum statusEnum {  queued,  claimed,  printed,  failed,  canceled,  };

  @BuiltValueField(wireName: r'attempts')
  int get attempts;

  @BuiltValueField(wireName: r'label')
  String? get label;

  @BuiltValueField(wireName: r'last_error')
  String? get lastError;

  @BuiltValueField(wireName: r'copy_of_id')
  String? get copyOfId;

  @BuiltValueField(wireName: r'created_at')
  String get createdAt;

  @BuiltValueField(wireName: r'printed_at')
  String? get printedAt;

  /// The order of a pre-bill.
  @BuiltValueField(wireName: r'workspace_id')
  String? get workspaceId;

  /// The order's revision when the pre-bill was built.
  @BuiltValueField(wireName: r'source_revision')
  int? get sourceRevision;

  /// False when the printer is disabled or its print station is revoked, so a waiting job is stuck.
  @BuiltValueField(wireName: r'printer_available')
  bool get printerAvailable;

  /// A reprint of this job exists and was not canceled.
  @BuiltValueField(wireName: r'reprinted')
  bool get reprinted;

  @BuiltValueField(wireName: r'reprint')
  PrintJobReprint? get reprint;

  PrintJob._();

  factory PrintJob([void updates(PrintJobBuilder b)]) = _$PrintJob;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PrintJobBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PrintJob> get serializer => _$PrintJobSerializer();
}

class _$PrintJobSerializer implements PrimitiveSerializer<PrintJob> {
  @override
  final Iterable<Type> types = const [PrintJob, _$PrintJob];

  @override
  final String wireName = r'PrintJob';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PrintJob object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'printer_id';
    yield serializers.serialize(
      object.printerId,
      specifiedType: const FullType(String),
    );
    yield r'printer_name';
    yield serializers.serialize(
      object.printerName,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(PrintJobKindEnum),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(PrintJobStatusEnum),
    );
    yield r'attempts';
    yield serializers.serialize(
      object.attempts,
      specifiedType: const FullType(int),
    );
    yield r'label';
    yield object.label == null
        ? null
        : serializers.serialize(
            object.label,
            specifiedType: const FullType.nullable(String),
          );
    yield r'last_error';
    yield object.lastError == null
        ? null
        : serializers.serialize(
            object.lastError,
            specifiedType: const FullType.nullable(String),
          );
    yield r'copy_of_id';
    yield object.copyOfId == null
        ? null
        : serializers.serialize(
            object.copyOfId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(String),
    );
    yield r'printed_at';
    yield object.printedAt == null
        ? null
        : serializers.serialize(
            object.printedAt,
            specifiedType: const FullType.nullable(String),
          );
    yield r'workspace_id';
    yield object.workspaceId == null
        ? null
        : serializers.serialize(
            object.workspaceId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'source_revision';
    yield object.sourceRevision == null
        ? null
        : serializers.serialize(
            object.sourceRevision,
            specifiedType: const FullType.nullable(int),
          );
    yield r'printer_available';
    yield serializers.serialize(
      object.printerAvailable,
      specifiedType: const FullType(bool),
    );
    yield r'reprinted';
    yield serializers.serialize(
      object.reprinted,
      specifiedType: const FullType(bool),
    );
    if (object.reprint != null) {
      yield r'reprint';
      yield serializers.serialize(
        object.reprint,
        specifiedType: const FullType(PrintJobReprint),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PrintJob object, {
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
    required PrintJobBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'printer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.printerId = valueDes;
          break;
        case r'printer_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.printerName = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrintJobKindEnum),
          ) as PrintJobKindEnum;
          result.kind = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PrintJobStatusEnum),
          ) as PrintJobStatusEnum;
          result.status = valueDes;
          break;
        case r'attempts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.attempts = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.label = valueDes;
          break;
        case r'last_error':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lastError = valueDes;
          break;
        case r'copy_of_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.copyOfId = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.createdAt = valueDes;
          break;
        case r'printed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.printedAt = valueDes;
          break;
        case r'workspace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.workspaceId = valueDes;
          break;
        case r'source_revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.sourceRevision = valueDes;
          break;
        case r'printer_available':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.printerAvailable = valueDes;
          break;
        case r'reprinted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.reprinted = valueDes;
          break;
        case r'reprint':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(PrintJobReprint),
          ) as PrintJobReprint?;
          if (valueDes == null) continue;
          result.reprint.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PrintJob deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PrintJobBuilder();
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

class PrintJobKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'receipt')
  static const PrintJobKindEnum receipt = _$printJobKindEnum_receipt;
  @BuiltValueEnumConst(wireName: r'prebill')
  static const PrintJobKindEnum prebill = _$printJobKindEnum_prebill;
  @BuiltValueEnumConst(wireName: r'kitchen_ticket')
  static const PrintJobKindEnum kitchenTicket =
      _$printJobKindEnum_kitchenTicket;
  @BuiltValueEnumConst(wireName: r'void_ticket')
  static const PrintJobKindEnum voidTicket = _$printJobKindEnum_voidTicket;
  @BuiltValueEnumConst(wireName: r'cup_label')
  static const PrintJobKindEnum cupLabel = _$printJobKindEnum_cupLabel;
  @BuiltValueEnumConst(wireName: r'checklist')
  static const PrintJobKindEnum checklist = _$printJobKindEnum_checklist;
  @BuiltValueEnumConst(wireName: r'table_qr')
  static const PrintJobKindEnum tableQr = _$printJobKindEnum_tableQr;
  @BuiltValueEnumConst(wireName: r'test')
  static const PrintJobKindEnum test = _$printJobKindEnum_test;

  static Serializer<PrintJobKindEnum> get serializer =>
      _$printJobKindEnumSerializer;

  const PrintJobKindEnum._(String name) : super(name);

  static BuiltSet<PrintJobKindEnum> get values => _$printJobKindEnumValues;
  static PrintJobKindEnum valueOf(String name) =>
      _$printJobKindEnumValueOf(name);
}

class PrintJobStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'queued')
  static const PrintJobStatusEnum queued = _$printJobStatusEnum_queued;
  @BuiltValueEnumConst(wireName: r'claimed')
  static const PrintJobStatusEnum claimed = _$printJobStatusEnum_claimed;
  @BuiltValueEnumConst(wireName: r'printed')
  static const PrintJobStatusEnum printed = _$printJobStatusEnum_printed;
  @BuiltValueEnumConst(wireName: r'failed')
  static const PrintJobStatusEnum failed = _$printJobStatusEnum_failed;
  @BuiltValueEnumConst(wireName: r'canceled')
  static const PrintJobStatusEnum canceled = _$printJobStatusEnum_canceled;

  static Serializer<PrintJobStatusEnum> get serializer =>
      _$printJobStatusEnumSerializer;

  const PrintJobStatusEnum._(String name) : super(name);

  static BuiltSet<PrintJobStatusEnum> get values => _$printJobStatusEnumValues;
  static PrintJobStatusEnum valueOf(String name) =>
      _$printJobStatusEnumValueOf(name);
}
