# assign_erp


git init
git add .
git commit -m "Change UI Tile and side_nav bg color"
git branch -M main
git push -u origin main

---

# 🔐 ERP Authentication Flow (Two-Tier)

### 🧩 1. Workspace Sign-In (Tenant-Level Access)
Authenticate using your organization's **Workspace Email** and **Password** to access the organization's workspace.

### 👨‍💼 2. Employee Sign-In (User-Level Access)
After workspace authentication, sign in as a specific **Employee** using your **Employee Email** and **Passcode**.

---


# ⚙️ Onboarding Flow Structure (Three-Tier)

1. **Initial Setup**  
   New Agents begin by signing in using the provided `Onboarding` or `Initial-Setup` Workspace Email and Password.

2. **Create a New Workspace (Agent)**  
   After signing in, Agents can create their new Workspace by clicking the **"Setup New Workspace"** button.
   While the Workspace is being created, an Agent has the option to auto-generate **Temporary Employee Passcode**.
   This is used after the **Workspace Successful SignIn** to sign in to the **Employee portal** using the **Employee Email + Temporary Passcode**.

---

# 👨‍💼 Creating a Subscriber (Tenant/Client) Workspace

1. The Agent signs in to their own Workspace.
2. Navigate to the **Agent** section and click **"Setup New Workspace"**.
3. Fill in the required details and click **"Create Workspace"**.
4. An Agent has the option to auto-generate **Temporary Employee Passcode** is sent to the Subscriber's email.  
5. The Subscriber uses this, along with their Employee Email and Passcode, to sign in after completing the Workspace Sign-In process.
6. Upon their first login through the Employee Sign-In Portal, they will be prompted to create a new personal passcode.

> **Note:**  
> Clients can reset their Workspace Password anytime using the **"Forgot Password"** option on the Workspace Sign-In screen.

---

## 🔐 Passcode Expiry Notice

- The default Temporary (Auto-Generated) Passcode **expires after 7 days**.
- Employees are Prompted to create a **preferred Passcode** upon first sign-in.

---

# 🔄 Resetting Credentials

## 🔐 Resetting Workspace Password

1. On the Workspace Sign-In screen, click **"Forgot Password"**.
2. Follow the instructions sent to the registered **Workspace email** to reset the password.

## 🔐 Resetting Employee Passcode

In addition to the **First login Prompt**, Employees can reset their Passcode manually:

1. Log in to the Organization's Workspace, then into Employee's account.
2. Go to the **Setup** section → **Staff Accounts** tab.
3. Click **"Reset Passcode"** next to the desired user.
4. Auto-Generate a **Temporary Passcode** (Valid for 7 days)
5. The user will be logged out and must sign in again using the **new Temporary Passcode**.
6. Upon successful sign-in, users are Prompted to create a **preferred Passcode** upon first sign-in.


