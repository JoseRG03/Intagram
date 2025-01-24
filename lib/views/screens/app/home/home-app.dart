import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intec_social_app/views/screens/app/home/posts-story.dart';
import '../../../../controllers/posts-controller.dart';
import '../../../../controllers/user-controller.dart';

class FeedPage extends StatefulWidget {

  const FeedPage({
    Key? key,
  }) : super(key: key);

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late Future<Map<String, dynamic>?> _currentUserFuture;

  UserController userController = UserController();
  PostsController postsController = PostsController();

  @override
  void initState() {
    super.initState();
    _currentUserFuture = userController.getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostStoryScreen(
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stories Module
          FutureBuilder<List<Map<String, dynamic>>>(
            future: postsController.getStories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: Text("No stories available")),
                );
              }

              final stories = snapshot.data!;
              return SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: stories.length,
                  itemBuilder: (context, index) {
                    final story = stories[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          _showStory(context, story);
                        },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(story['imageUrl']),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const Divider(),
          // Feed Posts
          Expanded(
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _currentUserFuture,
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!userSnapshot.hasData || userSnapshot.data == null) {
                  return const Center(child: Text("Failed to load user data"));
                }

                final currentUser = userSnapshot.data!;
                final currentUserId = currentUser['id'];

                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: postsController.getPosts(),
                  builder: (context, postsSnapshot) {
                    if (postsSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!postsSnapshot.hasData || postsSnapshot.data!.isEmpty) {
                      return const Center(child: Text("No posts available"));
                    }

                    final posts = postsSnapshot.data!;
                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];

                        return FutureBuilder<Map<String, dynamic>?>(
                          future: userController.getUserData(),
                          builder: (context, userDetailsSnapshot) {
                            if (!userDetailsSnapshot.hasData) {
                              return const SizedBox.shrink();
                            }

                            final user = userDetailsSnapshot.data!;
                            final likes = List<String>.from(post['likes'] ?? []);
                            final isLikedByCurrentUser = likes.contains(currentUserId);

                            return Card(
                              margin: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // User Info
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(user['image'] ?? ''),
                                      child: user['image'] == null
                                          ? const Icon(Icons.person)
                                          : null,
                                    ),
                                    title: Text(user['name'] ?? 'Unknown User'),
                                    subtitle: Text(post['timestamp']?.toDate().toString() ?? ''),
                                  ),
                                  // Post Image
                                  Image.network(post['imageUrl']),
                                  // Likes and Comments
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          isLikedByCurrentUser
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isLikedByCurrentUser ? Colors.red : Colors.grey,
                                        ),
                                        onPressed: () async {
                                          if (isLikedByCurrentUser) {
                                            await postsController.unlikePost(post['id']);
                                          } else {
                                            await postsController.likePost(post['id']);
                                          }
                                        },
                                      ),
                                      Text("${likes.length} likes"),
                                      const SizedBox(width: 16),
                                      IconButton(
                                        icon: const Icon(Icons.comment),
                                        onPressed: () {
                                          _showComments(context, post['id']);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStory(BuildContext context, Map<String, dynamic> story) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Image.network(story['imageUrl']),
        );
      },
    );
  }

  void _showComments(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CommentsSheet(
          postId: postId,
          postsController: postsController,
          userController: userController,
        );
      },
    );
  }
}

class CommentsSheet extends StatelessWidget {
  final String postId;
  final PostsController postsController;
  final UserController userController;

  const CommentsSheet({
    required this.postId,
    required this.postsController,
    required this.userController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final commentController = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: postsController.getComments(postId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final comments = snapshot.data!;

              return ListView.builder(
                shrinkWrap: true,
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return FutureBuilder<Map<String, dynamic>?>(
                    future: userController.getUserData(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return const Text("Loading...");
                      }

                      final user = userSnapshot.data!;
                      return ListTile(
                        title: Text("${user['name']}: ${comment['comment']}"),
                      );
                    },
                  );
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: "Add a comment...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final comment = commentController.text.trim();
                    if (comment.isNotEmpty) {
                      await postsController.addComment(postId, comment);
                      commentController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
