import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/constants/app_constant.dart';
import 'package:assign_erp/core/network/data_sources/models/workspace_role.dart';
import 'package:assign_erp/core/util/size_config.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/custom_text_field.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/live_support/data/models/live_chat_model.dart';
import 'package:assign_erp/features/live_support/presentation/bloc/chat/chat_bloc.dart';
import 'package:assign_erp/features/live_support/presentation/bloc/live_chat_bloc.dart';
import 'package:assign_erp/features/live_support/presentation/widget/chat_overview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Live support dashboard
class AgentChatDashboard extends StatefulWidget {
  final String? clientWorkspaceId;
  const AgentChatDashboard({super.key, this.clientWorkspaceId});

  @override
  State<AgentChatDashboard> createState() => _AgentChatDashboardState();
}

class _AgentChatDashboardState extends State<AgentChatDashboard> {
  String? selectedChatId;
  String? selectedUserName;

  get _clientWorkspaceId =>
      widget.clientWorkspaceId; // Same as Client's WorkspaceId
  get _agentId => context.workspace?.agentID; // Same as Agent's WorkspaceId

  void _selectChat(String chatId, String userName) {
    setState(() {
      selectedChatId = chatId;
      selectedUserName = userName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: liveSupportScreenTitle,
      body: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 🧭 LEFT PANEL: Chat list
          ChatOverviewPane(
            workspaceId: _clientWorkspaceId,
            onChatSelected: _selectChat,
            selectedChatId: selectedChatId,
          ),

          /*SizedBox(
            width: context.screenWidth * 0.3,
            child: ChatOverviewPane(
              workspaceId: _clientWorkspaceId,
              onChatSelected: _selectChat,
              selectedChatId: selectedChatId,
            ),
          ),*/
          /// Message window
          _buildRightPane(context),
        ],
      ),
    );
  }

  /* 🧭 LEFT PANEL: Chat list
  _buildLeftPane(BuildContext context) {
    return Container(
      color: kLightBlueColor.withAlpha((0.3 * 255).toInt()),
      child: ChatOverviewPane(
        workspaceId: _clientWorkspaceId,
        onChatSelected: _selectChat,
        selectedChatId: selectedChatId,
      ),
    );
  }*/

  /// 💬 RIGHT PANEL: Message window
  Expanded _buildRightPane(BuildContext context) {
    return Expanded(
      child: selectedChatId == null
          ? Center(
              child: Text(
                'Select a conversation',
                style: context.ofTheme.textTheme.bodyLarge,
                textScaler: TextScaler.linear(context.textScaleFactor),
              ),
            )
          : ChatDetailPane(
              workspaceId: _clientWorkspaceId,
              agentId: _agentId,
              selectedChatId: selectedChatId ?? '',
              userName: selectedUserName ?? '',
            ),
    );
  }
}

/// Chat detail pane
class ChatDetailPane extends StatefulWidget {
  final String workspaceId;
  final String selectedChatId;
  final String userName;
  final String agentId;

  const ChatDetailPane({
    super.key,
    required this.workspaceId,
    required this.selectedChatId,
    required this.userName,
    required this.agentId,
  });

  @override
  State<ChatDetailPane> createState() => _ChatDetailPaneState();
}

