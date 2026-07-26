import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../data/models/hashtag.dart';
import '../data/repositories/hashtag_repository.dart';

class HashtagProvider extends ChangeNotifier {
  final HashtagRepository _repo = HashtagRepository();

  List<Hashtag> hashtags = [];
  Map<int, int> photoCounts = {};
  bool loading = false;

  /// Hashtag ids the user has unlocked during this app session. Resets on
  /// every fresh launch — locked hashtags always start locked again.
  final Set<int> unlockedIds = {};

  List<Hashtag> get pinned => hashtags.where((h) => h.isPinned).toList();

  List<Hashtag> get lockedHashtags => hashtags.where((h) => h.isLocked).toList();

  List<int> get lockedHashtagIds => lockedHashtags.map((h) => h.id!).toList();

  bool isUnlocked(Hashtag h) => !h.isLocked || unlockedIds.contains(h.id);

  Future<void> load() async {
    loading = true;
    notifyListeners();
    hashtags = await _repo.getAll();
    photoCounts = await _repo.photoCounts();
    loading = false;
    notifyListeners();
  }

  String randomColor() {
    final list = AppColors.hashtagPaletteHex;
    final idx = DateTime.now().microsecondsSinceEpoch % list.length;
    return list[idx];
  }

  Future<Hashtag> create({
    required String name,
    required String colorHex,
    bool isLocked = false,
    String? rawPassword,
  }) async {
    final h = await _repo.create(
      name: name,
      colorHex: colorHex,
      isLocked: isLocked,
      rawPassword: rawPassword,
    );
    await load();
    return h;
  }

  Future<void> rename(Hashtag h, String newName) async {
    await _repo.rename(h, newName);
    await load();
  }

  Future<void> setColor(Hashtag h, String colorHex) async {
    await _repo.setColor(h, colorHex);
    await load();
  }

  Future<void> togglePin(Hashtag h) async {
    await _repo.togglePin(h);
    await load();
  }

  Future<void> setSortPreference(Hashtag h, String sort) async {
    await _repo.setSortPreference(h, sort);
    await load();
  }

  Future<void> setLock(Hashtag h, {required bool locked, String? rawPassword}) async {
    await _repo.setLock(h, locked: locked, rawPassword: rawPassword);
    if (!locked) unlockedIds.remove(h.id);
    await load();
  }

  bool verifyPassword(Hashtag h, String raw) => _repo.verifyPassword(h, raw);

  void markUnlocked(Hashtag h) {
    if (h.id != null) unlockedIds.add(h.id!);
    notifyListeners();
  }

  Future<void> delete(Hashtag h) async {
    await _repo.delete(h.id!);
    unlockedIds.remove(h.id);
    await load();
  }

  Future<void> tagAsset(String assetId, int hashtagId) async {
    await _repo.tagAsset(assetId, hashtagId);
    photoCounts = await _repo.photoCounts();
    notifyListeners();
  }

  Future<void> untagAsset(String assetId, int hashtagId) async {
    await _repo.untagAsset(assetId, hashtagId);
    photoCounts = await _repo.photoCounts();
    notifyListeners();
  }

  Future<void> tagAssets(List<String> assetIds, List<int> hashtagIds) async {
    await _repo.tagAssets(assetIds, hashtagIds);
    photoCounts = await _repo.photoCounts();
    notifyListeners();
  }

  Future<List<Hashtag>> hashtagsForAsset(String assetId) => _repo.hashtagsForAsset(assetId);

  Future<Map<String, List<int>>> hashtagIdsForAssets(List<String> assetIds) =>
      _repo.hashtagIdsForAssets(assetIds);

  Future<List<String>> assetIdsForHashtag(Hashtag h) =>
      _repo.assetIdsForHashtag(h.id!, sort: h.sortPreference);

  Future<List<String>> search(List<int> hashtagIds, {required bool matchAll}) =>
      _repo.search(hashtagIds, matchAll: matchAll);

  Future<Set<String>> lockedAssetIds() {
    final ids = lockedHashtagIds.where((id) => !unlockedIds.contains(id)).toList();
    return _repo.lockedAssetIds(ids);
  }

  Future<int> taggedPhotoCount() => _repo.taggedPhotoCount();

  Hashtag? mostUsed() {
    if (photoCounts.isEmpty) return null;
    final sorted = photoCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topId = sorted.first.key;
    try {
      return hashtags.firstWhere((h) => h.id == topId);
    } catch (_) {
      return null;
    }
  }

  Future<void> reorder(Hashtag h, List<String> orderedAssetIds) async {
    await _repo.reorderWithinHashtag(h.id!, orderedAssetIds);
  }
}
