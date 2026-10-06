// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'أوربكس';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navLive => 'مباشر';

  @override
  String get navGuide => 'الدليل';

  @override
  String get navMovies => 'أفلام';

  @override
  String get navSeries => 'مسلسلات';

  @override
  String get navFavorites => 'المفضلة';

  @override
  String get navProfile => 'حسابي';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get devFoundations => 'أسس التصميم';

  @override
  String get devGallery => 'معرض المكوّنات';

  @override
  String get badgeLive => 'مباشر';

  @override
  String get badgeNew => 'جديد';

  @override
  String get badgePin => 'PIN';

  @override
  String get a11yLoading => 'جارٍ التحميل';

  @override
  String get a11yNowPlaying => 'يُعرض الآن';

  @override
  String get a11yLocked => 'مقفل';

  @override
  String get a11yAddFavorite => 'إضافة إلى المفضلة';

  @override
  String get a11yRemoveFavorite => 'إزالة من المفضلة';

  @override
  String get a11yShowPassword => 'إظهار كلمة المرور';

  @override
  String get a11yHidePassword => 'إخفاء كلمة المرور';

  @override
  String get a11yClear => 'مسح';

  @override
  String get a11yVoiceSearch => 'البحث الصوتي';

  @override
  String get a11yDismiss => 'إغلاق';

  @override
  String get splashTagline => 'كل بثّ تملكه، في مدار واحد.';

  @override
  String get splashLoading => 'جارٍ تحميل مكتبتك';

  @override
  String get playerOnlyNotice =>
      'أوربكس مشغّل وسائط فقط. لا يتضمن أي قنوات أو محتوى.';

  @override
  String get actionSkip => 'تخطٍّ';

  @override
  String get actionNext => 'التالي';

  @override
  String get actionBack => 'رجوع';

  @override
  String get actionGetStarted => 'ابدأ الآن';

  @override
  String onboardingStep(int step, int total) {
    return 'الخطوة $step من $total';
  }

  @override
  String get onboarding1Title => 'اربط خدمة IPTV الخاصة بك';

  @override
  String get onboarding1Body =>
      'سجّل الدخول عبر Xtream Codes أو رابط M3U أو ملف قائمة تشغيل. يشغّل أوربكس ما يقدّمه مزوّدك فقط، ولا يوفّر أي محتوى بنفسه.';

  @override
  String get onboarding2Title => 'البث المباشر والأفلام والمسلسلات معًا';

  @override
  String get onboarding2Body =>
      'تنقّل بين القنوات مع دليل برامج كامل، ثم انتقل إلى الأفلام والمسلسلات. كل ما في قائمتك، منظّم وسريع.';

  @override
  String get onboarding3Title => 'احتفظ بمفضلتك. وتابع من الثانية نفسها.';

  @override
  String get onboarding3Body =>
      'أضف أي قناة أو فيلم أو مسلسل إلى المفضلة. يُحفظ تقدّمك على هذا الجهاز، فيُفتح كل عنوان من حيث توقفت تمامًا.';

  @override
  String get onboardingXtreamCard => 'Xtream Codes';

  @override
  String get onboardingOnline => 'متصل';

  @override
  String get onboardingM3uChip => 'قائمة M3U';

  @override
  String get onboardingEpgChip => 'دليل EPG';

  @override
  String get onboardingFileChip => 'ملف M3U محلي';

  @override
  String get onboardingCardCaption => 'غرفة المعيشة · 1,284 قناة';

  @override
  String get onboardingResume => 'استئناف م3 · ح4 «Ash on the Avenue»';

  @override
  String get onboardingMinLeft => 'متبقٍ 18 دقيقة';

  @override
  String get onboardingFavorites => 'المفضلة';

  @override
  String get addAccountTitle => 'إضافة حساب IPTV';

  @override
  String get addAccountIntro =>
      'استخدم خدمة مخوّلًا بالوصول إليها. أوربكس لا يبيع القنوات ولا يوفّرها.';

  @override
  String savedProfiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ملف محفوظ',
      many: '$count ملفًا محفوظًا',
      few: '$count ملفات محفوظة',
      two: 'ملفان محفوظان',
      one: 'ملف محفوظ واحد',
      zero: 'لا توجد ملفات محفوظة',
    );
    return '$_temp0';
  }

  @override
  String get sourceXtream => 'Xtream';

  @override
  String get sourceM3u => 'M3U';

  @override
  String get sourceFile => 'ملف';

  @override
  String get fieldAccountName => 'اسم الحساب';

  @override
  String get fieldServerUrl => 'رابط الخادم';

  @override
  String get fieldUsername => 'اسم المستخدم';

  @override
  String get fieldPassword => 'كلمة المرور';

  @override
  String get fieldPlaylistName => 'اسم القائمة';

  @override
  String get fieldM3uUrl => 'رابط قائمة M3U';

  @override
  String get fieldEpgUrlXmltv => 'رابط EPG (XMLTV)';

  @override
  String get epgOptionalTitle => 'رابط EPG';

  @override
  String get epgOptionalTag => '· اختياري';

  @override
  String get epgOptionalHint => 'يُستخدم دليل مزوّدك عند تركه فارغًا';

  @override
  String get saveProfileEncrypted =>
      'حفظ كملف شخصي · يُخزَّن مشفّرًا على هذا الجهاز';

  @override
  String get actionTest => 'اختبار';

  @override
  String get actionConnect => 'اتصال';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionEditDetails => 'تعديل البيانات';

  @override
  String get actionTryAgain => 'حاول مجددًا';

  @override
  String get or => 'أو';

  @override
  String get chooseLocalFile => 'اختر ملفًا محليًا';

  @override
  String get chooseLocalFileHint => 'ملف M3U أو M3U8 من هذا الجهاز';

  @override
  String get testingConnection => 'جارٍ اختبار الاتصال…';

  @override
  String get testingHint => 'يستغرق عادةً أقل من 10 ثوانٍ';

  @override
  String get testPassed => 'الاتصال يعمل';

  @override
  String get testPassedHint => 'كل شيء سليم — اضغط «اتصال» للحفظ.';

  @override
  String get testFailed => 'تعذّر الاتصال';

  @override
  String get stepReach => 'الخادم متاح';

  @override
  String get stepSignIn => 'تم تسجيل الدخول';

  @override
  String get stepDownload => 'تم تنزيل القائمة';

  @override
  String get stepRead => 'قراءة القنوات والأفلام';

  @override
  String get stepGuide => 'بيانات الدليل (EPG)';

  @override
  String get stepWaiting => 'في الانتظار';

  @override
  String get stepSkipped => 'غير متوفر';

  @override
  String get stepGuideBroken => 'غير متاح';

  @override
  String get requiredField => 'مطلوب';

  @override
  String get invalidUrl => 'أدخل رابطًا صالحًا';

  @override
  String get useDemoProvider => 'استخدام مزوّد تجريبي (للتطوير)';

  @override
  String get errorOffline => 'أنت غير متصل';

  @override
  String get errorOfflineBody =>
      'تحقّق من شبكة Wi‑Fi أو بيانات الجوال. يعيد أوربكس الاتصال تلقائيًا فور عودتك.';

  @override
  String get errorHostNotFound =>
      'لم نعثر على هذا الخادم. تحقّق من الرابط والمنفذ.';

  @override
  String get errorRefused => 'رفض الخادم الاتصال. تحقّق من المنفذ.';

  @override
  String get errorTimeout => 'الخادم لا يستجيب';

  @override
  String errorTimeoutBody(String host) {
    return 'لم يردّ $host خلال 10 ثوانٍ. غالبًا ما تكون المشكلة مؤقتة لدى المزوّد.';
  }

  @override
  String errorServer(int code) {
    return 'يواجه خادم المزوّد مشكلة (الخطأ $code). حاول لاحقًا.';
  }

  @override
  String errorAccessDenied(int code) {
    return 'رفض المزوّد الوصول (الخطأ $code). قد يكون عنوان IP أو التطبيق محظورًا.';
  }

  @override
  String get errorCredentials =>
      'اسم المستخدم أو كلمة المرور غير صحيحة. راجع البيانات من مزوّدك وحاول مجددًا.';

  @override
  String get errorExpired => 'انتهت صلاحية هذا الحساب';

  @override
  String errorExpiredBody(String name, String date) {
    return 'يفيد مزوّدك بأن «$name» انتهى في $date. جدّد اشتراكك لدى المزوّد ثم حدّث هنا.';
  }

  @override
  String get errorExpiredShort => 'انتهت صلاحية هذا الاشتراك.';

  @override
  String errorDisabled(String status) {
    return 'عطّل المزوّد هذا الحساب ($status).';
  }

  @override
  String get errorNotIptv => 'لا يبدو هذا العنوان خادم IPTV.';

  @override
  String get errorPlaylist => 'هذه ليست قائمة M3U صالحة.';

  @override
  String get errorGuide => 'تعذّرت قراءة الدليل.';

  @override
  String get errorTls => 'فشل الاتصال الآمن (مشكلة في الشهادة).';

  @override
  String get errorUnknown => 'حدث خطأ ما. حاول مجددًا.';

  @override
  String get passwordsCaseSensitive => 'كلمات المرور حساسة لحالة الأحرف';

  @override
  String get loadingPlaylist => 'جارٍ تحميل قائمتك';

  @override
  String get loadingPlaylistBody =>
      'البث المباشر جاهز أولًا — وتستمر الأفلام والمسلسلات في التحميل في الخلفية.';

  @override
  String get sectionChannels => 'القنوات';

  @override
  String get sectionMovies => 'الأفلام';

  @override
  String get sectionSeries => 'المسلسلات';

  @override
  String get watchLiveNow => 'شاهد البث المباشر الآن';

  @override
  String get allSetTitle => 'كل شيء جاهز';

  @override
  String allSetBody(String name) {
    return 'تم ربط «$name» وحفظه على هذا الجهاز.';
  }

  @override
  String get statLive => 'قنوات مباشرة';

  @override
  String get statMovies => 'أفلام';

  @override
  String get statSeries => 'مسلسلات';

  @override
  String get statGuide => 'دليل البرامج';

  @override
  String guideDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم',
      many: '$count يومًا',
      few: '$count أيام',
      two: 'يومان',
      one: 'يوم واحد',
      zero: 'لا أيام',
    );
    return '$_temp0';
  }

  @override
  String get startWatching => 'ابدأ المشاهدة';

  @override
  String get profilesTitle => 'اختر حسابًا';

  @override
  String get profilesSubtitle => 'ملفات IPTV الخاصة بك على هذا الجهاز';

  @override
  String get actionEdit => 'تعديل';

  @override
  String get actionDone => 'تم';

  @override
  String get addAccount => 'إضافة حساب';

  @override
  String get addAccountTypes => 'Xtream · M3U';

  @override
  String get editAccount => 'تعديل الحساب';

  @override
  String get setAsDefault => 'تعيين كافتراضي';

  @override
  String get actionDelete => 'حذف';

  @override
  String get openDefaultOnLaunch => 'فتح الحساب الافتراضي عند التشغيل';

  @override
  String get openDefaultOnLaunchHint => 'تخطّي هذه الشاشة في المرة القادمة';

  @override
  String continueWith(String name) {
    return 'المتابعة باستخدام $name';
  }

  @override
  String expiresOn(String date) {
    return 'ينتهي في $date';
  }

  @override
  String deleteAccountTitle(String name) {
    return 'حذف «$name»؟';
  }

  @override
  String get deleteAccountBody =>
      'سيؤدي ذلك إلى إزالة الحساب ومفضلته وتقدّم المشاهدة من هذا الجهاز. لن يتأثر اشتراكك لدى المزوّد.';

  @override
  String get accountDeleted => 'تم حذف الحساب';

  @override
  String get actionUndo => 'تراجع';

  @override
  String get lastUsedNever => 'لم يُفتح بعد';

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'قبل $count دقيقة',
      few: 'قبل $count دقائق',
      two: 'قبل دقيقتين',
      one: 'قبل دقيقة',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'قبل $count ساعة',
      few: 'قبل $count ساعات',
      two: 'قبل ساعتين',
      one: 'قبل ساعة',
    );
    return '$_temp0';
  }

  @override
  String get yesterday => 'أمس';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'قبل $count يومًا',
      few: 'قبل $count أيام',
      two: 'قبل يومين',
      one: 'قبل يوم',
    );
    return '$_temp0';
  }

  @override
  String get kindXtream => 'XTREAM';

  @override
  String get kindM3u => 'M3U';

  @override
  String get kindFile => 'ملف';

  @override
  String get actionPlay => 'تشغيل';

  @override
  String get actionResume => 'استئناف';

  @override
  String get actionMoreInfo => 'المزيد';

  @override
  String get actionSearch => 'بحث';

  @override
  String get actionSeeAll => 'عرض الكل';

  @override
  String get actionAll => 'الكل';

  @override
  String get switchAccount => 'تبديل الحساب';

  @override
  String get homeContinue => 'متابعة المشاهدة';

  @override
  String get homeLiveNow => 'مباشر الآن';

  @override
  String get homeAllChannels => 'كل القنوات';

  @override
  String get homeRecentlyAdded => 'أُضيف حديثًا';

  @override
  String get homePopularMovies => 'أفلام رائجة';

  @override
  String get homePopularSeries => 'مسلسلات رائجة';

  @override
  String get homeRecommended => 'مقترحات لك';

  @override
  String get homeRecentlyWatched => 'شوهد مؤخرًا';

  @override
  String get homeFavorites => 'مفضلتك';

  @override
  String get homeManage => 'إدارة';

  @override
  String becauseYouWatched(String title) {
    return 'لأنك شاهدت $title';
  }

  @override
  String get topPicksTonight => 'أفضل اختيارات الليلة';

  @override
  String get watched => 'تمت المشاهدة';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'نهارك سعيد';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get searchHint => 'قنوات، أفلام، مسلسلات';

  @override
  String get searchHintLong => 'ابحث في القنوات والأفلام والمسلسلات';

  @override
  String seasonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count موسم',
      many: '$count موسمًا',
      few: '$count مواسم',
      two: 'موسمان',
      one: 'موسم واحد',
    );
    return '$_temp0';
  }

  @override
  String get homeEmptyTitle => 'جارٍ تحميل مكتبتك';

  @override
  String get homeEmptyBody =>
      'تظهر القنوات والأفلام والمسلسلات هنا فور جاهزية قائمتك.';

  @override
  String get moviesTitle => 'أفلام';

  @override
  String get seriesTitle => 'مسلسلات';

  @override
  String get trending => 'الأكثر رواجًا';

  @override
  String get topRated => 'الأعلى تقييمًا';

  @override
  String get recommended => 'مقترحة';

  @override
  String get popular => 'رائج';

  @override
  String get genres => 'التصنيفات';

  @override
  String get featuredBadge => 'مميّز';

  @override
  String get featuredSeries => 'مسلسل مميّز';

  @override
  String get actionDetails => 'التفاصيل';

  @override
  String resumeEpisode(int season, int episode) {
    return 'استئناف م$season · ح$episode';
  }

  @override
  String seriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مسلسل',
      many: '$count مسلسلًا',
      few: '$count مسلسلات',
      two: 'مسلسلان',
      one: 'مسلسل واحد',
      zero: 'لا مسلسلات',
    );
    return '$_temp0';
  }

  @override
  String moviesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فيلم',
      many: '$count فيلمًا',
      few: '$count أفلام',
      two: 'فيلمان',
      one: 'فيلم واحد',
      zero: 'لا أفلام',
    );
    return '$_temp0';
  }

  @override
  String get gridView => 'عرض شبكي';

  @override
  String get listView => 'عرض قائمة';

  @override
  String get actionFilter => 'تصفية';

  @override
  String get sortTitle => 'الترتيب حسب';

  @override
  String get sortPlaylist => 'ترتيب القائمة';

  @override
  String get sortRecent => 'شوهد مؤخرًا';

  @override
  String get sortRating => 'الأعلى تقييمًا';

  @override
  String get sortName => 'الاسم (أ–ي)';

  @override
  String get emptyCategoryTitle => 'لا شيء هنا بعد';

  @override
  String get emptyCategoryBody => 'هذا التصنيف فارغ في قائمتك.';

  @override
  String resumeAt(String time) {
    return 'استئناف من $time';
  }

  @override
  String get trailer => 'الإعلان';

  @override
  String get favorited => 'في المفضلة';

  @override
  String get favorite => 'المفضلة';

  @override
  String get share => 'مشاركة';

  @override
  String get markWatched => 'شاهدته';

  @override
  String get markUnwatched => 'وضع علامة «لم أشاهده»';

  @override
  String get director => 'المخرج';

  @override
  String get castLabel => 'طاقم التمثيل';

  @override
  String get released => 'تاريخ الإصدار';

  @override
  String get cast => 'طاقم التمثيل';

  @override
  String get relatedMovies => 'أفلام ذات صلة';

  @override
  String get moreLikeThis => 'المزيد من هذا النوع';

  @override
  String get moreActions => 'المزيد';

  @override
  String shareText(String title) {
    return '$title — أشاهده على أوربكس';
  }

  @override
  String seasonN(int n) {
    return 'الموسم $n';
  }

  @override
  String get episodesTitle => 'الحلقات';

  @override
  String get upNext => 'التالي';

  @override
  String get continueWatchingShort => 'متابعة المشاهدة';

  @override
  String episodeN(int n) {
    return 'الحلقة $n';
  }

  @override
  String minutesShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دقيقة',
      few: '$count دقائق',
      two: 'دقيقتان',
      one: 'دقيقة',
    );
    return '$_temp0';
  }

  @override
  String playEpisode(int season, int episode) {
    return 'تشغيل م$season · ح$episode';
  }

  @override
  String episodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حلقة',
      many: '$count حلقة',
      few: '$count حلقات',
      two: 'حلقتان',
      one: 'حلقة واحدة',
      zero: 'لا حلقات',
    );
    return '$_temp0';
  }

  @override
  String get recentSearches => 'عمليات البحث الأخيرة';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get trendingSearches => 'الأكثر بحثًا الآن';

  @override
  String get browse => 'تصفّح';

  @override
  String get browseLive => 'القنوات المباشرة';

  @override
  String get browseMovies => 'أفلام';

  @override
  String get browseSeries => 'مسلسلات';

  @override
  String get browseFavorites => 'المفضلة';

  @override
  String get filterMovies => 'أفلام';

  @override
  String get filterSeries => 'مسلسلات';

  @override
  String get filterChannels => 'قنوات';

  @override
  String get filterGenre => 'التصنيف';

  @override
  String get filterYear => 'السنة';

  @override
  String allCount(int count) {
    return 'الكل · $count';
  }

  @override
  String typeCount(String type, int count) {
    return '$type · $count';
  }

  @override
  String get kindMovie => 'فيلم';

  @override
  String get kindSeries => 'مسلسل';

  @override
  String get liveNowLabel => 'مباشر الآن';

  @override
  String get searchChannels => 'القنوات';

  @override
  String get searchTitles => 'الأفلام والمسلسلات';

  @override
  String noResultsTitle(String query) {
    return 'لا نتائج لـ«$query»';
  }

  @override
  String get noResultsBody =>
      'تحقّق من الإملاء، أو أزل عوامل التصفية للبحث في كل شيء.';

  @override
  String get clearFilters => 'مسح عوامل التصفية';

  @override
  String get listening => 'جارٍ الاستماع…';

  @override
  String get voiceHint => 'جرّب «بلس الرياضية 1» أو «مسلسلات كوميدية»';

  @override
  String get tapToStop => 'اضغط للإيقاف';

  @override
  String get voiceUnavailable => 'البحث الصوتي غير متاح على هذا الجهاز.';

  @override
  String get voiceNoPermission => 'يلزم الوصول إلى الميكروفون للبحث الصوتي.';

  @override
  String get anyYear => 'أي سنة';

  @override
  String get anyGenre => 'أي تصنيف';

  @override
  String get favoritesTitle => 'المفضلة';

  @override
  String get dragToReorder => 'اسحب لإعادة الترتيب · اضغط − للإزالة';

  @override
  String get removeFavorite => 'إزالة من المفضلة';

  @override
  String removedFromFavorites(String name) {
    return 'أُزيل $name من المفضلة';
  }

  @override
  String get noFavoritesTitle => 'لا شيء محفوظ بعد';

  @override
  String get noFavoritesBody =>
      'اضغط على القلب في أي قناة أو فيلم أو مسلسل وستجده بانتظارك هنا.';

  @override
  String get browseLiveTv => 'تصفّح البث المباشر';

  @override
  String endsAt(String time) {
    return 'ينتهي $time';
  }

  @override
  String get liveTitle => 'البث المباشر';

  @override
  String get guide => 'الدليل';

  @override
  String get allChannels => 'كل القنوات';

  @override
  String get favoritesCategory => 'المفضلة';

  @override
  String get lockedCategory => 'مقفلة';

  @override
  String nowAt(String range) {
    return 'الآن · $range';
  }

  @override
  String nextAt(String time) {
    return 'التالي · $time';
  }

  @override
  String channelNumber(String number) {
    return 'القناة $number';
  }

  @override
  String get lockedByParental => 'مقفلة بالرقابة الأبوية';

  @override
  String get noGuideData => 'لا توجد بيانات للدليل';

  @override
  String filterCategory(String name) {
    return 'تصفية $name';
  }

  @override
  String get sortChannels => 'ترتيب القنوات';

  @override
  String get sortNumber => 'رقم القناة';

  @override
  String get sortFavoritesFirst => 'المفضلة أولًا';

  @override
  String get actionFullscreen => 'ملء الشاشة';

  @override
  String get actionMute => 'كتم الصوت';

  @override
  String get actionPip => 'صورة داخل صورة';

  @override
  String get scheduleLater => 'لاحقًا';

  @override
  String get scheduleNow => 'الآن';

  @override
  String get scheduleNext => 'التالي';

  @override
  String get scheduleEnded => 'انتهى';

  @override
  String get noChannelsTitle => 'لا قنوات هنا';

  @override
  String get noChannelsBody => 'لا يحتوي هذا التصنيف على قنوات في قائمتك.';

  @override
  String get tvGuideTitle => 'دليل البرامج';

  @override
  String get pickDate => 'اختر التاريخ';

  @override
  String get filterCategories => 'تصفية التصنيفات';

  @override
  String get today => 'اليوم';

  @override
  String get tomorrow => 'غدًا';

  @override
  String get yesterdayShort => 'أمس';

  @override
  String get nowButton => 'الآن';

  @override
  String get watchNow => 'شاهد الآن';

  @override
  String get watch => 'مشاهدة';

  @override
  String get onNow => 'يُعرض الآن';

  @override
  String minLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'متبقٍ $count دقيقة',
      few: 'متبقٍ $count دقائق',
      two: 'متبقٍ دقيقتان',
      one: 'متبقٍ دقيقة',
    );
    return '$_temp0';
  }

  @override
  String updatingPercent(int percent) {
    return 'جارٍ التحديث $percent%';
  }

  @override
  String get guideEmptyTitle => 'لا توجد بيانات للدليل بعد';

  @override
  String get guideEmptyBody =>
      'لم يرسل مزوّدك دليل برامج لهذه القنوات. حدّث، أو أضف رابط EPG إلى الحساب.';

  @override
  String get refreshGuide => 'تحديث الدليل';

  @override
  String get allCategories => 'كل التصنيفات';

  @override
  String categoriesSummary(String first, int more) {
    return '$first +$more';
  }

  @override
  String guideSources(int count, String days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مصدرًا',
      few: '$count مصادر',
      two: 'مصدرين',
      one: 'مصدر واحد',
    );
    return 'بيانات الدليل من $_temp0 · $days';
  }

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get searchSettings => 'البحث في الإعدادات';

  @override
  String get activeBadge => 'نشط';

  @override
  String catalogCounts(String channels, String movies, String series) {
    return '$channels قناة · $movies فيلم · $series مسلسل';
  }

  @override
  String get refreshLists => 'تحديث القوائم';

  @override
  String get refreshingLists => 'جارٍ تحديث القوائم…';

  @override
  String get sectionGeneral => 'عام';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'لغة النظام';

  @override
  String get startScreen => 'شاشة البدء';

  @override
  String get autoplayNext => 'تشغيل الحلقة التالية تلقائيًا';

  @override
  String get autoplayNextHint => 'يبدأ بعد عدّ تنازلي من 10 ثوانٍ';

  @override
  String get sectionPlayback => 'التشغيل والمشغّل';

  @override
  String get preferredPlayer => 'المشغّل المفضّل';

  @override
  String get orbixPlayer => 'مشغّل أوربكس';

  @override
  String get hardwareDecoding => 'فك الترميز بالعتاد';

  @override
  String get hardwareDecodingHint => 'تشغيل 4K أسلس واستهلاك أقل للبطارية';

  @override
  String get audioLanguage => 'لغة الصوت';

  @override
  String get audioLanguageHint => 'اضغط حسب ترتيب التفضيل';

  @override
  String audioLanguagesValue(String first, String second) {
    return '$first، ثم $second';
  }

  @override
  String get subtitleSettings => 'إعدادات الترجمة';

  @override
  String get subtitleSize => 'الحجم';

  @override
  String get subtitleStyle => 'النمط';

  @override
  String get sizeSmall => 'صغير';

  @override
  String get sizeMedium => 'متوسط';

  @override
  String get sizeLarge => 'كبير';

  @override
  String get styleOutline => 'حدود';

  @override
  String get styleShadow => 'ظل';

  @override
  String get styleBox => 'خلفية';

  @override
  String get defaultQuality => 'الجودة الافتراضية';

  @override
  String get qualityAuto => 'تلقائي';

  @override
  String get sectionAppearance => 'المظهر';

  @override
  String get theme => 'السمة';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeAmoled => 'أسود AMOLED';

  @override
  String get themeSystem => 'النظام';

  @override
  String get sectionGuide => 'دليل البرامج (EPG)';

  @override
  String get epgSources => 'مصادر EPG';

  @override
  String epgSourcesValue(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'المزوّد + $count',
      zero: 'المزوّد',
    );
    return '$_temp0';
  }

  @override
  String get epgSourcesNone => 'لا يوجد';

  @override
  String get providerGuide => 'من مزوّدك';

  @override
  String get yourGuide => 'رابط EPG الخاص بك';

  @override
  String get epgRefresh => 'تحديث EPG';

  @override
  String lastUpdated(Object when) {
    return 'آخر تحديث $when';
  }

  @override
  String get neverUpdated => 'لم يُنزَّل بعد';

  @override
  String everyHours(num hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'كل $hours ساعة',
      few: 'كل $hours ساعات',
      two: 'كل ساعتين',
      one: 'كل ساعة',
    );
    return '$_temp0';
  }

  @override
  String get guideShift => 'إزاحة توقيت الدليل';

  @override
  String shiftHours(Object value) {
    return '$value س';
  }

  @override
  String get sectionPlaylist => 'قائمة التشغيل';

  @override
  String get autoUpdatePlaylist => 'تحديث القائمة تلقائيًا';

  @override
  String get autoUpdatePlaylistHint =>
      'عند التشغيل، مرة واحدة يوميًا على الأكثر';

  @override
  String get sectionSecurity => 'الأمان والحسابات';

  @override
  String get parentalControls => 'الرقابة الأبوية';

  @override
  String parentalSummaryOn(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'رمز PIN مفعّل · $count تصنيفًا مقفلًا',
      few: 'رمز PIN مفعّل · $count تصنيفات مقفلة',
      two: 'رمز PIN مفعّل · تصنيفان مقفلان',
      one: 'رمز PIN مفعّل · تصنيف واحد مقفل',
      zero: 'رمز PIN مفعّل',
    );
    return '$_temp0';
  }

  @override
  String get parentalSummaryOff => 'متوقفة — عيّن رمز PIN لقفل المحتوى';

  @override
  String get manageAccounts => 'إدارة حسابات IPTV';

  @override
  String get sectionStorage => 'التخزين';

  @override
  String get cache => 'ذاكرة التخزين المؤقت';

  @override
  String cacheBreakdown(String artwork, String guide, String lists) {
    return 'الصور $artwork · الدليل $guide · القوائم $lists';
  }

  @override
  String get clearCache => 'مسح ذاكرة التخزين المؤقت';

  @override
  String get clearCacheTitle => 'مسح ذاكرة التخزين المؤقت؟';

  @override
  String get clearCacheBody =>
      'تُنزَّل الصور ودليل البرامج مجددًا عند الحاجة. تبقى الحسابات والمفضلة والتقدّم كما هي.';

  @override
  String get cacheCleared => 'تم مسح ذاكرة التخزين المؤقت';

  @override
  String get sectionAbout => 'حول';

  @override
  String get version => 'الإصدار';

  @override
  String get legalNotice => 'إشعار قانوني';

  @override
  String get legalNoticeBody =>
      'أوربكس مشغّل وسائط فقط. لا يوفّر القنوات أو الأفلام أو المسلسلات ولا يستضيفها أو يبيعها. استخدمه فقط مع خدمات مخوّل بالوصول إليها.';

  @override
  String noSettingsMatch(Object query) {
    return 'لا توجد إعدادات تطابق «$query»';
  }

  @override
  String get actionSave => 'حفظ';

  @override
  String get langArabic => 'العربية';

  @override
  String get langEnglish => 'الإنجليزية';

  @override
  String get langFrench => 'الفرنسية';

  @override
  String get langSpanish => 'الإسبانية';

  @override
  String get langGerman => 'الألمانية';

  @override
  String get langTurkish => 'التركية';

  @override
  String get parentalTitle => 'الرقابة الأبوية';

  @override
  String get protectionOn => 'الحماية مفعّلة';

  @override
  String get protectionOnBody =>
      'يلزم رمز PIN للتصنيفات والقنوات المقفلة ولهذه الإعدادات.';

  @override
  String get protectionOff => 'الحماية متوقفة';

  @override
  String get protectionOffBody =>
      'فعّل الحماية برمز PIN لقفل التصنيفات والقنوات.';

  @override
  String get pinProtection => 'الحماية برمز PIN';

  @override
  String pinSetOn(Object date) {
    return 'رمز من 4 أرقام · عُيّن في $date';
  }

  @override
  String get pinNotSet => 'لم يُعيَّن رمز PIN';

  @override
  String get changePin => 'تغيير رمز PIN';

  @override
  String get adultProtection => 'حماية من محتوى البالغين';

  @override
  String get adultProtectionHint => 'إخفاء عناوين وتصنيفات +18 في كل مكان';

  @override
  String get relockAfter => 'إعادة القفل بعد';

  @override
  String minutesN(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دقيقة',
      few: '$count دقائق',
      two: 'دقيقتان',
      one: 'دقيقة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get lockedCategories => 'التصنيفات المقفلة';

  @override
  String lockedOfTotal(int locked, int total) {
    return '$locked من $total';
  }

  @override
  String get lockLocked => 'مقفل';

  @override
  String get lockOpen => 'مفتوح';

  @override
  String get toggleLock => 'تبديل القفل';

  @override
  String channelsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قناة',
      many: '$count قناة',
      few: '$count قنوات',
      two: 'قناتان',
      one: 'قناة واحدة',
      zero: 'لا قنوات',
    );
    return '$_temp0';
  }

  @override
  String hiddenSuffix(Object count) {
    return '$count · مخفية';
  }

  @override
  String get lockedChannels => 'القنوات المقفلة';

  @override
  String get actionAdd => 'إضافة';

  @override
  String get noLockedChannels => 'لا توجد قنوات مقفلة بعد';

  @override
  String get unlockChannel => 'إلغاء قفل القناة';

  @override
  String get lockChannelTitle => 'قفل قناة';

  @override
  String get enterPin => 'أدخل رمز PIN';

  @override
  String get createPin => 'أنشئ رمز PIN من 4 أرقام';

  @override
  String get confirmPin => 'أدخله مرة أخرى';

  @override
  String get newPin => 'أدخل رمز PIN جديدًا';

  @override
  String isLocked(Object name) {
    return '$name مقفلة';
  }

  @override
  String get contentLocked => 'هذا المحتوى مقفل';

  @override
  String get parentalLocked => 'إعدادات الرقابة الأبوية مقفلة';

  @override
  String get wrongPin => 'رمز PIN غير صحيح. حاول مجددًا.';

  @override
  String get pinsDontMatch => 'الرمزان غير متطابقين. ابدأ من جديد.';

  @override
  String tryAgainIn(Object seconds) {
    return 'محاولات كثيرة جدًا. انتظر $seconds ث.';
  }

  @override
  String get forgotPin => 'نسيت رمز PIN؟';

  @override
  String get forgotPinHint => 'أعد تعيينه بكلمة مرور حساب IPTV';

  @override
  String pinDigitsEntered(Object count) {
    return 'أُدخل $count من 4 أرقام';
  }

  @override
  String get a11yDelete => 'حذف';

  @override
  String get pinSaved => 'تم حفظ رمز PIN';

  @override
  String get pinRemoved => 'أُوقفت الحماية برمز PIN';

  @override
  String get resetPinTitle => 'إعادة تعيين رمز PIN';

  @override
  String resetPinBody(Object account) {
    return 'أدخل كلمة مرور «$account» لإيقاف الحماية برمز PIN.';
  }

  @override
  String get resetPinNoPassword =>
      'لا توجد كلمة مرور لهذا الحساب. احذف الحساب وأضفه مجددًا لإعادة تعيين رمز PIN.';

  @override
  String get actionReset => 'إعادة تعيين';

  @override
  String get wrongPassword => 'كلمة المرور غير مطابقة.';

  @override
  String lastUpdatedToday(Object time) {
    return 'آخر تحديث اليوم، $time';
  }

  @override
  String get accountKindXtream => 'Xtream Codes';

  @override
  String get accountKindM3u => 'قائمة M3U';

  @override
  String get accountKindFile => 'ملف قائمة تشغيل';

  @override
  String get a11ySubtitles => 'الترجمة';

  @override
  String get a11yAudioTrack => 'مسار الصوت';

  @override
  String get a11yPlaybackSettings => 'إعدادات التشغيل';

  @override
  String get a11yLockControls => 'قفل عناصر التحكم';

  @override
  String get a11yUnlockControls => 'فتح عناصر التحكم';

  @override
  String get a11yPrevEpisode => 'الحلقة السابقة';

  @override
  String get a11yNextEpisode => 'الحلقة التالية';

  @override
  String get a11yBack10 => 'رجوع 10 ثوانٍ';

  @override
  String get a11yForward10 => 'تقديم 10 ثوانٍ';

  @override
  String get a11yPause => 'إيقاف مؤقت';

  @override
  String get a11yPlay => 'تشغيل';

  @override
  String get a11yRotate => 'تدوير الشاشة';

  @override
  String get a11yExitPlayer => 'الخروج من ملء الشاشة';

  @override
  String get a11yEnterFullscreen => 'ملء الشاشة';

  @override
  String get a11yChannelUp => 'القناة السابقة';

  @override
  String get a11yChannelDown => 'القناة التالية';

  @override
  String get a11yCloseChannels => 'إغلاق قائمة القنوات';

  @override
  String get a11yBrightness => 'السطوع';

  @override
  String get a11yVolume => 'الصوت';

  @override
  String get a11ySeek => 'التنقل';

  @override
  String get aspectFit => 'ملاءمة';

  @override
  String get aspectFill => 'تمديد';

  @override
  String get aspectZoom => 'تكبير';

  @override
  String get aspect169 => '16:9';

  @override
  String get subtitlesOff => 'إيقاف';

  @override
  String get playbackSettings => 'إعدادات التشغيل';

  @override
  String get audioTrackTitle => 'مسار الصوت';

  @override
  String get subtitlesTitle => 'الترجمة';

  @override
  String get sizeAndStyle => 'الحجم والنمط';

  @override
  String get playbackSpeed => 'سرعة التشغيل';

  @override
  String get videoQuality => 'جودة الفيديو';

  @override
  String get aspectRatio => 'نسبة العرض';

  @override
  String qualityNow(Object quality) {
    return '$quality الآن';
  }

  @override
  String pausedAt(Object time) {
    return 'متوقف مؤقتًا · $time';
  }

  @override
  String playingAt(Object time) {
    return 'قيد التشغيل · $time';
  }

  @override
  String get changesApply =>
      'تُطبَّق التغييرات فورًا. تُحفظ لغتا الصوت والترجمة ونمط الترجمة.';

  @override
  String get audioMono => 'أحادي';

  @override
  String get audioStereo => 'ستيريو';

  @override
  String audioSurround(Object layout) {
    return 'محيطي $layout';
  }

  @override
  String trackN(Object n) {
    return 'المسار $n';
  }

  @override
  String get channelsChip => 'القنوات';

  @override
  String upNextIn(Object seconds) {
    return 'التالي خلال $seconds';
  }

  @override
  String get playNow => 'تشغيل الآن';

  @override
  String episodeShort(int season, int episode) {
    return 'م$season · ح$episode';
  }

  @override
  String get playbackFailedTitle => 'تعذّر تشغيل هذا البث';

  @override
  String get playbackFailedBody =>
      'لم يرسل المزوّد بثًا قابلًا للتشغيل. قد يكون متوقفًا أو مشغولًا أو غير مسموح به على هذا الاتصال.';

  @override
  String seekBackLabel(Object seconds) {
    return '−$seconds ث';
  }

  @override
  String seekForwardLabel(Object seconds) {
    return '+$seconds ث';
  }

  @override
  String get pipUnavailable => 'ميزة صورة داخل صورة غير متاحة على هذا الجهاز';

  @override
  String get goLive => 'مباشر';

  @override
  String get behindLive => 'العودة إلى المباشر';

  @override
  String durationHours(Object hours) {
    return '$hours س';
  }

  @override
  String durationHoursMinutes(int hours, String minutes) {
    return '$hours س $minutes د';
  }

  @override
  String timeLeft(Object time) {
    return 'متبقٍ $time';
  }

  @override
  String get offlineBanner => 'لا يوجد اتصال';

  @override
  String get networkSettings => 'إعدادات الشبكة';

  @override
  String get retryingAutomatically => 'إعادة المحاولة تلقائيًا';

  @override
  String get retryNow => 'أعد المحاولة الآن';

  @override
  String get statusLabel => 'الحالة';

  @override
  String get statusExpired => 'منتهٍ';

  @override
  String get statusDisabled => 'معطّل';

  @override
  String get refreshStatus => 'تحديث الحالة';

  @override
  String get useAnotherAccount => 'استخدام حساب آخر';

  @override
  String get signInFailedTitle => 'تعذّر تسجيل الدخول';

  @override
  String noResultsFiltered(Object filter) {
    return 'تحقّق من الإملاء، أو أزل عامل التصفية «$filter» للبحث في كل شيء.';
  }

  @override
  String get addedToFavorites => 'أُضيف إلى المفضلة';

  @override
  String playlistUpdated(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم تحديث القائمة · $count قناة جديدة',
      few: 'تم تحديث القائمة · $count قنوات جديدة',
      two: 'تم تحديث القائمة · قناتان جديدتان',
      one: 'تم تحديث القائمة · قناة جديدة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get streamUnavailable => 'البث غير متاح';

  @override
  String cacheClearedFreed(Object size) {
    return 'تم مسح ذاكرة التخزين المؤقت · تحرير $size';
  }

  @override
  String get reconnectingStream => 'جارٍ إعادة الاتصال بالبث…';

  @override
  String get controlsLockedTap => 'عناصر التحكم مقفلة · اضغط لفتحها';
}
