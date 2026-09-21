import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/comment_providers.dart';
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/repositories/comment_repository.dart';

// Repository palsu: tidak melakukan HTTP sungguhan.
class FakeCommentRepository extends CommentRepository {
  FakeCommentRepository({this.items, this.throwError = false}) : super(Dio());
  final List<Comment>? items;
  final bool throwError;

  @override
  Future<List<Comment>> fetchComments(int postId) async {
    if (throwError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/comments'),
        type: DioExceptionType.connectionError,
      );
    }
    return items ?? const [];
  }
}

void main() {
  // Edge case utama: field hilang tidak boleh membuat crash.
  test('fromJson aman terhadap field yang hilang', () {
    final comment = Comment.fromJson({'id': 5});
    expect(comment.id, 5);
    expect(comment.postId, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });

  test('friendlyCommentErrorMessage untuk timeout', () {
    final err = DioException(
      requestOptions: RequestOptions(path: '/comments'),
      type: DioExceptionType.connectionTimeout,
    );
    expect(friendlyCommentErrorMessage(err), contains('timeout'));
  });

  test('friendlyCommentErrorMessage untuk 404 dan 500', () {
    DioException badResponse(int code) => DioException(
          requestOptions: RequestOptions(path: '/comments'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/comments'),
            statusCode: code,
          ),
        );

    expect(friendlyCommentErrorMessage(badResponse(404)), contains('404'));
    expect(friendlyCommentErrorMessage(badResponse(500)), contains('500'));
  });

  test('provider sukses dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        commentRepositoryProvider.overrideWithValue(
          FakeCommentRepository(items: const [
            Comment(
              postId: 1,
              id: 1,
              name: 'Budi',
              email: 'budi@mail.com',
              body: 'Halo',
            ),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final comments = await container.read(commentListProvider.future);
    expect(comments.length, 1);
    expect(comments.first.name, 'Budi');
  });

  test('provider error dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        commentRepositoryProvider.overrideWithValue(
          FakeCommentRepository(throwError: true),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.listen(commentListProvider, (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final value = container.read(commentListProvider);
    expect(value.hasError, isTrue);
    expect(value.error, isA<DioException>());
  });
}
