/// Item from `GET rider/notifications` (NotificationResource).
/// Backend sends the body as `message` (mapped from `content`);
/// both keys are accepted defensively.
class RiderNotification {
  final int id;
  final String title;
  final String? content;
  final bool? isRead;
  final String? createdAt;
  final String? type;
  final String? url;
  final Map<String, dynamic> raw;

  const RiderNotification({
    required this.id,
    required this.title,
    this.content,
    this.isRead,
    this.createdAt,
    this.type,
    this.url,
    this.raw = const {},
  });

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static bool? _asBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v.toString().toLowerCase().trim();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
    return null;
  }

  factory RiderNotification.fromJson(dynamic json) {
    final Map<String, dynamic> map;
    if (json is Map) {
      map = json.map((k, e) => MapEntry(k.toString(), e));
    } else {
      map = <String, dynamic>{};
    }
    return RiderNotification(
      id: _asInt(map['id']),
      title: map['title']?.toString() ?? '',
      content: (map['message'] ?? map['content'])?.toString(),
      isRead: _asBool(map['is_read']),
      createdAt: map['created_at']?.toString(),
      type: map['type']?.toString(),
      url: map['url']?.toString(),
      raw: map,
    );
  }

  static List<RiderNotification> listFromJson(dynamic json) {
    if (json is List) {
      return json.map(RiderNotification.fromJson).toList();
    }
    return [];
  }
}
