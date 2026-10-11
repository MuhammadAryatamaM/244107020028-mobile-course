// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notify/features/announcements/domain/repositories/i_announcement_repository.dart';
import 'package:campus_notify/features/announcements/domain/usecases/get_announcements_usecase.dart';
import 'package:campus_notify/features/announcements/domain/usecases/get_announcement_detail_usecase.dart';

// Mock

class MockAnnouncementRepository extends Mock
    implements IAnnouncementRepository {}

// Test Data

final testAnnouncements = [
  Announcement(
    id: '1',
    title: 'Pengumuman 1',
    body: 'Isi pengumuman 1',
    updatedAt: DateTime(2026, 1, 15, 10, 0),
    imageUrl: 'https://example.com/image1.jpg',
  ),
  Announcement(
    id: '2',
    title: 'Pengumuman 2',
    body: 'Isi pengumuman 2',
    updatedAt: DateTime(2026, 1, 16, 14, 30),
    imageUrl: null,
  ),
];

final testAnnouncement = Announcement(
  id: '1',
  title: 'Pengumuman 1',
  body: 'Isi pengumuman 1',
  updatedAt: DateTime(2026, 1, 15, 10, 0),
  imageUrl: 'https://example.com/image1.jpg',
);

const testId = '1';
const testNotFoundId = '999';

void main() {
  group('GetAnnouncementsUseCase', () {
    late MockAnnouncementRepository mockRepository;
    late GetAnnouncementsUseCase useCase;

    setUp(() {
      mockRepository = MockAnnouncementRepository();
      useCase = GetAnnouncementsUseCase(mockRepository);
    });

    test('sukses: mengembalikan daftar pengumuman', () async {
      when(() => mockRepository.fetchAnnouncements()).thenAnswer(
        (_) async => (announcements: testAnnouncements, failure: null),
      );

      final result = await useCase();

      expect(result.announcements, equals(testAnnouncements));
      expect(result.failure, isNull);
      verify(() => mockRepository.fetchAnnouncements()).called(1);
    });

    test('gagal: mengembalikan NetworkFailure saat repo error', () async {
      const failure = NetworkFailure('Connection timeout');

      when(() => mockRepository.fetchAnnouncements()).thenAnswer(
        (_) async => (announcements: <Announcement>[], failure: failure),
      );

      final result = await useCase();

      expect(result.announcements, isEmpty);
      expect(result.failure, equals(failure));
      expect(result.failure, isA<NetworkFailure>());
    });
  });

  group('GetAnnouncementDetailUseCase', () {
    late MockAnnouncementRepository mockRepository;
    late GetAnnouncementDetailUseCase useCase;

    setUp(() {
      mockRepository = MockAnnouncementRepository();
      useCase = GetAnnouncementDetailUseCase(mockRepository);
      registerFallbackValue('1');
    });

    test('sukses: mengembalikan detail pengumuman', () async {
      when(() => mockRepository.fetchAnnouncementDetail('1')).thenAnswer(
        (_) async => (announcement: testAnnouncement, failure: null),
      );

      final result = await useCase('1');

      expect(result.announcement, isNotNull);
      expect(result.announcement!.id, equals('1'));
      expect(result.failure, isNull);
      verify(() => mockRepository.fetchAnnouncementDetail('1')).called(1);
    });

    test('gagal: mengembalikan NotFoundFailure saat ID tidak ada', () async {
      const failure = NotFoundFailure('Announcement not found');

      when(() => mockRepository.fetchAnnouncementDetail('999'))
          .thenAnswer((_) async => (announcement: null, failure: failure));

      final result = await useCase('999');

      expect(result.announcement, isNull);
      expect(result.failure, equals(failure));
      expect(result.failure, isA<NotFoundFailure>());
    });
  });
}
