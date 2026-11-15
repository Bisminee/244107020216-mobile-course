import '../entities/note.dart';

/// Fungsi murni: filter catatan berdasarkan judul.
/// - case-insensitive
/// - spasi di awal/akhir diabaikan
/// - query kosong mengembalikan semua catatan
List<Note> filterNotes(List<Note> notes, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return notes;
  return notes.where((note) => note.title.toLowerCase().contains(q)).toList();
}

/// Use case pencarian: aturan filter tinggal di domain (murni, bisa diuji
/// tanpa widget/database).
class SearchNotes {
  const SearchNotes();

  List<Note> call({required List<Note> notes, required String query}) {
    return filterNotes(notes, query);
  }
}
