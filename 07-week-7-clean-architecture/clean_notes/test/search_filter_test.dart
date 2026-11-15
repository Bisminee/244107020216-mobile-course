import 'package:clean_notes/features/notes/domain/entities/note.dart';
import 'package:clean_notes/features/notes/domain/usecases/search_notes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final notes = [
    Note(id: 1, title: 'Belanja mingguan', updatedAt: DateTime(2026, 9, 27)),
    Note(id: 2, title: 'BELANJA bulanan', updatedAt: DateTime(2026, 9, 26)),
    Note(id: 3, title: 'Tugas kampus', updatedAt: DateTime(2026, 9, 25)),
  ];

  test('filter abaikan huruf besar/kecil', () {
    expect(filterNotes(notes, 'belanja'), hasLength(2));
    expect(filterNotes(notes, 'BeLaNjA'), hasLength(2));
  });

  test('query dengan spasi di tepi tetap cocok', () {
    final result = const SearchNotes()(notes: notes, query: '  kampus  ');
    expect(result, hasLength(1));
    expect(result.first.title, 'Tugas kampus');
  });

  test('query kosong mengembalikan semua catatan', () {
    expect(filterNotes(notes, ''), hasLength(3));
    expect(filterNotes(notes, '   '), hasLength(3));
  });

  test('query tak cocok mengembalikan list kosong (empty state)', () {
    expect(filterNotes(notes, 'zzz-tak-ada'), isEmpty);
  });

  test('use case mendelegasikan ke fungsi murni', () {
    final result = const SearchNotes()(notes: notes, query: 'tugas');
    expect(result, hasLength(1));
    expect(result.first.id, 3);
  });
}
