//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/bottle_keep_customer.dart';
import 'package:pos_api/src/model/bottle_keep_event.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bottle_keep.g.dart';

/// BottleKeep
///
/// Properties:
/// * [id]
/// * [branchId]
/// * [code] - The code on the bottle's label.
/// * [status]
/// * [levelPercent]
/// * [variantId]
/// * [productName]
/// * [optionsText]
/// * [customer]
/// * [guestName]
/// * [phone]
/// * [keptOn]
/// * [expiresOn]
/// * [sourceOrderId]
/// * [note]
/// * [revision]
/// * [photoUrl]
/// * [createdAt]
/// * [closedAt]
/// * [events]
@BuiltValue()
abstract class BottleKeep implements Built<BottleKeep, BottleKeepBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  /// The code on the bottle's label.
  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'status')
  BottleKeepStatusEnum get status;
  // enum statusEnum {  kept,  finished,  expired,  returned,  };

  @BuiltValueField(wireName: r'level_percent')
  int get levelPercent;

  @BuiltValueField(wireName: r'variant_id')
  String get variantId;

  @BuiltValueField(wireName: r'product_name')
  String? get productName;

  @BuiltValueField(wireName: r'options_text')
  String? get optionsText;

  @BuiltValueField(wireName: r'customer')
  BottleKeepCustomer? get customer;

  @BuiltValueField(wireName: r'guest_name')
  String? get guestName;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'kept_on')
  Date get keptOn;

  @BuiltValueField(wireName: r'expires_on')
  Date get expiresOn;

  @BuiltValueField(wireName: r'source_order_id')
  String? get sourceOrderId;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'photo_url')
  String? get photoUrl;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'closed_at')
  DateTime? get closedAt;

  @BuiltValueField(wireName: r'events')
  BuiltList<BottleKeepEvent>? get events;

  BottleKeep._();

  factory BottleKeep([void updates(BottleKeepBuilder b)]) = _$BottleKeep;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BottleKeepBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BottleKeep> get serializer => _$BottleKeepSerializer();
}

class _$BottleKeepSerializer implements PrimitiveSerializer<BottleKeep> {
  @override
  final Iterable<Type> types = const [BottleKeep, _$BottleKeep];

  @override
  final String wireName = r'BottleKeep';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BottleKeep object, {
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
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(BottleKeepStatusEnum),
    );
    yield r'level_percent';
    yield serializers.serialize(
      object.levelPercent,
      specifiedType: const FullType(int),
    );
    yield r'variant_id';
    yield serializers.serialize(
      object.variantId,
      specifiedType: const FullType(String),
    );
    if (object.productName != null) {
      yield r'product_name';
      yield serializers.serialize(
        object.productName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.optionsText != null) {
      yield r'options_text';
      yield serializers.serialize(
        object.optionsText,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.customer != null) {
      yield r'customer';
      yield serializers.serialize(
        object.customer,
        specifiedType: const FullType.nullable(BottleKeepCustomer),
      );
    }
    if (object.guestName != null) {
      yield r'guest_name';
      yield serializers.serialize(
        object.guestName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.phone != null) {
      yield r'phone';
      yield serializers.serialize(
        object.phone,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'kept_on';
    yield serializers.serialize(
      object.keptOn,
      specifiedType: const FullType(Date),
    );
    yield r'expires_on';
    yield serializers.serialize(
      object.expiresOn,
      specifiedType: const FullType(Date),
    );
    if (object.sourceOrderId != null) {
      yield r'source_order_id';
      yield serializers.serialize(
        object.sourceOrderId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
    if (object.photoUrl != null) {
      yield r'photo_url';
      yield serializers.serialize(
        object.photoUrl,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.closedAt != null) {
      yield r'closed_at';
      yield serializers.serialize(
        object.closedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.events != null) {
      yield r'events';
      yield serializers.serialize(
        object.events,
        specifiedType: const FullType(BuiltList, [FullType(BottleKeepEvent)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BottleKeep object, {
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
    required BottleKeepBuilder result,
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
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BottleKeepStatusEnum),
          ) as BottleKeepStatusEnum;
          result.status = valueDes;
          break;
        case r'level_percent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.levelPercent = valueDes;
          break;
        case r'variant_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.variantId = valueDes;
          break;
        case r'product_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.productName = valueDes;
          break;
        case r'options_text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.optionsText = valueDes;
          break;
        case r'customer':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BottleKeepCustomer),
          ) as BottleKeepCustomer?;
          if (valueDes == null) continue;
          result.customer.replace(valueDes);
          break;
        case r'guest_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.guestName = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phone = valueDes;
          break;
        case r'kept_on':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.keptOn = valueDes;
          break;
        case r'expires_on':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.expiresOn = valueDes;
          break;
        case r'source_order_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sourceOrderId = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
          break;
        case r'photo_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.photoUrl = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'closed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.closedAt = valueDes;
          break;
        case r'events':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(BottleKeepEvent)]),
          ) as BuiltList<BottleKeepEvent>?;
          if (valueDes == null) continue;
          result.events.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BottleKeep deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BottleKeepBuilder();
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

class BottleKeepStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'kept')
  static const BottleKeepStatusEnum kept = _$bottleKeepStatusEnum_kept;
  @BuiltValueEnumConst(wireName: r'finished')
  static const BottleKeepStatusEnum finished = _$bottleKeepStatusEnum_finished;
  @BuiltValueEnumConst(wireName: r'expired')
  static const BottleKeepStatusEnum expired = _$bottleKeepStatusEnum_expired;
  @BuiltValueEnumConst(wireName: r'returned')
  static const BottleKeepStatusEnum returned = _$bottleKeepStatusEnum_returned;

  static Serializer<BottleKeepStatusEnum> get serializer =>
      _$bottleKeepStatusEnumSerializer;

  const BottleKeepStatusEnum._(String name) : super(name);

  static BuiltSet<BottleKeepStatusEnum> get values =>
      _$bottleKeepStatusEnumValues;
  static BottleKeepStatusEnum valueOf(String name) =>
      _$bottleKeepStatusEnumValueOf(name);
}
