# Movielist — تفاصيل المشروع الكاملة

هذا الملف يوثّق **كل ما يخص المشروع تقريبًا**: الفكرة، الشاشات، الهيكل، الحزم، التكامل مع TMDB، والأصول. مُحدَّث وفقًا لمحتوى المستودع الحالي.

---

## 1. نظرة عامة

| البند | القيمة |
|--------|--------|
| **اسم الحزمة (pubspec)** | `movielist` |
| **اسم التطبيق (واجهة)** | MovieList |
| **الإصدار** | `1.0.0+1` |
| **منصات Flutter** | Android + iOS (وما يدعمه Flutter من المنصات الأخرى عند البناء) |
| **الفكرة** | تطبيق لاستكشاف **أفلام ومسلسلات** عبر **The Movie Database (TMDB)**، مع تسجيل دخول للحساب، مفضلات، قوائم مخصصة، وبحث وتصنيفات. |

---

## 2. متطلبات البيئة

- **Dart SDK**: `^3.9.2` (محدد في `pubspec.yaml` → `environment.sdk`)
- **Flutter**: إصدار مستقر يتوافق مع Dart 3.9+
- **حساب TMDB**: لإنشاء مفاتيح API واستخدام ميزات الحساب (مفضلات، قوائم، بحث متعدد الوسائط حسب منطق التطبيق)

---

## 3. الحزم (Dependencies)

### 3.1 حزم رئيسية (`dependencies` في `pubspec.yaml`)

| الحزمة | الإصدار (المحدد في pubspec) | الاستخدام الفعلي في المشروع |
|--------|-----------------------------|--------------------------------|
| `flutter` (SDK) | — | إطار الواجهة |
| `cupertino_icons` | ^1.0.8 | أيقونات iOS-style عند الحاجة |
| `auto_size_text` | ^3.0.0 | نصوص تتكيف مع المساحة — مستخدم في `custom_button.dart` و `profile_item.dart` |
| `flutter_slidable` | ^4.0.3 | سحب عناصر القوائم (مثل حذف/إجراءات) — مستخدم في `list_item.dart` |
| `flutter_svg` | ^2.2.2 | عرض شعار SVG — مستخدم في Splash، Login، Home AppBar، إلخ |
| `font_awesome_flutter` | ^10.12.0 | **موجود في pubspec** — **لا يوجد استيراد/استخدام حالي في مجلد `lib/`** |
| `shared_preferences` | ^2.5.4 | حفظ `session_id` محليًا بعد تسجيل الدخول (TMDB) |
| `tmdb_api` | ^2.2.3 | **موجود في pubspec** — **لا يوجد استيراد في `lib/`**؛ الاتصال بـ TMDB يتم عبر حزمة `http` داخل `TmdbService` |
| `webview_flutter` | ^4.13.0 | شاشة التسجيل (`SignupScreen`) تحمّل صفحة `themoviedb.org/signup` داخل WebView |

### 3.2 حزم تطوير (`dev_dependencies`)

| الحزمة | الغرض |
|--------|--------|
| `flutter_test` | اختبارات Flutter الافتراضية |
| `flutter_lints` | قواعد التحليل الثابت (مفعّل عبر `analysis_options.yaml`) |
| `flutter_launcher_icons` | توليد أيقونات المشغّل (إعداد `flutter_icons` في `pubspec.yaml`) |

### 3.3 حزم انتقالية (Transitive) مهمة

- **`http`**: تُستخدم صراحة في `lib/services/tmdb_service.dart` لطلبات REST إلى TMDB (ليست مذكورة كـ `dependency` مباشر في `pubspec.yaml`؛ تُجلب كاعتماد لحزمة أخرى — يمكن التحقق من `pubspec.lock`).

---

## 4. الأصول (Assets) والخطوط

### 4.1 Assets (`pubspec.yaml`)

- `assets/icon/movielist.svg` — الشعار
- `assets/test.jpg` — صورة اختبار/عرض
- `assets/icon/app_icon.png` — أيقونة التطبيق (لـ `flutter_launcher_icons`)

### 4.2 خطوط مخصصة

- عائلة **`Montserrat`** — أوزان من 100 إلى 900، ملفات تحت `assets/font/`
- مفعّلة في الثيم عبر `fontFamily: 'Montserrat'` في `lib/config/theme_manager.dart`

### 4.3 صور TMDB

- النماذج في `lib/data/models/models.dart` تبني روابط الصور عبر `https://image.tmdb.org/t/p/...` (مثل `w500` للبوستر و `w1280` للخلفية).

---

## 5. هيكل المشروع (ملفات `lib/`)

