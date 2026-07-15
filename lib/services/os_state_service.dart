import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../api/sanctum_api_client.dart';
import '../config.dart';
import '../constants/focus_templates.dart';
import '../models/os_state.dart';
import 'app_preferences.dart';
import 'server_config_repository.dart';

/// Server-backed Focus + Protocol state — mirrors web FocusContext.
class OsStateService extends ChangeNotifier {
  OsStateService({
    required ServerConfigRepository configRepo,
    required AppPreferences prefs,
    SanctumApiClient Function(SanctumConfig)? clientFactory,
  })  : _configRepo = configRepo,
        _prefs = prefs,
        _clientFactory = clientFactory ?? ((c) => SanctumApiClient(c));

  /// When true, OS state stays local-only (integration tests).
  static bool integrationTestMode = false;

  final ServerConfigRepository _configRepo;
  final AppPreferences _prefs;
  final SanctumApiClient Function(SanctumConfig) _clientFactory;

  OsState _state = OsState.empty();
  bool _hydrated = false;

  OsState get state => _state;
  bool get hydrated => _hydrated;
  bool get onboarded => _state.onboarded;
  AppMode get appMode => _state.appMode;
  FocusArea? get activeFocus => _state.activeFocus;
  List<Protocol> get protocols => _state.protocols;

  List<Protocol> protocolsForActiveFocus() =>
      _state.protocolsForFocus(_state.activeFocus?.id);

  SanctumApiClient? _client() {
    if (!_configRepo.hasConfiguredServer) return null;
    return _clientFactory(_configRepo.loadConfig());
  }

  Future<void> hydrate() async {
    final local = _loadLocal();

    if (integrationTestMode) {
      _state = local;
      await _persistLocal();
      await _prefs.setOnboardingComplete(_state.onboarded);
      _hydrated = true;
      notifyListeners();
      return;
    }

    final client = _client();

    if (client != null) {
      try {
        final remote = OsState.fromJson(await client.getJson('/api/os/state'));
        final remoteEmpty = !remote.onboarded && remote.focuses.isEmpty;
        final localHasData = local.onboarded || local.focuses.isNotEmpty;

        if (remoteEmpty && localHasData) {
          _state = await _saveToServer(local);
        } else {
          _state = remote;
        }
      } catch (_) {
        _state = local;
      } finally {
        client.close();
      }
    } else {
      _state = local;
    }

    await _persistLocal();
    await _prefs.setOnboardingComplete(_state.onboarded);
    _hydrated = true;
    notifyListeners();
  }

  Future<void> setActiveFocus(String focusId) async {
    await _commit(_state.copyWith(activeFocusId: focusId));
  }

  Future<void> setAppMode(AppMode mode) async {
    await _commit(_state.copyWith(appMode: mode));
  }

  Future<void> completeOnboarding({
    required List<FocusArea> focusSelections,
    required String primaryFocusId,
    List<String> protocolTemplateKeys = const [],
  }) async {
    final focuses = focusSelections.map((f) {
      final isPrimary = f.id == primaryFocusId;
      return f.copyWith(isPrimary: isPrimary, status: 'active');
    }).toList();

    FocusArea? primary;
    for (final f in focuses) {
      if (f.id == primaryFocusId) {
        primary = f;
        break;
      }
    }
    primary ??= focuses.isNotEmpty ? focuses.first : null;

    final protocols = _protocolsFromTemplateKeys(
      focusId: primary?.id,
      templateKeys: protocolTemplateKeys,
      existingProtocols: const [],
    );

    final next = OsState(
      onboarded: true,
      appMode: AppMode.input,
      focuses: focuses,
      protocols: protocols,
      activeFocusId: primary?.id,
    );
    await _commit(next);
    await _prefs.setOnboardingComplete(true);
  }

  /// Add Focus areas without replacing existing ones (multi-focus).
  Future<void> addFocusPhase({
    required List<FocusArea> focusSelections,
    String? activeFocusId,
    List<String> protocolTemplateKeys = const [],
    bool setAsPrimary = false,
    bool switchToNew = true,
  }) async {
    if (focusSelections.isEmpty) return;

    FocusArea? protocolFocus;
    if (activeFocusId != null) {
      for (final f in focusSelections) {
        if (f.id == activeFocusId) {
          protocolFocus = f;
          break;
        }
      }
    }
    protocolFocus ??= focusSelections.first;

    String? primaryId;
    if (setAsPrimary) {
      primaryId = protocolFocus.id;
    } else {
      for (final f in _state.focuses) {
        if (f.isPrimary) {
          primaryId = f.id;
          break;
        }
      }
    }

    final mergedFocuses = [
      ..._state.focuses.map(
        (f) => f.copyWith(isPrimary: setAsPrimary ? f.id == primaryId : f.isPrimary),
      ),
      ...focusSelections.map(
        (f) => f.copyWith(
          isPrimary: setAsPrimary && f.id == primaryId,
          status: 'active',
        ),
      ),
    ];

    final resolvedActiveId = switchToNew
        ? (activeFocusId ?? protocolFocus.id)
        : _state.activeFocusId;

    final newProtocols = _protocolsFromTemplateKeys(
      focusId: protocolFocus.id,
      templateKeys: protocolTemplateKeys,
      existingProtocols: _state.protocols,
    );

    await _commit(
      _state.copyWith(
        onboarded: true,
        focuses: mergedFocuses,
        protocols: [..._state.protocols, ...newProtocols],
        activeFocusId: resolvedActiveId,
      ),
    );
  }

