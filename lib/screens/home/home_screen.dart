import 'package:blog_app/data/model/post_model.dart';
import 'package:blog_app/screens/details/details_screen.dart';
import 'package:flutter/material.dart';

import '../../data/services/post_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _postService = PostService();

  List<PostModel> _posts = [];
  List<Map<String, dynamic>> _users = [];

  bool _isLoading = true;
  String _errorMessage = '';

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await Future.wait([
        _postService.fetchPosts(),
        _postService.fetchUsers(),
      ]);

      final posts = results[0] as List<PostModel>;
      final users = results[1] as List<Map<String, dynamic>>;

      if (!mounted) return;

      setState(() {
        _posts = posts;
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<PostModel> get _filteredPosts {
    if (_searchQuery.isEmpty) {
      return _posts;
    }

    return _posts.where((post) {
      return post.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
          false;
    }).toList();
  }

  String _getAuthorName(int? userId) {
    if (userId == null) return 'Unknown Author';

    final user = _users.where((user) => user['id'] == userId);

    if (user.isEmpty) return 'Unknown Author';

    return user.first['name'] as String;
  }

  @override
  Widget build(BuildContext context) {
    final filteredPosts = _filteredPosts;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody(filteredPosts)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BLOG READER',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Discover Stories',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222238),
                ),
              ),
            ],
          ),

          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.article_outlined,
              color: Colors.deepPurple,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<PostModel> posts) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 12),
            const Text('Something went wrong!'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadPosts, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (posts.isEmpty) {
      return const Center(child: Text('No articles found'));
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];

          return _buildPostCard(post);
        },
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
    final authorName = _getAuthorName(post.userId);

    return InkWell(
      onTap: () {
        final user = _users.firstWhere(
          (user) => user['id'] == post.userId,
          orElse: () => {'name': 'Unknown Author', 'email': ''},
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsScreen(
              post: post,
              authorName: user['name'] as String,
              authorEmail: user['email'] as String,
            ),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
                    child: Text(
                      authorName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  Text(
                    '#${post.id}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                post.title ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.4,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222238),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                post.body ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 16),

              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Read More',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.arrow_forward, size: 17, color: Colors.deepPurple),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