```
lib/
├── main.dart                 # نقطة الدخول → runApp(MovieList)
├── movielist.dart            # MaterialApp، العنوان، الثيم الداكن، home: SplashScreen
├── config/
│   └── theme_manager.dart    # CustomTheme.darkTheme() — Material 3، ألوان، حقول إدخال، شريط سفلي، إلخ
├── core/
│   ├── utils/                # app_colors, app_styles, app_strings, app_constants, app_assets, app_enums, app_extensions, social_links
│   └── widgets/              # custom_button, custom_divider
├── data/
│   └── models/
│       ├── models.dart       # AccountDetails, Avatar, Movie, TVShow, MediaItem, MovieList, …
│       └── menu_item.dart    # عناصر قائمة الملف الشخصي
├── presentation/
│   ├── views/
│   │   └── home_view.dart    # Scaffold + BottomNavBar + PageView (4 تبويبات)
│   └── widgets/
│       ├── app_bar/          # custom_app_bar, custom_search_bar
│       ├── bottom_nav_bar/   # bottom_nav_bar.dart
│       └── body/             # الشاشات الفرعية (home, search, lists, profile, details, register, splash, favorites, …)
└── services/
    └── tmdb_service.dart     # كل تكامل TMDB (HTTP + JSON + SharedPreferences)
```

---

## 6. تدفق التشغيل (Navigation)

1. **`main.dart`** → `MovieList` (`movielist.dart`).
2. **`SplashScreen`**: تأخير قصير، ثم التحقق من `TmdbService.isLoggedIn()`.
   - إذا **مسجّل** → `HomeView`.
   - إذا **لا** → `LoginScreen`.
3. **`LoginScreen`**: نموذج username/password → `TmdbService.login` → عند النجاح → `HomeView`.
   - رابط/انتقال لـ **`SignupScreen`** (WebView لصفحة التسجيل على TMDB).
4. **`HomeView`**: شريط سفلي ثابت + `PageView` بدون سحب يدوي بين الصفحات؛ التنقل بالضغط على الـ BottomNav:
   - **Home** → `HomePage`
   - **Search** → `SearchPage`
   - **Lists** → `ListsScreen()`
   - **Profile** → `ProfilePage`
5. من الشاشات المختلفة: انتقال بـ `MaterialPageRoute` إلى `MovieDetailScreen` / `TVDetailScreen` / `ListsScreen(movieId, mediaType)` / `CreateListScreen` / `ListDetailScreen` / `FavoritesScreen`، حسب السياق.

---

## 7. الميزات حسب الشاشة

### 7.1 الرئيسية (`HomePage`)

- جلب: أفلام شائعة، مسلسلات شائعة، الأعلى تقييمًا (أفلام ومسلسلات).
- عرض أقسام أفقية وبطاقات؛ تفضيل/إلغاء تفضيل من البطاقات مع مزامنة مع TMDB.
- استخدام `AutomaticKeepAliveClientMixin` للإبقاء على حالة التبويب عند التنقل.

### 7.2 البحث (`SearchPage`)

- بحث نصي عبر **`search/multi`** (فصل النتائج إلى أفلام ومسلسلات) — يتطلب جلسة مسجّلة حسب منطق `TmdbService.search`.
- تفضيلات على نتائج البحث (تحميل حالة المفضلة).
- **شبكة تصنيفات (Categories)**: عند اختيار تصنيف يتم تحميل محتوى عبر:
  - `getMoviesByGenre` لتصنيفات مثل Action (28), Comedy (35), Horror (27), Sci-Fi (878), Animation (16)، وغيرها حسب التعريف في الكود.
  - `getUpcomingMovies` و `getAiringTodayTVShows` كخيارات في الشبكة.

### 7.3 القوائم (`ListsScreen`, `CreateListScreen`, `ListDetailScreen`)

- عرض قوائم الحساب من TMDB (`getLists`).
- إنشاء قائمة (`createList`)، تفاصيل قائمة، إضافة/إزالة عناصر، تحديث/حذف قائمة (حسب الدوال في `TmdbService`).
- وضع خاص: فتح `ListsScreen` مع `movieId` و `mediaType` لإضافة فيلم/مسلسل لقائمة من شاشة التفاصيل.
- `flutter_slidable` في `list_item.dart` لإجراءات السحب.

### 7.4 المفضلة (`FavoritesScreen`)

- تبويبان: أفلام مفضلة / مسلسلات مفضلة (`getFavoriteMovies` / `getFavoriteTVShows`).
- الانتقال لتفاصيل العنصر.

### 7.5 التفاصيل (`MovieDetailScreen`, `TVDetailScreen`)

- تحميل تفاصيل كاملة (`getMovieDetails` / `getTVShowDetails`).
- حالة مفضلة، إضافة للقائمة، واجهة تفصيلية (ملخص، صور، إلخ حسب التنفيذ في الملف).

### 7.6 الملف الشخصي (`ProfilePage`)

- جلب تفاصيل الحساب عند توفر `session_id` (`getAccountDetails`).
- قائمة إعدادات (Account Settings, Notifications, …) مع صفحات فرعية مبسّطة/واجهات داخل نفس الملف أو ملفات مرتبطة.
- **Logout**: تأكيد حوار → `TmdbService.logout` (يحذف الجلسة محليًا ويستدعي API حذف الجلسة).

