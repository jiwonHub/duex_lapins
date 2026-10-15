import 'package:deux_lapins/core/di/providers.dart';
import 'package:deux_lapins/domain/models/editorial_content.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final publicHomeContentProvider = FutureProvider<PublicHomeContent?>(
      (ref) => ref.watch(editorialRepositoryProvider).getHomeContent(),
);

final publicJournalsProvider = FutureProvider<List<PublicJournal>>(
      (ref) => ref.watch(editorialRepositoryProvider).getJournals(),
);

final publicJournalProvider = FutureProvider.family<PublicJournal, String>(
      (ref, journalId) =>
      ref.watch(editorialRepositoryProvider).getJournal(journalId),
);