// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_account.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MealAccountPayModeEnum _$mealAccountPayModeEnum_wallet =
    const MealAccountPayModeEnum._('wallet');
const MealAccountPayModeEnum _$mealAccountPayModeEnum_sponsor =
    const MealAccountPayModeEnum._('sponsor');
const MealAccountPayModeEnum _$mealAccountPayModeEnum_sponsorSubsidy =
    const MealAccountPayModeEnum._('sponsorSubsidy');

MealAccountPayModeEnum _$mealAccountPayModeEnumValueOf(String name) {
  switch (name) {
    case 'wallet':
      return _$mealAccountPayModeEnum_wallet;
    case 'sponsor':
      return _$mealAccountPayModeEnum_sponsor;
    case 'sponsorSubsidy':
      return _$mealAccountPayModeEnum_sponsorSubsidy;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MealAccountPayModeEnum> _$mealAccountPayModeEnumValues =
    BuiltSet<MealAccountPayModeEnum>(const <MealAccountPayModeEnum>[
  _$mealAccountPayModeEnum_wallet,
  _$mealAccountPayModeEnum_sponsor,
  _$mealAccountPayModeEnum_sponsorSubsidy,
]);

const MealAccountStatusEnum _$mealAccountStatusEnum_active =
    const MealAccountStatusEnum._('active');
const MealAccountStatusEnum _$mealAccountStatusEnum_locked =
    const MealAccountStatusEnum._('locked');

MealAccountStatusEnum _$mealAccountStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$mealAccountStatusEnum_active;
    case 'locked':
      return _$mealAccountStatusEnum_locked;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MealAccountStatusEnum> _$mealAccountStatusEnumValues =
    BuiltSet<MealAccountStatusEnum>(const <MealAccountStatusEnum>[
  _$mealAccountStatusEnum_active,
  _$mealAccountStatusEnum_locked,
]);

Serializer<MealAccountPayModeEnum> _$mealAccountPayModeEnumSerializer =
    _$MealAccountPayModeEnumSerializer();
Serializer<MealAccountStatusEnum> _$mealAccountStatusEnumSerializer =
    _$MealAccountStatusEnumSerializer();

class _$MealAccountPayModeEnumSerializer
    implements PrimitiveSerializer<MealAccountPayModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'wallet': 'wallet',
    'sponsor': 'sponsor',
    'sponsorSubsidy': 'sponsor_subsidy',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'wallet': 'wallet',
    'sponsor': 'sponsor',
    'sponsor_subsidy': 'sponsorSubsidy',
  };

  @override
  final Iterable<Type> types = const <Type>[MealAccountPayModeEnum];
  @override
  final String wireName = 'MealAccountPayModeEnum';

  @override
  Object serialize(Serializers serializers, MealAccountPayModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MealAccountPayModeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MealAccountPayModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MealAccountStatusEnumSerializer
    implements PrimitiveSerializer<MealAccountStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'locked': 'locked',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'locked': 'locked',
  };

  @override
  final Iterable<Type> types = const <Type>[MealAccountStatusEnum];
  @override
  final String wireName = 'MealAccountStatusEnum';

  @override
  Object serialize(Serializers serializers, MealAccountStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MealAccountStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MealAccountStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

abstract class MealAccountBuilder {
  void replace(MealAccount other);
  void update(void Function(MealAccountBuilder) updates);
  String? get id;
  set id(String? id);

  String? get employeeCode;
  set employeeCode(String? employeeCode);

  String? get name;
  set name(String? name);

  String? get phone;
  set phone(String? phone);

  String? get customerId;
  set customerId(String? customerId);

  String? get groupLabel;
  set groupLabel(String? groupLabel);

  MealSponsorRefBuilder get sponsor;
  set sponsor(MealSponsorRefBuilder? sponsor);

  MealAccountPayModeEnum? get payMode;
  set payMode(MealAccountPayModeEnum? payMode);

  int? get dailyMealLimit;
  set dailyMealLimit(int? dailyMealLimit);

  ListBuilder<MealWindow> get mealWindows;
  set mealWindows(ListBuilder<MealWindow>? mealWindows);

  String? get lowBalanceThreshold;
  set lowBalanceThreshold(String? lowBalanceThreshold);

  String? get balance;
  set balance(String? balance);

  String? get currency;
  set currency(String? currency);

  MealAccountStatusEnum? get status;
  set status(MealAccountStatusEnum? status);

  int? get revision;
  set revision(int? revision);

  DateTime? get updatedAt;
  set updatedAt(DateTime? updatedAt);
}

class _$$MealAccount extends $MealAccount {
  @override
  final String id;
  @override
  final String employeeCode;
  @override
  final String? name;
  @override
  final String? phone;
  @override
  final String? customerId;
  @override
  final String? groupLabel;
  @override
  final MealSponsorRef? sponsor;
  @override
  final MealAccountPayModeEnum payMode;
  @override
  final int? dailyMealLimit;
  @override
  final BuiltList<MealWindow>? mealWindows;
  @override
  final String? lowBalanceThreshold;
  @override
  final String balance;
  @override
  final String currency;
  @override
  final MealAccountStatusEnum status;
  @override
  final int revision;
  @override
  final DateTime? updatedAt;

  factory _$$MealAccount([void Function($MealAccountBuilder)? updates]) =>
      ($MealAccountBuilder()..update(updates))._build();

  _$$MealAccount._(
      {required this.id,
      required this.employeeCode,
      this.name,
      this.phone,
      this.customerId,
      this.groupLabel,
      this.sponsor,
      required this.payMode,
      this.dailyMealLimit,
      this.mealWindows,
      this.lowBalanceThreshold,
      required this.balance,
      required this.currency,
      required this.status,
      required this.revision,
      this.updatedAt})
      : super._();
  @override
  $MealAccount rebuild(void Function($MealAccountBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  $MealAccountBuilder toBuilder() => $MealAccountBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is $MealAccount &&
        id == other.id &&
        employeeCode == other.employeeCode &&
        name == other.name &&
        phone == other.phone &&
        customerId == other.customerId &&
        groupLabel == other.groupLabel &&
        sponsor == other.sponsor &&
        payMode == other.payMode &&
        dailyMealLimit == other.dailyMealLimit &&
        mealWindows == other.mealWindows &&
        lowBalanceThreshold == other.lowBalanceThreshold &&
        balance == other.balance &&
        currency == other.currency &&
        status == other.status &&
        revision == other.revision &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, employeeCode.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, customerId.hashCode);
    _$hash = $jc(_$hash, groupLabel.hashCode);
    _$hash = $jc(_$hash, sponsor.hashCode);
    _$hash = $jc(_$hash, payMode.hashCode);
    _$hash = $jc(_$hash, dailyMealLimit.hashCode);
    _$hash = $jc(_$hash, mealWindows.hashCode);
    _$hash = $jc(_$hash, lowBalanceThreshold.hashCode);
    _$hash = $jc(_$hash, balance.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'$MealAccount')
          ..add('id', id)
          ..add('employeeCode', employeeCode)
          ..add('name', name)
          ..add('phone', phone)
          ..add('customerId', customerId)
          ..add('groupLabel', groupLabel)
          ..add('sponsor', sponsor)
          ..add('payMode', payMode)
          ..add('dailyMealLimit', dailyMealLimit)
          ..add('mealWindows', mealWindows)
          ..add('lowBalanceThreshold', lowBalanceThreshold)
          ..add('balance', balance)
          ..add('currency', currency)
          ..add('status', status)
          ..add('revision', revision)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class $MealAccountBuilder
    implements Builder<$MealAccount, $MealAccountBuilder>, MealAccountBuilder {
  _$$MealAccount? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(covariant String? id) => _$this._id = id;

  String? _employeeCode;
  String? get employeeCode => _$this._employeeCode;
  set employeeCode(covariant String? employeeCode) =>
      _$this._employeeCode = employeeCode;

  String? _name;
  String? get name => _$this._name;
  set name(covariant String? name) => _$this._name = name;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(covariant String? phone) => _$this._phone = phone;

  String? _customerId;
  String? get customerId => _$this._customerId;
  set customerId(covariant String? customerId) =>
      _$this._customerId = customerId;

  String? _groupLabel;
  String? get groupLabel => _$this._groupLabel;
  set groupLabel(covariant String? groupLabel) =>
      _$this._groupLabel = groupLabel;

  MealSponsorRefBuilder? _sponsor;
  MealSponsorRefBuilder get sponsor =>
      _$this._sponsor ??= MealSponsorRefBuilder();
  set sponsor(covariant MealSponsorRefBuilder? sponsor) =>
      _$this._sponsor = sponsor;

  MealAccountPayModeEnum? _payMode;
  MealAccountPayModeEnum? get payMode => _$this._payMode;
  set payMode(covariant MealAccountPayModeEnum? payMode) =>
      _$this._payMode = payMode;

  int? _dailyMealLimit;
  int? get dailyMealLimit => _$this._dailyMealLimit;
  set dailyMealLimit(covariant int? dailyMealLimit) =>
      _$this._dailyMealLimit = dailyMealLimit;

  ListBuilder<MealWindow>? _mealWindows;
  ListBuilder<MealWindow> get mealWindows =>
      _$this._mealWindows ??= ListBuilder<MealWindow>();
  set mealWindows(covariant ListBuilder<MealWindow>? mealWindows) =>
      _$this._mealWindows = mealWindows;

  String? _lowBalanceThreshold;
  String? get lowBalanceThreshold => _$this._lowBalanceThreshold;
  set lowBalanceThreshold(covariant String? lowBalanceThreshold) =>
      _$this._lowBalanceThreshold = lowBalanceThreshold;

  String? _balance;
  String? get balance => _$this._balance;
  set balance(covariant String? balance) => _$this._balance = balance;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(covariant String? currency) => _$this._currency = currency;

  MealAccountStatusEnum? _status;
  MealAccountStatusEnum? get status => _$this._status;
  set status(covariant MealAccountStatusEnum? status) =>
      _$this._status = status;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(covariant int? revision) => _$this._revision = revision;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(covariant DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  $MealAccountBuilder() {
    $MealAccount._defaults(this);
  }

  $MealAccountBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _employeeCode = $v.employeeCode;
      _name = $v.name;
      _phone = $v.phone;
      _customerId = $v.customerId;
      _groupLabel = $v.groupLabel;
      _sponsor = $v.sponsor?.toBuilder();
      _payMode = $v.payMode;
      _dailyMealLimit = $v.dailyMealLimit;
      _mealWindows = $v.mealWindows?.toBuilder();
      _lowBalanceThreshold = $v.lowBalanceThreshold;
      _balance = $v.balance;
      _currency = $v.currency;
      _status = $v.status;
      _revision = $v.revision;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant $MealAccount other) {
    _$v = other as _$$MealAccount;
  }

  @override
  void update(void Function($MealAccountBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  $MealAccount build() => _build();

  _$$MealAccount _build() {
    _$$MealAccount _$result;
    try {
      _$result = _$v ??
          _$$MealAccount._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'$MealAccount', 'id'),
            employeeCode: BuiltValueNullFieldError.checkNotNull(
                employeeCode, r'$MealAccount', 'employeeCode'),
            name: name,
            phone: phone,
            customerId: customerId,
            groupLabel: groupLabel,
            sponsor: _sponsor?.build(),
            payMode: BuiltValueNullFieldError.checkNotNull(
                payMode, r'$MealAccount', 'payMode'),
            dailyMealLimit: dailyMealLimit,
            mealWindows: _mealWindows?.build(),
            lowBalanceThreshold: lowBalanceThreshold,
            balance: BuiltValueNullFieldError.checkNotNull(
                balance, r'$MealAccount', 'balance'),
            currency: BuiltValueNullFieldError.checkNotNull(
                currency, r'$MealAccount', 'currency'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'$MealAccount', 'status'),
            revision: BuiltValueNullFieldError.checkNotNull(
                revision, r'$MealAccount', 'revision'),
            updatedAt: updatedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'sponsor';
        _sponsor?.build();

        _$failedField = 'mealWindows';
        _mealWindows?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'$MealAccount', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
