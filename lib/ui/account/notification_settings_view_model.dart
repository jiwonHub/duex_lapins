import 'package:deux_lapins/core/di/providers.dart';
import 'package:deux_lapins/domain/models/notification_preferences.dart';
import 'package:deux_lapins/ui/account/account_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationSettingsState {
  const NotificationSettingsState({
    this.preferences = const NotificationPreferences(),
    this.loading = true,
    this.saving = false,
    this.error,
  });

  final NotificationPreferences preferences;
  final bool loading;
  final bool saving;
  final String? error;
}

final notificationSettingsViewModelProvider =
NotifierProvider<NotificationSettingsViewModel, NotificationSettingsState>(
  NotificationSettingsViewModel.new,
);

class NotificationSettingsViewModel extends Notifier<NotificationSettingsState> {
  @override
  NotificationSettingsState build() {
    final memberId = ref.watch(accountViewModelProvider.select((s) => s.memberId));
    if (memberId != null) {
      Future<void>.microtask(() => load(memberId));
    }
    return NotificationSettingsState(loading: memberId != null);
  }

  Future<void> load(String memberId) async {
    state = NotificationSettingsState(loading: true);
    try {
      final settings = await ref.read(accountRepositoryProvider)
          .getNotificationPreferences(memberId);
      if (ref.read(accountViewModelProvider).memberId != memberId) return;
      state = NotificationSettingsState(preferences: settings, loading: false);
    } catch (error) {
      if (ref.read(accountViewModelProvider).memberId != memberId) return;
      state = NotificationSettingsState(loading: false, error: '$error');
    }
  }

  Future<void> update(NotificationPreferences preferences) async {
    if (state.loading || state.saving) return;
    final memberId = ref.read(accountViewModelProvider).memberId;
    if (memberId == null) throw StateError('로그인이 필요합니다.');
    final before = state.preferences;
    state = NotificationSettingsState(preferences: preferences, saving: true);
    try {
      final saved = await ref.read(accountRepositoryProvider)
          .saveNotificationPreferences(memberId, preferences);
      if (ref.read(accountViewModelProvider).memberId != memberId) return;
      state = NotificationSettingsState(preferences: saved, loading: false);
    } catch (error) {
      if (ref.read(accountViewModelProvider).memberId != memberId) return;
      state = NotificationSettingsState(preferences: before, loading: false, error: '$error');
    }
  }
}