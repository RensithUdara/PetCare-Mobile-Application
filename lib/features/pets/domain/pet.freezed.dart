// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Pet {

/// Firestore document id; not stored inside the document itself.
@JsonKey(includeToJson: false) String get id; String get ownerId; String get name;@JsonKey(unknownEnumValue: PetSpecies.other) PetSpecies get species; String? get breed;@JsonKey(unknownEnumValue: PetGender.unknown) PetGender get gender;@NullableDateTimeConverter() DateTime? get dateOfBirth; double? get weightKg; String? get color; String? get microchipId; String? get registrationNumber; String? get notes; String? get photoUrl;@NullableDateTimeConverter() DateTime? get createdAt;@NullableDateTimeConverter() DateTime? get updatedAt;
/// Create a copy of Pet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PetCopyWith<Pet> get copyWith => _$PetCopyWithImpl<Pet>(this as Pet, _$identity);

  /// Serializes this Pet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pet&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.species, species) || other.species == species)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.color, color) || other.color == color)&&(identical(other.microchipId, microchipId) || other.microchipId == microchipId)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,name,species,breed,gender,dateOfBirth,weightKg,color,microchipId,registrationNumber,notes,photoUrl,createdAt,updatedAt);

@override
String toString() {
  return 'Pet(id: $id, ownerId: $ownerId, name: $name, species: $species, breed: $breed, gender: $gender, dateOfBirth: $dateOfBirth, weightKg: $weightKg, color: $color, microchipId: $microchipId, registrationNumber: $registrationNumber, notes: $notes, photoUrl: $photoUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PetCopyWith<$Res>  {
  factory $PetCopyWith(Pet value, $Res Function(Pet) _then) = _$PetCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String ownerId, String name,@JsonKey(unknownEnumValue: PetSpecies.other) PetSpecies species, String? breed,@JsonKey(unknownEnumValue: PetGender.unknown) PetGender gender,@NullableDateTimeConverter() DateTime? dateOfBirth, double? weightKg, String? color, String? microchipId, String? registrationNumber, String? notes, String? photoUrl,@NullableDateTimeConverter() DateTime? createdAt,@NullableDateTimeConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$PetCopyWithImpl<$Res>
    implements $PetCopyWith<$Res> {
  _$PetCopyWithImpl(this._self, this._then);

  final Pet _self;
  final $Res Function(Pet) _then;

/// Create a copy of Pet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? name = null,Object? species = null,Object? breed = freezed,Object? gender = null,Object? dateOfBirth = freezed,Object? weightKg = freezed,Object? color = freezed,Object? microchipId = freezed,Object? registrationNumber = freezed,Object? notes = freezed,Object? photoUrl = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,species: null == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as PetSpecies,breed: freezed == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String?,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as PetGender,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,microchipId: freezed == microchipId ? _self.microchipId : microchipId // ignore: cast_nullable_to_non_nullable
as String?,registrationNumber: freezed == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Pet].
extension PetPatterns on Pet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Pet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Pet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Pet value)  $default,){
final _that = this;
switch (_that) {
case _Pet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Pet value)?  $default,){
final _that = this;
switch (_that) {
case _Pet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String ownerId,  String name, @JsonKey(unknownEnumValue: PetSpecies.other)  PetSpecies species,  String? breed, @JsonKey(unknownEnumValue: PetGender.unknown)  PetGender gender, @NullableDateTimeConverter()  DateTime? dateOfBirth,  double? weightKg,  String? color,  String? microchipId,  String? registrationNumber,  String? notes,  String? photoUrl, @NullableDateTimeConverter()  DateTime? createdAt, @NullableDateTimeConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Pet() when $default != null:
return $default(_that.id,_that.ownerId,_that.name,_that.species,_that.breed,_that.gender,_that.dateOfBirth,_that.weightKg,_that.color,_that.microchipId,_that.registrationNumber,_that.notes,_that.photoUrl,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String ownerId,  String name, @JsonKey(unknownEnumValue: PetSpecies.other)  PetSpecies species,  String? breed, @JsonKey(unknownEnumValue: PetGender.unknown)  PetGender gender, @NullableDateTimeConverter()  DateTime? dateOfBirth,  double? weightKg,  String? color,  String? microchipId,  String? registrationNumber,  String? notes,  String? photoUrl, @NullableDateTimeConverter()  DateTime? createdAt, @NullableDateTimeConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Pet():
return $default(_that.id,_that.ownerId,_that.name,_that.species,_that.breed,_that.gender,_that.dateOfBirth,_that.weightKg,_that.color,_that.microchipId,_that.registrationNumber,_that.notes,_that.photoUrl,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String ownerId,  String name, @JsonKey(unknownEnumValue: PetSpecies.other)  PetSpecies species,  String? breed, @JsonKey(unknownEnumValue: PetGender.unknown)  PetGender gender, @NullableDateTimeConverter()  DateTime? dateOfBirth,  double? weightKg,  String? color,  String? microchipId,  String? registrationNumber,  String? notes,  String? photoUrl, @NullableDateTimeConverter()  DateTime? createdAt, @NullableDateTimeConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Pet() when $default != null:
return $default(_that.id,_that.ownerId,_that.name,_that.species,_that.breed,_that.gender,_that.dateOfBirth,_that.weightKg,_that.color,_that.microchipId,_that.registrationNumber,_that.notes,_that.photoUrl,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Pet extends Pet {
  const _Pet({@JsonKey(includeToJson: false) this.id = '', required this.ownerId, required this.name, @JsonKey(unknownEnumValue: PetSpecies.other) required this.species, this.breed, @JsonKey(unknownEnumValue: PetGender.unknown) this.gender = PetGender.unknown, @NullableDateTimeConverter() this.dateOfBirth, this.weightKg, this.color, this.microchipId, this.registrationNumber, this.notes, this.photoUrl, @NullableDateTimeConverter() this.createdAt, @NullableDateTimeConverter() this.updatedAt}): super._();
  factory _Pet.fromJson(Map<String, dynamic> json) => _$PetFromJson(json);

/// Firestore document id; not stored inside the document itself.
@override@JsonKey(includeToJson: false) final  String id;
@override final  String ownerId;
@override final  String name;
@override@JsonKey(unknownEnumValue: PetSpecies.other) final  PetSpecies species;
@override final  String? breed;
@override@JsonKey(unknownEnumValue: PetGender.unknown) final  PetGender gender;
@override@NullableDateTimeConverter() final  DateTime? dateOfBirth;
@override final  double? weightKg;
@override final  String? color;
@override final  String? microchipId;
@override final  String? registrationNumber;
@override final  String? notes;
@override final  String? photoUrl;
@override@NullableDateTimeConverter() final  DateTime? createdAt;
@override@NullableDateTimeConverter() final  DateTime? updatedAt;

/// Create a copy of Pet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PetCopyWith<_Pet> get copyWith => __$PetCopyWithImpl<_Pet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pet&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.species, species) || other.species == species)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.color, color) || other.color == color)&&(identical(other.microchipId, microchipId) || other.microchipId == microchipId)&&(identical(other.registrationNumber, registrationNumber) || other.registrationNumber == registrationNumber)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerId,name,species,breed,gender,dateOfBirth,weightKg,color,microchipId,registrationNumber,notes,photoUrl,createdAt,updatedAt);

@override
String toString() {
  return 'Pet(id: $id, ownerId: $ownerId, name: $name, species: $species, breed: $breed, gender: $gender, dateOfBirth: $dateOfBirth, weightKg: $weightKg, color: $color, microchipId: $microchipId, registrationNumber: $registrationNumber, notes: $notes, photoUrl: $photoUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PetCopyWith<$Res> implements $PetCopyWith<$Res> {
  factory _$PetCopyWith(_Pet value, $Res Function(_Pet) _then) = __$PetCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String ownerId, String name,@JsonKey(unknownEnumValue: PetSpecies.other) PetSpecies species, String? breed,@JsonKey(unknownEnumValue: PetGender.unknown) PetGender gender,@NullableDateTimeConverter() DateTime? dateOfBirth, double? weightKg, String? color, String? microchipId, String? registrationNumber, String? notes, String? photoUrl,@NullableDateTimeConverter() DateTime? createdAt,@NullableDateTimeConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$PetCopyWithImpl<$Res>
    implements _$PetCopyWith<$Res> {
  __$PetCopyWithImpl(this._self, this._then);

  final _Pet _self;
  final $Res Function(_Pet) _then;

/// Create a copy of Pet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? name = null,Object? species = null,Object? breed = freezed,Object? gender = null,Object? dateOfBirth = freezed,Object? weightKg = freezed,Object? color = freezed,Object? microchipId = freezed,Object? registrationNumber = freezed,Object? notes = freezed,Object? photoUrl = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Pet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,species: null == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as PetSpecies,breed: freezed == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String?,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as PetGender,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,microchipId: freezed == microchipId ? _self.microchipId : microchipId // ignore: cast_nullable_to_non_nullable
as String?,registrationNumber: freezed == registrationNumber ? _self.registrationNumber : registrationNumber // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
