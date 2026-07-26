import 'package:photo_manager/photo_manager.dart';

/// Thin wrapper around `photo_manager`. The app only ever reads asset
/// metadata/thumbnails from the OS media store — it never copies, moves,
/// or edits the original files.
class PhotoRepository {
  /// Requests access to the *entire* photo/video library in one go
  /// (rather than iOS's "Limited Access" picker). Note: starting from
  /// iOS 14, the end user can still choose "Select Photos" on the system
  /// dialog regardless of what the app asks for — that choice belongs to
  /// the user/OS, not the app.
  Future<PermissionState> requestPermission() async {
    return PhotoManager.requestPermissionExtend();
  }

  Future<PermissionState> currentPermission() async {
    return PhotoManager.requestPermissionExtend();
  }

  Future<List<AssetEntity>> fetchAllAssets() async {
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.common, // images + videos, no audio
    );
    if (paths.isEmpty) return [];
    final AssetPathEntity all = paths.first;
    final int count = await all.assetCountAsync;
    if (count == 0) return [];
    return all.getAssetListRange(start: 0, end: count);
  }

  Future<AssetEntity?> fetchAssetById(String id) => AssetEntity.fromId(id);

  void openAppSettings() {
    PhotoManager.openSetting();
  }
}
