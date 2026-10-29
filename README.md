# Click Battle

Competitive vertical tapping duel (Flutter). Arcade Strip UI.

**Ürün & oyun kuralları (kritik — oku):** [`CLICKBATTLE.md`](./CLICKBATTLE.md)

Ortak ARU Soft kuralları: [`../lib/MOBILE_APP_RULES.md`](../lib/MOBILE_APP_RULES.md)

## Features

- Single Player (vs AI, difficulty 1–10) / Two Players
- Time Target & Score Target
- Fixed 50/50 hit zones (visual territory grows separately)
- Arcade Strip design language on every screen
- 10 languages (en, es, pt, zh, ja, de, fr, ko, it, tr)
- In-game How to Play mini match

## Analytics (Firebase / GA4)

Altyapı kodda; Firebase projesi ve `google-services.json` henüz yok. Config olmadan uygulama çalışır, olaylar no-op olur.

Kurulum, olay kataloğu, DebugView ve huniler: [`docs/ANALYTICS.md`](./docs/ANALYTICS.md)

```bash
adb shell setprop debug.firebase.analytics.app com.arusoft.clickbattle
```

## Run (web)

```bash
APP_ROOT=. ../lib/scripts/run_web.sh
```
