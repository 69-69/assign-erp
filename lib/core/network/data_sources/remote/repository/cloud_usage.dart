/*
PRICING-OPTION-1:::
===================

Here are **tenant pricing model ideas** for an ERP system with multitenant architecture (like your workspace setup), tailored to **typical SaaS + ERP usage patterns**:

---

### 💡 Core Considerations

| Factor                             | Why it Matters                               |
| ---------------------------------- | -------------------------------------------- |
| **Storage Usage**                  | Limits or charges based on `dataSizeInBytes` |
| **Number of Users (Seats)**        | Common in business-tier plans                |
| **Features Accessed**              | Advanced modules: HR, Inventory, Finance     |
| **API Usage / Integrations**       | Higher tiers allow external integrations     |
| **Support Level**                  | Premium tiers offer SLA / support priority   |
| **Custom Workflows / Automations** | Premium-only                                 |
| **Number of Workspaces**           | Limit free/standard users to 1 workspace     |

---

### 🔢 Example Pricing Tiers

| Plan           | Monthly Price | Features                                                                                       |
| -------------- | ------------- | ---------------------------------------------------------------------------------------------- |
| **Free**       | \$0           | - 1 Workspace<br>- 3 Users<br>- 50MB data<br>- Core ERP modules                                |
| **Startup**    | \$29          | - 1 Workspace<br>- 10 Users<br>- 1GB data<br>- Custom reports<br>- Email support               |
| **Business**   | \$99          | - Unlimited workspaces<br>- 25 Users<br>- 5GB data<br>- Integrations<br>- Role permissions     |
| **Enterprise** | \$299+        | - Unlimited users/data<br>- Custom SLAs<br>- Private instance option<br>- Dedicated onboarding |

---

### 🧮 Optional Usage-Based Add-ons

| Usage Metric            | Pricing              |
| ----------------------- | -------------------- |
| Extra Storage           | \$0.20 / GB / month  |
| Extra User              | \$3 / user / month   |
| API Calls               | \$0.01 / 1000 calls  |
| Document Scanning / OCR | Per document pricing |
| Custom Modules          | \$ / module / tenant |

---

### 🧠 Technical Notes

To support this:

* Use a `billing` subcollection under each `workspace`
* Use your existing `usage` tracking for dynamic enforcement or overage alerts
* Consider tagging users by role (`isAdmin`, `isBillingOwner`) for access

---

Would you like a **Firestore structure suggestion** to track tenant plans and limits? Or help generating this in UI (Flutter)?




PRICING-OPTION-2::
=================

Great! Here's how you can **design your Firestore structure and logic** to support a **tenant-based pricing model** in your ERP system:

---

## 🔧 Firestore Structure for Tenants and Billing

### 📁 Collection: `workspaces/{workspaceId}`

#### 📄 Document Fields:

```json
{
  "name": "Acme Inc",
  "createdAt": "...",
  "subscriptionPlan": "business", // free | startup | business | enterprise
  "billingOwner": "user_abc",
  "isSuspended": false,
  "isTrial": true,
  "trialEndsAt": "...",
  "dataSizeInBytes": 1532490, // from your usage tracker
  "userCount": 12,
  "maxUsers": 25, // based on plan
  "maxStorageInBytes": 5368709120 // 5 GB
}
```

---

### 📁 Subcollection: `workspaces/{workspaceId}/usage`

Track advanced usage metrics:

```json
{
  "monthlyApiCalls": 10325,
  "monthlyInvoices": 325,
  "lastReset": "2025-07-01T00:00:00Z"
}
```

---

### 📁 Collection: `plans/{planId}`

Predefined limits for pricing tiers:

```json
{
  "name": "Business",
  "pricePerMonth": 99,
  "maxUsers": 25,
  "maxStorageInBytes": 5368709120,
  "apiLimit": 100000,
  "features": ["inventory", "multiWarehouse", "customReports"],
  "support": "email"
}
```

---

## ⚙️ Logic: Enforcing Usage in Flutter or Cloud

### 🧩 Option A: In Flutter

When a user adds new data:

```dart
if (workspace.dataSizeInBytes >= workspace.maxStorageInBytes) {
  showDialog(context: ..., builder: (_) => Alert("Storage limit exceeded"));
}
```

### 🧩 Option B: In Firebase Cloud Function (preferred for security)

```js
if (updatedUsage > workspace.maxStorageInBytes) {
  throw new functions.https.HttpsError('resource-exhausted', 'Storage limit exceeded.');
}
```

---

## 🧠 Bonus Features

| Feature            | How to Implement                                    |
| ------------------ | --------------------------------------------------- |
| **Trial Expiry**   | Use `trialEndsAt` + daily cloud function to suspend |
| **Upgrade Prompt** | Flutter UI check against plan's limits              |
| **Overage Alerts** | Cloud Functions + FCM/email when usage \~90%        |

---

Would you like a **Flutter UI widget** for displaying current plan + usage + upgrade CTA?






PRICING-OPTION-3::
==================

Perfect! Here's a **responsive full-width Flutter card widget** for showing **tenant subscription info** in your ERP dashboard, including plan name, usage limits, and an upgrade button.

---

### ✅ **Flutter Widget: TenantPlanOverviewCard**

```dart
import 'package:flutter/material.dart';

class TenantPlanOverviewCard extends StatelessWidget {
  final String planName;
  final int storageUsedBytes;
  final int maxStorageBytes;
  final int userCount;
  final int maxUsers;
  final VoidCallback onUpgradeTap;

  const TenantPlanOverviewCard({
    super.key,
    required this.planName,
    required this.storageUsedBytes,
    required this.maxStorageBytes,
    required this.userCount,
    required this.maxUsers,
    required this.onUpgradeTap,
  });

  String _formatBytes(int bytes) {
    if (bytes >= 1 << 30) return '${(bytes / (1 << 30)).toStringAsFixed(1)} GB';
    if (bytes >= 1 << 20) return '${(bytes / (1 << 20)).toStringAsFixed(1)} MB';
    return '${(bytes / (1 << 10)).toStringAsFixed(1)} KB';
  }

  double _usagePercent(int used, int max) {
    if (max == 0) return 0.0;
    return used / max;
  }

  @override
  Widget build(BuildContext context) {
    final storagePercent = _usagePercent(storageUsedBytes, maxStorageBytes);
    final userPercent = _usagePercent(userCount, maxUsers);

    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.blueGrey.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subscription Plan: $planName',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),

            // Storage
            Text(
              'Storage Usage: ${_formatBytes(storageUsedBytes)} / ${_formatBytes(maxStorageBytes)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            LinearProgressIndicator(value: storagePercent),

            const SizedBox(height: 16),

            // User count
            Text(
              'Users: $userCount / $maxUsers',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            LinearProgressIndicator(value: userPercent),

            const SizedBox(height: 24),

            // CTA
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: onUpgradeTap,
                icon: const Icon(Icons.upgrade),
                label: const Text("Upgrade Plan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 🧪 Example Usage

```dart
TenantPlanOverviewCard(
  planName: "Business",
  storageUsedBytes: 1_000_000_000,
  maxStorageBytes: 5_000_000_000,
  userCount: 12,
  maxUsers: 25,
  onUpgradeTap: () {
    Navigator.pushNamed(context, "/billing/upgrade");
  },
)
```

---

### 💡 Optional Enhancements

* Show API usage bar
* Trial expiry countdown (e.g. `14 days remaining`)
* Tooltip on limits
* Dynamic color if over quota (e.g. red bar)

Would you like a dark-mode friendly version or want to include pricing info too?













OPTION-0:::
Exactly — **Option 2** is the most scalable and efficient way to track Firestore usage for multi-tenant apps like your ERP.

Here’s a breakdown of **how to implement it cleanly** in your system:

---

### ✅ **What You're Doing**

Every time a document is created, updated, or deleted inside a tenant’s workspace (e.g., `workspaces/{workspaceId}/collection/{docId}`), you:

* Estimate the size change (`afterSize - beforeSize`)
* Update a usage document like:

  ```
  workspaces/{workspaceId}/usage
    → dataSizeInBytes: total bytes used
    → lastUpdated: timestamp
  ```

---

### 📦 Why This Is Ideal

| 🔍 Feature        | ✅ Benefit                                       |
| ----------------- | ----------------------------------------------- |
| Real-time         | Tracks changes as they happen                   |
| Efficient         | No need to scan whole collections               |
| Scalable          | Works well for thousands of tenants             |
| Billable-friendly | You can charge based on actual usage easily     |
| Customizable      | Extend usage to include read/write counts, etc. |

---

### 🛠️ Firebase Setup (Cloud Function)

You've already got the core logic (good job). Just ensure you deploy it using Firebase CLI.

Example Cloud Function (Node.js):

```js
exports.trackFirestoreUsage = functions.firestore
  .document('workspaces/{workspaceId}/{collectionId}/{docId}')
  .onWrite(async (change, context) => {
    const { workspaceId } = context.params;
    const beforeData = change.before.exists ? change.before.data() : null;
    const afterData = change.after.exists ? change.after.data() : null;

    const beforeSize = beforeData ? estimateDocSize(beforeData) : 0;
    const afterSize = afterData ? estimateDocSize(afterData) : 0;
    const sizeChange = afterSize - beforeSize;

    const usageRef = db.doc(`workspaces/${workspaceId}/usage`);
    await db.runTransaction(async (t) => {
      const usageSnap = await t.get(usageRef);
      const currentUsage = usageSnap.exists ? usageSnap.data().dataSizeInBytes || 0 : 0;
      const newUsage = Math.max(0, currentUsage + sizeChange);

      t.set(usageRef, {
        dataSizeInBytes: newUsage,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true });
    });
  });
```

---

### 🧪 On the Flutter Side (optional display)

```dart
final usageDoc = await FirebaseFirestore.instance
  .doc('workspaces/$workspaceId/usage')
  .get();

final dataSize = usageDoc.data()?['dataSizeInBytes'] ?? 0;
final mbUsed = (dataSize / (1024 * 1024)).toStringAsFixed(2);
```

Display this in your dashboard as:

```plaintext
Data usage: 3.45 MB of 100 MB
```

---

### 📘 Tip:

You can also track:

* Document count
* Read/write counts
* Cost estimation (if you're metering by usage)

Let me know if you'd like help extending the usage tracking or building a quota system per tenant.




OPTION-0.1::
===========

Great! Here's how you can **extend the usage tracking** to give each workspace a clear overview and support future billing or quota limits in your ERP system:

---

## 🔁 Extended Usage Tracking for ERP Workspaces

You're already tracking `dataSizeInBytes` — now let’s add:

### ✅ Recommended Fields in `workspaces/{workspaceId}/usage`:

| Field             | Type        | Purpose                                    |
| ----------------- | ----------- | ------------------------------------------ |
| `dataSizeInBytes` | `int`       | Current total storage usage                |
| `docCount`        | `int`       | Number of documents in workspace           |
| `readCount`       | `int`       | Total document reads (optional)            |
| `writeCount`      | `int`       | Total writes (create/update/delete)        |
| `lastUpdated`     | `timestamp` | Last time the usage was updated            |
| `billingPlan`     | `string`    | Optional: `free`, `standard`, `enterprise` |
| `quotaInBytes`    | `int`       | Optional: maximum storage for the plan     |

---

## 🔧 Update Cloud Function to Track More Usage

Here’s an improved version of your Cloud Function to also track:

* document count
* write count
* optional quota breach warning

```js
exports.trackFirestoreUsage = functions.firestore
  .document('workspaces/{workspaceId}/{collectionId}/{docId}')
  .onWrite(async (change, context) => {
    const { workspaceId } = context.params;
    const beforeData = change.before.exists ? change.before.data() : null;
    const afterData = change.after.exists ? change.after.data() : null;

    const beforeSize = beforeData ? estimateDocSize(beforeData) : 0;
    const afterSize = afterData ? estimateDocSize(afterData) : 0;
    const sizeChange = afterSize - beforeSize;

    const usageRef = db.doc(`workspaces/${workspaceId}/usage`);
    await db.runTransaction(async (t) => {
      const usageSnap = await t.get(usageRef);
      const usageData = usageSnap.exists ? usageSnap.data() : {};

      const currentUsage = usageData.dataSizeInBytes || 0;
      const currentDocCount = usageData.docCount || 0;
      const currentWriteCount = usageData.writeCount || 0;

      let updatedDocCount = currentDocCount;
      if (!change.before.exists && change.after.exists) {
        updatedDocCount += 1; // new document
      } else if (change.before.exists && !change.after.exists) {
        updatedDocCount = Math.max(0, currentDocCount - 1); // deleted
      }

      const updatedUsage = Math.max(0, currentUsage + sizeChange);
      const updatedWriteCount = currentWriteCount + 1;

      t.set(usageRef, {
        dataSizeInBytes: updatedUsage,
        docCount: updatedDocCount,
        writeCount: updatedWriteCount,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      // Optional: send alert or flag if over quota
      const quota = usageData.quotaInBytes || 100 * 1024 * 1024; // 100MB default
      if (updatedUsage > quota) {
        console.warn(`⚠️ Workspace ${workspaceId} exceeded quota`);
        // Consider writing an alert document or triggering an email
      }
    });
  });
```

---

## 📊 Flutter UI (Dashboard Card Example)

Show this in a workspace usage widget:

```dart
final usageDoc = await FirebaseFirestore.instance
  .doc('workspaces/$workspaceId/usage')
  .get();

final data = usageDoc.data();
final bytes = data?['dataSizeInBytes'] ?? 0;
final quota = data?['quotaInBytes'] ?? 100 * 1024 * 1024;
final docCount = data?['docCount'] ?? 0;
final writeCount = data?['writeCount'] ?? 0;

final usageMB = (bytes / (1024 * 1024)).toStringAsFixed(2);
final quotaMB = (quota / (1024 * 1024)).toStringAsFixed(2);

Text("Used: $usageMB MB of $quotaMB MB"),
Text("Documents: $docCount"),
Text("Total Writes: $writeCount"),
```

---

## 📘 Future Ideas:

* Limit features when quota is exceeded (e.g. disable writes).
* Add a background scheduler to compute monthly usage summaries.
* Integrate with Stripe or another billing system for automatic charges.

---

Would you like help adding:

* alerts when usage exceeds limits?
* integration with billing plans?
* quota enforcement?

Let me know how far you'd like to go with this.





OPTION-1::
==========

Perfect — if you’re building a **multi-tenant ERP system** using **Firebase (Firestore)** and want to **track data size per workspace/tenant** for **billing or subscription tiers**, here’s a practical and scalable approach.

---

## ✅ Goal

You want to estimate:

* **How much data each workspace/tenant is using**, so you can:

  * Monitor storage usage
  * Enforce limits (based on subscription tier)
  * Bill accurately or restrict access

---

## 🧠 Assumptions

* Each **tenant/workspace** has a unique `workspaceId` (or similar).
* Your Firestore is structured like:

  ```
  workspaces/{workspaceId}/users
  workspaces/{workspaceId}/products
  workspaces/{workspaceId}/orders
  ...
  ```

---

## ✅ Option 1: Estimate Firestore Data Size Programmatically

### 🔧 Step 1: Create a utility to calculate document size

```dart
import 'dart:convert';

int estimateDocSize(Map<String, dynamic> data) {
  return utf8.encode(jsonEncode(data)).length;
}
```

---

### 🔧 Step 2: Sum all documents per workspace

```dart
Future<int> estimateWorkspaceDataSize(String workspaceId) async {
  int totalSize = 0;
  final firestore = FirebaseFirestore.instance;

  final collections = ['users', 'products', 'orders']; // Add more as needed

  for (String col in collections) {
    final snapshot = await firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection(col)
        .get();

    for (var doc in snapshot.docs) {
      totalSize += estimateDocSize(doc.data());
    }
  }

  return totalSize;
}
```

---

### 💡 Optionally Convert to MB

```dart
String formatSize(int sizeInBytes) {
  final sizeInMB = sizeInBytes / (1024 * 1024);
  return '${sizeInMB.toStringAsFixed(2)} MB';
}
```

---

### 🧪 Example Usage

```dart
final sizeInBytes = await estimateWorkspaceDataSize('workspace_123');
print("Workspace data usage: ${formatSize(sizeInBytes)}");
```

---

## ✅ Option 2: Store and Track Usage on Writes (More Efficient at Scale)

To avoid scanning thousands of documents repeatedly, you can:

1. **Track write size per operation**
2. **Update a counter field in Firestore**, e.g., `workspaces/{workspaceId}/usage.dataSizeInBytes`

This gives near real-time billing data without full collection scans.

---

## ✅ Bonus: Set Workspace Limits

```dart
const int maxFreeTierBytes = 5 * 1024 * 1024; // 5 MB

if (currentSizeInBytes > maxFreeTierBytes) {
  showUpgradeDialog();
}
```

---

## 🧾 Firebase Billing Considerations

| Plan                      | Limits                             |
| ------------------------- | ---------------------------------- |
| **Free (Spark)**          | 1 GB storage                       |
| **Blaze (Pay-as-you-go)** | Billed by data stored & operations |
| Firestore Max Doc Size    | 1 MB per document                  |
| Realtime DB Max           | 256 MB per node                    |

---

## ✅ Recommended for ERP Tenants

1. **Track workspace usage regularly**
2. **Store metadata in a `usage` document per workspace**
3. Optionally, **send alerts or lock features** based on tier

---

Would you like help implementing automatic tracking with Firestore triggers or background functions (e.g. Firebase Functions or Cloud Scheduler)?

OPTION-2::
===========
Great! If you want to **automatically track each tenant's (workspace's) Firestore usage**, the best way is to use **Firebase Cloud Functions** to:

---

## ✅ What We'll Do

1. **Track write sizes** on `create`/`update`/`delete`
2. **Update usage totals** in each workspace's metadata (e.g., `workspaces/{workspaceId}/usage`)
3. **Enforce limits or notify users**

---

## 📦 Setup Required

Before we start, make sure you have:

1. Firebase project set up

2. Firestore structure like:

   ```
   workspaces/{workspaceId}/[subcollections]
   ```

3. Firebase CLI installed:

   ```bash
   npm install -g firebase-tools
   ```

4. Initialize Cloud Functions in your project:

   ```bash
   firebase init functions
   ```

---

## ⚙️ Example Cloud Function (Firestore Usage Tracker)

Inside `functions/index.js` or `functions/src/index.ts` (for TypeScript):

### 🔧 JavaScript Example

```js
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

/**
 * Utility: Estimate size in bytes of a Firestore document
 */
