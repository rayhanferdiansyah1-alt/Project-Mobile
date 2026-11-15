# UI aplikasi SPK WIP Bodi & Cat

Layar cukup satu baris import:

```dart
import '../../ui/ui.dart'; // sesuaikan jumlah ../ dengan kedalaman folder
```

## Persiapan (sekali saja)

Font memakai Plus Jakarta Sans lewat paket `google_fonts`:

```
flutter pub add google_fonts
```

## Struktur

| File | Isi |
|---|---|
| `ui.dart` | Pintu masuk tunggal (export semua di bawah) |
| `layout.dart` | `AppContent` untuk lebar konten responsif di layar besar |
| `theme/app_colors.dart` | Semua warna, `StatusLevel`, `AppColors.status()` |
| `theme/app_text.dart` | Skala tipografi `AppText` |
| `theme/app_effects.dart` | `AppRadius`, `AppMotion`, `AppShadows`, `appCardDecoration()` |
| `theme/app_theme.dart` | `AppTheme.light()` + transisi halaman |
| `motion.dart` | `Pressable`, `FadeSlideIn`, `StaggeredFadeIn`, `CountUpText`, `Shake`, `PulsingDot` |
| `headers.dart` | `AppHeader`, `KbHeader`, `SaHeader`, `PartmanHeader`, `FormHeader`, `DetailHeader`, `AppUserMenu` |
| `cards.dart` | `PriorityCard`, `SaUnitCard`, `PartmanUnitCard`, `InfoPair` |
| `scoring.dart` | `ScoreRing`, `ScoreSummary`, `TotalScoreCard`, `CriteriaTile` |
| `forms.dart` | `AppButton`, `CancelSaveButtons`, `WideActionButton`, `AppFab`, `SegmentFilter`, `WipSearchBar`, `FieldBox` |
| `status.dart` | `StatusChip`, sumber opsi status, pilihan dan editor status bersama |
| `feedback.dart` | `showAppSnackbar`, `showDeleteConfirmDialog`, `EmptyState`, `SkeletonList`, `PageSkeleton` |
| `auth.dart` | `LoginHero`, `LoginGreeting`, `FieldLabel`, dekorasi field, `LoginErrorBanner` |

## Palet (60-30-10, terang)

| Peran | Warna |
|---|---|
| Latar | oatmeal `#ECEAE1` |
| Kartu | `#F7F6F0` |
| Header dan fill lembut | sage `#C8D5C2` / `#DDE6D6` |
| Aksen | teal laut `#3A7684` |
| Teks utama / redup | `#1F2A2B` / `#566265` |

Status memakai hijau, kuning, merah kalem dan selalu membawa ikon + teks.
Jangan menulis `Color(0x...)` atau `Colors.grey` di layar; tambahkan token
di `app_colors.dart`.

## Aturan

- Satu keluarga font, ukuran teks minimum 11,5.
- Status selalu lewat `StatusChip`.
- Elemen yang bisa ditekan dibungkus `Pressable` (atau `AppButton`).
- Daftar yang muncul bertahap memakai `StaggeredFadeIn`.
- Pesan ke pengguna lewat `showAppSnackbar` (bukan `SnackBar` polos).
- Gunakan `AppContent` agar daftar dan formulir tidak melebar berlebihan di desktop.
- Gerakan UI memakai `AppMotion`; animasi dibuat singkat dan konsisten.
