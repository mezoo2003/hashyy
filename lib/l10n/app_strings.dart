import 'package:flutter/widgets.dart';

/// Lightweight hand-written localization (Arabic / English).
///
/// We intentionally avoid the ARB/gen-l10n build step so the app has one
/// less moving part when building on CI (Codemagic) — everything needed to
/// translate the UI lives in this single file.
class AppStrings {
  AppStrings._();

  static const Map<String, Map<String, String>> _values = {
    'appName': {'en': 'Hash Gallery', 'ar': 'هاش جاليري'},

    // Navigation
    'gallery': {'en': 'Gallery', 'ar': 'المعرض'},
    'hashtags': {'en': 'Hashtags', 'ar': 'الهاشتاجات'},
    'search': {'en': 'Search', 'ar': 'بحث'},
    'settings': {'en': 'Settings', 'ar': 'الإعدادات'},
    'statistics': {'en': 'Statistics', 'ar': 'الإحصائيات'},

    // Empty / permission states
    'noPhotos': {'en': 'No photos yet', 'ar': 'مفيش صور لسه'},
    'noPhotosDesc': {
      'en': 'Photos and videos on your device will appear here.',
      'ar': 'الصور والفيديوهات اللي في جهازك هتظهر هنا.',
    },
    'permissionRequired': {'en': 'Access needed', 'ar': 'محتاجين إذن الوصول'},
    'permissionRequiredDesc': {
      'en': 'Hash Gallery needs access to your photos and videos to show them here. Nothing is ever copied or uploaded.',
      'ar': 'هاش جاليري محتاج إذن الوصول لصورك وفيديوهاتك عشان يعرضها هنا. مفيش أي حاجة بتتنسخ أو بترفع لأي مكان.',
    },
    'grantAccess': {'en': 'Grant access', 'ar': 'السماح بالوصول'},
    'openSettings': {'en': 'Open device settings', 'ar': 'فتح إعدادات الجهاز'},
    'loading': {'en': 'Loading…', 'ar': 'جاري التحميل…'},
    'allPhotos': {'en': 'All', 'ar': 'الكل'},
    'untagged': {'en': 'Untagged', 'ar': 'بدون هاشتاج'},

    // Tagging
    'addHashtag': {'en': 'Add hashtag', 'ar': 'إضافة هاشتاج'},
    'addHashtags': {'en': 'Add hashtags', 'ar': 'إضافة هاشتاجات'},
    'newHashtag': {'en': 'New hashtag', 'ar': 'هاشتاج جديد'},
    'createHashtag': {'en': 'Create hashtag', 'ar': 'إنشاء هاشتاج'},
    'hashtagName': {'en': 'Hashtag name', 'ar': 'اسم الهاشتاج'},
    'hashtagNameHint': {'en': 'e.g. travel', 'ar': 'مثال: سفر'},
    'selectColor': {'en': 'Color', 'ar': 'اللون'},
    'lockThisHashtag': {'en': 'Lock this hashtag', 'ar': 'إخفاء وحماية الهاشتاج ده'},
    'setPassword': {'en': 'Set password', 'ar': 'تحديد كلمة سر'},
    'password': {'en': 'Password', 'ar': 'كلمة السر'},
    'confirmPassword': {'en': 'Confirm password', 'ar': 'تأكيد كلمة السر'},
    'passwordsDontMatch': {'en': "Passwords don't match", 'ar': 'كلمتا السر مش متطابقتين'},
    'passwordTooShort': {'en': 'Use at least 4 characters', 'ar': 'استخدم 4 حروف/أرقام على الأقل'},
    'pinHashtag': {'en': 'Pin', 'ar': 'تثبيت'},
    'unpinHashtag': {'en': 'Unpin', 'ar': 'إلغاء التثبيت'},
    'renameHashtag': {'en': 'Rename', 'ar': 'إعادة تسمية'},
    'deleteHashtag': {'en': 'Delete hashtag', 'ar': 'حذف الهاشتاج'},
    'deleteHashtagConfirm': {
      'en': 'This will remove the hashtag and unlink it from all photos. Photos themselves are never deleted. This can\'t be undone.',
      'ar': 'هيتم حذف الهاشتاج وفك ربطه من كل الصور. الصور نفسها مش هتتمسح خالص. الإجراء ده مينفعش يترجع.',
    },
    'delete': {'en': 'Delete', 'ar': 'حذف'},
    'cancel': {'en': 'Cancel', 'ar': 'إلغاء'},
    'save': {'en': 'Save', 'ar': 'حفظ'},
    'done': {'en': 'Done', 'ar': 'تم'},
    'rename': {'en': 'Rename', 'ar': 'إعادة تسمية'},
    'ok': {'en': 'OK', 'ar': 'حسنًا'},
    'edit': {'en': 'Edit', 'ar': 'تعديل'},
    'create': {'en': 'Create', 'ar': 'إنشاء'},
    'photosLabel': {'en': 'photos', 'ar': 'صورة'},
    'itemsLabel': {'en': 'items', 'ar': 'عنصر'},

    // Hashtag list / detail
    'noHashtagsYet': {'en': 'No hashtags yet', 'ar': 'لسه مفيش هاشتاجات'},
    'noHashtagsYetDesc': {
      'en': 'Create your first hashtag to start organizing your gallery.',
      'ar': 'أنشئ أول هاشتاج عشان تبدأ تنظّم المعرض بتاعك.',
    },
    'createFirstHashtag': {'en': 'Create your first hashtag', 'ar': 'إنشاء أول هاشتاج'},
    'sortBy': {'en': 'Sort by', 'ar': 'الترتيب'},
    'newest': {'en': 'Newest first', 'ar': 'الأحدث أولًا'},
    'oldest': {'en': 'Oldest first', 'ar': 'الأقدم أولًا'},
    'manualOrder': {'en': 'Manual (drag to reorder)', 'ar': 'ترتيب يدوي (اسحب لإعادة الترتيب)'},

    // Search
    'searchHint': {'en': 'Search hashtags…', 'ar': 'دوّر على هاشتاج…'},
    'simpleSearch': {'en': 'Simple', 'ar': 'بحث بسيط'},
    'advancedSearch': {'en': 'Advanced', 'ar': 'بحث متقدم'},
    'matchAll': {'en': 'Match ALL (AND)', 'ar': 'كل الهاشتاجات مع بعض (AND)'},
    'matchAny': {'en': 'Match ANY (OR)', 'ar': 'أي هاشتاج منهم (OR)'},
    'noResults': {'en': 'No results', 'ar': 'مفيش نتايج'},
    'noResultsDesc': {'en': 'Try a different hashtag combination.', 'ar': 'جرّب تركيبة هاشتاجات تانية.'},
    'selectHashtagsToSearch': {'en': 'Pick one or more hashtags to search.', 'ar': 'اختار هاشتاج واحد أو أكتر عشان تبحث.'},

    // Bulk select
    'selectedCount': {'en': 'selected', 'ar': 'محدد'},
    'selectAll': {'en': 'Select all', 'ar': 'تحديد الكل'},
    'cancelSelection': {'en': 'Cancel', 'ar': 'إلغاء التحديد'},
    'bulkSelectHint': {'en': 'Tap photos to select them', 'ar': 'اضغط على الصور عشان تحددها'},

    // Unlock
    'unlock': {'en': 'Unlock', 'ar': 'فتح القفل'},
    'enterPassword': {'en': 'Enter password to view', 'ar': 'ادخل كلمة السر عشان تشوف المحتوى'},
    'useBiometric': {'en': 'Use fingerprint / Face ID', 'ar': 'استخدم البصمة / Face ID'},
    'wrongPassword': {'en': 'Wrong password', 'ar': 'كلمة السر غلط'},
    'locked': {'en': 'Locked', 'ar': 'مقفول'},
    'lockedHashtagDesc': {
      'en': 'This hashtag is protected. Unlock it to see its photos.',
      'ar': 'الهاشتاج ده محمي. افتح القفل عشان تشوف صوره.',
    },
    'biometricReason': {'en': 'Authenticate to view this hashtag', 'ar': 'تأكيد الهوية لعرض الهاشتاج ده'},

    // Statistics
    'totalPhotos': {'en': 'Total photos & videos', 'ar': 'إجمالي الصور والفيديوهات'},
    'taggedPhotos': {'en': 'Tagged', 'ar': 'متصنّف بهاشتاج'},
    'untaggedPhotos': {'en': 'Untagged', 'ar': 'من غير هاشتاج'},
    'totalHashtags': {'en': 'Total hashtags', 'ar': 'إجمالي الهاشتاجات'},
    'mostUsedHashtag': {'en': 'Most used hashtag', 'ar': 'أكتر هاشتاج مستخدم'},
    'photosPerHashtag': {'en': 'Photos per hashtag', 'ar': 'عدد الصور في كل هاشتاج'},
    'noDataYet': {'en': 'No data yet — start tagging your photos!', 'ar': 'لسه مفيش بيانات — ابدأ تصنّف صورك!'},

    // Settings
    'language': {'en': 'Language', 'ar': 'اللغة'},
    'arabic': {'en': 'العربية', 'ar': 'العربية'},
    'english': {'en': 'English', 'ar': 'English'},
    'theme': {'en': 'Appearance', 'ar': 'المظهر'},
    'lightMode': {'en': 'Light', 'ar': 'فاتح'},
    'darkMode': {'en': 'Dark', 'ar': 'داكن'},
    'systemMode': {'en': 'Match system', 'ar': 'مثل إعدادات الجهاز'},
    'manageHashtags': {'en': 'Manage hashtags', 'ar': 'إدارة الهاشتاجات'},
    'security': {'en': 'Security', 'ar': 'الحماية'},
    'about': {'en': 'About Hash Gallery', 'ar': 'عن هاش جاليري'},
    'aboutBody': {
      'en': 'Hash Gallery organizes your photos and videos with hashtags instead of albums. Everything stays 100% on your device — nothing is copied, uploaded, or shared.',
      'ar': 'هاش جاليري بينظّم صورك وفيديوهاتك بالهاشتاجات بدل الألبومات. كل حاجة فاضلة على جهازك بس 100% — مفيش أي نسخ أو رفع أو مشاركة لأي مكان.',
    },
    'version': {'en': 'Version', 'ar': 'الإصدار'},

    // Photo detail / quick tag
    'longPressHint': {'en': 'Long-press a photo to tag it quickly', 'ar': 'اضغط ضغطة طويلة على الصورة عشان تحطلها هاشتاج بسرعة'},
    'addHashtagsToPhoto': {'en': 'Hashtags for this item', 'ar': 'هاشتاجات العنصر ده'},
    'removeHashtag': {'en': 'Remove', 'ar': 'إزالة'},
    'video': {'en': 'Video', 'ar': 'فيديو'},
    'noHashtagSelected': {'en': 'No hashtags added yet', 'ar': 'لسه مفيش هاشتاجات متضافة'},
    'pickAtLeastOne': {'en': 'Pick at least one hashtag', 'ar': 'اختار هاشتاج واحد على الأقل'},
    'colorLabel': {'en': 'Color', 'ar': 'اللون'},
    'createAndAdd': {'en': 'Create & add', 'ar': 'إنشاء وإضافة'},
    'confirmDeleteTitle': {'en': 'Delete?', 'ar': 'تأكيد الحذف؟'},
    'retry': {'en': 'Retry', 'ar': 'إعادة المحاولة'},
    'somethingWentWrong': {'en': 'Something went wrong', 'ar': 'حصل خطأ ما'},
    'close': {'en': 'Close', 'ar': 'إغلاق'},
    'random': {'en': 'Random', 'ar': 'عشوائي'},
    'quickTag': {'en': 'Quick tag', 'ar': 'تصنيف سريع'},
  };

  static String of(BuildContext context, String key) {
    final lang = Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
    final entry = _values[key];
    if (entry == null) return key;
    return entry[lang] ?? entry['en'] ?? key;
  }
}

extension AppStringsExt on BuildContext {
  String tr(String key) => AppStrings.of(this, key);
}
