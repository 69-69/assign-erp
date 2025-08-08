import 'package:assign_erp/features/access_control/data/model/access_control_model.dart';

/// PERMISSION BASED ACCESS-CONTROL
enum CrmPermission {
  manageCRM,
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
  createCustomer,
  addCustomerNote,
  viewCRMReports,
  exportCRMData,
  viewCrmSecrets,
}

final List<AccessControl> _crmPermissionDetails = [
  AccessControl(
    module: "crm",
    title: "Manage CRM",
    description:
        "Allows users to manage CRM records, including creation, modification, and removal.",
    access: CrmPermission.manageCRM,
  ),
];

final List<AccessControl> _leadsPermissions = [
  AccessControl(
    module: "crm create",
    title: "Create Customer",
    description: "Allow users to create a new customer account.",
    access: CrmPermission.createCustomer,
  ),
  AccessControl(
    module: "crm lead",
    title: "View Leads",
    description: "Allow users to view all sales leads.",
    access: CrmPermission.viewLeads,
  ),
  AccessControl(
    module: "crm lead",
    title: "Create Lead",
    description: "Allow users to create new leads.",
    access: CrmPermission.createLead,
  ),
  AccessControl(
    module: "crm lead",
    title: "Edit Lead",
    description: "Allow users to update lead information.",
    access: CrmPermission.editLead,
  ),
  AccessControl(
    module: "crm lead",
    title: "Delete Lead",
    description: "Allow users to remove leads from the system.",
    access: CrmPermission.deleteLead,
  ),
  AccessControl(
    module: "crm lead",
    title: "Assign Lead",
    description: "Allow users to assign leads to team members.",
    access: CrmPermission.assignLead,
  ),
  AccessControl(
    module: "crm lead",
    title: "Convert Lead",
    description:
        "Allow users to convert leads into opportunities or customers.",
    access: CrmPermission.convertLead,
  ),
];

final List<AccessControl> _contactsPermissions = [
  AccessControl(
    module: "crm contacts",
    title: "View Contacts",
    description: "Allow users to view contact profiles.",
    access: CrmPermission.viewContacts,
  ),
  AccessControl(
    module: "crm contacts",
    title: "Create Contact",
    description: "Allow users to add new contacts.",
    access: CrmPermission.createContact,
  ),
  AccessControl(
    module: "crm contacts",
    title: "Edit Contact",
    description: "Allow users to edit existing contact information.",
    access: CrmPermission.editContact,
  ),
  AccessControl(
    module: "crm contacts",
    title: "Delete Contact",
    description: "Allow users to delete contacts from the system.",
    access: CrmPermission.deleteContact,
  ),
];

final List<AccessControl> _opportunitiesPermissions = [
  AccessControl(
    module: "crm opportunity",
    title: "View Opportunities",
    description: "Allow users to view opportunity pipelines.",
    access: CrmPermission.viewOpportunities,
  ),
  AccessControl(
    module: "crm opportunity",
    title: "Create Opportunity",
    description: "Allow users to create new opportunities.",
    access: CrmPermission.createOpportunity,
  ),
  AccessControl(
    module: "crm opportunity",
    title: "Edit Opportunity",
    description: "Allow users to modify opportunity details.",
    access: CrmPermission.editOpportunity,
  ),
  AccessControl(
    module: "crm opportunity",
    title: "Delete Opportunity",
    description: "Allow users to delete opportunities.",
    access: CrmPermission.deleteOpportunity,
  ),
  AccessControl(
    module: "crm opportunity",
    title: "Update Opportunity Stage",
    description: "Allow users to move opportunities through stages.",
    access: CrmPermission.updateOpportunityStage,
  ),
];

final List<AccessControl> _customersPermissions = [
  AccessControl(
    module: "crm customer",
    title: "View Customer Profiles",
    description: "Allow users to view customer records and history.",
    access: CrmPermission.viewCustomerProfile,
  ),
  AccessControl(
    module: "crm customer",
    title: "Edit Customer Profile",
    description: "Allow users to update customer information.",
    access: CrmPermission.editCustomerProfile,
  ),
  AccessControl(
    module: "crm customer",
    title: "Add Customer Note",
    description: "Allow users to log notes and updates for customers.",
    access: CrmPermission.addCustomerNote,
  ),
];

final List<AccessControl> _crmMetricsPermissions = [
  AccessControl(
    module: "crm metrics",
    title: "View CRM Reports",
    description: "Allow users to view analytics and performance reports.",
    access: CrmPermission.viewCRMReports,
  ),
  AccessControl(
    module: "crm metrics",
    title: "Export CRM Data",
    description: "Allow users to export CRM-related data.",
    access: CrmPermission.exportCRMData,
  ),
];

final List<AccessControl> _secretPermissionDetails = [
  AccessControl(
    module: "CRM Secrets",
    title: "View Customer IDs",
    description:
        "Allow users to view the reference numbers or IDs of customers.",
    access: CrmPermission.viewCrmSecrets,
  ),
];

final List<AccessControl> crmPermissions = [
  ..._crmPermissionDetails,
  ..._leadsPermissions,
  ..._contactsPermissions,
  ..._opportunitiesPermissions,
  ..._customersPermissions,
  ..._crmMetricsPermissions,
  ..._secretPermissionDetails,
];

final crmDisplayName = 'customer management';
