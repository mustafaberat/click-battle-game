# Click Battle — ürün & oyun kuralları

Bu dosya **yalnızca `clickbattle`** için kritik ürün, oyun mekaniği ve tasarım dilini sabitler.  
Genel ARU Soft kuralları: `../lib/MOBILE_APP_RULES.md`.

Değişiklik yapmadan önce burayı oku. Bu kurallar geçmiş sürümün “adil his” vaadini korur.

---

## 1. Vizyon

**Click Battle** = iki tarafın aynı telefonu (veya insan vs robot) paylaştığı, dikey **versus** düellosu.

- Kimlik: **Arcade Strip** — kırmızı / cyan / sarı, Bangers + Exo 2, hazard şerit, chunky CTA.
- His: hızlı, adil, okunaklı. “Bölge büyüdü diye tıklayacak yerim kalmadı” hissi **asla** olmamalı.
- Ürün cümlesi: *Tap faster. Claim the screen.* — ama **claim = görsel zafer**, tap alanı değil.

---

## 2. Kritik oyun mekaniği (kırılmaz)

### 2.1 Görsel bölge ≠ dokunma alanı

| Katman | Ne yapar | Skora bağlı mı? |
|---|---|---|
| **Visual territory** | Kırmızı üst / mavi alt boyası; frontier çizgisi skora göre kayar | Evet |
| **Hit zone** | Üst yarı = oyuncu 2 / robot, alt yarı = oyuncu 1 (insan) | **Hayır — her zaman %50 / %50** |

**Kural:** Rakip alanı görsel olarak büyüyebilir; sen **yine de ekranın kendi yarısına** basabilmelisin.  
Hit zone’u territory flex’ine bağlamak **bug**’tır (geçmişte bozulmuştu; tekrar etme).

Implementasyon notu (`game_screen.dart`):

1. Altta `Stack`.
2. Territory `Column` → `flex` skordan gelir (görsel).
3. Üstte sabit `Column` → iki `Expanded` eşit (hit) + ortada geometrik mid.
4. Robot tıklamaları da **üst yarı geometrisinde** üretilir; görsel kırmızı şeride sıkıştırılmaz.

Aynı kural **How to Play** mini maçında da geçerli.

### 2.2 Ayna simetri (2P)

- Üst oyuncu için HUD / skor / ikon **180°** çevrilmiş okunur (telefonu çevirerek oyun).
- Alt ve üst affordance’lar eşit ağırlıkta; bir taraf “menü gibi”, diğeri “oyun gibi” olmaz.

### 2.3 Modlar

- **Single:** alt = insan (mavi), üst = robot (kırmızı). Robot zorluğu 1–10.
- **Two player:** her yarı bir insan; üst yarı da tıklanır.
- **Time target** / **Score target:** bitiş koşulu; hit zone kuralını değiştirmez.

### 2.4 Zorluk (1–10)

- Slider görsel olarak **mavi → kırmızı**; **5 ortada**.
- Track her zaman görünür (girintili kanal + gradyan). Thumb tek başına “yolsuz” kalmaz.
- Eğri: 1→1 taps/s … 8→8, 9→12, 10→16 (yaklaşık).

---

## 3. Tasarım dili (Arcade Strip) — tüm ekranlar

Tek kaynak: `lib/components/arcade_chrome.dart`.

| Token | Kullanım |
|---|---|
| `ArcadeChrome.display` (Bangers) | Başlıklar, skor, countdown, game over |
| `ArcadeChrome.ui` (Exo 2) | Buton / satır / etiket |
| `yellow` CTA | Primary aksiyon (START, READY, PLAY AGAIN) |
| `red` / `blue` | Versus taraflar + secondary chip |
| `panelBox` | Settings, setup kartları, game over kartı |
| `ArcadePill` / `HazardStrip` / `ArcadeTagline` | Ortak chrome |

**Ekran seti (hepsi aynı dil):**

1. Home  
2. Game setup (mode selection)  
3. Settings  
4. How to Play (canlı mini maç)  
5. In-game HUD + countdown  
6. Game over  

Yeni ekran eklerken Material default (gri card, Inter, mor accent) **kullanma**. Önce `ArcadeChrome` ile çiz.

---

## 4. How to Play (ürün)

- Ayrı “Next” butonlu slideshow değil.
- Akış: arena açılır → 👆 tıkla → çizgi odak → robot tıklar → çok kolay kısa tur → ~5 tıkta biter → dokunarak çık.
- Ayarlar + Home’dan erişilir.
- Metinler 10 dilde (`app_strings.dart`).

---

## 5. Lokalizasyon

Desteklenen (öncelik): `en, es, pt, zh, ja, de, fr, ko, it, tr`.  
Cihaz dili varsayılan; kullanıcı override SharedPreferences’ta.

---

## 6. Bilinçli ürün kararları

- **Arka plan müziği yok** (kaldırıldı; geri getirme talep edilmeden).
- Reklam: game over → home yolunda; hit zone / fairness’i etkilemez.
- Icon / store görselleri Arcade Strip’e uyumlu tutulmalı (sarı CTA, kırmızı-mavi versus).

---

## 7. Değişiklik checklist’i

PR / büyük diff öncesi:

- [ ] Hit zone hâlâ sabit %50/%50 mı? (görsel flex değişse bile)
- [ ] Robot tıklaması üst yarı geometrisinde mi?
- [ ] Yeni UI `ArcadeChrome` mi kullanıyor?
- [ ] Yeni string 10 dilde mi?
- [ ] How to Play hâlâ Next’siz, tap-driven mı?
- [ ] Game over settings ile aynı panel dilinde mi?

---

*Son güncelleme: sabit hit-zone + Arcade Strip birliği ürün kararı olarak kilitlemesi.*
