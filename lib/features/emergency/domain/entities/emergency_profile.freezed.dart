// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'emergency_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EmergencyProfile {

 String get petId; String get ownerId;/// Stable public identifier printed in the QR code, e.g. `PC-8A72F9K`.
 String get publicId;/// Whether the public page is currently available.
 bool get enabled; bool get showPhoto; bool get showBreed; bool get showMicrochip; String? get contactName; String? get contactPhone;/// Allergies, conditions, medication a finder or vet must know about.
 String? get medicalWarnings;/// e.g. "Friendly but nervous around bikes. Please call me!"
 String? get message; DateTime? get updatedAt;
/// Create a copy of EmergencyProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmergencyProfileCopyWith<EmergencyProfile> get copyWith => _$EmergencyProfileCopyWithImpl<EmergencyProfile>(this as EmergencyProfile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmergencyProfile&&(identical(other.petId, petId) || other.petId == petId)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.publicId, publicId) || other.publicId == publicId)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.showPhoto, showPhoto) || other.showPhoto == showPhoto)&&(identical(other.showBreed, showBreed) || other.showBreed == showBreed)&&(identical(other.showMicrochip, showMicrochip) || other.showMicrochip == showMicrochip)&&(identical(other.contactName, contactName) || other.contactName == contactName)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&(identical(other.medicalWarnings, medicalWarnings) || other.medicalWarnings == medicalWarnings)&&(identical(other.message, message) || other.message == message)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,petId,ownerId,publicId,enabled,showPhoto,showBreed,showMicrochip,contactName,contactPhone,medicalWarnings,message,updatedAt);

