// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medical_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MedicalDocument {

/// Empty for a document that has not been saved yet.
 String get id; String get ownerId; String get petId; String get name; DocumentType get type;/// Date on the document (e.g. when the test was done), date only.
 DateTime get date; String get fileUrl;/// Storage path, used to delete the file.
 String get storagePath; String get fileName; String get contentType; int get sizeBytes; String? get description;/// Set when this is the certificate for a vaccination record.
 String? get vaccinationId; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of MedicalDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicalDocumentCopyWith<MedicalDocument> get copyWith => _$MedicalDocumentCopyWithImpl<MedicalDocument>(this as MedicalDocument, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicalDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.petId, petId) || other.petId == petId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.date, date) || other.date == date)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.description, description) || other.description == description)&&(identical(other.vaccinationId, vaccinationId) || other.vaccinationId == vaccinationId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,ownerId,petId,name,type,date,fileUrl,storagePath,fileName,contentType,sizeBytes,description,vaccinationId,createdAt,updatedAt);

@override
String toString() {
  return 'MedicalDocument(id: $id, ownerId: $ownerId, petId: $petId, name: $name, type: $type, date: $date, fileUrl: $fileUrl, storagePath: $storagePath, fileName: $fileName, contentType: $contentType, sizeBytes: $sizeBytes, description: $description, vaccinationId: $vaccinationId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MedicalDocumentCopyWith<$Res>  {
  factory $MedicalDocumentCopyWith(MedicalDocument value, $Res Function(MedicalDocument) _then) = _$MedicalDocumentCopyWithImpl;
@useResult
$Res call({
 String id, String ownerId, String petId, String name, DocumentType type, DateTime date, String fileUrl, String storagePath, String fileName, String contentType, int sizeBytes, String? description, String? vaccinationId, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$MedicalDocumentCopyWithImpl<$Res>
    implements $MedicalDocumentCopyWith<$Res> {
  _$MedicalDocumentCopyWithImpl(this._self, this._then);

  final MedicalDocument _self;
  final $Res Function(MedicalDocument) _then;

/// Create a copy of MedicalDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? petId = null,Object? name = null,Object? type = null,Object? date = null,Object? fileUrl = null,Object? storagePath = null,Object? fileName = null,Object? contentType = null,Object? sizeBytes = null,Object? description = freezed,Object? vaccinationId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,petId: null == petId ? _self.petId : petId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DocumentType,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,vaccinationId: freezed == vaccinationId ? _self.vaccinationId : vaccinationId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicalDocument].
extension MedicalDocumentPatterns on MedicalDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicalDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicalDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicalDocument value)  $default,){
final _that = this;
switch (_that) {
case _MedicalDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicalDocument value)?  $default,){
final _that = this;
switch (_that) {
case _MedicalDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ownerId,  String petId,  String name,  DocumentType type,  DateTime date,  String fileUrl,  String storagePath,  String fileName,  String contentType,  int sizeBytes,  String? description,  String? vaccinationId,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicalDocument() when $default != null:
return $default(_that.id,_that.ownerId,_that.petId,_that.name,_that.type,_that.date,_that.fileUrl,_that.storagePath,_that.fileName,_that.contentType,_that.sizeBytes,_that.description,_that.vaccinationId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ownerId,  String petId,  String name,  DocumentType type,  DateTime date,  String fileUrl,  String storagePath,  String fileName,  String contentType,  int sizeBytes,  String? description,  String? vaccinationId,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MedicalDocument():
return $default(_that.id,_that.ownerId,_that.petId,_that.name,_that.type,_that.date,_that.fileUrl,_that.storagePath,_that.fileName,_that.contentType,_that.sizeBytes,_that.description,_that.vaccinationId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ownerId,  String petId,  String name,  DocumentType type,  DateTime date,  String fileUrl,  String storagePath,  String fileName,  String contentType,  int sizeBytes,  String? description,  String? vaccinationId,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MedicalDocument() when $default != null:
return $default(_that.id,_that.ownerId,_that.petId,_that.name,_that.type,_that.date,_that.fileUrl,_that.storagePath,_that.fileName,_that.contentType,_that.sizeBytes,_that.description,_that.vaccinationId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _MedicalDocument extends MedicalDocument {
  const _MedicalDocument({this.id = '', required this.ownerId, required this.petId, required this.name, this.type = DocumentType.other, required this.date, required this.fileUrl, required this.storagePath, required this.fileName, required this.contentType, required this.sizeBytes, this.description, this.vaccinationId, this.createdAt, this.updatedAt}): super._();
  

/// Empty for a document that has not been saved yet.
@override@JsonKey() final  String id;
@override final  String ownerId;
@override final  String petId;
@override final  String name;
@override@JsonKey() final  DocumentType type;
/// Date on the document (e.g. when the test was done), date only.
@override final  DateTime date;
@override final  String fileUrl;
/// Storage path, used to delete the file.
@override final  String storagePath;
@override final  String fileName;
@override final  String contentType;
@override final  int sizeBytes;
@override final  String? description;
/// Set when this is the certificate for a vaccination record.
@override final  String? vaccinationId;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of MedicalDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicalDocumentCopyWith<_MedicalDocument> get copyWith => __$MedicalDocumentCopyWithImpl<_MedicalDocument>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicalDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.petId, petId) || other.petId == petId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.date, date) || other.date == date)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.description, description) || other.description == description)&&(identical(other.vaccinationId, vaccinationId) || other.vaccinationId == vaccinationId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,ownerId,petId,name,type,date,fileUrl,storagePath,fileName,contentType,sizeBytes,description,vaccinationId,createdAt,updatedAt);

@override
String toString() {
  return 'MedicalDocument(id: $id, ownerId: $ownerId, petId: $petId, name: $name, type: $type, date: $date, fileUrl: $fileUrl, storagePath: $storagePath, fileName: $fileName, contentType: $contentType, sizeBytes: $sizeBytes, description: $description, vaccinationId: $vaccinationId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MedicalDocumentCopyWith<$Res> implements $MedicalDocumentCopyWith<$Res> {
  factory _$MedicalDocumentCopyWith(_MedicalDocument value, $Res Function(_MedicalDocument) _then) = __$MedicalDocumentCopyWithImpl;
@override @useResult
$Res call({
 String id, String ownerId, String petId, String name, DocumentType type, DateTime date, String fileUrl, String storagePath, String fileName, String contentType, int sizeBytes, String? description, String? vaccinationId, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$MedicalDocumentCopyWithImpl<$Res>
    implements _$MedicalDocumentCopyWith<$Res> {
  __$MedicalDocumentCopyWithImpl(this._self, this._then);

  final _MedicalDocument _self;
  final $Res Function(_MedicalDocument) _then;

/// Create a copy of MedicalDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? petId = null,Object? name = null,Object? type = null,Object? date = null,Object? fileUrl = null,Object? storagePath = null,Object? fileName = null,Object? contentType = null,Object? sizeBytes = null,Object? description = freezed,Object? vaccinationId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_MedicalDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,petId: null == petId ? _self.petId : petId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DocumentType,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,vaccinationId: freezed == vaccinationId ? _self.vaccinationId : vaccinationId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
