/**
 * PetCare Cloud Functions.
 *
 * `sendDueReminders` is a *fallback* for vaccination and appointment
 * reminders. The app schedules reminders locally on each device and records
 * `lastSyncedAt` on `users/{uid}/devices/{token}`. The server only pushes a
 * reminder when none of the user's devices has synced recently (e.g. the app
 * was reinstalled or not opened for a week), so users never get duplicates.
 *
 * Medication doses are not pushed: they are frequent and time-critical, and
 * are handled entirely by local notifications.
 */
import {initializeApp} from "firebase-admin/app";
import {DocumentReference, getFirestore, Timestamp} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";
import {logger} from "firebase-functions";
import {onSchedule} from "firebase-functions/v2/scheduler";

initializeApp();

/** A device that synced within this window schedules reminders itself. */
const LOCAL_SYNC_FRESH_MS = 7 * 24 * 60 * 60 * 1000;
/** Never look back further than this, even after a long outage. */
const MAX_LOOKBACK_MS = 24 * 60 * 60 * 1000;
const DAY_MS = 24 * 60 * 60 * 1000;

type Kind = "vaccinations" | "appointments";

const payloadType: Record<Kind, string> = {
  vaccinations: "vaccination",
  appointments: "appointment",
};

/** "today", "tomorrow", "in N days" between two instants. */
export function relativeDay(from: Date, to: Date): string {
  const days = Math.round((to.getTime() - from.getTime()) / DAY_MS);
  if (days <= 0) return "today";
  if (days === 1) return "tomorrow";
  return `in ${days} days`;
}

/** Push tokens of [user]'s devices, or none if any device syncs locally. */
async function tokensNeedingPush(user: DocumentReference, now: Timestamp): Promise<string[]> {
  const devices = await user.collection("devices").get();
  const tokens: string[] = [];
  for (const d of devices.docs) {
    const lastSyncedAt = d.get("lastSyncedAt") as Timestamp | undefined;
    if (lastSyncedAt && now.toMillis() - lastSyncedAt.toMillis() < LOCAL_SYNC_FRESH_MS) {
      return []; // An active device already scheduled this reminder.
    }
    tokens.push(d.id);
  }
  return tokens;
}

async function messageFor(
  kind: Kind,
  data: FirebaseFirestore.DocumentData,
  user: DocumentReference,
): Promise<{title: string; body: string} | null> {
  const pet = await user.collection("pets").doc(String(data.petId)).get();
  if (!pet.exists) return null;
  const petName = String(pet.get("name"));
  const reminderAt = (data.reminderAt as Timestamp).toDate();

  if (kind === "vaccinations") {
    const due = (data.nextDueDate as Timestamp | undefined)?.toDate();
    if (!due) return null;
    return {
      title: "Vaccination reminder",
      body: `${petName}’s ${data.vaccineName} vaccination is due ${relativeDay(reminderAt, due)}.`,
    };
  }

  if (data.status !== "scheduled") return null;
  const at = (data.dateTime as Timestamp).toDate();
  return {
    title: "Appointment reminder",
    body: `${petName} has a veterinary appointment ${relativeDay(reminderAt, at)}.`,
  };
}

export const sendDueReminders = onSchedule(
  {schedule: "every 15 minutes", timeZone: "Etc/UTC", retryCount: 0},
  async () => {
    const db = getFirestore();
    const stateRef = db.collection("system").doc("reminderJob");
    const now = Timestamp.now();
    const lastRun = (await stateRef.get()).get("lastRunAt") as Timestamp | undefined;
    const from = Timestamp.fromMillis(
      Math.max(lastRun?.toMillis() ?? now.toMillis() - 15 * 60 * 1000, now.toMillis() - MAX_LOOKBACK_MS),
    );

    let sent = 0;
    for (const kind of ["vaccinations", "appointments"] as Kind[]) {
      // Requires the collection-group index in firestore.indexes.json.
      const due = await db
        .collectionGroup(kind)
        .where("reminderAt", ">", from)
        .where("reminderAt", "<=", now)
        .get();

      for (const doc of due.docs) {
        const user = doc.ref.parent.parent;
        if (!user) continue;
        const tokens = await tokensNeedingPush(user, now);
        if (tokens.length === 0) continue;
        const message = await messageFor(kind, doc.data(), user);
        if (!message) continue;

        const result = await getMessaging().sendEachForMulticast({
          tokens,
          notification: message,
          data: {type: payloadType[kind], id: doc.id},
          android: {notification: {channelId: kind}},
        });
        sent += result.successCount;

        // Drop tokens FCM reports as permanently invalid.
        await Promise.all(
          result.responses.map((r, i) => {
            const code = r.error?.code;
            const invalid = code === "messaging/registration-token-not-registered" ||
              code === "messaging/invalid-registration-token";
            return invalid ? user.collection("devices").doc(tokens[i]).delete() : null;
          }),
        );
      }
    }

    await stateRef.set({lastRunAt: now}, {merge: true});
    logger.info(`sendDueReminders: ${sent} push notification(s) sent`);
  },
);
