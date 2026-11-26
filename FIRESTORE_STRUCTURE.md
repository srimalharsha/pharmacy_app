# ChannelMed Manager — Firestore data structure

This document describes the current HTML workflow data paths on the `production-build` branch. The rules in `firestore.rules` are source code only; they are not automatically published to the Firebase project. Test them in the Firebase Emulator before using real pharmacy data.

## 1. Identity and roles

### `platformAdmins/{uid}`
- `role: "superAdmin"`
- `active: boolean`
- Created and maintained by a trusted administrator. Public clients cannot elevate this role.

### `userProfiles/{uid}`
- `role: "owner" | "staff"`
- `pharmacyId`, `branchId` (staff assigned to one branch; owner can manage all branches)
- `active`, `displayName`, `email`, `permissions`
- Staff permissions are controlled by the Pharmacy Owner and are also checked by Firestore Rules.

## 2. Pharmacy accounts and branches

- `pharmacies/{pharmacyId}` — one pharmacy account and subscription unit.
- `pharmacies/{pharmacyId}/branches/{branchId}` — branch profile and active status.

Each branch owns its own operational data. Owners can access branches belonging to their Pharmacy Account; staff access is restricted by their assigned branch except for explicitly authorised cross-branch stock-transfer approval checks.

## 3. Branch-scoped collections

| Collection path | Purpose |
|---|---|
| `pharmacies/{pharmacyId}/branches/{branchId}/inventory/{itemId}` | Medicine batch, barcode, batch number, prices, quantity, reorder level, expiry |
| `.../sales/{saleId}` | Completed/voided sales bill with immutable line-item snapshot |
| `.../sales/{saleId}/items/{itemId}` | Per-batch quantity snapshot used to verify stock deduction/return |
| `.../suppliers/{supplierId}` | Supplier contact and notes |
| `.../customers/{customerId}` | Customer contact and notes |
| `.../alertReviews/{inventoryId}` | Owner/staff record that an expiry or low-stock alert was reviewed |

Suppliers and customers are branch-specific. Sales and inventory records are branch-specific. Sales stock deduction and void stock restoration use Firestore transactions.

## 4. Pharmacy-level stock transfers

### `pharmacies/{pharmacyId}/stockTransfers/{transferId}`
Fields:
- `fromBranchId`, `toBranchId`
- `inventoryId`, `medicineName`, `batchNumber`, `quantity`
- `status: "pending" | "approved"`
- `createdBy`, `createdAt`, and on approval `approvedBy`, `approvedAt`

A transfer request does not change stock. Approval is performed in one transaction: it verifies the pending request and available source stock, creates or increments the destination batch, deducts the source quantity, and marks the transfer approved. Rules require the same approved transfer reference for both inventory movements.

## 5. Permission matrix

- Suppliers: `view`, `add`, `edit`, `delete`
- Customers: `view`, `add`, `edit`, `delete`
- Reports: `view`, `export`
- Expiry & Alerts: `view`, `manage`
- Stock Transfers: `view`, `create`, `approve`

The Owner has full access within their Pharmacy Account. Staff access is granted by their Owner. Hiding a button or module is not security; Firestore Rules must enforce the same permission.

## 6. Registration, subscriptions and platform administration

- `pharmacyApplications/{uid}` — pharmacy registration and approval status.
- `subscriptionPlans/{planId}` and `platformConfig/{configId}` — platform pricing, limits, trial and feature settings.
- `pharmacies/{pharmacyId}/payments/{paymentId}` — planned payment records. Payment confirmation and online gateway webhooks must be performed by a trusted server; never store card numbers or CVVs.
- `platformAuditLogs/{logId}` — Super Admin audit trail.

## 7. Security and release boundary

1. Require an active authenticated profile and matching Pharmacy Account.
2. Enforce tenant and branch isolation in Firestore Rules.
3. Do not let public clients elevate roles, approve pharmacy applications, or confirm payment.
4. Keep rules deny-by-default.
5. Run emulator tests for Owner, Staff permission combinations, branch isolation, sales, voids, transfers and invalid writes before deployment.
6. Publishing this repository's rules to GitHub does not publish them to Firebase Console.
7. Do not use the live system with real patient/customer/medicine data until the rules are published and tested and the end-to-end release checks pass.
