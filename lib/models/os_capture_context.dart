/// Active Focus / Protocol context attached to capture API writes.
class OsCaptureContext {
  const OsCaptureContext({this.focusId, this.protocolId});

  final String? focusId;
  final String? protocolId;

  Map<String, dynamic> toApiFields() {
    final fields = <String, dynamic>{};
    if (focusId != null && focusId!.isNotEmpty) {
      fields['os_focus_id'] = focusId;
    }
    if (protocolId != null && protocolId!.isNotEmpty) {
      fields['os_protocol_id'] = protocolId;
    }
    return fields;
  }
}