### 7.7 ملاحظة على `favorites_page.dart` (`ListPage`)

- يحتوي على `ListItem` بتكرار ثابت (مثال/واجهة) — **ليس** نفس تدفق `FavoritesScreen` الكامل؛ التبويب الفعلي للمفضلة في التطبيق الرئيسي يمر عبر `ListsScreen` → `FavoritesScreen` حسب التنقل في `lists_screen.dart`.

---

## 8. طبقة الخدمة — TMDB (`TmdbService`)

- **الملف**: `lib/services/tmdb_service.dart`
- **البروتوكول**: HTTPS + `http` package
- **الترويسات**: غالبًا `Authorization: Bearer ...` و `Content-Type: application/json`
- **التخزين المحلي**: `SharedPreferences` — مفتاح مثل `tmdb_session_id`

### 8.1 وظائف رئيسية (ملخص)

| المجال | أمثلة دوال |
|--------|------------|
| المصادقة | `login`, `logout`, `saveSessionId`, `getSessionId`, `isLoggedIn` |
| الحساب | `getAccountDetails`, `getAccountId` |
| بحث | `search` (multi) |
| اكتشاف محتوى | `getPopularMovies`, `getPopularTVShows`, `getTopRatedMovies`, `getTopRatedTVShows`, `getUpcomingMovies`, `getAiringTodayTVShows` |
| حسب النوع | `getMoviesByGenre`, `getTVShowsByGenre` |
| مفضلات | `addMovieToFavorites`, `addTVShowToFavorites`, `getFavoriteMovies`, `getFavoriteTVShows`, `isMovieFavorited`, `isTVShowFavorited` |
| قوائم المستخدم | `createList`, `getLists`, `getListDetails`, `addItemToList`, `removeItemFromList`, `updateList`, `deleteList` |
| تفاصيل | `getMovieDetails`, `getTVShowDetails` |

> **أمان**: المفاتيح و الـ Bearer token **مضمنة حاليًا في الكود** في `tmdb_service.dart`. للنشر العام يجب نقلها إلى `--dart-define` أو ملف إعدادات غير مُرفوع على Git وعدم مشاركة الأسرار في المستودع.

---

## 9. إدارة الحالة (State Management)

- **لا يوجد** BLoC / Riverpod / Provider كطبقة مركزية في الملفات المذكورة.
- الاعتماد على **`StatefulWidget` + `setState`** وخدمة `TmdbService` تُنشأ غالبًا كـ instance في الـ State.
- **`AutomaticKeepAliveClientMixin`** في بعض التبويبات للحفاظ على الحالة.

---

## 10. واجهة المستخدم والتصميم

- **Material Design** مع **`useMaterial3: true`**
- **ثيم داكن** موحّد عبر `AppColors` و `CustomTheme`
- **BottomNavigationBar** + **PageView** (`NeverScrollableScrollPhysics` للتمرير بين التبويبات)
- **CustomAppBar** قابل للتخصيص (ارتفاع، عناوين، TabBar في المفضلة)
- **NestedScrollView** في `FavoritesScreen` مع `TabBar` في الـ Sliver app bar

---

## 11. النماذج (Data Models) — `models.dart`

- `AccountDetails`, `Avatar`, `Gravatar`, `Tmdb`
- `Movie`, `TVShow`, `MediaItem`
- `MovieList` (قوائم TMDB)
- دوال مساعدة لروابط الصور من TMDB

---

## 12. إعدادات تحليل الكود

- **`analysis_options.yaml`**: يتضمن `package:flutter_lints/flutter.yaml`

---

## 13. أوامر مفيدة

```bash
flutter pub get
flutter analyze
flutter run
```

بناء إصدار (مثال):

```bash
flutter build apk
flutter build ios
```

---

## 14. ملفات منصة خارج `lib/` (إشارة سريعة)

- **`android/`**, **`ios/`**: إعدادات المشروع الأصلية لـ Flutter
- **`assets/`**: خطوط، أيقونات، SVG، صور
- **`test/`**: اختبار افتراضي `widget_test.dart` (إن وُجد)

---

## 15. ملخص: ما هو مذكور في `pubspec` وغير مستخدم في `lib/`

- **`tmdb_api`**: غير مستورد في الكود الحالي؛ التكامل يدوي عبر REST + `http`.
- **`font_awesome_flutter`**: غير مستخدم حاليًا في `lib/`.

يمكن إزالة الحزمتين من `pubspec.yaml` لتقليل الاعتمادات **أو** البدء باستخدامهما فعليًا في المشروع.

---

## 16. روابط خارجية ذات صلة

- [TMDB API Documentation](https://developer.themoviedb.org/docs)
- [Flutter Documentation](https://docs.flutter.dev/)

---

*آخر تحديث للتوثيق: وفقًا لحالة المستودع عند إنشاء هذا الملف.*