@override
String toString() {
  return 'EmergencyProfile(petId: $petId, ownerId: $ownerId, publicId: $publicId, enabled: $enabled, showPhoto: $showPhoto, showBreed: $showBreed, showMicrochip: $showMicrochip, contactName: $contactName, contactPhone: $contactPhone, medicalWarnings: $medicalWarnings, message: $message, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $EmergencyProfileCopyWith<$Res>  {
  factory $EmergencyProfileCopyWith(EmergencyProfile value, $Res Function(EmergencyProfile) _then) = _$EmergencyProfileCopyWithImpl;
@useResult
$Res call({
 String petId, String ownerId, String publicId, bool enabled, bool showPhoto, bool showBreed, bool showMicrochip, String? contactName, String? contactPhone, String? medicalWarnings, String? message, DateTime? updatedAt
});




}
/// @nodoc
class _$EmergencyProfileCopyWithImpl<$Res>
    implements $EmergencyProfileCopyWith<$Res> {
  _$EmergencyProfileCopyWithImpl(this._self, this._then);

  final EmergencyProfile _self;
  final $Res Function(EmergencyProfile) _then;

/// Create a copy of EmergencyProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? petId = null,Object? ownerId = null,Object? publicId = null,Object? enabled = null,Object? showPhoto = null,Object? showBreed = null,Object? showMicrochip = null,Object? contactName = freezed,Object? contactPhone = freezed,Object? medicalWarnings = freezed,Object? message = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
petId: null == petId ? _self.petId : petId // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,publicId: null == publicId ? _self.publicId : publicId // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,showPhoto: null == showPhoto ? _self.showPhoto : showPhoto // ignore: cast_nullable_to_non_nullable
as bool,showBreed: null == showBreed ? _self.showBreed : showBreed // ignore: cast_nullable_to_non_nullable
as bool,showMicrochip: null == showMicrochip ? _self.showMicrochip : showMicrochip // ignore: cast_nullable_to_non_nullable
as bool,contactName: freezed == contactName ? _self.contactName : contactName // ignore: cast_nullable_to_non_nullable
as String?,contactPhone: freezed == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String?,medicalWarnings: freezed == medicalWarnings ? _self.medicalWarnings : medicalWarnings // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EmergencyProfile].
extension EmergencyProfilePatterns on EmergencyProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmergencyProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmergencyProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmergencyProfile value)  $default,){
final _that = this;
switch (_that) {
case _EmergencyProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmergencyProfile value)?  $default,){
final _that = this;
switch (_that) {
case _EmergencyProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String petId,  String ownerId,  String publicId,  bool enabled,  bool showPhoto,  bool showBreed,  bool showMicrochip,  String? contactName,  String? contactPhone,  String? medicalWarnings,  String? message,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmergencyProfile() when $default != null:
return $default(_that.petId,_that.ownerId,_that.publicId,_that.enabled,_that.showPhoto,_that.showBreed,_that.showMicrochip,_that.contactName,_that.contactPhone,_that.medicalWarnings,_that.message,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String petId,  String ownerId,  String publicId,  bool enabled,  bool showPhoto,  bool showBreed,  bool showMicrochip,  String? contactName,  String? contactPhone,  String? medicalWarnings,  String? message,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _EmergencyProfile():
return $default(_that.petId,_that.ownerId,_that.publicId,_that.enabled,_that.showPhoto,_that.showBreed,_that.showMicrochip,_that.contactName,_that.contactPhone,_that.medicalWarnings,_that.message,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String petId,  String ownerId,  String publicId,  bool enabled,  bool showPhoto,  bool showBreed,  bool showMicrochip,  String? contactName,  String? contactPhone,  String? medicalWarnings,  String? message,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _EmergencyProfile() when $default != null:
return $default(_that.petId,_that.ownerId,_that.publicId,_that.enabled,_that.showPhoto,_that.showBreed,_that.showMicrochip,_that.contactName,_that.contactPhone,_that.medicalWarnings,_that.message,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _EmergencyProfile implements EmergencyProfile {
  const _EmergencyProfile({required this.petId, required this.ownerId, required this.publicId, this.enabled = true, this.showPhoto = true, this.showBreed = true, this.showMicrochip = false, this.contactName, this.contactPhone, this.medicalWarnings, this.message, this.updatedAt});
  

@override final  String petId;
@override final  String ownerId;
/// Stable public identifier printed in the QR code, e.g. `PC-8A72F9K`.
@override final  String publicId;
/// Whether the public page is currently available.
@override@JsonKey() final  bool enabled;
@override@JsonKey() final  bool showPhoto;
@override@JsonKey() final  bool showBreed;
@override@JsonKey() final  bool showMicrochip;
@override final  String? contactName;
@override final  String? contactPhone;
/// Allergies, conditions, medication a finder or vet must know about.
@override final  String? medicalWarnings;
/// e.g. "Friendly but nervous around bikes. Please call me!"
@override final  String? message;
@override final  DateTime? updatedAt;

/// Create a copy of EmergencyProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmergencyProfileCopyWith<_EmergencyProfile> get copyWith => __$EmergencyProfileCopyWithImpl<_EmergencyProfile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmergencyProfile&&(identical(other.petId, petId) || other.petId == petId)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.publicId, publicId) || other.publicId == publicId)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.showPhoto, showPhoto) || other.showPhoto == showPhoto)&&(identical(other.showBreed, showBreed) || other.showBreed == showBreed)&&(identical(other.showMicrochip, showMicrochip) || other.showMicrochip == showMicrochip)&&(identical(other.contactName, contactName) || other.contactName == contactName)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&(identical(other.medicalWarnings, medicalWarnings) || other.medicalWarnings == medicalWarnings)&&(identical(other.message, message) || other.message == message)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,petId,ownerId,publicId,enabled,showPhoto,showBreed,showMicrochip,contactName,contactPhone,medicalWarnings,message,updatedAt);

@override
String toString() {
  return 'EmergencyProfile(petId: $petId, ownerId: $ownerId, publicId: $publicId, enabled: $enabled, showPhoto: $showPhoto, showBreed: $showBreed, showMicrochip: $showMicrochip, contactName: $contactName, contactPhone: $contactPhone, medicalWarnings: $medicalWarnings, message: $message, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$EmergencyProfileCopyWith<$Res> implements $EmergencyProfileCopyWith<$Res> {
  factory _$EmergencyProfileCopyWith(_EmergencyProfile value, $Res Function(_EmergencyProfile) _then) = __$EmergencyProfileCopyWithImpl;
@override @useResult
$Res call({
 String petId, String ownerId, String publicId, bool enabled, bool showPhoto, bool showBreed, bool showMicrochip, String? contactName, String? contactPhone, String? medicalWarnings, String? message, DateTime? updatedAt
});




}
/// @nodoc
class __$EmergencyProfileCopyWithImpl<$Res>
    implements _$EmergencyProfileCopyWith<$Res> {
  __$EmergencyProfileCopyWithImpl(this._self, this._then);

  final _EmergencyProfile _self;
  final $Res Function(_EmergencyProfile) _then;

/// Create a copy of EmergencyProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? petId = null,Object? ownerId = null,Object? publicId = null,Object? enabled = null,Object? showPhoto = null,Object? showBreed = null,Object? showMicrochip = null,Object? contactName = freezed,Object? contactPhone = freezed,Object? medicalWarnings = freezed,Object? message = freezed,Object? updatedAt = freezed,}) {
  return _then(_EmergencyProfile(
petId: null == petId ? _self.petId : petId // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,publicId: null == publicId ? _self.publicId : publicId // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,showPhoto: null == showPhoto ? _self.showPhoto : showPhoto // ignore: cast_nullable_to_non_nullable
as bool,showBreed: null == showBreed ? _self.showBreed : showBreed // ignore: cast_nullable_to_non_nullable
as bool,showMicrochip: null == showMicrochip ? _self.showMicrochip : showMicrochip // ignore: cast_nullable_to_non_nullable
as bool,contactName: freezed == contactName ? _self.contactName : contactName // ignore: cast_nullable_to_non_nullable
as String?,contactPhone: freezed == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String?,medicalWarnings: freezed == medicalWarnings ? _self.medicalWarnings : medicalWarnings // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$PublicPetProfile {

 String get publicId;/// Needed so security rules can restrict writes to the owner.
 String get ownerId; String get petName;/// `PetSpecies` name, e.g. "dog".
 String get species; String? get breed; String? get photoUrl; String? get microchipId; String? get contactName; String? get contactPhone; String? get medicalWarnings; String? get message; DateTime? get updatedAt;
/// Create a copy of PublicPetProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicPetProfileCopyWith<PublicPetProfile> get copyWith => _$PublicPetProfileCopyWithImpl<PublicPetProfile>(this as PublicPetProfile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicPetProfile&&(identical(other.publicId, publicId) || other.publicId == publicId)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.petName, petName) || other.petName == petName)&&(identical(other.species, species) || other.species == species)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.microchipId, microchipId) || other.microchipId == microchipId)&&(identical(other.contactName, contactName) || other.contactName == contactName)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&(identical(other.medicalWarnings, medicalWarnings) || other.medicalWarnings == medicalWarnings)&&(identical(other.message, message) || other.message == message)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,publicId,ownerId,petName,species,breed,photoUrl,microchipId,contactName,contactPhone,medicalWarnings,message,updatedAt);

@override
String toString() {
  return 'PublicPetProfile(publicId: $publicId, ownerId: $ownerId, petName: $petName, species: $species, breed: $breed, photoUrl: $photoUrl, microchipId: $microchipId, contactName: $contactName, contactPhone: $contactPhone, medicalWarnings: $medicalWarnings, message: $message, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PublicPetProfileCopyWith<$Res>  {
  factory $PublicPetProfileCopyWith(PublicPetProfile value, $Res Function(PublicPetProfile) _then) = _$PublicPetProfileCopyWithImpl;
@useResult
$Res call({
 String publicId, String ownerId, String petName, String species, String? breed, String? photoUrl, String? microchipId, String? contactName, String? contactPhone, String? medicalWarnings, String? message, DateTime? updatedAt
});




}
/// @nodoc
class _$PublicPetProfileCopyWithImpl<$Res>
    implements $PublicPetProfileCopyWith<$Res> {
  _$PublicPetProfileCopyWithImpl(this._self, this._then);

  final PublicPetProfile _self;
  final $Res Function(PublicPetProfile) _then;

/// Create a copy of PublicPetProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? publicId = null,Object? ownerId = null,Object? petName = null,Object? species = null,Object? breed = freezed,Object? photoUrl = freezed,Object? microchipId = freezed,Object? contactName = freezed,Object? contactPhone = freezed,Object? medicalWarnings = freezed,Object? message = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
publicId: null == publicId ? _self.publicId : publicId // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,petName: null == petName ? _self.petName : petName // ignore: cast_nullable_to_non_nullable
as String,species: null == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as String,breed: freezed == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,microchipId: freezed == microchipId ? _self.microchipId : microchipId // ignore: cast_nullable_to_non_nullable
as String?,contactName: freezed == contactName ? _self.contactName : contactName // ignore: cast_nullable_to_non_nullable
as String?,contactPhone: freezed == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String?,medicalWarnings: freezed == medicalWarnings ? _self.medicalWarnings : medicalWarnings // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PublicPetProfile].
extension PublicPetProfilePatterns on PublicPetProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicPetProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicPetProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicPetProfile value)  $default,){
final _that = this;
switch (_that) {
case _PublicPetProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicPetProfile value)?  $default,){
final _that = this;
switch (_that) {
case _PublicPetProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String publicId,  String ownerId,  String petName,  String species,  String? breed,  String? photoUrl,  String? microchipId,  String? contactName,  String? contactPhone,  String? medicalWarnings,  String? message,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicPetProfile() when $default != null:
return $default(_that.publicId,_that.ownerId,_that.petName,_that.species,_that.breed,_that.photoUrl,_that.microchipId,_that.contactName,_that.contactPhone,_that.medicalWarnings,_that.message,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String publicId,  String ownerId,  String petName,  String species,  String? breed,  String? photoUrl,  String? microchipId,  String? contactName,  String? contactPhone,  String? medicalWarnings,  String? message,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PublicPetProfile():
return $default(_that.publicId,_that.ownerId,_that.petName,_that.species,_that.breed,_that.photoUrl,_that.microchipId,_that.contactName,_that.contactPhone,_that.medicalWarnings,_that.message,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String publicId,  String ownerId,  String petName,  String species,  String? breed,  String? photoUrl,  String? microchipId,  String? contactName,  String? contactPhone,  String? medicalWarnings,  String? message,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PublicPetProfile() when $default != null:
return $default(_that.publicId,_that.ownerId,_that.petName,_that.species,_that.breed,_that.photoUrl,_that.microchipId,_that.contactName,_that.contactPhone,_that.medicalWarnings,_that.message,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _PublicPetProfile implements PublicPetProfile {
  const _PublicPetProfile({required this.publicId, required this.ownerId, required this.petName, required this.species, this.breed, this.photoUrl, this.microchipId, this.contactName, this.contactPhone, this.medicalWarnings, this.message, this.updatedAt});
  

@override final  String publicId;
/// Needed so security rules can restrict writes to the owner.
@override final  String ownerId;
@override final  String petName;
/// `PetSpecies` name, e.g. "dog".
@override final  String species;
@override final  String? breed;
@override final  String? photoUrl;
@override final  String? microchipId;
@override final  String? contactName;
@override final  String? contactPhone;
@override final  String? medicalWarnings;
@override final  String? message;
@override final  DateTime? updatedAt;

/// Create a copy of PublicPetProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicPetProfileCopyWith<_PublicPetProfile> get copyWith => __$PublicPetProfileCopyWithImpl<_PublicPetProfile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicPetProfile&&(identical(other.publicId, publicId) || other.publicId == publicId)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.petName, petName) || other.petName == petName)&&(identical(other.species, species) || other.species == species)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.microchipId, microchipId) || other.microchipId == microchipId)&&(identical(other.contactName, contactName) || other.contactName == contactName)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&(identical(other.medicalWarnings, medicalWarnings) || other.medicalWarnings == medicalWarnings)&&(identical(other.message, message) || other.message == message)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,publicId,ownerId,petName,species,breed,photoUrl,microchipId,contactName,contactPhone,medicalWarnings,message,updatedAt);

@override
String toString() {
  return 'PublicPetProfile(publicId: $publicId, ownerId: $ownerId, petName: $petName, species: $species, breed: $breed, photoUrl: $photoUrl, microchipId: $microchipId, contactName: $contactName, contactPhone: $contactPhone, medicalWarnings: $medicalWarnings, message: $message, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PublicPetProfileCopyWith<$Res> implements $PublicPetProfileCopyWith<$Res> {
  factory _$PublicPetProfileCopyWith(_PublicPetProfile value, $Res Function(_PublicPetProfile) _then) = __$PublicPetProfileCopyWithImpl;
@override @useResult
$Res call({
 String publicId, String ownerId, String petName, String species, String? breed, String? photoUrl, String? microchipId, String? contactName, String? contactPhone, String? medicalWarnings, String? message, DateTime? updatedAt
});




}
/// @nodoc
class __$PublicPetProfileCopyWithImpl<$Res>
    implements _$PublicPetProfileCopyWith<$Res> {
  __$PublicPetProfileCopyWithImpl(this._self, this._then);

  final _PublicPetProfile _self;
  final $Res Function(_PublicPetProfile) _then;

/// Create a copy of PublicPetProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? publicId = null,Object? ownerId = null,Object? petName = null,Object? species = null,Object? breed = freezed,Object? photoUrl = freezed,Object? microchipId = freezed,Object? contactName = freezed,Object? contactPhone = freezed,Object? medicalWarnings = freezed,Object? message = freezed,Object? updatedAt = freezed,}) {
  return _then(_PublicPetProfile(
publicId: null == publicId ? _self.publicId : publicId // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,petName: null == petName ? _self.petName : petName // ignore: cast_nullable_to_non_nullable
as String,species: null == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as String,breed: freezed == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,microchipId: freezed == microchipId ? _self.microchipId : microchipId // ignore: cast_nullable_to_non_nullable
as String?,contactName: freezed == contactName ? _self.contactName : contactName // ignore: cast_nullable_to_non_nullable
as String?,contactPhone: freezed == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String?,medicalWarnings: freezed == medicalWarnings ? _self.medicalWarnings : medicalWarnings // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
