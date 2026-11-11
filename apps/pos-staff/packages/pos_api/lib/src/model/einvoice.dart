//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:pos_api/src/model/einvoice_buyer.dart';
import 'package:pos_api/src/model/einvoice_totals.dart';
import 'package:built_collection/built_collection.dart';
import 'package:pos_api/src/model/einvoice_line.dart';
import 'package:pos_api/src/model/einvoice_seller.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'einvoice.g.dart';

/// Einvoice
///
/// Properties:
/// * [id]
/// * [orderId]
/// * [orderNumber]
/// * [workspaceId]
/// * [branchId]
/// * [branchName]
/// * [relation]
/// * [originalEinvoiceId]
/// * [invoiceType]
/// * [provider]
/// * [status]
/// * [buyer]
/// * [seller]
/// * [lines]
/// * [totals]
/// * [paymentMethod]
/// * [currency]
/// * [templateCode]
/// * [symbol]
/// * [number]
/// * [cqtCode] - The tax authority's code
/// * [lookupCode]
/// * [lookupUrl]
/// * [issuedAt]
/// * [attempts]
/// * [nextAttemptAt]
/// * [lastError]
/// * [buyerLinkOpen] - The buyer's own page still takes details
/// * [buyerTokenExpiresAt]
/// * [buyerSubmittedAt]
/// * [canceledAt]
/// * [cancelReason]
/// * [completedAt]
/// * [total]
/// * [createdAt]
@BuiltValue()
abstract class Einvoice implements Built<Einvoice, EinvoiceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'order_id')
  String get orderId;

  @BuiltValueField(wireName: r'order_number')
  String get orderNumber;

  @BuiltValueField(wireName: r'workspace_id')
  String get workspaceId;

  @BuiltValueField(wireName: r'branch_id')
  String get branchId;

  @BuiltValueField(wireName: r'branch_name')
  String get branchName;

  @BuiltValueField(wireName: r'relation')
  EinvoiceRelationEnum get relation;
  // enum relationEnum {  original,  replacement,  };

  @BuiltValueField(wireName: r'original_einvoice_id')
  String? get originalEinvoiceId;

  @BuiltValueField(wireName: r'invoice_type')
  EinvoiceInvoiceTypeEnum get invoiceType;
  // enum invoiceTypeEnum {  cash_register,  coded,  };

  @BuiltValueField(wireName: r'provider')
  String? get provider;

  @BuiltValueField(wireName: r'status')
  EinvoiceStatusEnum get status;
  // enum statusEnum {  pending,  issuing,  issued,  failed,  canceled,  replaced,  adjusted,  };

  @BuiltValueField(wireName: r'buyer')
  EinvoiceBuyer get buyer;

  @BuiltValueField(wireName: r'seller')
  EinvoiceSeller get seller;

  @BuiltValueField(wireName: r'lines')
  BuiltList<EinvoiceLine> get lines;

  @BuiltValueField(wireName: r'totals')
  EinvoiceTotals get totals;

  @BuiltValueField(wireName: r'payment_method')
  EinvoicePaymentMethodEnum? get paymentMethod;
  // enum paymentMethodEnum {  TM,  CK,  TM/CK,  ,  };

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'template_code')
  String? get templateCode;

  @BuiltValueField(wireName: r'symbol')
  String? get symbol;

  @BuiltValueField(wireName: r'number')
  String? get number;

  /// The tax authority's code
  @BuiltValueField(wireName: r'cqt_code')
  String? get cqtCode;

  @BuiltValueField(wireName: r'lookup_code')
  String? get lookupCode;

  @BuiltValueField(wireName: r'lookup_url')
  String? get lookupUrl;

  @BuiltValueField(wireName: r'issued_at')
  DateTime? get issuedAt;

  @BuiltValueField(wireName: r'attempts')
  int get attempts;

  @BuiltValueField(wireName: r'next_attempt_at')
  DateTime? get nextAttemptAt;

  @BuiltValueField(wireName: r'last_error')
  String? get lastError;

  /// The buyer's own page still takes details
  @BuiltValueField(wireName: r'buyer_link_open')
  bool get buyerLinkOpen;

  @BuiltValueField(wireName: r'buyer_token_expires_at')
  DateTime? get buyerTokenExpiresAt;

  @BuiltValueField(wireName: r'buyer_submitted_at')
  DateTime? get buyerSubmittedAt;

  @BuiltValueField(wireName: r'canceled_at')
  DateTime? get canceledAt;

  @BuiltValueField(wireName: r'cancel_reason')
  String? get cancelReason;

  @BuiltValueField(wireName: r'completed_at')
  DateTime? get completedAt;

  @BuiltValueField(wireName: r'total')
  String? get total;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  Einvoice._();

  factory Einvoice([void updates(EinvoiceBuilder b)]) = _$Einvoice;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EinvoiceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Einvoice> get serializer => _$EinvoiceSerializer();
}

