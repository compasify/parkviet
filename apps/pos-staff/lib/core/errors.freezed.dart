// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'errors.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppFailure()';
}


}

/// @nodoc
class $AppFailureCopyWith<$Res>  {
$AppFailureCopyWith(AppFailure _, $Res Function(AppFailure) __);
}


/// Adds pattern-matching-related methods to [AppFailure].
extension AppFailurePatterns on AppFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TimeoutFailure value)?  timeout,TResult Function( TlsFailure value)?  tls,TResult Function( CleartextFailure value)?  cleartext,TResult Function( UnreachableFailure value)?  unreachable,TResult Function( UnauthorizedFailure value)?  unauthorized,TResult Function( ForbiddenFailure value)?  forbidden,TResult Function( NotFoundFailure value)?  notFound,TResult Function( RateLimitedFailure value)?  rateLimited,TResult Function( ConflictFailure value)?  conflict,TResult Function( ServerFailure value)?  server,TResult Function( UnexpectedFailure value)?  unexpected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TimeoutFailure() when timeout != null:
return timeout(_that);case TlsFailure() when tls != null:
return tls(_that);case CleartextFailure() when cleartext != null:
return cleartext(_that);case UnreachableFailure() when unreachable != null:
return unreachable(_that);case UnauthorizedFailure() when unauthorized != null:
return unauthorized(_that);case ForbiddenFailure() when forbidden != null:
return forbidden(_that);case NotFoundFailure() when notFound != null:
return notFound(_that);case RateLimitedFailure() when rateLimited != null:
return rateLimited(_that);case ConflictFailure() when conflict != null:
return conflict(_that);case ServerFailure() when server != null:
return server(_that);case UnexpectedFailure() when unexpected != null:
return unexpected(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TimeoutFailure value)  timeout,required TResult Function( TlsFailure value)  tls,required TResult Function( CleartextFailure value)  cleartext,required TResult Function( UnreachableFailure value)  unreachable,required TResult Function( UnauthorizedFailure value)  unauthorized,required TResult Function( ForbiddenFailure value)  forbidden,required TResult Function( NotFoundFailure value)  notFound,required TResult Function( RateLimitedFailure value)  rateLimited,required TResult Function( ConflictFailure value)  conflict,required TResult Function( ServerFailure value)  server,required TResult Function( UnexpectedFailure value)  unexpected,}){
final _that = this;
switch (_that) {
case TimeoutFailure():
return timeout(_that);case TlsFailure():
return tls(_that);case CleartextFailure():
return cleartext(_that);case UnreachableFailure():
return unreachable(_that);case UnauthorizedFailure():
return unauthorized(_that);case ForbiddenFailure():
return forbidden(_that);case NotFoundFailure():
return notFound(_that);case RateLimitedFailure():
return rateLimited(_that);case ConflictFailure():
return conflict(_that);case ServerFailure():
return server(_that);case UnexpectedFailure():
return unexpected(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TimeoutFailure value)?  timeout,TResult? Function( TlsFailure value)?  tls,TResult? Function( CleartextFailure value)?  cleartext,TResult? Function( UnreachableFailure value)?  unreachable,TResult? Function( UnauthorizedFailure value)?  unauthorized,TResult? Function( ForbiddenFailure value)?  forbidden,TResult? Function( NotFoundFailure value)?  notFound,TResult? Function( RateLimitedFailure value)?  rateLimited,TResult? Function( ConflictFailure value)?  conflict,TResult? Function( ServerFailure value)?  server,TResult? Function( UnexpectedFailure value)?  unexpected,}){
final _that = this;
switch (_that) {
case TimeoutFailure() when timeout != null:
return timeout(_that);case TlsFailure() when tls != null:
return tls(_that);case CleartextFailure() when cleartext != null:
return cleartext(_that);case UnreachableFailure() when unreachable != null:
return unreachable(_that);case UnauthorizedFailure() when unauthorized != null:
return unauthorized(_that);case ForbiddenFailure() when forbidden != null:
return forbidden(_that);case NotFoundFailure() when notFound != null:
return notFound(_that);case RateLimitedFailure() when rateLimited != null:
return rateLimited(_that);case ConflictFailure() when conflict != null:
return conflict(_that);case ServerFailure() when server != null:
return server(_that);case UnexpectedFailure() when unexpected != null:
return unexpected(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  timeout,TResult Function()?  tls,TResult Function()?  cleartext,TResult Function()?  unreachable,TResult Function( String code)?  unauthorized,TResult Function( String code)?  forbidden,TResult Function( String code)?  notFound,TResult Function( String code)?  rateLimited,TResult Function( String reason,  int? currentRevision,  String? message)?  conflict,TResult Function( int status,  String? code,  String? message)?  server,TResult Function( String detail)?  unexpected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TimeoutFailure() when timeout != null:
return timeout();case TlsFailure() when tls != null:
return tls();case CleartextFailure() when cleartext != null:
return cleartext();case UnreachableFailure() when unreachable != null:
return unreachable();case UnauthorizedFailure() when unauthorized != null:
return unauthorized(_that.code);case ForbiddenFailure() when forbidden != null:
return forbidden(_that.code);case NotFoundFailure() when notFound != null:
return notFound(_that.code);case RateLimitedFailure() when rateLimited != null:
return rateLimited(_that.code);case ConflictFailure() when conflict != null:
return conflict(_that.reason,_that.currentRevision,_that.message);case ServerFailure() when server != null:
return server(_that.status,_that.code,_that.message);case UnexpectedFailure() when unexpected != null:
return unexpected(_that.detail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  timeout,required TResult Function()  tls,required TResult Function()  cleartext,required TResult Function()  unreachable,required TResult Function( String code)  unauthorized,required TResult Function( String code)  forbidden,required TResult Function( String code)  notFound,required TResult Function( String code)  rateLimited,required TResult Function( String reason,  int? currentRevision,  String? message)  conflict,required TResult Function( int status,  String? code,  String? message)  server,required TResult Function( String detail)  unexpected,}) {final _that = this;
switch (_that) {
case TimeoutFailure():
return timeout();case TlsFailure():
return tls();case CleartextFailure():
return cleartext();case UnreachableFailure():
return unreachable();case UnauthorizedFailure():
return unauthorized(_that.code);case ForbiddenFailure():
return forbidden(_that.code);case NotFoundFailure():
return notFound(_that.code);case RateLimitedFailure():
return rateLimited(_that.code);case ConflictFailure():
return conflict(_that.reason,_that.currentRevision,_that.message);case ServerFailure():
return server(_that.status,_that.code,_that.message);case UnexpectedFailure():
return unexpected(_that.detail);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  timeout,TResult? Function()?  tls,TResult? Function()?  cleartext,TResult? Function()?  unreachable,TResult? Function( String code)?  unauthorized,TResult? Function( String code)?  forbidden,TResult? Function( String code)?  notFound,TResult? Function( String code)?  rateLimited,TResult? Function( String reason,  int? currentRevision,  String? message)?  conflict,TResult? Function( int status,  String? code,  String? message)?  server,TResult? Function( String detail)?  unexpected,}) {final _that = this;
switch (_that) {
case TimeoutFailure() when timeout != null:
return timeout();case TlsFailure() when tls != null:
return tls();case CleartextFailure() when cleartext != null:
return cleartext();case UnreachableFailure() when unreachable != null:
return unreachable();case UnauthorizedFailure() when unauthorized != null:
return unauthorized(_that.code);case ForbiddenFailure() when forbidden != null:
return forbidden(_that.code);case NotFoundFailure() when notFound != null:
return notFound(_that.code);case RateLimitedFailure() when rateLimited != null:
return rateLimited(_that.code);case ConflictFailure() when conflict != null:
return conflict(_that.reason,_that.currentRevision,_that.message);case ServerFailure() when server != null:
return server(_that.status,_that.code,_that.message);case UnexpectedFailure() when unexpected != null:
return unexpected(_that.detail);case _:
  return null;

}
}

}

/// @nodoc


class TimeoutFailure implements AppFailure {
  const TimeoutFailure();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeoutFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppFailure.timeout()';
}


}