  Future<String> addProtocol({
    required String focusId,
    required String title,
    String? templateKey,
    String notes = '',
  }) async {
    final tpl = templateKey != null ? protocolTemplates[templateKey] : null;
    final id = newFocusId();
    final protocol = Protocol(
      id: id,
      focusId: focusId,
      title: title.trim().isNotEmpty ? title.trim() : (tpl?.title ?? 'Custom Protocol'),
      templateKey: templateKey,
      notes: notes.trim(),
      status: 'active',
      startedAt: DateTime.now().toIso8601String(),
    );
    await _commit(_state.copyWith(protocols: [..._state.protocols, protocol]));
    return id;
  }

  Future<void> updateProtocol(
    String protocolId, {
    String? title,
    String? notes,
    String? status,
  }) async {
    await _commit(
      _state.copyWith(
        protocols: _state.protocols.map((p) {
          if (p.id != protocolId) return p;
          return Protocol(
            id: p.id,
            focusId: p.focusId,
            title: title ?? p.title,
            templateKey: p.templateKey,
            status: status ?? p.status,
            notes: notes ?? p.notes,
            startedAt: p.startedAt,
            completedAt: status == 'completed'
                ? DateTime.now().toIso8601String()
                : p.completedAt,
            components: p.components,
          );
        }).toList(),
      ),
    );
  }

  Future<void> updateFocus(
    String focusId, {
    String? title,
  }) async {
    await _commit(
      _state.copyWith(
        focuses: _state.focuses.map((f) {
          if (f.id != focusId) return f;
          return f.copyWith(title: title ?? f.title);
        }).toList(),
      ),
    );
  }

  Future<void> deleteFocus(String focusId) async {
    var remaining = _state.focuses.where((f) => f.id != focusId).toList();
    var activeFocusId = _state.activeFocusId;
    if (activeFocusId == focusId) {
      activeFocusId = remaining.isNotEmpty ? remaining.first.id : null;
    }
    final hadPrimary = _state.focuses.any((f) => f.id == focusId && f.isPrimary);
    if (hadPrimary && remaining.isNotEmpty && !remaining.any((f) => f.isPrimary)) {
      remaining = remaining
          .map((f) => f.copyWith(isPrimary: f.id == remaining.first.id))
          .toList();
    }
    await _commit(
      _state.copyWith(
        activeFocusId: activeFocusId,
        focuses: remaining,
        protocols: _state.protocols.where((p) => p.focusId != focusId).toList(),
      ),
    );
  }

  Future<void> deleteProtocol(String protocolId) async {
    await _commit(
      _state.copyWith(
        protocols: _state.protocols.where((p) => p.id != protocolId).toList(),
      ),
    );
  }

  List<Protocol> _protocolsFromTemplateKeys({
    required String? focusId,
    required List<String> templateKeys,
    required List<Protocol> existingProtocols,
  }) {
    if (focusId == null) return [];
    final protocols = <Protocol>[];
    for (final key in templateKeys) {
      final tpl = protocolTemplates[key];
      if (tpl == null) continue;
      final exists = existingProtocols.any(
        (p) => p.focusId == focusId && p.templateKey == key,
      );
      if (exists) continue;
      protocols.add(
        Protocol(
          id: newFocusId(),
          focusId: focusId,
          title: tpl.title,
          templateKey: key,
          status: 'active',
          startedAt: DateTime.now().toIso8601String(),
        ),
      );
    }
    return protocols;
  }

  Future<void> _commit(OsState next) async {
    _state = next;
    await _persistLocal();
    notifyListeners();

    final client = _client();
    if (client == null || integrationTestMode) return;

    try {
      _state = await _saveToServer(next);
      await _persistLocal();
      await _prefs.setOnboardingComplete(_state.onboarded);
      notifyListeners();
    } catch (_) {
      // offline — local remains source of truth
    } finally {
      client.close();
    }
  }

  Future<OsState> _saveToServer(OsState next) async {
    final client = _client();
    if (client == null) return next;
    try {
      final saved = await client.putJson('/api/os/state', next.toJson());
      return OsState.fromJson(saved);
    } finally {
      client.close();
    }
  }

  OsState _loadLocal() {
    final raw = _prefs.osStateJson;
    if (raw == null || raw.isEmpty) return OsState.empty();
    try {
      return OsState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return OsState.empty();
    }
  }

  Future<void> _persistLocal() async {
    await _prefs.setOsStateJson(jsonEncode(_state.toJson()));
  }

  Future<void> clearLocal() async {
    _state = OsState.empty();
    _hydrated = false;
    await _prefs.setOsStateJson(null);
    await _prefs.setOnboardingComplete(false);
    notifyListeners();
  }
}
