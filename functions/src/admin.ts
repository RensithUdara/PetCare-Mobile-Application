/**
 * Role management for the PetCare web portals.
 *
 * Roles are Firebase Auth custom claims: `{role: "admin"}` or
 * `{role: "doctor"}`; everyone else is a pet owner. Only these functions
 * set claims, and Firestore rules trust nothing else. After a role change
 * the client must refresh its ID token to see it.
 */
import {getAuth, type UserRecord} from "firebase-admin/auth";
import {FieldValue, getFirestore} from "firebase-admin/firestore";
import {defineString} from "firebase-functions/params";
import {HttpsError, onCall, type CallableRequest} from "firebase-functions/v2/https";

export type Role = "admin" | "doctor" | "owner";

/**
 * Comma-separated emails allowed to claim the first admin role with
 * `bootstrapAdmin` (set in functions/.env). Leave empty to disable.
 */
const adminEmails = defineString("ADMIN_EMAILS", {default: ""});

const CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // no 0/O/1/I

/** A doctor code like `DR-7K3M9Q`; [random] returns values in [0, 1). */
export function generateDoctorCode(random: () => number = Math.random): string {
  let code = "";
  for (let i = 0; i < 6; i++) code += CODE_ALPHABET[Math.floor(random() * CODE_ALPHABET.length)];
  return `DR-${code}`;
}

export function roleOf(claims: Record<string, unknown> | undefined): Role {
  const role = claims?.role;
  return role === "admin" || role === "doctor" ? role : "owner";
}

function requireAdmin(request: CallableRequest): string {
  if (!request.auth) throw new HttpsError("unauthenticated", "Please sign in.");
  if (request.auth.token.role !== "admin") throw new HttpsError("permission-denied", "Admins only.");
  return request.auth.uid;
}

function requireString(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim() === "") {
    throw new HttpsError("invalid-argument", `"${field}" is required.`);
  }
  return value.trim();
}

async function setRoleClaim(uid: string, role: Role): Promise<void> {
  const user = await getAuth().getUser(uid);
  const claims = {...(user.customClaims ?? {})};
  if (role === "owner") delete claims.role;
  else claims.role = role;
  await getAuth().setCustomUserClaims(uid, claims);
}

async function uniqueDoctorCode(): Promise<string> {
  const doctors = getFirestore().collection("doctors");
  for (let attempt = 0; attempt < 10; attempt++) {
    const code = generateDoctorCode();
    const taken = await doctors.where("doctorCode", "==", code).limit(1).get();
    if (taken.empty) return code;
  }
  throw new HttpsError("internal", "Could not generate a doctor code. Try again.");
}

/** Makes the caller an admin if their verified email is in ADMIN_EMAILS. */
export const bootstrapAdmin = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Please sign in.");
  const email = (request.auth.token.email ?? "").toLowerCase();
  const allowed = adminEmails.value().split(",").map((e) => e.trim().toLowerCase()).filter(Boolean);
  if (!email || !allowed.includes(email)) {
    throw new HttpsError("permission-denied", "This account is not on the admin list.");
  }
  if (request.auth.token.email_verified !== true) {
    throw new HttpsError("failed-precondition", "Verify your email address first.");
  }
  await setRoleClaim(request.auth.uid, "admin");
  return {role: "admin"};
});

/** Approves or rejects a doctor application. */
export const reviewDoctor = onCall(async (request) => {
  const adminUid = requireAdmin(request);
  const uid = requireString(request.data?.uid, "uid");
  const approve = request.data?.approve === true;
  const note = typeof request.data?.note === "string" ? request.data.note.trim() : null;

  const ref = getFirestore().doc(`doctors/${uid}`);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError("not-found", "No application for this user.");

  if (approve) {
    const code = (snap.get("doctorCode") as string | undefined) ?? (await uniqueDoctorCode());
    await ref.update({
      status: "approved",
      doctorCode: code,
      reviewNote: note,
      reviewedBy: adminUid,
      reviewedAt: FieldValue.serverTimestamp(),
    });
    await setRoleClaim(uid, "doctor");
    return {status: "approved", doctorCode: code};
  }

  await ref.update({
    status: "rejected",
    reviewNote: note,
    reviewedBy: adminUid,
    reviewedAt: FieldValue.serverTimestamp(),
  });
  const user = await getAuth().getUser(uid);
  if (roleOf(user.customClaims) === "doctor") {
    await setRoleClaim(uid, "owner");
    // End their sessions so the doctor role goes away on the next token refresh.
    await getAuth().revokeRefreshTokens(uid);
  }
  return {status: "rejected"};
});

