// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinic.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Clinic {

 String get id; String get ownerId; String get name; String? get address; String? get phone; String? get email;/// Always stored with a scheme, e.g. `https://happypaws.lk`.
 String? get website;/// Free text, e.g. "Mon–Fri 8:00–18:00, Sat 9:00–13:00".
 String? get openingHours; GeoPoint? get location; String? get notes; bool get isFavorite; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Clinic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClinicCopyWith<Clinic> get copyWith => _$ClinicCopyWithImpl<Clinic>(this as Clinic, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Clinic&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.website, website) || other.website == website)&&(identical(other.openingHours, openingHours) || other.openingHours == openingHours)&&(identical(other.location, location) || other.location == location)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,ownerId,name,address,phone,email,website,openingHours,location,notes,isFavorite,createdAt,updatedAt);

@override
String toString() {
  return 'Clinic(id: $id, ownerId: $ownerId, name: $name, address: $address, phone: $phone, email: $email, website: $website, openingHours: $openingHours, location: $location, notes: $notes, isFavorite: $isFavorite, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ClinicCopyWith<$Res>  {
  factory $ClinicCopyWith(Clinic value, $Res Function(Clinic) _then) = _$ClinicCopyWithImpl;
@useResult
$Res call({
 String id, String ownerId, String name, String? address, String? phone, String? email, String? website, String? openingHours, GeoPoint? location, String? notes, bool isFavorite, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$ClinicCopyWithImpl<$Res>
    implements $ClinicCopyWith<$Res> {
  _$ClinicCopyWithImpl(this._self, this._then);

  final Clinic _self;
  final $Res Function(Clinic) _then;

/// Create a copy of Clinic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? name = null,Object? address = freezed,Object? phone = freezed,Object? email = freezed,Object? website = freezed,Object? openingHours = freezed,Object? location = freezed,Object? notes = freezed,Object? isFavorite = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,openingHours: freezed == openingHours ? _self.openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GeoPoint?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Clinic].
extension ClinicPatterns on Clinic {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Clinic value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Clinic() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Clinic value)  $default,){
final _that = this;
switch (_that) {
case _Clinic():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Clinic value)?  $default,){
final _that = this;
switch (_that) {
case _Clinic() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ownerId,  String name,  String? address,  String? phone,  String? email,  String? website,  String? openingHours,  GeoPoint? location,  String? notes,  bool isFavorite,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Clinic() when $default != null:
return $default(_that.id,_that.ownerId,_that.name,_that.address,_that.phone,_that.email,_that.website,_that.openingHours,_that.location,_that.notes,_that.isFavorite,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ownerId,  String name,  String? address,  String? phone,  String? email,  String? website,  String? openingHours,  GeoPoint? location,  String? notes,  bool isFavorite,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Clinic():
return $default(_that.id,_that.ownerId,_that.name,_that.address,_that.phone,_that.email,_that.website,_that.openingHours,_that.location,_that.notes,_that.isFavorite,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ownerId,  String name,  String? address,  String? phone,  String? email,  String? website,  String? openingHours,  GeoPoint? location,  String? notes,  bool isFavorite,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Clinic() when $default != null:
return $default(_that.id,_that.ownerId,_that.name,_that.address,_that.phone,_that.email,_that.website,_that.openingHours,_that.location,_that.notes,_that.isFavorite,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Clinic extends Clinic {
  const _Clinic({this.id = '', required this.ownerId, required this.name, this.address, this.phone, this.email, this.website, this.openingHours, this.location, this.notes, this.isFavorite = false, this.createdAt, this.updatedAt}): super._();
  

@override@JsonKey() final  String id;
@override final  String ownerId;
@override final  String name;
@override final  String? address;
@override final  String? phone;
@override final  String? email;
/// Always stored with a scheme, e.g. `https://happypaws.lk`.
@override final  String? website;
/// Free text, e.g. "Mon–Fri 8:00–18:00, Sat 9:00–13:00".
@override final  String? openingHours;
@override final  GeoPoint? location;
@override final  String? notes;
@override@JsonKey() final  bool isFavorite;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Clinic
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClinicCopyWith<_Clinic> get copyWith => __$ClinicCopyWithImpl<_Clinic>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Clinic&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.website, website) || other.website == website)&&(identical(other.openingHours, openingHours) || other.openingHours == openingHours)&&(identical(other.location, location) || other.location == location)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,ownerId,name,address,phone,email,website,openingHours,location,notes,isFavorite,createdAt,updatedAt);

@override
String toString() {
  return 'Clinic(id: $id, ownerId: $ownerId, name: $name, address: $address, phone: $phone, email: $email, website: $website, openingHours: $openingHours, location: $location, notes: $notes, isFavorite: $isFavorite, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ClinicCopyWith<$Res> implements $ClinicCopyWith<$Res> {
  factory _$ClinicCopyWith(_Clinic value, $Res Function(_Clinic) _then) = __$ClinicCopyWithImpl;
@override @useResult
$Res call({
 String id, String ownerId, String name, String? address, String? phone, String? email, String? website, String? openingHours, GeoPoint? location, String? notes, bool isFavorite, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$ClinicCopyWithImpl<$Res>
    implements _$ClinicCopyWith<$Res> {
  __$ClinicCopyWithImpl(this._self, this._then);

  final _Clinic _self;
  final $Res Function(_Clinic) _then;

/// Create a copy of Clinic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? name = null,Object? address = freezed,Object? phone = freezed,Object? email = freezed,Object? website = freezed,Object? openingHours = freezed,Object? location = freezed,Object? notes = freezed,Object? isFavorite = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Clinic(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,openingHours: freezed == openingHours ? _self.openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GeoPoint?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$Veterinarian {

 String get id; String get ownerId; String get name; String? get clinicId; String? get specialization; String? get phone; String? get email; String? get notes; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Veterinarian
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VeterinarianCopyWith<Veterinarian> get copyWith => _$VeterinarianCopyWithImpl<Veterinarian>(this as Veterinarian, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Veterinarian&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.clinicId, clinicId) || other.clinicId == clinicId)&&(identical(other.specialization, specialization) || other.specialization == specialization)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,ownerId,name,clinicId,specialization,phone,email,notes,createdAt,updatedAt);

@override
String toString() {
  return 'Veterinarian(id: $id, ownerId: $ownerId, name: $name, clinicId: $clinicId, specialization: $specialization, phone: $phone, email: $email, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $VeterinarianCopyWith<$Res>  {
  factory $VeterinarianCopyWith(Veterinarian value, $Res Function(Veterinarian) _then) = _$VeterinarianCopyWithImpl;
@useResult
$Res call({
 String id, String ownerId, String name, String? clinicId, String? specialization, String? phone, String? email, String? notes, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$VeterinarianCopyWithImpl<$Res>
    implements $VeterinarianCopyWith<$Res> {
  _$VeterinarianCopyWithImpl(this._self, this._then);

  final Veterinarian _self;
  final $Res Function(Veterinarian) _then;

/// Create a copy of Veterinarian
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? name = null,Object? clinicId = freezed,Object? specialization = freezed,Object? phone = freezed,Object? email = freezed,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,clinicId: freezed == clinicId ? _self.clinicId : clinicId // ignore: cast_nullable_to_non_nullable
as String?,specialization: freezed == specialization ? _self.specialization : specialization // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Veterinarian].
extension VeterinarianPatterns on Veterinarian {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Veterinarian value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Veterinarian() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Veterinarian value)  $default,){
final _that = this;
switch (_that) {
case _Veterinarian():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Veterinarian value)?  $default,){
final _that = this;
switch (_that) {
case _Veterinarian() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ownerId,  String name,  String? clinicId,  String? specialization,  String? phone,  String? email,  String? notes,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Veterinarian() when $default != null:
return $default(_that.id,_that.ownerId,_that.name,_that.clinicId,_that.specialization,_that.phone,_that.email,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ownerId,  String name,  String? clinicId,  String? specialization,  String? phone,  String? email,  String? notes,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Veterinarian():
return $default(_that.id,_that.ownerId,_that.name,_that.clinicId,_that.specialization,_that.phone,_that.email,_that.notes,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ownerId,  String name,  String? clinicId,  String? specialization,  String? phone,  String? email,  String? notes,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Veterinarian() when $default != null:
return $default(_that.id,_that.ownerId,_that.name,_that.clinicId,_that.specialization,_that.phone,_that.email,_that.notes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Veterinarian extends Veterinarian {
  const _Veterinarian({this.id = '', required this.ownerId, required this.name, this.clinicId, this.specialization, this.phone, this.email, this.notes, this.createdAt, this.updatedAt}): super._();
  

@override@JsonKey() final  String id;
@override final  String ownerId;
@override final  String name;
@override final  String? clinicId;
@override final  String? specialization;
@override final  String? phone;
@override final  String? email;
@override final  String? notes;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Veterinarian
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VeterinarianCopyWith<_Veterinarian> get copyWith => __$VeterinarianCopyWithImpl<_Veterinarian>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Veterinarian&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.clinicId, clinicId) || other.clinicId == clinicId)&&(identical(other.specialization, specialization) || other.specialization == specialization)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,ownerId,name,clinicId,specialization,phone,email,notes,createdAt,updatedAt);

@override
String toString() {
  return 'Veterinarian(id: $id, ownerId: $ownerId, name: $name, clinicId: $clinicId, specialization: $specialization, phone: $phone, email: $email, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$VeterinarianCopyWith<$Res> implements $VeterinarianCopyWith<$Res> {
  factory _$VeterinarianCopyWith(_Veterinarian value, $Res Function(_Veterinarian) _then) = __$VeterinarianCopyWithImpl;
@override @useResult
$Res call({
 String id, String ownerId, String name, String? clinicId, String? specialization, String? phone, String? email, String? notes, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$VeterinarianCopyWithImpl<$Res>
    implements _$VeterinarianCopyWith<$Res> {
  __$VeterinarianCopyWithImpl(this._self, this._then);

  final _Veterinarian _self;
  final $Res Function(_Veterinarian) _then;

/// Create a copy of Veterinarian
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? name = null,Object? clinicId = freezed,Object? specialization = freezed,Object? phone = freezed,Object? email = freezed,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Veterinarian(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,clinicId: freezed == clinicId ? _self.clinicId : clinicId // ignore: cast_nullable_to_non_nullable
as String?,specialization: freezed == specialization ? _self.specialization : specialization // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
