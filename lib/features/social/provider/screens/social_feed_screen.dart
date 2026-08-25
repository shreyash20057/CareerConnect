import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/social_provider.dart';
import '../../../models/social_post_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/extensions.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() =>
      _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    context.read<SocialProvider>().startListening();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final social = context.watch<SocialProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Community'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () =>
                _showCreatePostSheet(context),
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Create post',
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Jobs'),
            Tab(text: 'Students'),
          ],
          labelColor: AppTheme.primary,
          unselectedLabelColor:
              AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13),
        ),
      ),
      body: social.loading
          ? const _FeedShimmer()
          : TabBarView(
              controller: _tab,
              children: [
                _PostsList(posts: social.posts),
                _PostsList(
                  posts: social.posts
                      .where((p) =>
                          p.postType ==
                              PostType.jobPosting ||
                          p.postType ==
                              PostType.internshipPosting)
                      .toList(),
                ),
                _PostsList(
                  posts: social.posts
                      .where((p) =>
                          p.authorType ==
                          PostAuthorType.student)
                      .toList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePostSheet(context),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.edit_rounded,
            color: Colors.white),
        label: const Text(
          'Post',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _showCreatePostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<SocialProvider>(),
        child: const _CreatePostSheet(),
      ),
    );
  }
}

// ── Posts List ────────────────────────────────────────────────────────────

class _PostsList extends StatelessWidget {
  final List<SocialPostModel> posts;
  const _PostsList({required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.dynamic_feed_rounded,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nothing here yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Be the first to post!',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<SocialProvider>().startListening(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
            vertical: 12, horizontal: 0),
        itemCount: posts.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 0),
        itemBuilder: (context, index) =>
            _PostCard(post: posts[index]),
      ),
    );
  }
}

// ── Post Card ─────────────────────────────────────────────────────────────

class _PostCard extends StatelessWidget {
  final SocialPostModel post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final social = context.watch<SocialProvider>();
    final scheme = Theme.of(context).colorScheme;
    final liked = social.isLikedByMe(post);
    final isCompany =
        post.authorType == PostAuthorType.company;

