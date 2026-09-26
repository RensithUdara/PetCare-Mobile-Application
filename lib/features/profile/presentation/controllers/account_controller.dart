import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../notifications/presentation/controllers/reminder_sync_controller.dart';
import '../../../pets/domain/entities/photo_change.dart';
import '../../../sync/presentation/providers/sync_providers.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_providers.dart';

@immutable
class AccountState {
  const AccountState({this.isBusy = false, this.error});

  final bool isBusy;
  final Failure? error;
}

/// UI state for editing the profile and account-level actions. Business
/// rules live in the use cases.
class AccountController extends Notifier<AccountState> {
  @override
  AccountState build() => const AccountState();

  Future<bool> _run(Future<void> Function() action) async {
    if (state.isBusy) return false;
    state = const AccountState(isBusy: true);
    try {
      await action();
      if (ref.mounted) state = const AccountState();
      return true;
    } catch (e) {
      final failure = e is Failure ? e : Failure('Something went wrong. Please try again.', cause: e);
      if (ref.mounted) state = AccountState(error: failure);
      return false;
    }
  }

  Future<bool> saveProfile(UserProfile profile, {PhotoChange photo = const PhotoUnchanged()}) {
    if (photo is PhotoReplaced && ref.read(isOfflineProvider)) {
      state = const AccountState(
        error: Failure('You’re offline. Connect to the internet to upload a photo.', code: 'offline'),
      );
      return Future.value(false);
    }
    return _run(() => ref.read(updateUserProfileProvider)(profile, photo: photo));
  }

  Future<bool> changePassword({required String currentPassword, required String newPassword}) => _run(
        () => ref.read(changePasswordProvider)(currentPassword: currentPassword, newPassword: newPassword),
      );

  Future<bool> signOut() => _run(() async {
        // While still signed in: unregister this device and clear reminders.
        await ref.read(reminderSyncControllerProvider.notifier).prepareSignOut();
        await ref.read(signOutProvider)();
      });

  Future<bool> deleteAccount({String? password}) {
    if (ref.read(isOfflineProvider)) {
      state = const AccountState(
        error: Failure('You’re offline. Connect to the internet to delete your account.', code: 'offline'),
      );
      return Future.value(false);
    }
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return Future.value(false);
    return _run(() async {
      final reminders = ref.read(reminderSyncControllerProvider.notifier);
      await reminders.prepareSignOut();
      try {
        await ref.read(deleteAccountProvider)(uid: uid, password: password);
      } catch (_) {
        // Still signed in: bring this device's reminders back.
        ref.invalidate(reminderSyncControllerProvider);
        rethrow;
      }
    });
  }

  void clearError() => state = const AccountState();
}

final accountControllerProvider =
    NotifierProvider.autoDispose<AccountController, AccountState>(AccountController.new);
