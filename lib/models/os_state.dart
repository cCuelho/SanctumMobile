/// Sanctum OS Focus + Protocol state — mirrors web FocusContext / GET /api/os/state.
library;

enum AppMode { input, insights }

class FocusArea {
  const FocusArea({
    required this.id,
    required this.title,
    this.templateKey,
    this.bodyRegion,
    this.bodyRegionLabel,
    this.status = 'active',
    this.isPrimary = false,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? templateKey;
  final String? bodyRegion;
  final String? bodyRegionLabel;
  final String status;
  final bool isPrimary;
  final String? createdAt;

  factory FocusArea.fromJson(Map<String, dynamic> json) {
    return FocusArea(
      id: '${json['id']}',
      title: json['title'] as String? ?? 'Focus',
      templateKey: json['templateKey'] as String?,
      bodyRegion: json['bodyRegion'] as String?,
      bodyRegionLabel: json['bodyRegionLabel'] as String?,
      status: json['status'] as String? ?? 'active',
      isPrimary: json['isPrimary'] == true,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (templateKey != null) 'templateKey': templateKey,
        if (bodyRegion != null) 'bodyRegion': bodyRegion,
        if (bodyRegionLabel != null) 'bodyRegionLabel': bodyRegionLabel,
        'status': status,
        'isPrimary': isPrimary,
        if (createdAt != null) 'createdAt': createdAt,
      };

  FocusArea copyWith({
    String? id,
    String? title,
    String? templateKey,
    String? bodyRegion,
    String? bodyRegionLabel,
    String? status,
    bool? isPrimary,
    String? createdAt,
  }) {
    return FocusArea(
      id: id ?? this.id,
      title: title ?? this.title,
      templateKey: templateKey ?? this.templateKey,
      bodyRegion: bodyRegion ?? this.bodyRegion,
      bodyRegionLabel: bodyRegionLabel ?? this.bodyRegionLabel,
      status: status ?? this.status,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Protocol {
  const Protocol({
    required this.id,
    required this.focusId,
    required this.title,
    this.templateKey,
    this.status = 'active',
    this.notes = '',
    this.startedAt,
    this.completedAt,
    this.components = const [],
  });

  final String id;
  final String focusId;
  final String title;
  final String? templateKey;
  final String status;
  final String notes;
  final String? startedAt;
  final String? completedAt;
  final List<dynamic> components;

  bool get isActive => status == 'active' || status == 'draft';

  factory Protocol.fromJson(Map<String, dynamic> json) {
    return Protocol(
      id: '${json['id']}',
      focusId: '${json['focusId']}',
      title: json['title'] as String? ?? 'Protocol',
      templateKey: json['templateKey'] as String?,
      status: json['status'] as String? ?? 'active',
      notes: json['notes'] as String? ?? '',
      startedAt: json['startedAt'] as String?,
      completedAt: json['completedAt'] as String?,
      components: json['components'] as List<dynamic>? ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'focusId': focusId,
        'title': title,
        if (templateKey != null) 'templateKey': templateKey,
        'status': status,
        'notes': notes,
        if (startedAt != null) 'startedAt': startedAt,
        if (completedAt != null) 'completedAt': completedAt,
        'components': components,
      };
}

class OsState {
  const OsState({
    this.onboarded = false,
    this.appMode = AppMode.input,
    this.focuses = const [],
    this.protocols = const [],
    this.activeFocusId,
  });

  final bool onboarded;
  final AppMode appMode;
  final List<FocusArea> focuses;
  final List<Protocol> protocols;
  final String? activeFocusId;

  static OsState empty() => const OsState();

  factory OsState.fromJson(Map<String, dynamic> json) {
    final modeRaw = json['appMode'] as String? ?? 'input';
    return OsState(
      onboarded: json['onboarded'] == true,
      appMode: modeRaw == 'insights' ? AppMode.insights : AppMode.input,
      focuses: (json['focuses'] as List<dynamic>? ?? [])
          .map((e) => FocusArea.fromJson(e as Map<String, dynamic>))
          .toList(),
      protocols: (json['protocols'] as List<dynamic>? ?? [])
          .map((e) => Protocol.fromJson(e as Map<String, dynamic>))
          .toList(),
      activeFocusId: json['activeFocusId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'onboarded': onboarded,
        'appMode': appMode == AppMode.insights ? 'insights' : 'input',
        'focuses': focuses.map((f) => f.toJson()).toList(),
        'protocols': protocols.map((p) => p.toJson()).toList(),
        if (activeFocusId != null) 'activeFocusId': activeFocusId,
      };

  FocusArea? get activeFocus {
    if (activeFocusId != null) {
      for (final f in focuses) {
        if (f.id == activeFocusId) return f;
      }
    }
    for (final f in focuses) {
      if (f.isPrimary) return f;
    }
    return focuses.isNotEmpty ? focuses.first : null;
  }

  List<Protocol> protocolsForFocus(String? focusId) {
    if (focusId == null) return [];
    return protocols.where((p) => p.focusId == focusId && p.isActive).toList();
  }

  OsState copyWith({
    bool? onboarded,
    AppMode? appMode,
    List<FocusArea>? focuses,
    List<Protocol>? protocols,
    String? activeFocusId,
  }) {
    return OsState(
      onboarded: onboarded ?? this.onboarded,
      appMode: appMode ?? this.appMode,
      focuses: focuses ?? this.focuses,
      protocols: protocols ?? this.protocols,
      activeFocusId: activeFocusId ?? this.activeFocusId,
    );
  }
}
