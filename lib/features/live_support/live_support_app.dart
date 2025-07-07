import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/live_support/presentation/bloc/chat/chat_bloc.dart';
import 'package:assign_erp/features/live_support/presentation/bloc/live_chat_bloc.dart';
import 'package:assign_erp/features/live_support/presentation/screen/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/models/live_chat_model.dart';

class LiveSupportApp extends StatelessWidget {
  const LiveSupportApp({super.key});

  @override
  Widget build(BuildContext context) {
    final work = context.workspace;
    final employeeId = context.employee?.id ?? '';

    return BlocProvider<ChatBloc>(
      create: (context) => ChatBloc(firestore: FirebaseFirestore.instance)
        ..add(
          LoadChatMessagesById<LiveChatMessage>(
            workspaceId: work!.id,
            chatId: employeeId,
          ),
        ),
      child: ClientChatDashboard(chatId: employeeId),
    );
  }
}
