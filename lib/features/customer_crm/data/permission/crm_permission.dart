import 'package:assign_erp/core/network/data_sources/models/permission_item_model.dart';

/// PERMISSION BASED ACCESS-CONTROL
enum CrmPermission {
  viewLeads,
  createLead,
  editLead,
  deleteLead,
  assignLead,
  convertLead,
  viewContacts,
  createContact,
  editContact,
  deleteContact,
  viewOpportunities,
  createOpportunity,
  editOpportunity,
  deleteOpportunity,
  updateOpportunityStage,
  viewCustomerProfile,
  editCustomerProfile,
  addCustomerNote,
  viewCRMReports,
  exportCRMData,
}

final List<PermissionItem> _leadsPermissions = [
  PermissionItem(
    module: "crm lead",
    title: "View Leads",
    subtitle: "Allow users to view all sales leads.",
    permission: CrmPermission.viewLeads,
  ),
  PermissionItem(
    module: "crm lead",
    title: "Create Lead",
    subtitle: "Allow users to create new leads.",
    permission: CrmPermission.createLead,
  ),
  PermissionItem(
    module: "crm lead",
    title: "Edit Lead",
    subtitle: "Allow users to update lead information.",
    permission: CrmPermission.editLead,
  ),
  PermissionItem(
    module: "crm lead",
    title: "Delete Lead",
    subtitle: "Allow users to remove leads from the system.",
    permission: CrmPermission.deleteLead,
  ),
  PermissionItem(
    module: "crm lead",
    title: "Assign Lead",
    subtitle: "Allow users to assign leads to team members.",
    permission: CrmPermission.assignLead,
  ),
  PermissionItem(
    module: "crm lead",
    title: "Convert Lead",
    subtitle: "Allow users to convert leads into opportunities or customers.",
    permission: CrmPermission.convertLead,
  ),
];

final List<PermissionItem> _contactsPermissions = [
  PermissionItem(
    module: "crm contacts",
    title: "View Contacts",
    subtitle: "Allow users to view contact profiles.",
    permission: CrmPermission.viewContacts,
  ),
  PermissionItem(
    module: "crm contacts",
    title: "Create Contact",
    subtitle: "Allow users to add new contacts.",
    permission: CrmPermission.createContact,
  ),
  PermissionItem(
    module: "crm contacts",
    title: "Edit Contact",
    subtitle: "Allow users to edit existing contact information.",
    permission: CrmPermission.editContact,
  ),
  PermissionItem(
    module: "crm contacts",
    title: "Delete Contact",
    subtitle: "Allow users to delete contacts from the system.",
    permission: CrmPermission.deleteContact,
  ),
];

final List<PermissionItem> _opportunitiesPermissions = [
  PermissionItem(
    module: "crm opportunity",
    title: "View Opportunities",
    subtitle: "Allow users to view opportunity pipelines.",
    permission: CrmPermission.viewOpportunities,
  ),
  PermissionItem(
    module: "crm opportunity",
    title: "Create Opportunity",
    subtitle: "Allow users to create new opportunities.",
    permission: CrmPermission.createOpportunity,
  ),
  PermissionItem(
    module: "crm opportunity",
    title: "Edit Opportunity",
    subtitle: "Allow users to modify opportunity details.",
    permission: CrmPermission.editOpportunity,
  ),
  PermissionItem(
    module: "crm opportunity",
    title: "Delete Opportunity",
    subtitle: "Allow users to delete opportunities.",
    permission: CrmPermission.deleteOpportunity,
  ),
  PermissionItem(
    module: "crm opportunity",
    title: "Update Opportunity Stage",
    subtitle: "Allow users to move opportunities through stages.",
    permission: CrmPermission.updateOpportunityStage,
  ),
];

final List<PermissionItem> _customersPermissions = [
  PermissionItem(
    module: "crm customer",
    title: "View Customer Profiles",
    subtitle: "Allow users to view customer records and history.",
    permission: CrmPermission.viewCustomerProfile,
  ),
  PermissionItem(
    module: "crm customer",
    title: "Edit Customer Profile",
    subtitle: "Allow users to update customer information.",
    permission: CrmPermission.editCustomerProfile,
  ),
  PermissionItem(
    module: "crm customer",
    title: "Add Customer Note",
    subtitle: "Allow users to log notes and updates for customers.",
    permission: CrmPermission.addCustomerNote,
  ),
];

final List<PermissionItem> _crmMetricsPermissions = [
  PermissionItem(
    module: "crm metrics",
    title: "View CRM Reports",
    subtitle: "Allow users to view analytics and performance reports.",
    permission: CrmPermission.viewCRMReports,
  ),
  PermissionItem(
    module: "crm metrics",
    title: "Export CRM Data",
    subtitle: "Allow users to export CRM-related data.",
    permission: CrmPermission.exportCRMData,
  ),
];

final List<PermissionItem> crmPermissions = [
  ..._leadsPermissions,
  ..._contactsPermissions,
  ..._opportunitiesPermissions,
  ..._customersPermissions,
  ..._crmMetricsPermissions,
];

final crmDisplayName = 'customer relation';
