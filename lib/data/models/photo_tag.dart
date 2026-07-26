/// Many-to-many link between a device photo/video (by its OS asset id,
/// never a copy of the file itself) and a [Hashtag].
class PhotoTag {
  final int? id;
  final String photoAssetId;
  final int hashtagId;
  final int dateTagged; // millisecondsSinceEpoch
  final int manualOrder;

  const PhotoTag({
    this.id,
    required this.photoAssetId,
    required this.hashtagId,
    required this.dateTagged,
    this.manualOrder = 0,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'photo_asset_id': photoAssetId,
      'hashtag_id': hashtagId,
      'date_tagged': dateTagged,
      'manual_order': manualOrder,
    };
  }

  factory PhotoTag.fromMap(Map<String, Object?> map) {
    return PhotoTag(
      id: map['id'] as int?,
      photoAssetId: map['photo_asset_id'] as String,
      hashtagId: map['hashtag_id'] as int,
      dateTagged: map['date_tagged'] as int? ?? 0,
      manualOrder: map['manual_order'] as int? ?? 0,
    );
  }
}
