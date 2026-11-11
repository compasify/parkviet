// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppSession {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSession);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppSession()';
}


}

/// @nodoc
class $AppSessionCopyWith<$Res>  {
$AppSessionCopyWith(AppSession _, $Res Function(AppSession) __);
}


/// Adds pattern-matching-related methods to [AppSession].
extension AppSessionPatterns on AppSession {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Unpaired value)?  unpaired,TResult Function( Offline value)?  offline,TResult Function( Paired value)?  paired,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Unpaired() when unpaired != null:
return unpaired(_that);case Offline() when offline != null:
return offline(_that);case Paired() when paired != null:
return paired(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Unpaired value)  unpaired,required TResult Function( Offline value)  offline,required TResult Function( Paired value)  paired,}){
final _that = this;
switch (_that) {
case Unpaired():
return unpaired(_that);case Offline():
return offline(_that);case Paired():
return paired(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Unpaired value)?  unpaired,TResult? Function( Offline value)?  offline,TResult? Function( Paired value)?  paired,}){
final _that = this;
switch (_that) {
case Unpaired() when unpaired != null:
return unpaired(_that);case Offline() when offline != null:
return offline(_that);case Paired() when paired != null:
return paired(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( bool revoked)?  unpaired,TResult Function( String serverUrl,  AppFailure failure)?  offline,TResult Function( String serverUrl,  DeviceSession me,  ServerClock clock)?  paired,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Unpaired() when unpaired != null:
return unpaired(_that.revoked);case Offline() when offline != null:
return offline(_that.serverUrl,_that.failure);case Paired() when paired != null:
return paired(_that.serverUrl,_that.me,_that.clock);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( bool revoked)  unpaired,required TResult Function( String serverUrl,  AppFailure failure)  offline,required TResult Function( String serverUrl,  DeviceSession me,  ServerClock clock)  paired,}) {final _that = this;
switch (_that) {
case Unpaired():
return unpaired(_that.revoked);case Offline():
return offline(_that.serverUrl,_that.failure);case Paired():
return paired(_that.serverUrl,_that.me,_that.clock);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( bool revoked)?  unpaired,TResult? Function( String serverUrl,  AppFailure failure)?  offline,TResult? Function( String serverUrl,  DeviceSession me,  ServerClock clock)?  paired,}) {final _that = this;
switch (_that) {
case Unpaired() when unpaired != null:
return unpaired(_that.revoked);case Offline() when offline != null:
return offline(_that.serverUrl,_that.failure);case Paired() when paired != null:
return paired(_that.serverUrl,_that.me,_that.clock);case _:
  return null;

}
}

}

/// @nodoc


class Unpaired implements AppSession {
  const Unpaired({this.revoked = false});
  

@JsonKey() final  bool revoked;

/// Create a copy of AppSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnpairedCopyWith<Unpaired> get copyWith => _$UnpairedCopyWithImpl<Unpaired>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Unpaired&&(identical(other.revoked, revoked) || other.revoked == revoked));
}


@override
int get hashCode => Object.hash(runtimeType,revoked);

@override
String toString() {
  return 'AppSession.unpaired(revoked: $revoked)';
}


}

/// @nodoc
abstract mixin class $UnpairedCopyWith<$Res> implements $AppSessionCopyWith<$Res> {
  factory $UnpairedCopyWith(Unpaired value, $Res Function(Unpaired) _then) = _$UnpairedCopyWithImpl;
@useResult
$Res call({
 bool revoked
});




}
/// @nodoc
class _$UnpairedCopyWithImpl<$Res>
    implements $UnpairedCopyWith<$Res> {
  _$UnpairedCopyWithImpl(this._self, this._then);

  final Unpaired _self;
  final $Res Function(Unpaired) _then;

/// Create a copy of AppSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? revoked = null,}) {
  return _then(Unpaired(
revoked: null == revoked ? _self.revoked : revoked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class Offline implements AppSession {
  const Offline({required this.serverUrl, required this.failure});
  

 final  String serverUrl;
 final  AppFailure failure;

/// Create a copy of AppSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfflineCopyWith<Offline> get copyWith => _$OfflineCopyWithImpl<Offline>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Offline&&(identical(other.serverUrl, serverUrl) || other.serverUrl == serverUrl)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,serverUrl,failure);

@override
String toString() {
  return 'AppSession.offline(serverUrl: $serverUrl, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $OfflineCopyWith<$Res> implements $AppSessionCopyWith<$Res> {
  factory $OfflineCopyWith(Offline value, $Res Function(Offline) _then) = _$OfflineCopyWithImpl;
@useResult
$Res call({
 String serverUrl, AppFailure failure
});


$AppFailureCopyWith<$Res> get failure;

}
/// @nodoc
class _$OfflineCopyWithImpl<$Res>
    implements $OfflineCopyWith<$Res> {
  _$OfflineCopyWithImpl(this._self, this._then);

  final Offline _self;
  final $Res Function(Offline) _then;

/// Create a copy of AppSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? serverUrl = null,Object? failure = null,}) {
  return _then(Offline(
serverUrl: null == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure,
  ));
}

/// Create a copy of AppSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppFailureCopyWith<$Res> get failure {
  
  return $AppFailureCopyWith<$Res>(_self.failure, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}

/// @nodoc


class Paired implements AppSession {
  const Paired({required this.serverUrl, required this.me, required this.clock});
  

 final  String serverUrl;
 final  DeviceSession me;
 final  ServerClock clock;

/// Create a copy of AppSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PairedCopyWith<Paired> get copyWith => _$PairedCopyWithImpl<Paired>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Paired&&(identical(other.serverUrl, serverUrl) || other.serverUrl == serverUrl)&&(identical(other.me, me) || other.me == me)&&(identical(other.clock, clock) || other.clock == clock));
}


@override
int get hashCode => Object.hash(runtimeType,serverUrl,me,clock);

@override
String toString() {
  return 'AppSession.paired(serverUrl: $serverUrl, me: $me, clock: $clock)';
}


}

/// @nodoc
abstract mixin class $PairedCopyWith<$Res> implements $AppSessionCopyWith<$Res> {
  factory $PairedCopyWith(Paired value, $Res Function(Paired) _then) = _$PairedCopyWithImpl;
@useResult
$Res call({
 String serverUrl, DeviceSession me, ServerClock clock
});




}
/// @nodoc
class _$PairedCopyWithImpl<$Res>
    implements $PairedCopyWith<$Res> {
  _$PairedCopyWithImpl(this._self, this._then);

  final Paired _self;
  final $Res Function(Paired) _then;

/// Create a copy of AppSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? serverUrl = null,Object? me = null,Object? clock = null,}) {
  return _then(Paired(
serverUrl: null == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String,me: null == me ? _self.me : me // ignore: cast_nullable_to_non_nullable
as DeviceSession,clock: null == clock ? _self.clock : clock // ignore: cast_nullable_to_non_nullable
as ServerClock,
  ));
}


}

// dart format on
