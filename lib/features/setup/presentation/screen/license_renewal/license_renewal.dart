import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:assign_erp/core/network/data_sources/models/subscription_licenses_enum.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/core/widgets/custom_scroll_bar.dart';
import 'package:assign_erp/core/widgets/screen_helper.dart';
import 'package:assign_erp/features/agent/data/data_sources/remote/get_agent.dart';
import 'package:assign_erp/features/agent/data/models/agent_client_model.dart';
import 'package:assign_erp/features/auth/data/model/workspace_model.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:flutter/material.dart';

class LicenseRenewal extends StatefulWidget {
  const LicenseRenewal({super.key});

  @override
  State<LicenseRenewal> createState() => _LicenseRenewalState();
}

class _LicenseRenewalState extends State<LicenseRenewal> {
  Workspace? myAgent;
  List<AgentClient> clients = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getAgent();
  }

  _getAgent() async {
    final info = (await GetAgent.byAgentId(context.workspace!.agentID));
    setState(() => myAgent = info);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      noAppBar: true,
      body: myAgent != null
          ? _buildBody(context)
          : Center(
              child: Text(
                'License Agent not found!',
                style: context.ofTheme.textTheme.titleLarge,
              ),
            ),
      bottomNavigationBar: const SizedBox.shrink(),
    );
  }

  _buildBody(BuildContext context) {
    return Center(
      child: CustomScrollBar(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 28.0),
        child: GenericCard(
          headTitle: 'Subscription License',
          title: '[ ${licenseAsString(context.workspace!.license)} ]',
          subTitle: 'License Agent Contact',
          extra: [
            {'title': '-', 'value': '${myAgent!.clientName} :-'},
            {'title': 'Mobile', 'value': myAgent!.mobileNumber},
            {'title': 'Email', 'value': myAgent!.email},
          ],
        ),
      ),
    );
  }
}