function estimateDocSize(data) {
  const json = JSON.stringify(data);
  return Buffer.byteLength(json, 'utf8');
}

/**
 * Track writes and update workspace usage
 */
exports.trackFirestoreUsage = functions.firestore
  .document('workspaces/{workspaceId}/{collectionId}/{docId}')
  .onWrite(async (change, context) => {
    const { workspaceId } = context.params;

    const beforeData = change.before.exists ? change.before.data() : null;
    const afterData = change.after.exists ? change.after.data() : null;

    const beforeSize = beforeData ? estimateDocSize(beforeData) : 0;
    const afterSize = afterData ? estimateDocSize(afterData) : 0;

    const sizeChange = afterSize - beforeSize; // can be negative on delete

    const usageRef = db.doc(`workspaces/${workspaceId}/usage`);
    await db.runTransaction(async (t) => {
      const usageSnap = await t.get(usageRef);
      const currentUsage = usageSnap.exists ? usageSnap.data().dataSizeInBytes || 0 : 0;
      const updatedUsage = Math.max(0, currentUsage + sizeChange);

      t.set(usageRef, {
        dataSizeInBytes: updatedUsage,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true });
    });
  });
```

---

## ✅ What This Does

* Watches **all writes under `workspaces/{workspaceId}`**
* Tracks size differences on **create/update/delete**
* Updates `workspaces/{workspaceId}/usage` document:

  ```json
  {
    "dataSizeInBytes": 241332,
    "lastUpdated": "..."
  }
  ```

---

## 📌 Where to Enforce Subscription Limits

You can enforce limits either:

| Location             | Purpose                                                                                                                    |
| -------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| ✅ **Flutter client** | Disable uploads or alert user when limit is hit                                                                            |
| ✅ **Cloud Function** | Block writes using [Callable Functions](https://firebase.google.com/docs/functions/callable) or [Security Rules](advanced) |

---

## 🚀 Deploy

```bash
firebase deploy --only functions
```

---

## 🔔 Want More?

* [ ] Setup **monthly resets** using **Cloud Scheduler**
* [ ] Add **Firebase Alerts or Emails** on threshold reached
* [ ] Store **collection-level breakdowns** (optional but useful for analytics)
* [ ] Implement **Firestore Security Rules** to block writes when over limit

---

Would you like help with any of these next steps or setting this up in TypeScript?




OPTION-3::
===========
Great — let’s now connect your **Cloud Functions-based usage tracking** in your **Flutter ERP app**, so each workspace (tenant) knows how much Firestore data they’re using, and you can **enforce limits or show upgrade prompts**.

---

## ✅ What You’ve Already Got from Cloud Functions

Your function stores data usage at:

```json
workspaces/{workspaceId}/usage {
  dataSizeInBytes: 241332,
  lastUpdated: ...
}
```

---

## ✅ Step-by-Step in Flutter

### 📦 1. Add dependencies

```yaml
dependencies:
  cloud_firestore: ^4.9.0
  flutter_riverpod: ^2.5.1 # if using for state management
