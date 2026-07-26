import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../database/database_helper.dart';
import '../models/hashtag.dart';

class HashtagRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  static String hashPassword(String raw) {
    return sha256.convert(utf8.encode(raw)).toString();
  }

  Future<List<Hashtag>> getAll() => _db.getAllHashtags();

  Future<Hashtag> create({
    required String name,
    required String colorHex,
    bool isLocked = false,
    String? rawPassword,
  }) async {
    final hashtag = Hashtag(
      name: name.trim(),
      colorHex: colorHex,
      isLocked: isLocked,
      passwordHash: (isLocked && rawPassword != null) ? hashPassword(rawPassword) : null,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    final id = await _db.insertHashtag(hashtag);
    return hashtag.copyWith(id: id);
  }

  Future<void> rename(Hashtag hashtag, String newName) {
    return _db.updateHashtag(hashtag.copyWith(name: newName.trim()));
  }

  Future<void> setColor(Hashtag hashtag, String colorHex) {
    return _db.updateHashtag(hashtag.copyWith(colorHex: colorHex));
  }

  Future<void> togglePin(Hashtag hashtag) {
    return _db.updateHashtag(hashtag.copyWith(isPinned: !hashtag.isPinned));
  }

  Future<void> setSortPreference(Hashtag hashtag, String sortPreference) {
    return _db.updateHashtag(hashtag.copyWith(sortPreference: sortPreference));
  }

  Future<void> setLock(Hashtag hashtag, {required bool locked, String? rawPassword}) {
    return _db.updateHashtag(
      hashtag.copyWith(
        isLocked: locked,
        passwordHash: locked && rawPassword != null ? hashPassword(rawPassword) : null,
        clearPassword: !locked,
      ),
    );
  }

  bool verifyPassword(Hashtag hashtag, String rawPassword) {
    if (hashtag.passwordHash == null) return true;
    return hashtag.passwordHash == hashPassword(rawPassword);
  }

  Future<void> delete(int id) => _db.deleteHashtag(id);

  Future<void> tagAsset(String assetId, int hashtagId) => _db.tagPhoto(assetId, hashtagId);

  Future<void> tagAssets(List<String> assetIds, List<int> hashtagIds) =>
      _db.tagPhotos(assetIds, hashtagIds);

  Future<void> untagAsset(String assetId, int hashtagId) => _db.untagPhoto(assetId, hashtagId);

  Future<List<Hashtag>> hashtagsForAsset(String assetId) => _db.getHashtagsForAsset(assetId);

  Future<Map<String, List<int>>> hashtagIdsForAssets(List<String> assetIds) =>
      _db.getHashtagIdsForAssets(assetIds);

  Future<List<String>> assetIdsForHashtag(int hashtagId, {String sort = 'newest'}) =>
      _db.getAssetIdsForHashtag(hashtagId, sort: sort);

  Future<Map<int, int>> photoCounts() => _db.getPhotoCountsForAllHashtags();

  Future<List<String>> search(List<int> hashtagIds, {required bool matchAll}) =>
      _db.searchByHashtags(hashtagIds, matchAll: matchAll);

  Future<Set<String>> lockedAssetIds(List<int> lockedHashtagIds) =>
      _db.getAssetIdsUnderLockedHashtags(lockedHashtagIds);

  Future<int> taggedPhotoCount() => _db.getTaggedPhotoCount();

  Future<void> reorderWithinHashtag(int hashtagId, List<String> orderedAssetIds) async {
    for (var i = 0; i < orderedAssetIds.length; i++) {
      await _db.updateManualOrder(orderedAssetIds[i], hashtagId, i);
    }
  }
}
