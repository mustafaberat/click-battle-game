# Click Battle — Firebase / GA4 Analytics

Bu belge, Firebase Analytics altyapısının nasıl açılacağını, hangi olayların gönderildiğini ve GA4’te bakılacak keşifleri açıklar.

Uygulama **Android-only**’dir (`applicationId`: `com.arusoft.clickbattle`). `ios/` klasörü yok. Firebase yapılandırması henüz yok; sahte anahtar veya sahte `google-services.json` repoya **konulmadı**. Config olmadan uygulama yine çalışır: Analytics sessizce no-op olur.

Ekranlar `FirebaseAnalytics` çağırmaz. Tüm olaylar `lib/analytics/analytics_service.dart` üzerinden geçer.

---

## 1. Sahibinin yapması gerekenler (zorunlu)

### 1.1 Firebase projesi ve GA4

1. [Firebase Console](https://console.firebase.google.com/) → **Add project**.
2. Proje adı örn. `click-battle` (veya mevcut ARU Soft projesi).
3. **Google Analytics’i etkinleştir** ve bir GA4 property bağla (yeni property oluşturabilirsiniz).
4. Analytics location / veri paylaşımı ayarlarını kaydedin.

### 1.2 Android uygulamasını kaydet

1. Project Overview → **Add app** → Android.
2. **Android package name:** `com.arusoft.clickbattle`  
   (kaynak: `android/app/build.gradle.kts` → `applicationId`)
3. App nickname: `Click Battle`.
4. Debug signing SHA-1 isteğe bağlıdır (Analytics için gerekmez; Dynamic Links / Phone Auth için gerekir).
5. **google-services.json** dosyasını indirin.
6. Dosyayı şuraya koyun (adı tam olarak `google-services.json` olsun):

   ```
   android/app/google-services.json
   ```

7. Bu dosya gizli bir API secret içermez; Firebase’in önerisi onu commit etmektir. Sahte/placeholder değer yazmayın.

Gradle Google Services eklentisi **yalnızca bu dosya varsa** uygulanır. Dosya yokken `flutter build` / `flutter run` kırılmaz; Analytics kapalı kalır.

### 1.3 FlutterFire configure (önerilen)

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=<firebase-project-id> --platforms=android
```

Bu komut:

- `android/app/google-services.json` üretir / günceller
- `lib/firebase_options.dart` üretir (`DefaultFirebaseOptions`)

`firebase_options.dart` **şu an kodda import edilmez.** Uygulama Android’de `Firebase.initializeApp()` çağırır; native plugin `google-services.json` okur. `flutterfire configure` çalıştırdıktan sonra üretilen `firebase_options.dart` dosyasını commit edebilirsiniz (gerçek proje değerleriyle). Placeholder / uydurma key commit etmeyin.

İsterseniz ileride init’i şöyle güncelleyebilirsiniz:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

Şimdiki kod, dosya yokken de derlenir ve config yoksa yakalanan hatayla no-op’a düşer.

### 1.4 Google Analytics 4 — özel tanımlar

Firebase Console → **Analytics → Custom definitions**:

| Tür | Parametre / property | Kapsam | Örnek kullanım |
|---|---|---|---|
| Custom dimension | `player_mode` | Event | vs_ai / vs_friend |
| Custom dimension | `game_type` | Event | time / score |
| Custom dimension | `winner` | Event | player / robot / player1 / player2 / tie |
| Custom dimension | `source` | Event | home / settings |
| Custom dimension | `screen` | Event | geri tuşu kaynağı |
| Custom dimension | `ad_placement` | Event | home_banner / gameover_home |
| Custom dimension | `stage` | Event | load / show / not_ready |
| Custom metric | `duration_sec` | Event | maç süresi |
| Custom metric | `total_taps` | Event | toplam tık |
| Custom metric | `player1_score` | Event | alt oyuncu skoru |
| Custom metric | `player2_score` | Event | üst / robot skoru |
| Custom metric | `difficulty` | Event | 1–10 |
| User property | `player_mode` | User | son tercih |
| User property | `game_type` | User | son tercih |
| User property | `app_language` | User | en, tr, … |
| User property | `last_difficulty` | User | "1"…"10" |
| User property | `sound_on` | User | true / false |
| User property | `music_on` | User | true / false (UI’da müzik kapalı) |

Boyutlar raporda görünmesi için kaydedilmelidir; aksi halde DebugView’de görünür, keşiflerde kısıtlı kalır.

### 1.5 AdMob bağlantısı (opsiyonel)

AdMob uygulaması zaten `ca-app-pub-1508520223269936~7354217156`. Firebase ↔ AdMob link’i otomatik `ad_impression` benzeri olaylar da üretebilir. Aşağıdaki katalogdaki `banner_*` / `interstitial_*` olayları **bizim sarmalayıcımızın** olaylarıdır; reklam sıklığını değiştirmezler.

---

## 2. DebugView

Cihazı Analytics DebugView’e bağlamak için paket adı:

```bash
adb shell setprop debug.firebase.analytics.app com.arusoft.clickbattle
```

Kapatmak:

```bash
adb shell setprop debug.firebase.analytics.app .none.
```

Sonra uygulamayı USB debug ile çalıştırın. Firebase Console → **Analytics → DebugView**. Olaylar birkaç saniye içinde düşmelidir.

Logcat (verbose):

```bash
adb shell setprop log.tag.FA VERBOSE
adb shell setprop log.tag.FA-SVC VERBOSE
adb logcat -v time -s FA FA-SVC
```

---

## 3. Kod mimarisi

| Dosya | Görev |
|---|---|
| `lib/analytics/analytics_service.dart` | Ekranların kullandığı tek API |
| `lib/analytics/analytics_events.dart` | Olay / parametre / ekran / user property sabitleri |
| `lib/analytics/analytics_sanitizer.dart` | snake_case, 40 karakter, reserved prefix koruması |
| `lib/analytics/firebase_analytics_backend.dart` | Firebase çağrıları |
| `lib/analytics/analytics_navigator_observer.dart` | Named route `screen_view` |
| `lib/main.dart` | `initialize()` `runApp` öncesi; hata → no-op |

`google-services.json` yoksa veya `Firebase.initializeApp()` fırlatırsa uygulama açılır; `debugPrint` ile loglanır.

### Oyunda olmayan kontroller

Kod tabanı tarandı. Şu an **yok**, bu yüzden olay da yok:

- Oyun içi pause
- Skor paylaş (WhatsApp vb. `.todo.md`’de fikir olarak duruyor)
- Settings’te ses / müzik anahtarı (müzik ürün kararıyla kapatıldı). `AppManager.setSoundEnabled` / `setMusicEnabled` çağrılırsa `toggle_sound` / `toggle_music` yine gider.

---

## 4. Olay kataloğu

Otomatik GA4 olayları (`first_open`, `session_start`, `user_engagement`, `app_update` …) ayrıca gelir; aşağıya yazılmaz.

`screen_view` Firebase’in önerilen API’si ile (`logScreenView`) gönderilir; özel `logEvent('screen_view')` kullanılmaz.

| Olay | Ne zaman | Parametreler |
|---|---|---|
| `screen_view` | Named route push / replace / pop-to (`/`, `/settings`, `/mode_selection`, `/how_to_play`, `/game`). Game over overlay ayrıca `game_over` | `firebase_screen` = `home`, `settings`, `mode_selection`, `how_to_play`, `game`, `game_over` |
| `home_reached` | HomeScreen oluşunca (açılış veya settings’ten replacement) | — |
| `tap_start` | Home sarı CTA (Tap to start / mode seçimine gidiş) | — |
| `tap_settings` | Home → Ayarlar | — |
| `tap_how_to_play` | Home veya Settings How to Play | `source`: `home` \| `settings` |
| `tap_back` | Mode setup veya Settings geri | `screen`: `mode_selection` \| `settings` |
| `select_player_mode` | vs AI / vs arkadaş kutusu | `player_mode`: `vs_ai` \| `vs_friend` |
| `select_game_type` | Time attack / Survival | `game_type`: `time` \| `score` |
| `select_limit` | 10/30/60 sn veya 10/50/100 puan | `game_type`, `value` |
| `tap_start_battle` | START BATTLE | `player_mode`, `game_type`, `time_limit`, `score_limit`, `difficulty` (yalnız vs_ai) |
| `game_start` | 3-2-1 countdown bitince, maç gerçekten başlayınca | `player_mode`, `game_type`, `time_limit`, `score_limit`, `difficulty` (vs_ai), `rematch` (0/1) |
| `game_end` | Süre/skor hedefi doldu | `player_mode`, `game_type`, `time_limit`, `score_limit`, `difficulty`, `winner`, `duration_sec`, `player1_score`, `player2_score`, `total_taps` |
| `game_quit` | Maç bitmeden GameScreen dispose (sistem geri vb.) | game_end alanları + `during_countdown` (0/1); `winner` yok |
| `tap_rematch` | Game over → Play again | — |
| `tap_back_home` | Game over → Back to home (interstitial öncesi) | — |
| `tap_rate_app` | Settings → Rate | — |
| `change_language` | Dil dropdown | `language` |
| `toggle_sound` | `AppManager.setSoundEnabled` | `enabled` (0/1) |
| `toggle_music` | `AppManager.setMusicEnabled` | `enabled` (0/1) |
| `tutorial_begin` | How to Play açılınca | — |
| `tutorial_complete` | Mini maç ~5 tıkta bitince | `player1_score`, `player2_score` |
| `tutorial_skip` | How to Play kapat (bitmeden) | — |
| `tutorial_replay` | Demo replay | — |
| `tutorial_got_it` | Demo “got it” | — |
| `banner_loaded` | Home banner yüklendi | `ad_placement` = `home_banner` |
| `banner_failed` | Banner yüklenemedi | `ad_placement`, `error_code`, `error_message` |
| `interstitial_shown` | Game over → home interstitial gösterildi | `ad_placement` = `gameover_home` |
| `interstitial_dismissed` | Interstitial kapandı | `ad_placement` |
| `interstitial_failed` | Yükleme / gösterme / hazır değil | `ad_placement`, `stage` (`load` \| `show` \| `not_ready`), `error_code`, `error_message` |

`winner` değerleri:

- vs_ai: `player` / `robot` / `tie`
- vs_friend: `player1` / `player2` / `tie`

Zorluk slider’ı her kaydırmada olay **göndermez** (spam olmasın). Seçim `tap_start_battle` ve `game_start` içindeki `difficulty` parametresindedir.

---

## 5. Kullanıcı özellikleri

| Property | Kaynak | Değer |
|---|---|---|
| `app_language` | Açılış + dil değişimi | `en`, `es`, `pt`, `zh`, `ja`, `de`, `fr`, `ko`, `it`, `tr` |
| `sound_on` | Ayarlar servisi | `true` / `false` |
| `music_on` | Ayarlar servisi | `true` / `false` |
| `player_mode` | Mode seçimi / START BATTLE | `vs_ai` / `vs_friend` |
| `game_type` | Mode seçimi / START BATTLE | `time` / `score` |
| `last_difficulty` | START BATTLE (vs_ai) | `"1"` … `"10"` |

---

## 6. Önerilen GA4 keşifleri / huniler

### 6.1 İlk maça gidiş (activation)

Huni:

1. `home_reached` (veya `screen_view` / `home`)
2. `tap_start`
3. `select_player_mode` (opsiyonel adım)
4. `tap_start_battle`
5. `game_start`
6. `game_end`

Kırılım: `player_mode`, `game_type`.  
`tap_start_battle` var, `game_start` yok → countdown’ta terk.  
`game_start` var, `game_end` yok → `game_quit` oranı.

### 6.2 Rematch / retention sinyali

Huni: `game_end` → `tap_rematch` → `game_start` (`rematch=1`).

Aynı oturumda 2+ `game_start` = oturum içi tekrar oynama. D1/D7 için GA4 Retention + `game_end` kullanın.

### 6.3 How to Play etkisi

Karşılaştırma: `tutorial_complete` gören kullanıcı vs görmeyen.

Huni: `tap_how_to_play` → `tutorial_begin` → `tutorial_complete` (veya `tutorial_skip`) → `tap_start_battle`.

`tutorial_skip` yüksekse demo erken sıkıyor olabilir.

### 6.4 Reklam etkisi (sıklığı değiştirmeden)

- `game_end` → `tap_back_home` → `interstitial_shown` → `interstitial_dismissed`
- `interstitial_failed` / `stage=not_ready` payı (fill)
- `banner_loaded` vs `banner_failed` (home)
- Interstitial gören vs görmeyen kullanıcıların bir sonraki `game_start` oranı (reklamın rematch’i öldürüp öldürmediği)

Bu olaylar yalnızca mevcut AdMob callback’lerine bağlanır; preload / timeout / show sıklığı aynıdır.

### 6.5 Dil ve zorluk

- `app_language` × `game_end` (hangi dilde bitirme var)
- `last_difficulty` × `winner=robot` (çok zor mu?)

---

## 7. Sürüm notu

`firebase_core` ^5.1.0 ve `firebase_analytics` ^13.0.1, projenin Flutter ≥ 3.35 / Dart 3.11 kilidi ve `google_mobile_ads` ^6 ile uyumludur (FlutterFire BoM 5.1, Dart ≥ 3.6, Flutter ≥ 3.27).