```

---

### 📄 2. Define a Usage Model

```dart
class WorkspaceUsage {
  final int dataSizeInBytes;
  final DateTime? lastUpdated;

  WorkspaceUsage({required this.dataSizeInBytes, this.lastUpdated});

  factory WorkspaceUsage.fromMap(Map<String, dynamic> map) {
    return WorkspaceUsage(
      dataSizeInBytes: map['dataSizeInBytes'] ?? 0,
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }
}
```

---

### 📲 3. Fetch Workspace Usage

```dart
Future<WorkspaceUsage?> getWorkspaceUsage(String workspaceId) async {
  final doc = await FirebaseFirestore.instance
      .collection('workspaces')
      .doc(workspaceId)
      .collection('usage')
      .doc('usage') // or just 'workspaces/{id}/usage' if flat
      .get();

  if (!doc.exists) return null;

  return WorkspaceUsage.fromMap(doc.data()!);
}
```

> ⚠️ Make sure the `usage` document is in the **correct location** (flat under `workspaces/{id}` or in a subcollection like `usage/data`).

---

### 💻 4. Display Usage in UI

```dart
class WorkspaceUsageCard extends StatelessWidget {
  final String workspaceId;

  const WorkspaceUsageCard({required this.workspaceId, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WorkspaceUsage?>(
      future: getWorkspaceUsage(workspaceId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final usage = snapshot.data!;
        final mb = (usage.dataSizeInBytes / (1024 * 1024)).toStringAsFixed(2);

        return Card(
          child: ListTile(
            title: Text('Data Usage: $mb MB'),
            subtitle: usage.lastUpdated != null
                ? Text('Last updated: ${usage.lastUpdated}')
                : null,
          ),
        );
      },
    );
  }
}
```

---

## 🚨 5. Enforce Subscription Limits

Let’s say you have 3 tiers:

| Tier     | Limit  |
| -------- | ------ |
| Free     | 5 MB   |
| Pro      | 50 MB  |
| Business | 200 MB |

You can enforce this in your Flutter app:

```dart
void checkUsageAndWarn(BuildContext context, WorkspaceUsage usage) {
  const maxAllowedBytes = 5 * 1024 * 1024; // Free Tier

  if (usage.dataSizeInBytes > maxAllowedBytes) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Upgrade Required"),
        content: const Text("You've exceeded your free tier. Upgrade for more storage."),
        actions: [
          TextButton(
            child: const Text("Upgrade"),
            onPressed: () {
              Navigator.pop(context);
              // Navigate to upgrade page
            },
          ),
        ],
      ),
    );
  }
}
```

---

## 🔒 6. (Optional) Block Writes When Over Limit

To *block writes* if a workspace is over its quota, you’d need:

* Firestore **Security Rules** to read `usage.dataSizeInBytes`
* Use a **custom claim** or write through a **Cloud Function**

Let me know if you want that too — it's a slightly deeper step.

---

## ✅ Summary

| ✅ Task                           | Done?                                  |
| -------------------------------- | -------------------------------------- |
| Setup usage tracking in Firebase | ✅ Cloud Function handles it            |
| Fetch usage in Flutter           | ✅ `getWorkspaceUsage()`                |
| Display usage in UI              | ✅ `WorkspaceUsageCard`                 |
| Enforce usage limits             | ✅ Warning dialog                       |
| (Optional) Block writes          | 🔒 Can be done with rules or functions |

---

Would you like me to help:

* Build a complete `UsageService` in Flutter?
* Add auto-refresh using `StreamBuilder`?
* Implement tier-based billing logic?

Let me know!




OPTION-4::
===========
Great question — you're already using a **Cloud Function** to track Firestore data size on every write. That logic lives **in Firebase (server-side)**, and Flutter doesn't run or implement that function directly.

But here's how it **connects with Flutter**:

---

## 🔄 What Happens in the Background (Server-Side)

This part:

```js
exports.trackFirestoreUsage = functions.firestore
  .document('workspaces/{workspaceId}/{collectionId}/{docId}')
  .onWrite(async (change, context) => {
```

✅ Automatically triggers on *any* Firestore change inside `workspaces/{workspaceId}` — on **create**, **update**, or **delete**.

🔁 It:

* Calculates size diff
* Updates: `workspaces/{workspaceId}/usage` → `{ dataSizeInBytes: ..., lastUpdated: ... }`

---

## 🧠 How Flutter Uses It

In **Flutter**, you **don't call the function directly**.

Instead, you **read the updated usage data** from Firestore like this:

---

### ✅ 1. Fetch Usage in Flutter

```dart
Future<WorkspaceUsage?> getWorkspaceUsage(String workspaceId) async {
  final doc = await FirebaseFirestore.instance
    .collection('workspaces')
    .doc(workspaceId)
    .collection('usage') // or .doc('usage') if flat
    .doc('usage')
    .get();

  if (!doc.exists) return null;

  return WorkspaceUsage.fromMap(doc.data()!);
}
```

---

### 🖼️ 2. Display in UI

```dart
class UsageInfoTile extends StatelessWidget {
  final String workspaceId;

  const UsageInfoTile({required this.workspaceId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getWorkspaceUsage(workspaceId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final usage = snapshot.data!;
        final mb = (usage.dataSizeInBytes / (1024 * 1024)).toStringAsFixed(2);

        return ListTile(
          title: Text("Used: $mb MB"),
          subtitle: Text("Last updated: ${usage.lastUpdated}"),
        );
      },
    );
  }
}
```

---

### 📦 Example Firestore Data Structure

After your Cloud Function runs, Firestore will have something like:

```
workspaces/
  workspaceA/
    usage/
      usage (doc) => {
        dataSizeInBytes: 1052484,
        lastUpdated: <Timestamp>
      }
    products/
    employees/
    orders/
```

Or, if you're using flat structure:

```
workspaces/
  workspaceA/
    usage: {
      dataSizeInBytes: 1052484,
      lastUpdated: ...
    }
```

📌 Adjust your `getWorkspaceUsage()` accordingly (flat or nested).

---

### 🔐 Enforce Usage Logic in Flutter

Use the `dataSizeInBytes` value to:

* Show upgrade prompts
* Disable upload buttons
* Hide creation forms if over quota

Example:

```dart
if (usage.dataSizeInBytes > 5 * 1024 * 1024) {
  // 5 MB limit (for free tier)
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Storage Limit Exceeded"),
      content: Text("Upgrade your plan to store more data."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Upgrade"),
        ),
      ],
    ),
  );
}
```

---

## 🔄 Summary: Flutter ↔ Cloud Function

| What                              | Where              |
| --------------------------------- | ------------------ |
| Tracks Firestore writes           | **Cloud Function** |
| Calculates size diff              | **Cloud Function** |
| Saves usage to Firestore          | **Cloud Function** |
| Reads & displays usage            | **Flutter App**    |
| Enforces logic or UI restrictions | **Flutter App**    |

---

### ✅ You Don’t Have To:

* Call the Cloud Function manually
* Calculate document sizes on the client

---

Want help:

* Streaming live usage updates in Flutter?
* Creating a visual "storage bar" (like 2.5 MB of 5 MB used)?
* Integrating with Stripe or Razorpay for paid plans?

Let me know — happy to guide!




OPTION-5::
===========
You're on the right track — but **no**, you **don’t paste that code directly into the Firebase Console**. That JavaScript code belongs in a **Cloud Functions project**, which you set up locally using the Firebase CLI.

Here’s how to **properly set it up**:

---

### ✅ 1. **Install Firebase CLI**

If not already installed:

```bash
npm install -g firebase-tools
```

---

### ✅ 2. **Initialize Functions in Your Project**

Navigate to your project folder (or create one):

```bash
firebase init functions
```

* Choose `JavaScript` or `TypeScript`
* Select your Firebase project
* Enable ESLint if you like
* Say **yes** to installing dependencies

It will create a folder:

```
functions/
  └── index.js (or index.ts)
