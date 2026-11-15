# Review Checklist - Mid Project Review (Minggu 8)

## 1. Audit Riwayat Git

Perintah yang dijalankan:
```
git log --oneline -15
git branch -a
git status
```

Temuan:
| Temuan | Bukti | Tindakan |
|---|---|---|
| Commit langsung ke `main` (belum ada `develop`) | `git branch` hanya `main` sebelum minggu 8 | Dibuat `develop` dari `main`, semua kerja fitur lewat `feature/*` |
| Pesan commit tidak konvensional | `34aeb3e` (kosong), `5d3e631 week 5`, `f3b0cdc update readme` | Ditulis ulang di tabel bagian 2 (simulasi, tanpa rewrite history publik) |
| Branch fitur menumpuk | `feat/notes-search`, `feat/ai-assistant`, `perf/optimizations` | Semua sudah di-merge lalu dihapus (`git fetch --prune` bersih) |
| File tak terlacak | `git status` bersih setelah commit | `.gitignore` menutup `build/`, `.dart_tool/`, `google-services.json` |

## 2. Tiga Commit Buruk -> Format Konvensional (simulasi)

| Sebelum | Sesudah | Alasan |
|---|---|---|
| `34aeb3e` (pesan kosong) | `chore(week-6): snapshot project sebelum setup Firebase` | Tanpa pesan, reviewer tidak tahu isi perubahan; `chore` tepat karena hanya konfigurasi |
| `5d3e631 week 5` | `feat(notes): scaffold project week5_offline_notes + dependency` | Menyebut Scope (`notes`) dan isi perubahan, bukan hanya nomor minggu |
| `f3b0cdc update readme` | `docs(week-3): lengkapi README praktikum + screenshot` | `update` tidak informatif; `docs` + scope + isi memudahkan pencarian riwayat |

Catatan: pesan lama **tidak ditulis ulang di history publik** (agar tidak memaksa force-push dan merusak kolaborasi); perbaikan dicatat di sini sebagai latihan disiplin.

## 3. Bukti GitFlow + Pull Request

| Item | Bukti |
|---|---|
| Issue | [#1 feat(notes): pencarian judul catatan + empty state](https://github.com/Bisminee/244107020216-mobile-course/issues/1) (closed) |
| PR #2 | [feat(notes): tambah pencarian judul + empty state + test](https://github.com/Bisminee/244107020216-mobile-course/pull/2) — merged ke `develop` |
| PR #3 | [feat(assistant): integrasi Gemini chat + secure API key + fallback](https://github.com/Bisminee/244107020216-mobile-course/pull/3) — merged |
| PR #4 | [perf: scoped rebuild + test bukti](https://github.com/Bisminee/244107020216-mobile-course/pull/4) — merged |
| Branch | `main` (rilis), `develop` (integrasi), `feat/*`, `perf/*` |
| Ukuran PR | PR #2 mengubah 10 file (±300 baris termasuk test + screenshot); PR #3/#4 lebih kecil |

## 4. Review Sejawat (simulasi 15 menit)

Reviewer mensyaratkan minimal 2 temuan kebenaran, 1 arsitektur, 1 test + 1 saran baca.

**PR #2 (search notes):**
| # | Level | Temuan | Tindak lanjut |
|---|---|---|---|
| 1 | blocker | `TextEditingController` di `_showAddDialog` tidak di-dispose | **Diterima**, diperbaiki (`whenComplete` dispose) |
| 2 | saran | Widget test belum menguji tombol clear | **Diterima**, tambah test `tombol clear mengembalikan daftar lengkap` |
| 3 | ditolak | Debounce input | **Ditolak**: filter in-memory, debounce hanya menambah delay |

Keputusan awal: **Request changes** -> diperbaiki -> **Approve** -> merge (commit `aaaefae`).

**PR #3 (asisten AI):**
| # | Level | Temuan | Tindak lanjut |
|---|---|---|---|
| 1 | blocker | `retry()` memanggil `ask()` sehingga pesan user terduplikasi | **Diterima**, pisah `_send(..., appendUser: false)` + test |
| 2 | saran | API key terlalu pendek tetap tersimpan | **Diterima**, validasi minimal 20 karakter |
| 3 | ditolak | Streaming SSE | **Ditolak**: kompleksitas tinggi untuk satu halaman |

**PR #4 (performa):**
| # | Level | Temuan | Tindak lanjut |
|---|---|---|---|
| 1 | saran kuat | `RepaintBoundary` di sekitar `ListView` placebo (Viewport sudah punya boundary sendiri) | **Diterima**, wrapper dihapus |
| 2 | diterima | `select` + ekstrak `_DirtyBanner` terbukti mengurangi rebuild | Dipertahankan |
| 3 | ditolak | Pagination daftar catatan | **Ditolak**: data lokal kecil |

## 5. Kesiapan Paruh Semester

| Kriteria | Status | Bukti |
|---|---|---|
| Struktur feature-first | ✅ | 3 fitur (`notes`, `announcements`, `assistant`) + `settings`; grep sterilitas nol (Minggu 7) |
| `flutter analyze` | ✅ | No issues found |
| `dart format --set-exit-if-changed` | ✅ | 0 file berubah |
| `flutter test` | ✅ | 29 test lulus |
| PR kecil + commit jelas | ✅ | PR #2, #3, #4 merged via review |
| README + screenshot + cara jalan | ✅ | README tiap minggu |
| Komentar review ditindaklanjuti | ✅ | 3 blocker diperbaiki + test bukti |
| CI menolak PR kotor | ✅ | `.github/workflows/ci.yml` |

## 6. Peta Issue/PR
```
Issue #1 (search notes)
  └─ branch feat/notes-search
       └─ PR #2 (review: request changes -> approve) -> merged ke develop
            └─ commit fix review aaaefae

feat/ai-assistant -> PR #3 (request changes -> approve) -> develop
perf/optimizations -> PR #4 (request changes -> approve) -> develop
develop -> main (release akhir minggu)
```