    return Container(
      color: scheme.surface,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Author row ──────────────────────────────
          Row(
            children: [
              _AuthorAvatar(
                name: post.authorName,
                isCompany: isCompany,
                photoUrl: post.authorPhotoUrl,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            post.authorName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (isCompany)
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius:
                                  BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Company',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      post.createdAt.timeAgo,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              _PostTypeBadge(type: post.postType),
            ],
          ),

          const SizedBox(height: 12),

          // ── Content ──────────────────────────────────
          Text(
            post.content,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.55,
            ),
          ),

          // ── Job link ─────────────────────────────────
          if (post.jobId != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () =>
                  context.push('/job/${post.jobId}'),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppTheme.primary
                          .withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.work_outline_rounded,
                      size: 16,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        post.jobTitle ?? 'View opportunity',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: AppTheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ── Tags ─────────────────────────────────────
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: post.tags.map((tag) {
                return Text(
                  '#$tag',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 12),

          // ── Action row ───────────────────────────────
          Row(
            children: [
              _ActionButton(
                icon: liked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: liked
                    ? AppTheme.error
                    : AppTheme.textSecondary,
                label:
                    '${post.likedBy.length}',
                onTap: () =>
                    social.toggleLike(post),
              ),
              const SizedBox(width: 16),
              _ActionButton(
                icon: Icons.comment_outlined,
                color: AppTheme.textSecondary,
                label: '${post.commentCount}',
                onTap: () => _openComments(context),
              ),
              const SizedBox(width: 16),
              _ActionButton(
                icon: Icons.share_outlined,
                color: AppTheme.textSecondary,
                label: 'Share',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<SocialProvider>(),
        child: _CommentsSheet(post: post),
      ),
    );
  }
}

// ── Author Avatar ─────────────────────────────────────────────────────────

class _AuthorAvatar extends StatelessWidget {
  final String name;
  final bool isCompany;
  final String? photoUrl;

  const _AuthorAvatar({
    required this.name,
    required this.isCompany,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isCompany
            ? AppTheme.primaryLight
            : AppTheme.secondaryLight,
        shape: BoxShape.circle,
        image: photoUrl != null
            ? DecorationImage(
                image: NetworkImage(photoUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: photoUrl == null
          ? Center(
              child: Text(
                name.isNotEmpty
                    ? name[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: isCompany
                      ? AppTheme.primary
                      : AppTheme.secondary,
                ),
              ),
            )
          : null,
    );
  }
}

// ── Post Type Badge ───────────────────────────────────────────────────────

class _PostTypeBadge extends StatelessWidget {
  final PostType type;
  const _PostTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String label;

    switch (type) {
      case PostType.jobPosting:
      case PostType.internshipPosting:
        icon = Icons.work_rounded;
        color = AppTheme.primary;
        label = 'Hiring';
        break;
      case PostType.achievement:
        icon = Icons.emoji_events_rounded;
        color = AppTheme.warning;
        label = 'Win';
        break;
      case PostType.tip:
        icon = Icons.lightbulb_rounded;
        color = AppTheme.secondary;
        label = 'Tip';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Comments Sheet ────────────────────────────────────────────────────────

class _CommentsSheet extends StatefulWidget {
  final SocialPostModel post;
  const _CommentsSheet({required this.post});

  @override
  State<_CommentsSheet> createState() =>
      _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _controller = TextEditingController();
  List<CommentModel> _comments = [];
  bool _loading = true;
  bool _posting = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final comments = await context
        .read<SocialProvider>()
        .getComments(widget.post.id);
    if (mounted) {
      setState(() {
        _comments = comments;
        _loading = false;
      });
    }
  }

  Future<void> _postComment() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _posting = true);
    final ok = await context
        .read<SocialProvider>()
        .addComment(widget.post.id, _controller.text);
    if (ok && mounted) {
      _controller.clear();
      await _loadComments();
    }
    setState(() => _posting = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                16, 16, 16, 8),
            child: Text(
              'Comments (${widget.post.commentCount})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.sizeOf(context).height * 0.4,
              ),
              child: _comments.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No comments yet. Be the first!',
                        style: TextStyle(
                            color: AppTheme.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: _comments.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 14),
                      itemBuilder: (_, i) =>
                          _CommentRow(
                              comment: _comments[i]),
                    ),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: const TextStyle(
                          color: AppTheme.textTertiary),
                      filled: true,
                      fillColor:
                          scheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _postComment(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _posting ? null : _postComment,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: _posting
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  final CommentModel comment;
  const _CommentRow({required this.comment});

  @override
  Widget build(BuildContext context) {
    final isCompany =
        comment.authorType == PostAuthorType.company;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AuthorAvatar(
          name: comment.authorName,
          isCompany: isCompany,
          photoUrl: comment.authorPhotoUrl,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.authorName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    comment.createdAt.timeAgo,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                comment.content,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Create Post Sheet ─────────────────────────────────────────────────────

class _CreatePostSheet extends StatefulWidget {
  const _CreatePostSheet();

  @override
  State<_CreatePostSheet> createState() =>
      _CreatePostSheetState();
}

class _CreatePostSheetState
    extends State<_CreatePostSheet> {
  final _controller = TextEditingController();
  PostType _selectedType = PostType.general;

  final _types = [
    (PostType.general, 'General', Icons.edit_rounded),
    (PostType.achievement, 'Achievement',
        Icons.emoji_events_rounded),
    (PostType.tip, 'Tip', Icons.lightbulb_rounded),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_controller.text.trim().isEmpty) return;
    final ok = await context.read<SocialProvider>().createPost(
          content: _controller.text,
          postType: _selectedType,
        );
    if (ok && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final social = context.watch<SocialProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                16, 16, 16, 12),
            child: Row(
              children: [
                const Text(
                  'Create a post',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Post type selector
          Padding(
            padding: const EdgeInsets.fromLTRB(
                16, 12, 16, 0),
            child: Row(
              children: _types.map((t) {
                final selected = _selectedType == t.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(
                        () => _selectedType = t.$1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primary
                            : scheme.surfaceContainerHighest,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            t.$3,
                            size: 13,
                            color: selected
                                ? Colors.white
                                : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            t.$2,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Text input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 6,
              minLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Share something with the community...',
                hintStyle: const TextStyle(
                    color: AppTheme.textTertiary),
                filled: true,
                fillColor:
                    scheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
                16, 0, 16, 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    social.submitting ? null : _submit,
                child: social.submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Post to community',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shimmer ───────────────────────────────────────────────────────────────

class _FeedShimmer extends StatelessWidget {
  const _FeedShimmer();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, __) =>
          const SizedBox(height: 8),
      itemBuilder: (_, __) => Container(
        height: 160,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}