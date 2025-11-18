import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/storage_service.dart';
import 'quiz_provider.dart';

class SettingsState {
  final bool hapticsEnabled;
  final bool soundEnabled;
  final int autoAdvanceDelayMs;
  final String thumbBarPosition;
  final String themeMode; // 'light', 'dark', 'system'
  final bool autoScrollEnabled; // Auto-advance to next quiz after answering

  SettingsState({
    this.hapticsEnabled = true,
    this.soundEnabled = true,
    this.autoAdvanceDelayMs = 1500,
    this.thumbBarPosition = 'right',
    this.themeMode = 'system',
    this.autoScrollEnabled = false, // Off by default
  });

  SettingsState copyWith({
    bool? hapticsEnabled,
    bool? soundEnabled,
    int? autoAdvanceDelayMs,
    String? thumbBarPosition,
    String? themeMode,
    bool? autoScrollEnabled,
  }) {
    return SettingsState(
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      autoAdvanceDelayMs: autoAdvanceDelayMs ?? this.autoAdvanceDelayMs,
      thumbBarPosition: thumbBarPosition ?? this.thumbBarPosition,
      themeMode: themeMode ?? this.themeMode,
      autoScrollEnabled: autoScrollEnabled ?? this.autoScrollEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final StorageService _storageService;

  SettingsNotifier(this._storageService) : super(SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _storageService.loadSettings();
    state = SettingsState(
      hapticsEnabled: settings['hapticsEnabled'] as bool,
      soundEnabled: settings['soundEnabled'] as bool,
      autoAdvanceDelayMs: settings['autoAdvanceDelayMs'] as int,
      thumbBarPosition: settings['thumbBarPosition'] as String,
      themeMode: settings['themeMode'] as String? ?? 'system',
      autoScrollEnabled: settings['autoScrollEnabled'] as bool? ?? false,
    );
  }

  Future<void> setHapticsEnabled(bool value) async {
    state = state.copyWith(hapticsEnabled: value);
    await _storageService.saveSettings({
      'hapticsEnabled': state.hapticsEnabled,
      'soundEnabled': state.soundEnabled,
      'autoAdvanceDelayMs': state.autoAdvanceDelayMs,
      'thumbBarPosition': state.thumbBarPosition,
      'themeMode': state.themeMode,
      'autoScrollEnabled': state.autoScrollEnabled,
    });
  }

  Future<void> setSoundEnabled(bool value) async {
    state = state.copyWith(soundEnabled: value);
    await _storageService.saveSettings({
      'hapticsEnabled': state.hapticsEnabled,
      'soundEnabled': state.soundEnabled,
      'autoAdvanceDelayMs': state.autoAdvanceDelayMs,
      'thumbBarPosition': state.thumbBarPosition,
      'themeMode': state.themeMode,
      'autoScrollEnabled': state.autoScrollEnabled,
    });
  }

  Future<void> setAutoAdvanceDelayMs(int value) async {
    state = state.copyWith(autoAdvanceDelayMs: value.clamp(0, 10000));
    await _storageService.saveSettings({
      'hapticsEnabled': state.hapticsEnabled,
      'soundEnabled': state.soundEnabled,
      'autoAdvanceDelayMs': state.autoAdvanceDelayMs,
      'thumbBarPosition': state.thumbBarPosition,
      'themeMode': state.themeMode,
      'autoScrollEnabled': state.autoScrollEnabled,
    });
  }

  Future<void> setThumbBarPosition(String position) async {
    state = state.copyWith(thumbBarPosition: position);
    await _storageService.saveSettings({
      'hapticsEnabled': state.hapticsEnabled,
      'soundEnabled': state.soundEnabled,
      'autoAdvanceDelayMs': state.autoAdvanceDelayMs,
      'thumbBarPosition': state.thumbBarPosition,
      'themeMode': state.themeMode,
      'autoScrollEnabled': state.autoScrollEnabled,
    });
  }

  Future<void> setThemeMode(String mode) async {
    state = state.copyWith(themeMode: mode);
    await _storageService.saveSettings({
      'hapticsEnabled': state.hapticsEnabled,
      'soundEnabled': state.soundEnabled,
      'autoAdvanceDelayMs': state.autoAdvanceDelayMs,
      'thumbBarPosition': state.thumbBarPosition,
      'themeMode': state.themeMode,
      'autoScrollEnabled': state.autoScrollEnabled,
    });
  }

  Future<void> setAutoScrollEnabled(bool value) async {
    state = state.copyWith(autoScrollEnabled: value);
    await _storageService.saveSettings({
      'hapticsEnabled': state.hapticsEnabled,
      'soundEnabled': state.soundEnabled,
      'autoAdvanceDelayMs': state.autoAdvanceDelayMs,
      'thumbBarPosition': state.thumbBarPosition,
      'themeMode': state.themeMode,
      'autoScrollEnabled': state.autoScrollEnabled,
    });
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref.read(storageServiceProvider));
});