/** Changes a user's role. Admins cannot demote themselves. */
export const setUserRole = onCall(async (request) => {
  const adminUid = requireAdmin(request);
  const uid = requireString(request.data?.uid, "uid");
  const role = request.data?.role as Role;
  if (!["admin", "doctor", "owner"].includes(role)) {
    throw new HttpsError("invalid-argument", "Role must be admin, doctor or owner.");
  }
  if (uid === adminUid && role !== "admin") {
    throw new HttpsError("failed-precondition", "You can’t remove your own admin role.");
  }
  if (role === "doctor") {
    const application = await getFirestore().doc(`doctors/${uid}`).get();
    if (application.get("status") !== "approved") {
      throw new HttpsError("failed-precondition", "Approve the doctor’s application instead.");
    }
  }
  await setRoleClaim(uid, role);
  return {role};
});

/** Blocks or unblocks sign-in for a user. */
export const setUserDisabled = onCall(async (request) => {
  const adminUid = requireAdmin(request);
  const uid = requireString(request.data?.uid, "uid");
  const disabled = request.data?.disabled === true;
  if (uid === adminUid) throw new HttpsError("failed-precondition", "You can’t disable your own account.");
  await getAuth().updateUser(uid, {disabled});
  if (disabled) await getAuth().revokeRefreshTokens(uid);
  return {disabled};
});

export interface AdminUser {
  uid: string;
  email: string | null;
  displayName: string | null;
  role: Role;
  disabled: boolean;
  createdAt: string | null;
  lastSignInAt: string | null;
}

function toAdminUser(u: UserRecord): AdminUser {
  return {
    uid: u.uid,
    email: u.email ?? null,
    displayName: u.displayName ?? null,
    role: roleOf(u.customClaims),
    disabled: u.disabled,
    createdAt: u.metadata.creationTime ?? null,
    lastSignInAt: u.metadata.lastSignInTime ?? null,
  };
}

/** A page of users (up to 1000) with their roles. */
export const listUsers = onCall(async (request) => {
  requireAdmin(request);
  const pageToken = typeof request.data?.pageToken === "string" ? request.data.pageToken : undefined;
  const page = await getAuth().listUsers(1000, pageToken);
  return {users: page.users.map(toAdminUser), nextPageToken: page.pageToken ?? null};
});

/** Platform-wide counts for the admin dashboard (no personal data). */
export const adminStats = onCall(async (request) => {
  requireAdmin(request);
  const db = getFirestore();
  const count = async (q: FirebaseFirestore.Query) => (await q.count().get()).data().count;
  const doctors = db.collection("doctors");
  const [users, pets, vaccinations, appointments, medications, documents, shares, approved, pending, rejected] =
    await Promise.all([
      count(db.collection("users")),
      count(db.collectionGroup("pets")),
      count(db.collectionGroup("vaccinations")),
      count(db.collectionGroup("appointments")),
      count(db.collectionGroup("medications")),
      count(db.collectionGroup("documents")),
      count(db.collection("shares")),
      count(doctors.where("status", "==", "approved")),
      count(doctors.where("status", "==", "pending")),
      count(doctors.where("status", "==", "rejected")),
    ]);
  return {
    users, pets, vaccinations, appointments, medications, documents, shares,
    doctors: {approved, pending, rejected},
  };
});
