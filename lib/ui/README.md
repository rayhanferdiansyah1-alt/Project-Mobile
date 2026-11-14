# Folder `ui/` -- satu pintu untuk semua tampilan

Aturan: layar di `screens/` hanya merangkai komponen dan menjalankan logika.
Warna, gradien, bayangan, dan widget tampilan didefinisikan di sini.

```
ui/
├── theme/        app_colors (semua warna kustom), app_effects (gradien & bayangan), app_theme (ThemeData)
└── components/
    ├── headers/  curved_header (+RoleBadge, HeaderTitle), partman/sa/kb/form/detail_header
    ├── cards/    partman_unit_card, sa_unit_card, priority_card
    ├── auth/     login_hero, login_card, auth_input_decoration, gradient_login_button, ...
    └── ...       pill_tabs, status_pill, status_option, status_update_sheet_view,
                  cancel_save_buttons, score_ring, criteria_tile, dll.
```

Mau ganti warna brand / status? Edit `theme/app_colors.dart`.
Mau ubah bentuk header? Edit `headers/curved_header.dart`.