class _ChatDetailPaneState extends State<ChatDetailPane> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String get _chatId => widget.selectedChatId;
  String get _agentId => widget.agentId;
  String get _workspaceId => widget.workspaceId;
  // String get _userName => widget.userName;

  Future<void> _sendMessage() async {
    final msg = _controller.text.trim();
    if (msg.isEmpty) return;

    /// 2. Create message with embedded summary
    final message = LiveChatMessage(
      senderId: _agentId,
      message: msg,
      senderRole: WorkspaceRole.agentFranchise.label,
    );

    /// 3. Add message to BLoC
    context.read<ChatBloc>().add(
      AddChat<LiveChatMessage>(
        chatId: _chatId,
        message: message,
        workspaceId: _workspaceId,
      ),
    );

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatBloc>(
      create: (context) => ChatBloc(firestore: FirebaseFirestore.instance)
        ..add(
          LoadChatMessagesById<LiveChatMessage>(
            workspaceId: _workspaceId,
            chatId: _chatId,
          ),
        ),
      child: Column(
        children: [
          Expanded(child: _buildMessageList()),
          Padding(padding: const EdgeInsets.all(20), child: _buildChatInput()),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return BlocBuilder<ChatBloc, LiveChatState<LiveChatMessage>>(
      builder: (context, state) {
        return switch (state) {
          LoadingChats<LiveChatMessage>() => context.loader,
          ChatsLoaded<LiveChatMessage>(data: var results) => _buildMessageBody(
            results,
          ),
          LiveChatError<LiveChatMessage>(error: final error) =>
            context.buildError(error),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  ListView _buildMessageBody(List<LiveChatMessage> messages) {
    // Sort messages by ascending timestamp before displaying
    // messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    messages.sort((a, b) {
      final aTime = a.timestamp ?? DateTime(0);
      final bTime = b.timestamp ?? DateTime(0);
      return aTime.compareTo(bTime);
    });

    // Auto-scroll to the bottom after the frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return _buildCard(messages);
  }

  ListView _buildCard(List<LiveChatMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isAgent = msg.senderRole == WorkspaceRole.agentFranchise.label;

        return Align(
          alignment: isAgent ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isAgent ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              msg.message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatInput() {
    return CustomTextField(
      key: const Key('live_chat_support_field'),
      controller: _controller,
      keyboardType: TextInputType.none,
      textInputAction: TextInputAction.send,
      onFieldSubmitted: (_) => _sendMessage(),
      inputDecoration: InputDecoration(
        isDense: true,
        filled: true,
        contentPadding: const EdgeInsets.all(1.0),
        hintText: 'Enter your message...',
        label: const Text('Live Support'),
        alignLabelWithHint: true,
        fillColor: kLightBlueColor.withAlpha((0.2 * 255).toInt()),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: const Icon(Icons.support_agent, size: 15),
        suffixIcon: IconButton(
          icon: const Icon(Icons.send, color: kPrimaryLightColor),
          onPressed: () => _sendMessage(),
        ),
      ),
    );
  }
}

/*/// Chat overview pane
class ChatOverviewPane extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      /// @TODO: replace with client workspaceId: 'yndCsTKZxnT9olh5RUK3OfAh4S33',
      stream: LiveSupportService().getChatOverviews(workspaceId: workspaceId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return context.loader;
        final chats = snapshot.data!.docs;

        return _buildBody(chats);
      },
    );
  }

  ListView _buildBody(List<QueryDocumentSnapshot<Map<String, dynamic>>> chats) {
    return ListView.builder(
      primary: true,
      itemCount: chats.length,
      itemBuilder: (_, i) {
        final doc = chats[i];
        final chat = LiveChatOverview.fromMap(doc.data());
        final isSelected = doc.id == selectedChatId;

        return _buildCard(isSelected, chat, doc);
      },
    );
  }

  ListTile _buildCard(
    bool isSelected,
    LiveChatOverview chat,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return ListTile(
      selected: isSelected,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildCircleAvatar(chat),
      title: _buildHeader(chat, isSelected),
      subtitle: Text(
        chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey.shade800),
      ),
      trailing: chat.isResolved
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.chat_bubble_outline, color: Colors.grey),
      tileColor: isSelected ? Colors.blue.withAlpha((0.1 * 255).toInt()) : null,
      onTap: () => onChatSelected(doc.id, chat.userName!),
    );
  }

  Row _buildHeader(LiveChatOverview chat, bool isSelected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            chat.userName ?? 'Unknown User',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.blueAccent : Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: Text(
            _formatTimestamp(chat.lastTimestamp ?? DateTime.now()),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  CircleAvatar _buildCircleAvatar(LiveChatOverview chat) {
    return CircleAvatar(
      backgroundColor: Colors.blueGrey.shade200,
      child: Text(
        chat.userName.isNullOrEmpty ? '?' : chat.userName![0].toUpperCase(),
        style: const TextStyle(color: Colors.black),
      ),
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
}*/

/*
class ChatOverviewPane extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: LiveSupportService().getChatOverviews(
        /// @TODO: replace with client workspaceId,
        workspaceId: 'yndCsTKZxnT9olh5RUK3OfAh4S33',
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return context.loader;
        final chats = snapshot.data!.docs;

        return _buildCard(chats);
      },
    );
  }

  ListView _buildCard(List<QueryDocumentSnapshot<Map<String, dynamic>>> chats) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (_, i) {
        final doc = chats[i];
        final chat = LiveChatSummary.fromMap(doc.data());
        final isSelected = doc.id == selectedChatId;

        return ListTile(
          selected: isSelected,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: _buildCircleAvatar(chat),
          title: _buildHeader(chat, isSelected),
          subtitle: Text(
            chat.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade800),
          ),
          trailing: chat.isResolved
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.chat_bubble_outline, color: Colors.grey),
          tileColor: isSelected
              ? Colors.blue.withAlpha((0.1 * 255).toInt())
              : null,
          onTap: () => onChatSelected(doc.id, chat.userName!),
        );
      },
    );
  }

  Row _buildHeader(LiveChatSummary chat, bool isSelected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            chat.userName ?? 'Unknown User',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.blueAccent : Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          _formatTimestamp(chat.lastTimestamp ?? DateTime.now()),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  CircleAvatar _buildCircleAvatar(LiveChatSummary chat) {
    return CircleAvatar(
      backgroundColor: Colors.blueGrey.shade200,
      child: Text(
        chat.userName.isNullOrEmpty ? '?' : chat.userName![0].toUpperCase(),
        style: const TextStyle(color: Colors.black),
      ),
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



class _ChatDetailPaneState extends State<ChatDetailPane> {
  final _chatService = LiveSupportService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String get _userId => widget.userId;
  String get _agentId => widget.agentId;
  String get _workspaceId => widget.workspaceId;
  // String get _userName => widget.userName;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      // Update chat summary
      await _chatService.sendMessageAndUpdateChat(
        chatId: _userId,
        senderId: _agentId,
        senderRole: WorkspaceRole.agentFranchise.label,
        messageText: text,
        workspaceId: _workspaceId,
      );
    } catch (e) {
      // Handle error (log or show user feedback)
      debugPrint('Failed to send message: $e');
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseFirestore.instance
        .collection(liveChatSupportDBCollectionPath)
        .doc(_workspaceId)
        .collection('chats')
        .doc(_userId)
        .collection('messages')
        .orderBy('timestamp');

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: messagesRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return context.loader;
              final messages = snapshot.data!.docs;

              // Automatically scroll to the bottom when new messages are added
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });

              return _buildMessageBody(messages);
            },
          ),
        ),
        _buildChatInput(),
      ],
    );
  }

  ListView _buildMessageBody(List<QueryDocumentSnapshot<Object?>> messages) {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: messages.map((msg) {
        final data = LiveChatMessage.fromMap(
          msg.data() as Map<String, dynamic>,
        );
        final isAgent = data.senderRole == WorkspaceRole.agentFranchise.label;

        /*final data = msg.data() as Map<String, dynamic>;
        final isAgent =
            data['senderRole'] == WorkspaceRole.agentFranchise.label;*/

        return Align(
          alignment: isAgent ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isAgent ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(data.message),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChatInput() {
    return CustomTextField(
      key: const Key('live_support_field'),
      controller: _controller,
      keyboardType: TextInputType.text,
      onFieldSubmitted: (_) => _sendMessage(),
      inputDecoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.all(1.0),
        hintText: 'Enter your message...',
        label: const Text('Live Support'),
        alignLabelWithHint: true,
        filled: true,
        fillColor: kLightBlueColor.withAlpha((0.5 * 255).toInt()),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: const Icon(Icons.support_agent, size: 15),
        suffixIcon: IconButton(
          icon: const Icon(Icons.send, color: kPrimaryLightColor),
          onPressed: () => _sendMessage(),
        ),
      ),
    );
  }
}*/

/* Fetch Assigned Tenants
Future<List<String>> fetchTenantWorkspaceIds(String agentId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('agent_clients')
      .doc(agentId)
      .collection('tenants')
      .get();

  return snapshot.docs.map((doc) => doc.id).toList(); // tenantWorkspaceIds
}

STEP-2: For Each Tenant Workspace, Stream Chats

import 'package:async/async.dart';

Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAgentAssignedChats(
  String agentId,
  List<String> tenantWorkspaceIds,
) {
  final streamGroup = StreamGroup<List<QueryDocumentSnapshot<Map<String, dynamic>>>>();

  for (final tenantWorkspaceId in tenantWorkspaceIds) {
    final stream = FirebaseFirestore.instance
        .collection('workspaces_live_chat_support_db')
        .doc(tenantWorkspaceId)
        .collection('chats')
        .where('agentId', isEqualTo: agentId)
        .snapshots()
        .map((snap) => snap.docs);

    streamGroup.add(stream);
  }

  streamGroup.close();
  return streamGroup.stream;
}

STEP-3: Use in UI
@override
Widget build(BuildContext context) {
  final agentId = _workspace.agentID;

  return FutureBuilder<List<String>>(
    future: fetchTenantWorkspaceIds(agentId),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return context.loader;

      final tenantIds = snapshot.data!;
      return StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        stream: getAgentAssignedChats(agentId, tenantIds),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return context.loader;

          final chatDocs = snapshot.data!;
          chatDocs.sort((a, b) {
            final aTime = a['lastTimestamp'] as Timestamp?;
            final bTime = b['lastTimestamp'] as Timestamp?;
            return (bTime?.compareTo(aTime ?? Timestamp.now()) ?? 0);
          });

          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (_, i) {
              final doc = chatDocs[i];
              final chat = LiveSupportChat.fromMap(doc.data());

              return ListTile(
                title: Text(chat.userName),
                subtitle: Text(chat.lastMessage),
                onTap: () => onChatSelected(doc.id, chat.userName),
              );
            },
          );
        },
      );
    },
  );
}

*/

/// -------------End-------
/*class _ChatDetailPaneState extends State<ChatDetailPane> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final message = {
      'senderId': widget.workspaceId,
      'senderRole': WorkspaceRole.agentFranchise.label,
      'message': text,
      'timestamp': DateTime.now(),
    };

    final messagesRef = FirebaseFirestore.instance
        .collection(liveChatSupportDBCollectionPath)
        .doc(widget.workspaceId)
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages');

    messagesRef.add(message);

    FirebaseFirestore.instance
        .collection(liveChatSupportDBCollectionPath)
        .doc(widget.workspaceId)
        .collection('chats')
        .doc(widget.chatId)
        .update({'lastMessage': text, 'lastTimestamp': DateTime.now()});

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseFirestore.instance
        .collection(liveChatSupportDBCollectionPath)
        .doc(widget.workspaceId)
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp');

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: messagesRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return context.loader;
              final messages = snapshot.data!.docs;

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: messages.map((msg) {
                  final data = msg.data() as Map<String, dynamic>;
                  final isAgent =
                      data['senderRole'] == WorkspaceRole.agentFranchise.label;

                  return Align(
                    alignment: isAgent
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isAgent ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(data['message']),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(child: _buildChatInput()),
              IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatInput() {
    return CustomTextField(
      key: const Key('live_support_field'),
      controller: _controller,
      keyboardType: TextInputType.text,
      onFieldSubmitted: (_) => _sendMessage(),
      inputDecoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.all(1.0),
        hintText: 'Enter your message...',
        label: const Text('Live Support'),
        alignLabelWithHint: true,
        filled: true,
        fillColor: kLightBlueColor.withAlpha((0.5 * 255).toInt()),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: const Icon(Icons.support_agent, size: 15),
        suffixIcon: IconButton(
          icon: const Icon(Icons.send, color: kPrimaryLightColor),
          onPressed: () => _sendMessage(),
        ),
      ),
    );
  }
}*/

/*Great thinking — that’s a more **desktop-friendly layout** (like Slack, Intercom, or Zendesk) using a **split-screen interface**. This avoids navigation and keeps everything visible, reactive, and stateful.

---

## 🧱 Layout Plan: Split-Screen Chat UI

We'll build a `Row` with two main parts:

| Section     | Widget                             | Width  |
| ----------- | ---------------------------------- | ------ |
| Left Panel  | `ChatOverviewPane` — list of chats | 30–35% |
| Right Panel | `ChatDetailPane` — selected chat   | 65–70% |

---

## ✅ Full Example: `AgentChatDashboard`

```dart
class AgentChatDashboard extends StatefulWidget {
  final String tenantId;
  const AgentChatDashboard({super.key, required this.tenantId});

  @override
  State<AgentChatDashboard> createState() => _AgentChatDashboardState();
}

class _AgentChatDashboardState extends State<AgentChatDashboard> {
  String? selectedChatId;
  String? selectedUserName;

  void _selectChat(String chatId, String userName) {
    setState(() {
      selectedChatId = chatId;
      selectedUserName = userName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Chat Support')),
      body: Row(
        children: [
          /// 🧭 LEFT PANEL: Chat list
          Container(
            width: 300,
            color: Colors.grey[100],
            child: ChatOverviewPane(
              tenantId: widget.tenantId,
              onChatSelected: _selectChat,
              selectedChatId: selectedChatId,
            ),
          ),

          /// 💬 RIGHT PANEL: Message window
          Expanded(
            child: selectedChatId == null
                ? const Center(child: Text('Select a conversation'))
                : ChatDetailPane(
                    tenantId: widget.tenantId,
                    chatId: selectedChatId!,
                    userName: selectedUserName ?? '',
                  ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🧭 ChatOverviewPane

```dart
class ChatOverviewPane extends StatelessWidget {
  final String tenantId;
  final String? selectedChatId;
  final void Function(String chatId, String userName) onChatSelected;

  const ChatOverviewPane({
    super.key,
    required this.tenantId,
    required this.onChatSelected,
    this.selectedChatId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tenants')
          .doc(tenantId)
          .collection('chats')
          .orderBy('lastTimestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final chats = snapshot.data!.docs;

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (_, i) {
            final chat = chats[i];
            final data = chat.data() as Map<String, dynamic>;
            final isSelected = chat.id == selectedChatId;

            return ListTile(
              selected: isSelected,
              title: Text(data['userName'] ?? 'Unknown'),
              subtitle: Text(data['lastMessage'] ?? ''),
              onTap: () => onChatSelected(chat.id, data['userName'] ?? ''),
              trailing: data['isResolved'] == true
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
            );
          },
        );
      },
    );
  }
}
```

---

## 💬 ChatDetailPane (from previous response)

Same as the `ChatDetailScreen`, just embedded directly. Example:

```dart
class ChatDetailPane extends StatefulWidget {
  final String tenantId;
  final String chatId;
  final String userName;

  const ChatDetailPane({
    super.key,
    required this.tenantId,
    required this.chatId,
    required this.userName,
  });

  @override
  State<ChatDetailPane> createState() => _ChatDetailPaneState();
}

class _ChatDetailPaneState extends State<ChatDetailPane> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final message = {
      'senderId': 'agent_123',
      'senderRole': 'agent',
      'message': text,
      'timestamp': DateTime.now(),
    };

    final messagesRef = FirebaseFirestore.instance
        .collection('tenants')
        .doc(widget.tenantId)
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages');

    messagesRef.add(message);

    FirebaseFirestore.instance
        .collection('tenants')
        .doc(widget.tenantId)
        .collection('chats')
        .doc(widget.chatId)
        .update({
      'lastMessage': text,
      'lastTimestamp': DateTime.now(),
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseFirestore.instance
        .collection('tenants')
        .doc(widget.tenantId)
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp');

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: messagesRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final messages = snapshot.data!.docs;

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: messages.map((msg) {
                  final data = msg.data() as Map<String, dynamic>;
                  final isAgent = data['senderRole'] == 'agent';

                  return Align(
                    alignment: isAgent ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isAgent ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(data['message']),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Type a message...'),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

---

## ✅ Summary

| Feature                          | ✅ Implemented |
| -------------------------------- | ------------- |
| Split layout with `Row`          | ✅             |
| In-place chat loading (no route) | ✅             |
| Responsive and reactive          | ✅             |
| Scalable for multiple tenants    | ✅             |

---

### 👉 Want to Add:

* Responsive support for mobile?
* Chat status tags (e.g., unread, new)?
* Auto-scroll to bottom?

Let me know, and I’ll extend it accordingly!
*/
