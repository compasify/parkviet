// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MealStatusPayModeEnum _$mealStatusPayModeEnum_wallet =
    const MealStatusPayModeEnum._('wallet');
const MealStatusPayModeEnum _$mealStatusPayModeEnum_sponsor =
    const MealStatusPayModeEnum._('sponsor');
const MealStatusPayModeEnum _$mealStatusPayModeEnum_sponsorSubsidy =
    const MealStatusPayModeEnum._('sponsorSubsidy');

MealStatusPayModeEnum _$mealStatusPayModeEnumValueOf(String name) {
  switch (name) {
    case 'wallet':
      return _$mealStatusPayModeEnum_wallet;
    case 'sponsor':
      return _$mealStatusPayModeEnum_sponsor;
    case 'sponsorSubsidy':
      return _$mealStatusPayModeEnum_sponsorSubsidy;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MealStatusPayModeEnum> _$mealStatusPayModeEnumValues =
    BuiltSet<MealStatusPayModeEnum>(const <MealStatusPayModeEnum>[
  _$mealStatusPayModeEnum_wallet,
  _$mealStatusPayModeEnum_sponsor,
  _$mealStatusPayModeEnum_sponsorSubsidy,
]);

const MealStatusStatusEnum _$mealStatusStatusEnum_active =
    const MealStatusStatusEnum._('active');
const MealStatusStatusEnum _$mealStatusStatusEnum_locked =
    const MealStatusStatusEnum._('locked');

MealStatusStatusEnum _$mealStatusStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$mealStatusStatusEnum_active;
    case 'locked':
      return _$mealStatusStatusEnum_locked;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MealStatusStatusEnum> _$mealStatusStatusEnumValues =
    BuiltSet<MealStatusStatusEnum>(const <MealStatusStatusEnum>[
  _$mealStatusStatusEnum_active,
  _$mealStatusStatusEnum_locked,
]);

Serializer<MealStatusPayModeEnum> _$mealStatusPayModeEnumSerializer =
    _$MealStatusPayModeEnumSerializer();
Serializer<MealStatusStatusEnum> _$mealStatusStatusEnumSerializer =
    _$MealStatusStatusEnumSerializer();

class _$MealStatusPayModeEnumSerializer
    implements PrimitiveSerializer<MealStatusPayModeEnum> {
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
  final Iterable<Type> types = const <Type>[MealStatusPayModeEnum];
  @override
  final String wireName = 'MealStatusPayModeEnum';

  @override
  Object serialize(Serializers serializers, MealStatusPayModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MealStatusPayModeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MealStatusPayModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MealStatusStatusEnumSerializer
    implements PrimitiveSerializer<MealStatusStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'locked': 'locked',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'locked': 'locked',
  };

  @override
  final Iterable<Type> types = const <Type>[MealStatusStatusEnum];
  @override
  final String wireName = 'MealStatusStatusEnum';

  @override
  Object serialize(Serializers serializers, MealStatusStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MealStatusStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MealStatusStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MealStatus extends MealStatus {
  @override
  final bool walletCovers;
  @override
  final int mealsToday;
  @override
  final bool lowBalance;
  @override
  final int? mealsLeft;
  @override
  final MealSplitPlan plan;
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

  factory _$MealStatus([void Function(MealStatusBuilder)? updates]) =>
      (MealStatusBuilder()..update(updates))._build();

  _$MealStatus._(
      {required this.walletCovers,
      required this.mealsToday,
      required this.lowBalance,
      this.mealsLeft,
      required this.plan,
      required this.id,
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
  MealStatus rebuild(void Function(MealStatusBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MealStatusBuilder toBuilder() => MealStatusBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MealStatus &&
        walletCovers == other.walletCovers &&
        mealsToday == other.mealsToday &&
        lowBalance == other.lowBalance &&
        mealsLeft == other.mealsLeft &&
        plan == other.plan &&
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
    _$hash = $jc(_$hash, walletCovers.hashCode);
    _$hash = $jc(_$hash, mealsToday.hashCode);
    _$hash = $jc(_$hash, lowBalance.hashCode);
    _$hash = $jc(_$hash, mealsLeft.hashCode);
    _$hash = $jc(_$hash, plan.hashCode);
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
    return (newBuiltValueToStringHelper(r'MealStatus')
          ..add('walletCovers', walletCovers)
          ..add('mealsToday', mealsToday)
          ..add('lowBalance', lowBalance)
          ..add('mealsLeft', mealsLeft)
          ..add('plan', plan)
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

class MealStatusBuilder
    implements Builder<MealStatus, MealStatusBuilder>, MealAccountBuilder {
  _$MealStatus? _$v;

  bool? _walletCovers;
  bool? get walletCovers => _$this._walletCovers;
  set walletCovers(covariant bool? walletCovers) =>
      _$this._walletCovers = walletCovers;

  int? _mealsToday;
  int? get mealsToday => _$this._mealsToday;
  set mealsToday(covariant int? mealsToday) => _$this._mealsToday = mealsToday;

  bool? _lowBalance;
  bool? get lowBalance => _$this._lowBalance;
  set lowBalance(covariant bool? lowBalance) => _$this._lowBalance = lowBalance;

  int? _mealsLeft;
  int? get mealsLeft => _$this._mealsLeft;
  set mealsLeft(covariant int? mealsLeft) => _$this._mealsLeft = mealsLeft;

  MealSplitPlanBuilder? _plan;
  MealSplitPlanBuilder get plan => _$this._plan ??= MealSplitPlanBuilder();
  set plan(covariant MealSplitPlanBuilder? plan) => _$this._plan = plan;

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

  MealStatusBuilder() {
    MealStatus._defaults(this);
  }

  MealStatusBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _walletCovers = $v.walletCovers;
      _mealsToday = $v.mealsToday;
      _lowBalance = $v.lowBalance;
      _mealsLeft = $v.mealsLeft;
      _plan = $v.plan.toBuilder();
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
  void replace(covariant MealStatus other) {
    _$v = other as _$MealStatus;
  }

  @override
  void update(void Function(MealStatusBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MealStatus build() => _build();

  _$MealStatus _build() {
    _$MealStatus _$result;
    try {
      _$result = _$v ??
          _$MealStatus._(
            walletCovers: BuiltValueNullFieldError.checkNotNull(
                walletCovers, r'MealStatus', 'walletCovers'),
            mealsToday: BuiltValueNullFieldError.checkNotNull(
                mealsToday, r'MealStatus', 'mealsToday'),
            lowBalance: BuiltValueNullFieldError.checkNotNull(
                lowBalance, r'MealStatus', 'lowBalance'),
            mealsLeft: mealsLeft,
            plan: plan.build(),
            id: BuiltValueNullFieldError.checkNotNull(id, r'MealStatus', 'id'),
            employeeCode: BuiltValueNullFieldError.checkNotNull(
                employeeCode, r'MealStatus', 'employeeCode'),
            name: name,
            phone: phone,
            customerId: customerId,
            groupLabel: groupLabel,
            sponsor: _sponsor?.build(),
            payMode: BuiltValueNullFieldError.checkNotNull(
                payMode, r'MealStatus', 'payMode'),
            dailyMealLimit: dailyMealLimit,
            mealWindows: _mealWindows?.build(),
            lowBalanceThreshold: lowBalanceThreshold,
            balance: BuiltValueNullFieldError.checkNotNull(
                balance, r'MealStatus', 'balance'),
            currency: BuiltValueNullFieldError.checkNotNull(
                currency, r'MealStatus', 'currency'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'MealStatus', 'status'),
            revision: BuiltValueNullFieldError.checkNotNull(
                revision, r'MealStatus', 'revision'),
            updatedAt: updatedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'plan';
        plan.build();

        _$failedField = 'sponsor';
        _sponsor?.build();

        _$failedField = 'mealWindows';
        _mealWindows?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MealStatus', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
