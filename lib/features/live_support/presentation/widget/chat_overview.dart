import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/util/column_row_builder.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/util/str_util.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/live_support/data/models/live_chat_model.dart';
import 'package:assign_erp/features/live_support/presentation/bloc/chat/live_support_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatOverviewPane extends StatefulWidget {
  final String workspaceId;
  final String? selectedChatId;
  final void Function(String chatId, String userName) onChatSelected;

  const ChatOverviewPane({
    super.key,
    required this.workspaceId,
    required this.onChatSelected,
    this.selectedChatId,
  });

  @override
  State<ChatOverviewPane> createState() => _ChatOverviewPaneState();
}

class _ChatOverviewPaneState extends State<ChatOverviewPane>
    with SingleTickerProviderStateMixin {
  bool _isDrawerOpen = false;
  late AnimationController _controller;
  late Animation<double> _widthAnimation;

  String get workspaceId => widget.workspaceId;

  String? get selectedChatId => widget.selectedChatId;
  final double _beginWidth = 50;
  late double _endWidth;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _endWidth = context.screenWidth * (context.isMobile ? 0.7 : 0.3);
    _widthAnimation = Tween<double>(
      begin: _beginWidth,
      end: _endWidth,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleToggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
      _isDrawerOpen ? _controller.forward() : _controller.reverse();
    });
  }

  void _expandDrawer() {
    setState(() {
      _isDrawerOpen = true;
      _controller.forward();
    });
  }

  void _collapseDrawer() {
    setState(() {
      _isDrawerOpen = false;
      _controller.reverse();
    });
  }

  Size _calculateDrawerSize() =>
      Size(_isDrawerOpen ? _widthAnimation.value : _beginWidth, _beginWidth);

  @override
  Widget build(BuildContext context) {
    return /*BlocProvider<ChatBloc>(
      create: (context) =>
          ChatBloc(firestore: FirebaseFirestore.instance)
            ..add(LoadChatOverviews<LiveChatMessage>(workspaceId: workspaceId)),
      child: Container(
        color: kGrayColor.withAlpha((0.2 * 255).toInt()),
        child:*/ StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: LiveSupportService().getChatOverviews(workspaceId: workspaceId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return context.loader;
        final chats = snapshot.data!.docs;
        return Container(
          // border left
          decoration: BoxDecoration(
            color: kGrayColor.withAlpha((0.2 * 255).toInt()),
            border: Border(
              right: BorderSide(
                width: 10,
                color: kPrimaryColor.withAlpha((1 * 255).toInt()),
              ),
            ),
          ),
          child: _buildChatOverviewContent(chats),
        );
      },
      // ),
      // ),
    );
  }

  /*Widget _buildBody() {
    return BlocBuilder<ChatOverviewBloc, LiveChatState<LiveChatOverview>>(
      builder: (context, state) {
        return switch (state) {
          LoadingChats<LiveChatOverview>() => context.loader,
          ChatOverviewLoaded<LiveChatOverview>(data: var results) => _buildChatOverviewContent(
            results,
          ),
          LiveChatError<LiveChatOverview>(error: final error) =>
            context.buildError(error),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }*/

  Widget _buildChatOverviewContent(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> chats,
  ) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          children: [
            Expanded(
              child: context.isMobile
                  ? _buildSidePanel(context, chats: chats)
                  : MouseRegion(
                      onEnter: (_) => _expandDrawer(),
                      onExit: (_) => _collapseDrawer(),
                      child: _buildSidePanel(context, chats: chats),
                    ),
            ),
            const SizedBox(height: 10),
            _buildDrawerToggleButton(context),
          ],
        );
      },
    );
  }

  Widget _buildSidePanel(
    BuildContext context, {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> chats = const [],
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Expanded(child: _buildChatList(context, chats))],
    );
  }

  Widget _buildDrawerToggleButton(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        alignment: Alignment.center,
        focusColor: kLightBlueColor,
        backgroundColor: kTransparentColor,
        shape: const RoundedRectangleBorder(),
        fixedSize: _calculateDrawerSize(),
      ),
      icon: Icon(Icons.menu),
      onPressed: _handleToggleDrawer,
    );
  }

  Widget _buildChatList(
    BuildContext context,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> chats,
  ) {
    final double width = _widthAnimation.value.clamp(100, _endWidth);

    return context.columnBuilder(
      mainAxisSize: MainAxisSize.min,
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final doc = chats[index];
        final isSelected = doc.id == selectedChatId;
        final chat = LiveChatOverview.fromMap(doc.data());
        return SizedBox(
          width: width,
          child: _buildChatListTile(isSelected, doc, chat: chat),
        );
      },
    );
  }

  Widget _buildChatListTile(
    bool isSelected,
    QueryDocumentSnapshot<Map<String, dynamic>> doc, {
    required LiveChatOverview chat,
  }) {
    return ListTile(
      selected: isSelected,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildUserAvatarWithStatus(chat),
      title: _buildChatTileHeader(chat, isSelected),
      subtitle: Text(
        chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey.shade800),
      ),
      tileColor: isSelected ? Colors.blue.withAlpha((0.1 * 255).toInt()) : null,
      onTap: () {
        widget.onChatSelected(doc.id, chat.userName!);
        _collapseDrawer();
      },
    );
  }

  Row _buildChatTileHeader(LiveChatOverview chat, bool isSelected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            chat.userName ?? 'Unknown User',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? kPrimaryAccentColor : kDarkTextColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: Text(
            _formatTimestamp(chat.lastTimestamp ?? DateTime.now()),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: kTextColor),
          ),
        ),
      ],
    );
  }

  Widget _buildUserAvatarWithStatus(LiveChatOverview chat) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          backgroundColor: kGrayBlueColor,
          child: Text(
            chat.userName.isNullOrEmpty ? '?' : chat.userName![0].toUpperCase(),
            style: TextStyle(color: kLightColor),
          ),
        ),
        Positioned(
          right: -1,
          top: -1,
          child: chat.isResolved
              ? Icon(Icons.check_circle, color: kSuccessColor, size: 14)
              : Icon(Icons.chat_bubble, color: kDangerColor, size: 14),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays > 0) {
      return '${timestamp.month}/${timestamp.day}';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
