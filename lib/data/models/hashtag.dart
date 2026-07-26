/// A user-created hashtag used to classify photos/videos.
/// Sort preference values: 'newest', 'oldest', 'manual'.
class Hashtag {
  final int? id;
  final String name;
  final String colorHex; // e.g. '#D97706'
  final bool isPinned;
  final bool isLocked;
  final String? passwordHash; // sha256 hash, only set when isLocked
  final String sortPreference;
  final int createdAt; // millisecondsSinceEpoch

  const Hashtag({
    this.id,
    required this.name,
    required this.colorHex,
    this.isPinned = false,
    this.isLocked = false,
    this.passwordHash,
    this.sortPreference = 'newest',
    required this.createdAt,
  });

  Hashtag copyWith({
    int? id,
    String? name,
    String? colorHex,
    bool? isPinned,
    bool? isLocked,
    String? passwordHash,
    bool clearPassword = false,
    String? sortPreference,
    int? createdAt,
  }) {
    return Hashtag(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      isPinned: isPinned ?? this.isPinned,
      isLocked: isLocked ?? this.isLocked,
      passwordHash: clearPassword ? null : (passwordHash ?? this.passwordHash),
      sortPreference: sortPreference ?? this.sortPreference,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'color_hex': colorHex,
      'is_pinned': isPinned ? 1 : 0,
      'is_locked': isLocked ? 1 : 0,
      'password_hash': passwordHash,
      'sort_preference': sortPreference,
      'created_at': createdAt,
    };
  }

  factory Hashtag.fromMap(Map<String, Object?> map) {
    return Hashtag(
      id: map['id'] as int?,
      name: map['name'] as String,
      colorHex: map['color_hex'] as String,
      isPinned: (map['is_pinned'] as int? ?? 0) == 1,
      isLocked: (map['is_locked'] as int? ?? 0) == 1,
      passwordHash: map['password_hash'] as String?,
      sortPreference: map['sort_preference'] as String? ?? 'newest',
      createdAt: map['created_at'] as int? ?? 0,
    );
  }
}
