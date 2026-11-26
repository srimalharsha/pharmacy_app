# ChannelMed Manager — Production Build Plan

## Product decision
Build one production Flutter application for Web, Android, and Windows, backed by the existing Firebase project. Keep the current HTML site available as a legacy/demo reference until the Flutter replacement is tested and ready. Do not delete or overwrite existing pharmacy data during migration.

## Fixed business rules
- Roles: Super Admin, Pharmacy Owner, Staff. Do not add Branch Manager, Pharmacist, or Cashier roles.
- A Pharmacy Account can own multiple branches. Subscription is per Pharmacy Account, not per branch.
- Every staff member is assigned to one branch. The Owner can enable/disable each permission.
- Super Admin manages pharmacy approvals, account activation, feature availability, limits, subscription plans, and payment reviews.
- Normal login is email/password. Email verification is only for registration and password reset.
- Login persists until the user explicitly signs out. Back navigation must not sign out.
- Tenant isolation is mandatory: a pharmacy can only access its own account and branches.
- Initial pricing proposal: LKR 1,500 monthly, LKR 15,000 yearly, 30-day trial. Super Admin can change these values.
- Initial payment methods: bank transfer with manual receipt review and an online gateway with server-side verification. Never store card numbers or CVVs.

## Architecture decisions
- Flutter single codebase targeting Web, Android, and Windows.
- Firebase Authentication for identity.
- Cloud Firestore for tenant and branch data.
- Firebase Storage for permitted documents and medicine/product images.
- Cloud Functions or another trusted server for privileged operations such as application approval, subscription activation, payment webhooks, and audited administrative changes.
- Firestore Rules remain deny-by-default and enforce tenant/branch/role permissions. Hiding a UI module is never considered security.
- Use transactions/batched writes for sales, purchases, stock transfers, and void/refund workflows.
- Store money as integer minor units where possible (LKR cents) and record immutable transaction snapshots.
- Use a single documented data model and repository/service layer shared by all three platforms.

## Functional scope
1. Authentication, password reset, persistent sessions, role routing.
2. Super Admin: pharmacy applications, account status, plans/pricing, feature flags, limits, payments, audit log.
3. Owner: pharmacy profile, multiple branches, staff invitations, branch assignment, granular permissions.
4. Medicine catalogue and stock batches: barcode/manual search, batch number, purchase/selling price, quantity, expiry, low-stock alerts.
5. POS: barcode scan, cart, customer, discount permission, payment methods, printable/shareable invoice, sales history, void with stock restoration.
6. Suppliers and purchase orders/receiving: supplier records, purchase history, stock increment, costs.
7. Customers: contact details, purchase history, balances/credit if enabled.
8. Stock transfers: request, approve, dispatch, receive, paired stock movements, audit history.
9. Reports: daily/monthly sales, gross profit, purchases, expenses, stock valuation, branch and consolidated owner views.
10. Expiry and low-stock alerts.
11. Subscription lifecycle and payment review.
12. Settings, backups/export, audit trail, error handling and accessibility.

## Delivery gates
- Gate A — Audit and data contract: inspect existing HTML workflows, Firestore paths, profiles, and rules; document migration mappings.
- Gate B — Flutter foundation: app routing, responsive navigation, Firebase initialization, auth, session restoration, role guards.
- Gate C — Core operations: branches, inventory, barcode, POS, invoices, sales history, safe void.
- Gate D — Business modules: suppliers, purchases, customers, transfers, alerts, reports.
- Gate E — Platform administration: approvals, permissions, plans, payments, audit.
- Gate F — Security and quality: rules review, emulator tests, transaction tests, permission matrix, tenant-isolation tests, backups.
- Gate G — Release: web deployment, Android APK/AAB, Windows build, installation and smoke-test instructions.

## Current verified repository state (2026-11-26)
- Added `pharmacy-operations.html` on the production-build branch with branch-scoped supplier and customer CRUD, sales/stock-value reporting with CSV export, expiry/low-stock alerts with review records, and transactional inter-branch stock transfers.
- Connected Owner and Staff workspaces to these modules and wired the existing staff permission matrix to module access.
- Extended `firestore.rules` source with tenant/branch-scoped permissions for suppliers, customers, alert reviews, reports and stock transfers. Rules have not been published to Firebase and have not yet passed Emulator Suite tests.
- JavaScript syntax checks passed for the changed operations, owner, staff, billing and inventory pages. This is a static syntax check only; browser/Firebase end-to-end tests and live deployment remain outstanding.
- The repository currently contains a functional-looking HTML prototype/workspace for login, owner/staff/super-admin, inventory, and billing. These workflows require further end-to-end validation.
- lib/main.dart is currently a static Flutter dashboard prototype and is not connected to Firebase.
- pubspec.yaml already lists Firebase, scanner, PDF/printing, and sharing packages, but platform Firebase configuration and production workflows are not complete.
- The existing Firestore rules and HTML client code need a consistency/security audit before live pharmacy use.
- No claim of production readiness, successful real payment processing, or completed native builds should be made until the corresponding release gate is tested.

## External setup and cost constraints
- Firebase Android app registration and platform configuration files may need owner action in Firebase Console.
- Deploying Cloud Functions and some payment integrations generally requires the Firebase Blaze billing plan; confirm costs before enabling them.
- Online payment credentials, bank details, and signing keys must be entered by the account owner through secure provider/Firebase interfaces, never pasted into chat.