const companyCategories = [
  'Retail Stores',
  'Pharmacies',
  'Healthcare',
  'Manufacturing',
  'Wholesale',
  'Hospitality',
  'Construction',
  'Real Estate Firms',
  'Logistics, Supply Chain',
  'Education',
  'Professional Services',
  'Agriculture',
  'Food Production',
  'Energy and Utilities',
];

const paymentTerms = [
  'payment terms',
  'cash',
  'credit',
  'cheque',
  'gift cards',
  'mobile money',
  'bank transfer',
  'cash in advance',
  'partial payment',
  'letter of credit',
  'payment upon delivery',
];

const paymentStatus = [
  'payment status',
  'unpaid',
  'fully paid',
  'installment',
  'partially paid',
];

const invoiceType = [
  'invoice type',
  'proforma invoice',
  'final invoice',
  'purchase order',
  'way bill',
  'receipt',
];

const category = ['category', 'small', 'medium', 'large', 'x-large', 'general'];

/// Sales Statuses
const saleStatus = ['sale status', 'pending', 'completed', 'returned'];

const deliveryTypes = [
  'delivery type',
  'in-person',
  'car',
  'motor rider',
  'mini-van',
  'truck',
  'standard',
  'express',
  'scheduled',
  'curb-side',
  'same-day',
  'on-demand',
  'shipping',
];

/// Delivery Statuses
const deliveryStatus = [
  'delivery status',
  'pending',
  'packed',
  'shipped / dispatched', // dispatched
  'in-transit',
  'delivered',
  'cancelled',
  'delayed',
];

/// Request For Quotation Statuses
const requestForQuoteStatus = [
  'quote status',
  'draft',
  'submitted',
  'open',
  'closed',
  'under-review',
  'awarded',
  'rejected',
  'cancelled',
];

/// Orders Sources
const orderSources = ['order source', 'website', 'in store', 'mobile app'];

/// Orders (SO) Statuses
const orderStatus = [
  'order status',
  'pending',
  'processing',
  'production',
  'shipped / dispatched', // dispatched
  'completed',
  'cancelled',
  'returned',
];

/// Purchase Order (PO) Statuses
const purchaseOrderStatus = [
  'order status',
  'draft',
  'pending approval',
  'approved',
  'sent to supplier',
  'confirmed by supplier',
  'partially fulfilled',
  'fulfilled',
  'received',
  'invoiced',
  'paid',
  'closed',
  'cancelled',
];

/// Sale Order: SO
final List<String> orderTypes = ['order type', 'sales order', 'return order'];

/// Miscellaneous Orders: any types of orders
final List<String> miscOrderTypes = [
  'order type',
  'return order',
  'transfer order',
  'work order',
  'service order',
  'back order',
  'consignment order',
  'drop ship order',
  'replacement order',
  'subscription order',
];

/// User manual Categories
final List<String> userManualCategories = [
  'agent',
  'setup',
  'pos',
  'crm',
  'inventory',
  'warehouse',
];
