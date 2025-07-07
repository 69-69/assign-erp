import 'package:assign_erp/core/network/data_sources/models/workspace_model.dart';
import 'package:assign_erp/core/widgets/custom_scaffold.dart';
import 'package:assign_erp/features/agent/data/data_sources/remote/get_agent.dart';
import 'package:assign_erp/features/auth/presentation/guard/auth_guard.dart';
import 'package:assign_erp/features/manual/presentation/screen/how_to_renew_license/widget/subscription_overview.dart';
import 'package:flutter/material.dart';

class HowToRenewLicenseScreen extends StatefulWidget {
  const HowToRenewLicenseScreen({super.key});

  @override
  State<HowToRenewLicenseScreen> createState() =>
      _HowToRenewLicenseScreenState();
}

class _HowToRenewLicenseScreenState extends State<HowToRenewLicenseScreen> {
  Workspace? agentInfo;

  @override
  void initState() {
    super.initState();
    _getAgent();
  }

  _getAgent() async {
    final info = (await GetAgent.byAgentId(context.workspace!.agentID));
    setState(() => agentInfo = info);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      subTitle: 'Software Subscription Licenses Guide',
      body: SubscriptionOverview(myAgent: agentInfo),
    );
  }
}