```

---

### ✅ 3. **Paste Your Function Code**

Open `functions/index.js` and **replace or add** this:

```js
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

function estimateDocSize(data) {
  const json = JSON.stringify(data);
  return Buffer.byteLength(json, 'utf8');
}

exports.trackFirestoreUsage = functions.firestore
  .document('workspaces/{workspaceId}/{collectionId}/{docId}')
  .onWrite(async (change, context) => {
    const { workspaceId } = context.params;

    const beforeData = change.before.exists ? change.before.data() : null;
    const afterData = change.after.exists ? change.after.data() : null;

    const beforeSize = beforeData ? estimateDocSize(beforeData) : 0;
    const afterSize = afterData ? estimateDocSize(afterData) : 0;

    const sizeChange = afterSize - beforeSize;

    const usageRef = db.doc(`workspaces/${workspaceId}/usage`);
    await db.runTransaction(async (t) => {
      const usageSnap = await t.get(usageRef);
      const currentUsage = usageSnap.exists ? usageSnap.data().dataSizeInBytes || 0 : 0;
      const updatedUsage = Math.max(0, currentUsage + sizeChange);

      t.set(usageRef, {
        dataSizeInBytes: updatedUsage,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true });
    });
  });
```

---

### ✅ 4. **Deploy Your Function**

Run:

```bash
firebase deploy --only functions
```

Firebase will deploy `trackFirestoreUsage` to your project.

---

### ✅ 5. **Confirm It's Live**

After deployment, any write inside:

```
workspaces/{workspaceId}/{collectionId}/{docId}
```

will trigger the function.

Check in Firestore at:

```
workspaces/{workspaceId}/usage
```

for the `dataSizeInBytes` value.

---

### 📦 Bonus: Organize Your Billing Tiers

Use `dataSizeInBytes` in your app to:

* Block features when limit exceeded
* Show progress bar (`e.g., Used 4.2 MB of 5 MB`)
* Trigger Stripe upgrade dialogs

---

### ❗ Tip

Want to exclude certain collections like `logs` or `usage` itself?

Change this line:

```js
.document('workspaces/{workspaceId}/{collectionId}/{docId}')
```

To:

```js
.document('workspaces/{workspaceId}/{collectionId}/{docId}')
  .onWrite((change, context) => {
    const { collectionId } = context.params;
    if (collectionId === 'usage' || collectionId === 'logs') return null;
    ...
  })
```

---

Would you like a **custom usage dashboard UI** for Flutter or help with **Firestore rules** based on size? I can guide you further.


* */
