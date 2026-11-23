# ChannelMed Manager — Firestore data structure (design draft)

This document defines the tenant-isolated data model before operational collections are enabled. It does not make the current demo a live pharmacy system.

## 1. Identity and platform administration

### `platformAdmins/{uid}`
Created only by a trusted administrator in Firebase Console or a trusted server process. Never created by a public sign-up form.

Fields:
- `role`: `"superAdmin"`
- `active`: boolean
- `createdAt`: server timestamp

A signed-in user may read only their own platform-admin record. Clients cannot create, update, list, or delete these records.

### `userProfiles/{uid}`
Created or changed only by a trusted server process after approval/invitation.

Fields:
- `role`: `"owner" | "branchManager" | "pharmacist" | "cashier"`
- `pharmacyId`: pharmacy document ID
- `branchId`: branch document ID for branch-scoped staff; owner may have no branchId
- `active`: boolean
- `displayName`: string
- `createdAt`, `updatedAt`: server timestamps

A staff profile is assigned to exactly one branch. An owner belongs to one Pharmacy Account and can access its branches.

## 2. Pharmacy accounts and branches

### `pharmacies/{pharmacyId}`
One document represents one pharmacy business/account (the subscription unit).

Suggested fields:
- `name`, `registrationNumber`, `phone`, `email`, `address`
- `ownerUid`
- `status`: `"pending" | "active" | "suspended" | "closed"`
- `subscriptionId`, `createdAt`, `updatedAt`

### `pharmacies/{pharmacyId}/branches/{branchId}`
Each branch has independent operational records.

Suggested fields:
- `name`, `code`, `address`, `phone`
- `active`: boolean
- `createdAt`, `updatedAt`

Do not put stock, invoices, purchases, or staff records in a shared global collection without tenant and branch authorization checks.

## 3. Branch-scoped operational collections

Use subcollections under the owning Pharmacy Account and, where the data is branch-specific, under its branch:

- `pharmacies/{pharmacyId}/branches/{branchId}/medicines/{medicineId}`
- `pharmacies/{pharmacyId}/branches/{branchId}/stockBatches/{batchId}`
- `pharmacies/{pharmacyId}/branches/{branchId}/sales/{saleId}`
- `pharmacies/{pharmacyId}/branches/{branchId}/purchases/{purchaseId}`
- `pharmacies/{pharmacyId}/branches/{branchId}/suppliers/{supplierId}`
- `pharmacies/{pharmacyId}/branches/{branchId}/customers/{customerId}`
- `pharmacies/{pharmacyId}/branches/{branchId}/stockTransfers/{transferId}`

Each document should include server timestamps and the relevant branch reference where useful. Stock transfers must be recorded as paired, auditable movements from one branch to another; they must not silently edit quantities.

## 4. Registration and subscription collections

### `pharmacyApplications/{applicationId}`
Stores new pharmacy applications before activation. Suggested fields include applicant UID, pharmacy details, selected package, status (`pending/reviewing/approved/rejected`), and timestamps. Public users must not be able to approve applications or set an active pharmacy role.

### `subscriptionPlans/{planId}`
Protected platform configuration for monthly/yearly prices, trial duration, limits, and enabled features. Initial planning values are monthly Rs. 1,500, yearly Rs. 15,000, and 30-day trial; they are not active billing settings until implemented.

### `pharmacies/{pharmacyId}/payments/{paymentId}`
Payment status, method (`bankTransfer/onlineGateway`), receipt reference, amount, currency, review status, and server verification metadata. Never store card numbers, CVVs, or other card credentials.

## 5. Security principles

1. Authentication alone does not grant access to pharmacy data.
2. A user's `userProfiles/{uid}` record must be active and must match the requested `pharmacyId`.
3. Owners may access permitted data across their own pharmacy's branches.
4. Branch Managers, Pharmacists, and Cashiers are restricted to their assigned branch and role permissions.
5. Staff must have exactly one assigned branch. Reassignment is an owner-authorized, audited operation.
6. Only trusted server-side code may create or elevate roles, approve pharmacy applications, activate subscriptions, or confirm online payments.
7. UI feature hiding is not security. Firestore rules and trusted server checks must enforce every permission.
8. Start with deny-by-default rules. Add collection-specific permissions only after each workflow is designed and tested.

## 6. Login routing

After Firebase email/password sign-in:
1. Read `platformAdmins/{uid}`; if active with role `superAdmin`, open the Super Admin workspace.
2. Otherwise read `userProfiles/{uid}`; require `active == true`.
3. Confirm the referenced Pharmacy Account is active.
4. Route owners to the account workspace and branch staff to their permitted branch workspace.
5. If no active profile exists, show a clear pending/not-authorized message and do not show operational data.

Email verification is intended for new registration and password recovery flows; it is not required on every normal sign-in.

## 7. Current implementation boundary

The current GitHub Pages site is a demo. Existing Firestore rules intentionally deny all operational data access except a user's own Super Admin registry read. This document is a design baseline, not a deployed permission change. Do not paste permissive rules or enter real pharmacy/customer/medicine data until the secure workflows are implemented and tested.
