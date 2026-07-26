import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../data/repositories/photo_repository.dart';

enum GalleryStatus { initial, loading, denied, ready, error }

class GalleryProvider extends ChangeNotifier {
  final PhotoRepository _repo = PhotoRepository();

  GalleryStatus status = GalleryStatus.initial;
  List<AssetEntity> assets = [];
  String? errorMessage;

  Future<void> init() async {
    status = GalleryStatus.loading;
    notifyListeners();
    try {
      final permission = await _repo.requestPermission();
      if (!permission.hasAccess) {
        status = GalleryStatus.denied;
        notifyListeners();
        return;
      }
      assets = await _repo.fetchAllAssets();
      status = GalleryStatus.ready;
    } catch (e) {
      errorMessage = e.toString();
      status = GalleryStatus.error;
    }
    notifyListeners();
  }

  Future<void> refresh() => init();

  void openAppSettings() => _repo.openAppSettings();

  AssetEntity? byId(String id) {
    try {
      return assets.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