class _$EinvoiceSerializer implements PrimitiveSerializer<Einvoice> {
  @override
  final Iterable<Type> types = const [Einvoice, _$Einvoice];

  @override
  final String wireName = r'Einvoice';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Einvoice object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'order_id';
    yield serializers.serialize(
      object.orderId,
      specifiedType: const FullType(String),
    );
    yield r'order_number';
    yield serializers.serialize(
      object.orderNumber,
      specifiedType: const FullType(String),
    );
    yield r'workspace_id';
    yield serializers.serialize(
      object.workspaceId,
      specifiedType: const FullType(String),
    );
    yield r'branch_id';
    yield serializers.serialize(
      object.branchId,
      specifiedType: const FullType(String),
    );
    yield r'branch_name';
    yield serializers.serialize(
      object.branchName,
      specifiedType: const FullType(String),
    );
    yield r'relation';
    yield serializers.serialize(
      object.relation,
      specifiedType: const FullType(EinvoiceRelationEnum),
    );
    yield r'original_einvoice_id';
    yield object.originalEinvoiceId == null
        ? null
        : serializers.serialize(
            object.originalEinvoiceId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'invoice_type';
    yield serializers.serialize(
      object.invoiceType,
      specifiedType: const FullType(EinvoiceInvoiceTypeEnum),
    );
    yield r'provider';
    yield object.provider == null
        ? null
        : serializers.serialize(
            object.provider,
            specifiedType: const FullType.nullable(String),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(EinvoiceStatusEnum),
    );
    yield r'buyer';
    yield serializers.serialize(
      object.buyer,
      specifiedType: const FullType(EinvoiceBuyer),
    );
    yield r'seller';
    yield serializers.serialize(
      object.seller,
      specifiedType: const FullType(EinvoiceSeller),
    );
    yield r'lines';
    yield serializers.serialize(
      object.lines,
      specifiedType: const FullType(BuiltList, [FullType(EinvoiceLine)]),
    );
    yield r'totals';
    yield serializers.serialize(
      object.totals,
      specifiedType: const FullType(EinvoiceTotals),
    );
    yield r'payment_method';
    yield object.paymentMethod == null
        ? null
        : serializers.serialize(
            object.paymentMethod,
            specifiedType: const FullType.nullable(EinvoicePaymentMethodEnum),
          );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'template_code';
    yield object.templateCode == null
        ? null
        : serializers.serialize(
            object.templateCode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'symbol';
    yield object.symbol == null
        ? null
        : serializers.serialize(
            object.symbol,
            specifiedType: const FullType.nullable(String),
          );
    yield r'number';
    yield object.number == null
        ? null
        : serializers.serialize(
            object.number,
            specifiedType: const FullType.nullable(String),
          );
    yield r'cqt_code';
    yield object.cqtCode == null
        ? null
        : serializers.serialize(
            object.cqtCode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'lookup_code';
    yield object.lookupCode == null
        ? null
        : serializers.serialize(
            object.lookupCode,
            specifiedType: const FullType.nullable(String),
          );
    yield r'lookup_url';
    yield object.lookupUrl == null
        ? null
        : serializers.serialize(
            object.lookupUrl,
            specifiedType: const FullType.nullable(String),
          );
    yield r'issued_at';
    yield object.issuedAt == null
        ? null
        : serializers.serialize(
            object.issuedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'attempts';
    yield serializers.serialize(
      object.attempts,
      specifiedType: const FullType(int),
    );
    yield r'next_attempt_at';
    yield object.nextAttemptAt == null
        ? null
        : serializers.serialize(
            object.nextAttemptAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'last_error';
    yield object.lastError == null
        ? null
        : serializers.serialize(
            object.lastError,
            specifiedType: const FullType.nullable(String),
          );
    yield r'buyer_link_open';
    yield serializers.serialize(
      object.buyerLinkOpen,
      specifiedType: const FullType(bool),
    );
    yield r'buyer_token_expires_at';
    yield object.buyerTokenExpiresAt == null
        ? null
        : serializers.serialize(
            object.buyerTokenExpiresAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'buyer_submitted_at';
    yield object.buyerSubmittedAt == null
        ? null
        : serializers.serialize(
            object.buyerSubmittedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'canceled_at';
    yield object.canceledAt == null
        ? null
        : serializers.serialize(
            object.canceledAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'cancel_reason';
    yield object.cancelReason == null
        ? null
        : serializers.serialize(
            object.cancelReason,
            specifiedType: const FullType.nullable(String),
          );
    yield r'completed_at';
    yield object.completedAt == null
        ? null
        : serializers.serialize(
            object.completedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'total';
    yield object.total == null
        ? null
        : serializers.serialize(
            object.total,
            specifiedType: const FullType.nullable(String),
          );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Einvoice object, {
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
    required EinvoiceBuilder result,
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
        case r'order_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.orderId = valueDes;
          break;
        case r'order_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.orderNumber = valueDes;
          break;
        case r'workspace_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.workspaceId = valueDes;
          break;
        case r'branch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchId = valueDes;
          break;
        case r'branch_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.branchName = valueDes;
          break;
        case r'relation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EinvoiceRelationEnum),
          ) as EinvoiceRelationEnum;
          result.relation = valueDes;
          break;
        case r'original_einvoice_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.originalEinvoiceId = valueDes;
          break;
        case r'invoice_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EinvoiceInvoiceTypeEnum),
          ) as EinvoiceInvoiceTypeEnum;
          result.invoiceType = valueDes;
          break;
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.provider = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EinvoiceStatusEnum),
          ) as EinvoiceStatusEnum;
          result.status = valueDes;
          break;
        case r'buyer':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EinvoiceBuyer),
          ) as EinvoiceBuyer;
          result.buyer.replace(valueDes);
          break;
        case r'seller':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EinvoiceSeller),
          ) as EinvoiceSeller;
          result.seller.replace(valueDes);
          break;
        case r'lines':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(EinvoiceLine)]),
          ) as BuiltList<EinvoiceLine>;
          result.lines.replace(valueDes);
          break;
        case r'totals':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EinvoiceTotals),
          ) as EinvoiceTotals;
          result.totals.replace(valueDes);
          break;
        case r'payment_method':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(EinvoicePaymentMethodEnum),
          ) as EinvoicePaymentMethodEnum?;
          if (valueDes == null) continue;
          result.paymentMethod = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'template_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.templateCode = valueDes;
          break;
        case r'symbol':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.symbol = valueDes;
          break;
        case r'number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.number = valueDes;
          break;
        case r'cqt_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.cqtCode = valueDes;
          break;
        case r'lookup_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lookupCode = valueDes;
          break;
        case r'lookup_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lookupUrl = valueDes;
          break;
        case r'issued_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.issuedAt = valueDes;
          break;
        case r'attempts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.attempts = valueDes;
          break;
        case r'next_attempt_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.nextAttemptAt = valueDes;
          break;
        case r'last_error':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lastError = valueDes;
          break;
        case r'buyer_link_open':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.buyerLinkOpen = valueDes;
          break;
        case r'buyer_token_expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.buyerTokenExpiresAt = valueDes;
          break;
        case r'buyer_submitted_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.buyerSubmittedAt = valueDes;
          break;
        case r'canceled_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.canceledAt = valueDes;
          break;
        case r'cancel_reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.cancelReason = valueDes;
          break;
        case r'completed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.completedAt = valueDes;
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.total = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Einvoice deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EinvoiceBuilder();
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

class EinvoiceRelationEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'original')
  static const EinvoiceRelationEnum original = _$einvoiceRelationEnum_original;
  @BuiltValueEnumConst(wireName: r'replacement')
  static const EinvoiceRelationEnum replacement =
      _$einvoiceRelationEnum_replacement;

  static Serializer<EinvoiceRelationEnum> get serializer =>
      _$einvoiceRelationEnumSerializer;

  const EinvoiceRelationEnum._(String name) : super(name);

  static BuiltSet<EinvoiceRelationEnum> get values =>
      _$einvoiceRelationEnumValues;
  static EinvoiceRelationEnum valueOf(String name) =>
      _$einvoiceRelationEnumValueOf(name);
}

class EinvoiceInvoiceTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'cash_register')
  static const EinvoiceInvoiceTypeEnum cashRegister =
      _$einvoiceInvoiceTypeEnum_cashRegister;
  @BuiltValueEnumConst(wireName: r'coded')
  static const EinvoiceInvoiceTypeEnum coded = _$einvoiceInvoiceTypeEnum_coded;

  static Serializer<EinvoiceInvoiceTypeEnum> get serializer =>
      _$einvoiceInvoiceTypeEnumSerializer;

  const EinvoiceInvoiceTypeEnum._(String name) : super(name);

  static BuiltSet<EinvoiceInvoiceTypeEnum> get values =>
      _$einvoiceInvoiceTypeEnumValues;
  static EinvoiceInvoiceTypeEnum valueOf(String name) =>
      _$einvoiceInvoiceTypeEnumValueOf(name);
}

class EinvoiceStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'pending')
  static const EinvoiceStatusEnum pending = _$einvoiceStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'issuing')
  static const EinvoiceStatusEnum issuing = _$einvoiceStatusEnum_issuing;
  @BuiltValueEnumConst(wireName: r'issued')
  static const EinvoiceStatusEnum issued = _$einvoiceStatusEnum_issued;
  @BuiltValueEnumConst(wireName: r'failed')
  static const EinvoiceStatusEnum failed = _$einvoiceStatusEnum_failed;
  @BuiltValueEnumConst(wireName: r'canceled')
  static const EinvoiceStatusEnum canceled = _$einvoiceStatusEnum_canceled;
  @BuiltValueEnumConst(wireName: r'replaced')
  static const EinvoiceStatusEnum replaced = _$einvoiceStatusEnum_replaced;
  @BuiltValueEnumConst(wireName: r'adjusted')
  static const EinvoiceStatusEnum adjusted = _$einvoiceStatusEnum_adjusted;

  static Serializer<EinvoiceStatusEnum> get serializer =>
      _$einvoiceStatusEnumSerializer;

  const EinvoiceStatusEnum._(String name) : super(name);

  static BuiltSet<EinvoiceStatusEnum> get values => _$einvoiceStatusEnumValues;
  static EinvoiceStatusEnum valueOf(String name) =>
      _$einvoiceStatusEnumValueOf(name);
}

class EinvoicePaymentMethodEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'TM')
  static const EinvoicePaymentMethodEnum TM = _$einvoicePaymentMethodEnum_TM;
  @BuiltValueEnumConst(wireName: r'CK')
  static const EinvoicePaymentMethodEnum CK = _$einvoicePaymentMethodEnum_CK;
  @BuiltValueEnumConst(wireName: r'TM/CK')
  static const EinvoicePaymentMethodEnum tMSlashCK =
      _$einvoicePaymentMethodEnum_tMSlashCK;

  static Serializer<EinvoicePaymentMethodEnum> get serializer =>
      _$einvoicePaymentMethodEnumSerializer;

  const EinvoicePaymentMethodEnum._(String name) : super(name);

  static BuiltSet<EinvoicePaymentMethodEnum> get values =>
      _$einvoicePaymentMethodEnumValues;
  static EinvoicePaymentMethodEnum valueOf(String name) =>
      _$einvoicePaymentMethodEnumValueOf(name);
}
