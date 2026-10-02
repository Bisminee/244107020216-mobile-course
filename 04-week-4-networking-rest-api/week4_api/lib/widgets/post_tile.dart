import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/models/post.dart';

// Widget baris post agar ListView.builder pendek dan mudah diuji.
class PostTile extends StatelessWidget {
  const PostTile({super.key, required this.post, this.showBody = true});

  final Post post;
  final bool showBody;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(post.id.toString())),
      title: Text(
        post.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: showBody
          ? Text(
              post.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: () => context.push('/post/${post.id}'),
    );
  }
}
