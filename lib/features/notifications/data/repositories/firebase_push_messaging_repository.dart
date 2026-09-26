import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/push_messaging_repository.dart';

/// Push messages carry `data: {type: "vaccination", id: "<id>"}`; this is
/// converted to the same payload format local notifications use.
String? _payloadOf(RemoteMessage m) {
  final type = m.data['type'];
  final id = m.data['id'];
  return (type is String && id is String) ? '$type:$id' : null;
}

class FirebasePushMessagingRepository implements PushMessagingRepository {
  FirebasePushMessagingRepository(this._messaging);

  final FirebaseMessaging _messaging;

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      // No Play Services / APNs not configured (e.g. iOS simulator).
      debugPrint('FCM token unavailable: $e');
      return null;
    }
  }

  @override
  Stream<String> get tokenRefreshes => _messaging.onTokenRefresh;

  @override
  Stream<PushMessage> get foregroundMessages => FirebaseMessaging.onMessage.map(
        (m) => PushMessage(
          title: m.notification?.title,
          body: m.notification?.body,
          payload: _payloadOf(m),
        ),
      );

  @override
  Stream<String> get openedPayloads => FirebaseMessaging.onMessageOpenedApp
      .map(_payloadOf)
      .where((p) => p != null)
      .cast<String>();

  @override
  Future<String?> initialPayload() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : _payloadOf(message);
  }
}

/// Devices live at `users/{uid}/devices/{token}`.
class FirestoreDeviceRegistry implements DeviceRegistry {
  FirestoreDeviceRegistry(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String ownerId, String token) =>
      _firestore.collection('users').doc(ownerId).collection('devices').doc(token);

  @override
  Future<void> register({
    required String ownerId,
    required String token,
    required DateTime lastSyncedAt,
  }) =>
      _doc(ownerId, token).set({
        'token': token,
        'platform': defaultTargetPlatform.name,
        'lastSyncedAt': Timestamp.fromDate(lastSyncedAt),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  @override
  Future<void> unregister({required String ownerId, required String token}) =>
      _doc(ownerId, token).delete();
}
