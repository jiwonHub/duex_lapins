import 'package:deux_lapins/domain/models/editorial_content.dart';

abstract class EditorialRepository {
  Future<PublicHomeContent?> getHomeContent();
  Future<List<PublicJournal>> getJournals();
  Future<PublicJournal> getJournal(String id);
}