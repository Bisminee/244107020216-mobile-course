import 'package:clean_notes/core/format.dart';
import 'package:clean_notes/features/notes/data/models/note_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('format', () {
    test('formatDateTime menghasilkan tanggal yang mudah dibaca', () {
      final value = DateTime(2026, 9, 27, 7, 30);
      expect(formatDateTime(value), contains('September'));
      expect(formatDateTime(value), contains('2026'));
    });

    test('formatRelative memakai "baru saja" untuk waktu dekat', () {
      final now = DateTime(2026, 9, 27, 12);
      expect(
        formatRelative(now.subtract(const Duration(seconds: 10)), now: now),
        'baru saja',
      );
      expect(
        formatRelative(now.subtract(const Duration(minutes: 5)), now: now),
        '5 menit lalu',
      );
      expect(
        formatRelative(now.subtract(const Duration(days: 2)), now: now),
        '2 hari lalu',
      );
    });
  });

  group('NoteModel', () {
    test('fromMap aman terhadap field yang hilang', () {
      final model = NoteModel.fromMap({'title': 'Belanja'});
      expect(model.title, 'Belanja');
      expect(model.body, '');
      expect(model.dirty, isFalse);
      expect(model.id, isNull);
    });

    test('flag dirty bertahan pada serialisasi', () {
      final model = NoteModel(
        title: 'a',
        updatedAt: DateTime(2026, 9, 27),
        dirty: true,
      );
      final restored = NoteModel.fromMap(model.toMap());
      expect(restored.dirty, isTrue);
      expect(restored.updatedAt, DateTime(2026, 9, 27));
    });

    test('toEntity melepas tipe model (batas data ke domain)', () {
      final model = NoteModel(
        id: 3,
        title: 'a',
        body: 'b',
        updatedAt: DateTime(2026, 9, 27),
        dirty: true,
      );
      final entity = model.toEntity();
      expect(entity.id, 3);
      expect(entity.title, 'a');
      expect(entity.dirty, isTrue);
    });
  });
}