/// @nodoc


class TlsFailure implements AppFailure {
  const TlsFailure();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TlsFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppFailure.tls()';
}


}




/// @nodoc


class CleartextFailure implements AppFailure {
  const CleartextFailure();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CleartextFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppFailure.cleartext()';
}


}




/// @nodoc


class UnreachableFailure implements AppFailure {
  const UnreachableFailure();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnreachableFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppFailure.unreachable()';
}


}




/// @nodoc


class UnauthorizedFailure implements AppFailure {
  const UnauthorizedFailure(this.code);
  

 final  String code;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnauthorizedFailureCopyWith<UnauthorizedFailure> get copyWith => _$UnauthorizedFailureCopyWithImpl<UnauthorizedFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnauthorizedFailure&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,code);

@override
String toString() {
  return 'AppFailure.unauthorized(code: $code)';
}


}

/// @nodoc
abstract mixin class $UnauthorizedFailureCopyWith<$Res> implements $AppFailureCopyWith<$Res> {
  factory $UnauthorizedFailureCopyWith(UnauthorizedFailure value, $Res Function(UnauthorizedFailure) _then) = _$UnauthorizedFailureCopyWithImpl;
@useResult
$Res call({
 String code
});




}
/// @nodoc
class _$UnauthorizedFailureCopyWithImpl<$Res>
    implements $UnauthorizedFailureCopyWith<$Res> {
  _$UnauthorizedFailureCopyWithImpl(this._self, this._then);

  final UnauthorizedFailure _self;
  final $Res Function(UnauthorizedFailure) _then;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,}) {
  return _then(UnauthorizedFailure(
null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ForbiddenFailure implements AppFailure {
  const ForbiddenFailure(this.code);
  

 final  String code;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForbiddenFailureCopyWith<ForbiddenFailure> get copyWith => _$ForbiddenFailureCopyWithImpl<ForbiddenFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForbiddenFailure&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,code);

@override
String toString() {
  return 'AppFailure.forbidden(code: $code)';
}


}

/// @nodoc
abstract mixin class $ForbiddenFailureCopyWith<$Res> implements $AppFailureCopyWith<$Res> {
  factory $ForbiddenFailureCopyWith(ForbiddenFailure value, $Res Function(ForbiddenFailure) _then) = _$ForbiddenFailureCopyWithImpl;
@useResult
$Res call({
 String code
});




}
/// @nodoc
class _$ForbiddenFailureCopyWithImpl<$Res>
    implements $ForbiddenFailureCopyWith<$Res> {
  _$ForbiddenFailureCopyWithImpl(this._self, this._then);

  final ForbiddenFailure _self;
  final $Res Function(ForbiddenFailure) _then;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,}) {
  return _then(ForbiddenFailure(
null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class NotFoundFailure implements AppFailure {
  const NotFoundFailure(this.code);
  

 final  String code;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotFoundFailureCopyWith<NotFoundFailure> get copyWith => _$NotFoundFailureCopyWithImpl<NotFoundFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotFoundFailure&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,code);

@override
String toString() {
  return 'AppFailure.notFound(code: $code)';
}


}

/// @nodoc
abstract mixin class $NotFoundFailureCopyWith<$Res> implements $AppFailureCopyWith<$Res> {
  factory $NotFoundFailureCopyWith(NotFoundFailure value, $Res Function(NotFoundFailure) _then) = _$NotFoundFailureCopyWithImpl;
@useResult
$Res call({
 String code
});




}
/// @nodoc
class _$NotFoundFailureCopyWithImpl<$Res>
    implements $NotFoundFailureCopyWith<$Res> {
  _$NotFoundFailureCopyWithImpl(this._self, this._then);

  final NotFoundFailure _self;
  final $Res Function(NotFoundFailure) _then;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,}) {
  return _then(NotFoundFailure(
null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class RateLimitedFailure implements AppFailure {
  const RateLimitedFailure(this.code);
  

 final  String code;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RateLimitedFailureCopyWith<RateLimitedFailure> get copyWith => _$RateLimitedFailureCopyWithImpl<RateLimitedFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RateLimitedFailure&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,code);

@override
String toString() {
  return 'AppFailure.rateLimited(code: $code)';
}


}

/// @nodoc
abstract mixin class $RateLimitedFailureCopyWith<$Res> implements $AppFailureCopyWith<$Res> {
  factory $RateLimitedFailureCopyWith(RateLimitedFailure value, $Res Function(RateLimitedFailure) _then) = _$RateLimitedFailureCopyWithImpl;
@useResult
$Res call({
 String code
});




}
/// @nodoc
class _$RateLimitedFailureCopyWithImpl<$Res>
    implements $RateLimitedFailureCopyWith<$Res> {
  _$RateLimitedFailureCopyWithImpl(this._self, this._then);

  final RateLimitedFailure _self;
  final $Res Function(RateLimitedFailure) _then;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,}) {
  return _then(RateLimitedFailure(
null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ConflictFailure implements AppFailure {
  const ConflictFailure({required this.reason, this.currentRevision, this.message});
  

 final  String reason;
 final  int? currentRevision;
 final  String? message;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConflictFailureCopyWith<ConflictFailure> get copyWith => _$ConflictFailureCopyWithImpl<ConflictFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConflictFailure&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.currentRevision, currentRevision) || other.currentRevision == currentRevision)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,reason,currentRevision,message);

@override
String toString() {
  return 'AppFailure.conflict(reason: $reason, currentRevision: $currentRevision, message: $message)';
}


}

/// @nodoc
abstract mixin class $ConflictFailureCopyWith<$Res> implements $AppFailureCopyWith<$Res> {
  factory $ConflictFailureCopyWith(ConflictFailure value, $Res Function(ConflictFailure) _then) = _$ConflictFailureCopyWithImpl;
@useResult
$Res call({
 String reason, int? currentRevision, String? message
});




}
/// @nodoc
class _$ConflictFailureCopyWithImpl<$Res>
    implements $ConflictFailureCopyWith<$Res> {
  _$ConflictFailureCopyWithImpl(this._self, this._then);

  final ConflictFailure _self;
  final $Res Function(ConflictFailure) _then;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,Object? currentRevision = freezed,Object? message = freezed,}) {
  return _then(ConflictFailure(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,currentRevision: freezed == currentRevision ? _self.currentRevision : currentRevision // ignore: cast_nullable_to_non_nullable
as int?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class ServerFailure implements AppFailure {
  const ServerFailure({required this.status, this.code, this.message});
  

 final  int status;
 final  String? code;
 final  String? message;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerFailureCopyWith<ServerFailure> get copyWith => _$ServerFailureCopyWithImpl<ServerFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerFailure&&(identical(other.status, status) || other.status == status)&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,status,code,message);

@override
String toString() {
  return 'AppFailure.server(status: $status, code: $code, message: $message)';
}


}

/// @nodoc
abstract mixin class $ServerFailureCopyWith<$Res> implements $AppFailureCopyWith<$Res> {
  factory $ServerFailureCopyWith(ServerFailure value, $Res Function(ServerFailure) _then) = _$ServerFailureCopyWithImpl;
@useResult
$Res call({
 int status, String? code, String? message
});




}
/// @nodoc
class _$ServerFailureCopyWithImpl<$Res>
    implements $ServerFailureCopyWith<$Res> {
  _$ServerFailureCopyWithImpl(this._self, this._then);

  final ServerFailure _self;
  final $Res Function(ServerFailure) _then;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? status = null,Object? code = freezed,Object? message = freezed,}) {
  return _then(ServerFailure(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class UnexpectedFailure implements AppFailure {
  const UnexpectedFailure(this.detail);
  

 final  String detail;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnexpectedFailureCopyWith<UnexpectedFailure> get copyWith => _$UnexpectedFailureCopyWithImpl<UnexpectedFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnexpectedFailure&&(identical(other.detail, detail) || other.detail == detail));
}


@override
int get hashCode => Object.hash(runtimeType,detail);

@override
String toString() {
  return 'AppFailure.unexpected(detail: $detail)';
}


}

/// @nodoc
abstract mixin class $UnexpectedFailureCopyWith<$Res> implements $AppFailureCopyWith<$Res> {
  factory $UnexpectedFailureCopyWith(UnexpectedFailure value, $Res Function(UnexpectedFailure) _then) = _$UnexpectedFailureCopyWithImpl;
@useResult
$Res call({
 String detail
});




}
/// @nodoc
class _$UnexpectedFailureCopyWithImpl<$Res>
    implements $UnexpectedFailureCopyWith<$Res> {
  _$UnexpectedFailureCopyWithImpl(this._self, this._then);

  final UnexpectedFailure _self;
  final $Res Function(UnexpectedFailure) _then;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? detail = null,}) {
  return _then(UnexpectedFailure(
null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
