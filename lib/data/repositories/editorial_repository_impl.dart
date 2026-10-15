import 'package:deux_lapins/core/network/shared_mock_api_client.dart';
import 'package:deux_lapins/domain/models/editorial_content.dart';
import 'package:deux_lapins/domain/repositories/editorial_repository.dart';

class EditorialRepositoryImpl implements EditorialRepository {
  const EditorialRepositoryImpl(this._client);

  final SharedMockApiClient _client;

  Future<dynamic> _get(String path) async {
    final response = await _client.request('GET', path);

    if (response['success'] != true) {
      final error = response['error'];

      throw StateError(error is Map
          ? error['message']?.toString() ?? '콘텐츠 조회에 실패했습니다.'
          : '콘텐츠 조회에 실패했습니다.');
    }

    return response['data'];
  }

  @override
  Future<PublicHomeContent?> getHomeContent() async {
    final data = await _get('/public/home-content');

    if (data == null) return null;

    return PublicHomeContent.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
  }

  @override
  Future<List<PublicJournal>> getJournals() async {
    final data = await _get('/public/journals') as List<dynamic>;

    return data
        .map((row) => PublicJournal.fromJson(
      Map<String, dynamic>.from(row as Map),
    ))
        .toList(growable: false);
  }

  @override
  Future<PublicJournal> getJournal(String id) async {
    final data = await _get(
      '/public/journals/${Uri.encodeComponent(id)}',
    );

    return PublicJournal.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
  }
}