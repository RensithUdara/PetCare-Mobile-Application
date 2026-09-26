import { isAfter } from 'date-fns';
import {
  CalendarClock,
  FileText,
  Pencil,
  Pill,
  Plus,
  Scale,
  Stethoscope,
  Syringe,
  Trash2,
  type LucideIcon,
} from 'lucide-react';
import { useState, type FormEvent, type ReactNode } from 'react';
import { CartesianGrid, Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';

import { useLiveQuery } from '../hooks/useFirestore';
import {
  deleteRecord,
  errorMessage,
  petRecords,
  saveAppointment,
  saveMedication,
  saveVaccination,
  type RecordKind,
} from '../lib/api';
import {
  appointmentFromDoc,
  documentFromDoc,
  medicationFromDoc,
  vaccinationFromDoc,
  weightFromDoc,
} from '../lib/converters';
import {
  fmtBytes,
  fmtDate,
  fmtDateTime,
  fmtWeight,
  fromDateInput,
  fromDateTimeInput,
  toDateInput,
  toDateTimeInput,
  vaccinationStatuses,
  type VaccinationStatus,
} from '../lib/format';
import { REMINDER_OPTIONS } from '../lib/reminders';
import {
  APPOINTMENT_TYPES,
  DEFAULT_DOSE_TIMES,
  FREQUENCIES,
  VACCINE_CATEGORIES,
  type AddedBy,
  type Appointment,
  type AppointmentStatus,
  type AppointmentType,
  type Frequency,
  type Medication,
  type Vaccination,
  type VaccineCategory,
} from '../lib/types';
import { useDialogs } from './dialogs';
import { Badge, Button, Card, ChoiceTiles, EmptyState, ErrorNote, IconBadge, Input, Modal, Select, Spinner, Textarea, type Accent } from './ui';

// ── Data ────────────────────────────────────────────────────────────────
/** Live records of one pet (always filtered by pet, as rules require for vets). */
export function usePetRecords(ownerId: string, petId: string) {
  const key = (k: RecordKind) => `${k}-${ownerId}-${petId}`;
  const vaccinations = useLiveQuery(petRecords(ownerId, 'vaccinations', petId), key('vaccinations'), vaccinationFromDoc);
  const appointments = useLiveQuery(petRecords(ownerId, 'appointments', petId), key('appointments'), appointmentFromDoc);
  const medications = useLiveQuery(petRecords(ownerId, 'medications', petId), key('medications'), medicationFromDoc);
  const weights = useLiveQuery(petRecords(ownerId, 'weights', petId), key('weights'), weightFromDoc);
  const documents = useLiveQuery(petRecords(ownerId, 'documents', petId), key('documents'), documentFromDoc);
  return {
    vaccinations: { ...vaccinations, data: [...vaccinations.data].sort((a, b) => +b.dateAdministered - +a.dateAdministered) },
    appointments: { ...appointments, data: [...appointments.data].sort((a, b) => +b.dateTime - +a.dateTime) },
    medications: { ...medications, data: [...medications.data].sort((a, b) => +b.startDate - +a.startDate) },
    weights: { ...weights, data: [...weights.data].sort((a, b) => +a.date - +b.date) },
    documents: { ...documents, data: [...documents.data].sort((a, b) => +(b.date ?? 0) - +(a.date ?? 0)) },
  };
}

/** Who is looking: the owner can do everything; a vet adds and edits their own. */
export interface Viewer {
  uid: string;
  isOwner: boolean;
  /** Shown on records a vet adds, e.g. "Dr. Nimali Perera". */
  name?: string;
}

const canEdit = (viewer: Viewer, r: AddedBy) => viewer.isOwner || r.addedByUid === viewer.uid;
const addedByFields = (viewer: Viewer): AddedBy =>
  viewer.isOwner ? {} : { addedByUid: viewer.uid, addedByName: viewer.name ?? 'Veterinarian' };

// ── Shared bits ─────────────────────────────────────────────────────────
function RecordRow({
  icon,
  accent,
  title,
  meta,
  badges,
  actions,
  children,
}: {
  icon: LucideIcon;
  accent: Accent;
  title: ReactNode;
  meta: ReactNode;
  badges?: ReactNode;
  actions?: ReactNode;
  children?: ReactNode;
}) {
  return (
    <div className="flex gap-4 border-b border-slate-100 p-4 last:border-0">
      <IconBadge icon={icon} accent={accent} size={42} />
      <div className="min-w-0 flex-1">
        <div className="flex flex-wrap items-center gap-2">
          <span className="font-bold">{title}</span>
          {badges}
        </div>
        <div className="mt-0.5 text-sm text-slate-500">{meta}</div>
        {children}
      </div>
      {actions && <div className="flex shrink-0 items-start gap-1">{actions}</div>}
    </div>
  );
}

function RowActions({ onEdit, onDelete }: { onEdit?: () => void; onDelete?: () => void }) {
  return (
    <>
      {onEdit && (
        <button aria-label="Edit" onClick={onEdit} className="rounded-lg p-2 text-slate-400 hover:bg-slate-100 hover:text-slate-700">
          <Pencil size={16} />
        </button>
      )}
      {onDelete && (
        <button aria-label="Delete" onClick={onDelete} className="rounded-lg p-2 text-slate-400 hover:bg-red-50 hover:text-red-600">
          <Trash2 size={16} />
        </button>
      )}
    </>
  );
}

const AddedByBadge = ({ r }: { r: AddedBy }) => (r.addedByName ? <Badge tone="violet">Added by {r.addedByName}</Badge> : null);

function useDelete(ownerId: string, kind: RecordKind, noun: string) {
  const { confirm, success } = useDialogs();
  return async (id: string, name: string) => {
    if (!(await confirm({ title: `Delete ${noun}?`, message: `This removes “${name}” permanently.`, confirmLabel: 'Delete', icon: Trash2, destructive: true })))
      return;
    try {
      await deleteRecord(ownerId, kind, id);
      await success({ title: `${noun[0].toUpperCase()}${noun.slice(1)} deleted` });
    } catch (e) {
      alert(errorMessage(e));
    }
  };
}

function ListCard({ loading, empty, children, emptyIcon, emptyText, action }: { loading: boolean; empty: boolean; children: ReactNode; emptyIcon: LucideIcon; emptyText: string; action?: ReactNode }) {
  if (loading) return <Card><Spinner /></Card>;
  if (empty) return <Card><EmptyState icon={emptyIcon} title={emptyText} action={action} /></Card>;
  return <Card padded={false}>{children}</Card>;
}

// ── Vaccinations ────────────────────────────────────────────────────────
const VAX_BADGE: Record<VaccinationStatus, [string, 'red' | 'amber' | 'green' | 'slate']> = {
  overdue: ['Overdue', 'red'],
  upcoming: ['Due soon', 'amber'],
  upToDate: ['Up to date', 'green'],
  completed: ['Completed', 'slate'],
};

export function VaccinationsPanel({ ownerId, petId, viewer }: { ownerId: string; petId: string; viewer: Viewer }) {
  const { vaccinations } = usePetRecords(ownerId, petId);
  const [editing, setEditing] = useState<Vaccination | 'new' | null>(null);
  const remove = useDelete(ownerId, 'vaccinations', 'vaccination');
  const statuses = vaccinationStatuses(vaccinations.data);
  const add = <Button icon={Plus} onClick={() => setEditing('new')}>Add vaccination</Button>;

  return (
    <>
      <div className="mb-3 flex justify-end">{vaccinations.data.length > 0 && add}</div>
      <ListCard loading={vaccinations.loading} empty={!vaccinations.data.length} emptyIcon={Syringe} emptyText="No vaccinations yet" action={add}>
        {vaccinations.data.map((v) => {
          const [label, tone] = VAX_BADGE[statuses.get(v.id) ?? 'upToDate'];
          return (
            <RecordRow
              key={v.id}
              icon={Syringe}
              accent="vaccinations"
              title={v.vaccineName}
              badges={<><Badge tone={tone}>{label}</Badge><AddedByBadge r={v} /></>}
              meta={<>Given {fmtDate(v.dateAdministered)}{v.nextDueDate && <> · Next due {fmtDate(v.nextDueDate)}</>}{v.veterinarian && <> · {v.veterinarian}</>}</>}
              actions={canEdit(viewer, v) && <RowActions onEdit={() => setEditing(v)} onDelete={viewer.isOwner ? () => remove(v.id, v.vaccineName) : undefined} />}
            >
              {v.notes && <p className="mt-1 text-sm text-slate-600">{v.notes}</p>}
            </RecordRow>
          );
        })}
      </ListCard>
      <Modal open={editing !== null} title={editing === 'new' ? 'Add vaccination' : 'Edit vaccination'} onClose={() => setEditing(null)}>
        {editing !== null && (
          <VaccinationForm ownerId={ownerId} petId={petId} viewer={viewer} initial={editing === 'new' ? null : editing} onDone={() => setEditing(null)} />
        )}
      </Modal>
    </>
  );
}

function VaccinationForm({ ownerId, petId, viewer, initial, onDone }: { ownerId: string; petId: string; viewer: Viewer; initial: Vaccination | null; onDone: () => void }) {
  const { success } = useDialogs();
  const [f, setF] = useState({
    vaccineName: initial?.vaccineName ?? '',
    category: (initial?.category ?? 'core') as VaccineCategory,
    dateAdministered: toDateInput(initial?.dateAdministered ?? new Date()),
    nextDueDate: toDateInput(initial?.nextDueDate),
    reminder: String(initial?.reminderDaysBefore ?? 7),
    veterinarian: initial?.veterinarian ?? (viewer.isOwner ? '' : viewer.name ?? ''),
    clinic: initial?.clinic ?? '',
    batchNumber: initial?.batchNumber ?? '',
    notes: initial?.notes ?? '',
  });
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const set = (k: keyof typeof f) => (e: { target: { value: string } }) => setF((s) => ({ ...s, [k]: e.target.value }));

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    const given = fromDateInput(f.dateAdministered);
    const next = fromDateInput(f.nextDueDate);
    const errs: Record<string, string> = {};
    if (!f.vaccineName.trim()) errs.vaccineName = 'Vaccine name is required.';
    if (!given) errs.dateAdministered = 'Date is required.';
    else if (isAfter(given, new Date())) errs.dateAdministered = 'Can’t be in the future.';
    if (given && next && next <= given) errs.nextDueDate = 'Must be after the date given.';
    setErrors(errs);
    if (Object.keys(errs).length) return;
    setBusy(true);
    setError(null);
    try {
      await saveVaccination({
        id: initial?.id,
        ownerId,
        petId,
        vaccineName: f.vaccineName,
        category: f.category,
        dateAdministered: given!,
        nextDueDate: next,
        reminderDaysBefore: f.reminder === '' ? null : Number(f.reminder),
        veterinarian: f.veterinarian,
        clinic: f.clinic,
        batchNumber: f.batchNumber,
        notes: f.notes,
        ...(initial ? { addedByUid: initial.addedByUid, addedByName: initial.addedByName } : addedByFields(viewer)),
      });
      onDone();
      await success({ title: initial ? 'Vaccination updated' : 'Vaccination added', message: next ? `Next dose due ${fmtDate(next)}.` : undefined });
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <form onSubmit={submit} className="space-y-4" noValidate>
      <Input label="Vaccine name *" value={f.vaccineName} onChange={set('vaccineName')} error={errors.vaccineName} placeholder="e.g. Rabies" list="vaccine-suggestions" />
      <datalist id="vaccine-suggestions">
        {['Rabies', 'DHPP', 'Leptospirosis', 'Bordetella', 'FVRCP', 'FeLV', 'Parvovirus'].map((v) => <option key={v} value={v} />)}
      </datalist>
      <ChoiceTiles label="Category" value={f.category} onChange={(v) => setF((s) => ({ ...s, category: v }))} accent="vaccinations" options={Object.entries(VACCINE_CATEGORIES).map(([value, label]) => ({ value: value as VaccineCategory, label }))} />
      <div className="grid gap-4 sm:grid-cols-2">
        <Input label="Date given *" type="date" value={f.dateAdministered} onChange={set('dateAdministered')} error={errors.dateAdministered} />
        <Input label="Next due" type="date" value={f.nextDueDate} onChange={set('nextDueDate')} error={errors.nextDueDate} />
      </div>
      {f.nextDueDate && (
        <Select label="Reminder" value={f.reminder} onChange={set('reminder')}>
          <option value="">No reminder</option>
          {REMINDER_OPTIONS.map((o) => <option key={o.days} value={o.days}>{o.vaccination}</option>)}
        </Select>
      )}
      <div className="grid gap-4 sm:grid-cols-2">
        <Input label="Veterinarian" value={f.veterinarian} onChange={set('veterinarian')} />
        <Input label="Clinic" value={f.clinic} onChange={set('clinic')} />
      </div>
      <Input label="Batch number" value={f.batchNumber} onChange={set('batchNumber')} />
      <Textarea label="Notes" value={f.notes} onChange={set('notes')} />
      <ErrorNote text={error} />
      <Button type="submit" loading={busy} className="w-full">{initial ? 'Save changes' : 'Add vaccination'}</Button>
    </form>
  );
}

// ── Appointments & visit notes ──────────────────────────────────────────
const STATUS_BADGE: Record<AppointmentStatus, [string, 'blue' | 'green' | 'slate']> = {
  scheduled: ['Scheduled', 'blue'],
  completed: ['Completed', 'green'],
  cancelled: ['Cancelled', 'slate'],
};

export function AppointmentsPanel({ ownerId, petId, viewer }: { ownerId: string; petId: string; viewer: Viewer }) {
  const { appointments } = usePetRecords(ownerId, petId);
  const [editing, setEditing] = useState<{ appt: Appointment | null; visit: boolean } | null>(null);
  const remove = useDelete(ownerId, 'appointments', 'appointment');
  const actions = (
    <div className="flex flex-wrap gap-2">
      <Button variant="outline" icon={Stethoscope} onClick={() => setEditing({ appt: null, visit: true })}>Record a visit</Button>
      <Button icon={Plus} onClick={() => setEditing({ appt: null, visit: false })}>Schedule</Button>
    </div>
  );

  return (
    <>
      <div className="mb-3 flex justify-end">{appointments.data.length > 0 && actions}</div>
      <ListCard loading={appointments.loading} empty={!appointments.data.length} emptyIcon={CalendarClock} emptyText="No appointments yet" action={actions}>
        {appointments.data.map((a) => {
          const [label, tone] = STATUS_BADGE[a.status];
          const needsUpdate = a.status === 'scheduled' && a.dateTime < new Date();
          return (
            <RecordRow
              key={a.id}
              icon={a.status === 'completed' ? Stethoscope : CalendarClock}
              accent="appointments"
              title={APPOINTMENT_TYPES[a.type]}
              badges={<><Badge tone={needsUpdate ? 'amber' : tone}>{needsUpdate ? 'Needs update' : label}</Badge><AddedByBadge r={a} /></>}
              meta={<>{fmtDateTime(a.dateTime)}{a.clinic && <> · {a.clinic}</>}{a.veterinarian && <> · {a.veterinarian}</>}</>}
              actions={canEdit(viewer, a) && <RowActions onEdit={() => setEditing({ appt: a, visit: a.status === 'completed' })} onDelete={viewer.isOwner ? () => remove(a.id, APPOINTMENT_TYPES[a.type]) : undefined} />}
            >
              {a.reason && <p className="mt-1 text-sm text-slate-600"><b>Reason:</b> {a.reason}</p>}
              {a.notes && <p className="mt-1 whitespace-pre-line text-sm text-slate-600">{a.notes}</p>}
            </RecordRow>
          );
        })}
      </ListCard>
      <Modal
        open={editing !== null}
        title={editing?.appt ? (editing.visit ? 'Edit visit' : 'Edit appointment') : editing?.visit ? 'Record a visit' : 'Schedule appointment'}
        onClose={() => setEditing(null)}
      >
        {editing && <AppointmentForm ownerId={ownerId} petId={petId} viewer={viewer} initial={editing.appt} visit={editing.visit} onDone={() => setEditing(null)} />}
      </Modal>
    </>
  );
}

function AppointmentForm({ ownerId, petId, viewer, initial, visit, onDone }: { ownerId: string; petId: string; viewer: Viewer; initial: Appointment | null; visit: boolean; onDone: () => void }) {
  const { success } = useDialogs();
  const [f, setF] = useState({
    type: (initial?.type ?? 'routineCheckup') as AppointmentType,
    dateTime: toDateTimeInput(initial?.dateTime ?? (visit ? new Date() : null)),
    status: (initial?.status ?? (visit ? 'completed' : 'scheduled')) as AppointmentStatus,
    reminder: String(initial?.reminderDaysBefore ?? 1),
    clinic: initial?.clinic ?? '',
    veterinarian: initial?.veterinarian ?? (viewer.isOwner ? '' : viewer.name ?? ''),
    reason: initial?.reason ?? '',
    notes: initial?.notes ?? '',
  });
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const set = (k: keyof typeof f) => (e: { target: { value: string } }) => setF((s) => ({ ...s, [k]: e.target.value }));

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    const when = fromDateTimeInput(f.dateTime);
    const errs: Record<string, string> = {};
    if (!when) errs.dateTime = 'Date and time are required.';
    if (visit && !f.notes.trim()) errs.notes = 'Add your visit notes.';
    setErrors(errs);
    if (Object.keys(errs).length) return;
    // A new appointment in the past is saved as a completed visit (as in the app).
    const status: AppointmentStatus = !initial && when! < new Date() ? 'completed' : f.status;
    setBusy(true);
    setError(null);
    try {
      await saveAppointment({
        id: initial?.id,
        ownerId,
        petId,
        type: f.type,
        dateTime: when!,
        status,
        reminderDaysBefore: f.reminder === '' ? null : Number(f.reminder),
        clinic: f.clinic,
        veterinarian: f.veterinarian,
        reason: f.reason,
        notes: f.notes,
        ...(initial ? { addedByUid: initial.addedByUid, addedByName: initial.addedByName } : addedByFields(viewer)),
      });
      onDone();
      await success({ title: visit ? 'Visit recorded' : initial ? 'Appointment updated' : 'Appointment scheduled', message: fmtDateTime(when) });
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <form onSubmit={submit} className="space-y-4" noValidate>
      <ChoiceTiles
        label="Type"
        columns={4}
        accent="appointments"
        value={f.type}
        onChange={(v) => setF((s) => ({ ...s, type: v }))}
        options={Object.entries(APPOINTMENT_TYPES).map(([value, label]) => ({ value: value as AppointmentType, label: value === 'routineCheckup' ? 'Checkup' : label }))}
      />
      <div className="grid gap-4 sm:grid-cols-2">
        <Input label={visit ? 'Visit date & time *' : 'Date & time *'} type="datetime-local" value={f.dateTime} onChange={set('dateTime')} error={errors.dateTime} />
        {initial && !visit ? (
          <Select label="Status" value={f.status} onChange={set('status')}>
            <option value="scheduled">Scheduled</option>
            <option value="completed">Completed</option>
            <option value="cancelled">Cancelled</option>
          </Select>
        ) : !visit ? (
          <Select label="Reminder" value={f.reminder} onChange={set('reminder')}>
            <option value="">No reminder</option>
            {REMINDER_OPTIONS.map((o) => <option key={o.days} value={o.days}>{o.appointment}</option>)}
          </Select>
        ) : null}
      </div>
      <div className="grid gap-4 sm:grid-cols-2">
        <Input label="Clinic" value={f.clinic} onChange={set('clinic')} />
        <Input label="Veterinarian" value={f.veterinarian} onChange={set('veterinarian')} />
      </div>
      <Input label="Reason" value={f.reason} onChange={set('reason')} placeholder="e.g. Annual checkup" />
      <Textarea label={visit ? 'Visit notes *' : 'Notes'} value={f.notes} onChange={set('notes')} error={errors.notes} placeholder={visit ? 'Findings, diagnosis, treatment, advice…' : ''} />
      <ErrorNote text={error} />
      <Button type="submit" loading={busy} className="w-full">{visit ? 'Save visit' : initial ? 'Save changes' : 'Schedule appointment'}</Button>
    </form>
  );
}

// ── Medications / prescriptions ─────────────────────────────────────────
export function MedicationsPanel({ ownerId, petId, viewer }: { ownerId: string; petId: string; viewer: Viewer }) {
  const { medications } = usePetRecords(ownerId, petId);
  const [editing, setEditing] = useState<Medication | 'new' | null>(null);
  const remove = useDelete(ownerId, 'medications', 'medication');
  const now = new Date();
  const add = <Button icon={Plus} onClick={() => setEditing('new')}>{viewer.isOwner ? 'Add medication' : 'Prescribe'}</Button>;

  return (
    <>
      <div className="mb-3 flex justify-end">{medications.data.length > 0 && add}</div>
      <ListCard loading={medications.loading} empty={!medications.data.length} emptyIcon={Pill} emptyText="No medications yet" action={add}>
        {medications.data.map((m) => {
          const active = m.startDate <= now && (!m.endDate || m.endDate >= new Date(now.getFullYear(), now.getMonth(), now.getDate()));
          return (
            <RecordRow
              key={m.id}
              icon={Pill}
              accent="medications"
              title={m.name}
              badges={<><Badge tone={active ? 'green' : 'slate'}>{active ? 'Active' : m.startDate > now ? 'Upcoming' : 'Finished'}</Badge><AddedByBadge r={m} /></>}
              meta={<>{[m.dosage, FREQUENCIES[m.frequency], m.doseTimes.join(', ')].filter(Boolean).join(' · ')}<br />{fmtDate(m.startDate)} – {m.endDate ? fmtDate(m.endDate) : 'ongoing'}</>}
              actions={canEdit(viewer, m) && <RowActions onEdit={() => setEditing(m)} onDelete={viewer.isOwner ? () => remove(m.id, m.name) : undefined} />}
            >
              {m.instructions && <p className="mt-1 text-sm text-slate-600">{m.instructions}</p>}
            </RecordRow>
          );
        })}
      </ListCard>
      <Modal open={editing !== null} title={editing === 'new' ? (viewer.isOwner ? 'Add medication' : 'New prescription') : 'Edit medication'} onClose={() => setEditing(null)}>
        {editing !== null && <MedicationForm ownerId={ownerId} petId={petId} viewer={viewer} initial={editing === 'new' ? null : editing} onDone={() => setEditing(null)} />}
      </Modal>
    </>
  );
}

function MedicationForm({ ownerId, petId, viewer, initial, onDone }: { ownerId: string; petId: string; viewer: Viewer; initial: Medication | null; onDone: () => void }) {
  const { success } = useDialogs();
  const [f, setF] = useState({
    name: initial?.name ?? '',
    dosage: initial?.dosage ?? '',
    frequency: (initial?.frequency ?? 'onceDaily') as Frequency,
    doseTimes: initial?.doseTimes ?? DEFAULT_DOSE_TIMES.onceDaily,
    startDate: toDateInput(initial?.startDate ?? new Date()),
    endDate: toDateInput(initial?.endDate),
    remindersEnabled: initial?.remindersEnabled ?? true,
    instructions: initial?.instructions ?? '',
    notes: initial?.notes ?? '',
  });
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const set = (k: 'name' | 'dosage' | 'startDate' | 'endDate' | 'instructions' | 'notes') => (e: { target: { value: string } }) =>
    setF((s) => ({ ...s, [k]: e.target.value }));

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    const start = fromDateInput(f.startDate);
    const end = fromDateInput(f.endDate);
    const errs: Record<string, string> = {};
    if (!f.name.trim()) errs.name = 'Medication name is required.';
    if (!start) errs.startDate = 'Start date is required.';
    if (start && end && end < start) errs.endDate = 'Must be on or after the start date.';
    setErrors(errs);
    if (Object.keys(errs).length) return;
    setBusy(true);
    setError(null);
    try {
      await saveMedication({
        id: initial?.id,
        ownerId,
        petId,
        name: f.name,
        dosage: f.dosage,
        frequency: f.frequency,
        doseTimes: [...f.doseTimes].sort(),
        startDate: start!,
        endDate: end,
        remindersEnabled: f.remindersEnabled,
        instructions: f.instructions,
        veterinarian: viewer.isOwner ? initial?.veterinarian ?? null : viewer.name ?? null,
        notes: f.notes,
        ...(initial ? { addedByUid: initial.addedByUid, addedByName: initial.addedByName } : addedByFields(viewer)),
      });
      onDone();
      await success({ title: initial ? 'Medication updated' : viewer.isOwner ? 'Medication added' : 'Prescription added', message: viewer.isOwner ? undefined : 'The owner gets dose reminders in the app.' });
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <form onSubmit={submit} className="space-y-4" noValidate>
      <div className="grid gap-4 sm:grid-cols-2">
        <Input label="Medication *" value={f.name} onChange={set('name')} error={errors.name} placeholder="e.g. Amoxicillin" />
        <Input label="Dosage" value={f.dosage} onChange={set('dosage')} placeholder="e.g. 1 tablet" />
      </div>
      <Select
        label="Frequency"
        value={f.frequency}
        onChange={(e) => {
          const frequency = e.target.value as Frequency;
          setF((s) => ({ ...s, frequency, doseTimes: DEFAULT_DOSE_TIMES[frequency] }));
        }}
      >
        {Object.entries(FREQUENCIES).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
      </Select>
      {f.frequency !== 'asNeeded' && (
        <div>
          <span className="label">Dose times</span>
          <div className="flex flex-wrap gap-2">
            {f.doseTimes.map((t, i) => (
              <input
                key={i}
                type="time"
                aria-label={`Dose ${i + 1} time`}
                value={t}
                onChange={(e) => setF((s) => ({ ...s, doseTimes: s.doseTimes.map((x, j) => (j === i ? e.target.value : x)) }))}
                className="input w-32"
              />
            ))}
          </div>
        </div>
      )}
      <div className="grid gap-4 sm:grid-cols-2">
        <Input label="Start date *" type="date" value={f.startDate} onChange={set('startDate')} error={errors.startDate} />
        <Input label="End date" type="date" value={f.endDate} onChange={set('endDate')} error={errors.endDate} hint="Leave empty for ongoing" />
      </div>
      <Textarea label="Instructions" value={f.instructions} onChange={set('instructions')} placeholder="e.g. Give with food" />
      {f.frequency !== 'asNeeded' && (
        <label className="flex items-center gap-3 text-sm font-semibold">
          <input type="checkbox" checked={f.remindersEnabled} onChange={(e) => setF((s) => ({ ...s, remindersEnabled: e.target.checked }))} className="h-5 w-5 accent-brand-teal" />
          Dose reminders in the owner’s app
        </label>
      )}
      <ErrorNote text={error} />
      <Button type="submit" loading={busy} className="w-full">{initial ? 'Save changes' : viewer.isOwner ? 'Add medication' : 'Add prescription'}</Button>
    </form>
  );
}

// ── Weight & documents (read-only on the web) ───────────────────────────
export function WeightPanel({ ownerId, petId }: { ownerId: string; petId: string }) {
  const { weights } = usePetRecords(ownerId, petId);
  if (weights.loading) return <Card><Spinner /></Card>;
  if (!weights.data.length) return <Card><EmptyState icon={Scale} title="No weigh-ins yet" message="Weights logged in the app appear here." /></Card>;
  const data = weights.data.map((w) => ({ date: fmtDate(w.date), kg: w.weightKg }));
  return (
    <Card>
      <div className="h-64">
        <ResponsiveContainer>
          <LineChart data={data} margin={{ top: 10, right: 10, bottom: 0, left: -10 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
            <XAxis dataKey="date" fontSize={12} tickLine={false} />
            <YAxis fontSize={12} tickLine={false} unit=" kg" domain={['auto', 'auto']} />
            <Tooltip formatter={(v) => [fmtWeight(Number(v)), 'Weight']} />
            <Line isAnimationActive={false} type="monotone" dataKey="kg" stroke="#EC4899" strokeWidth={3} dot={{ r: 4, fill: '#EC4899' }} />
          </LineChart>
        </ResponsiveContainer>
      </div>
      <div className="mt-4 divide-y divide-slate-100">
        {[...weights.data].reverse().map((w) => (
          <div key={w.id} className="flex justify-between py-2 text-sm">
            <span className="text-slate-500">{fmtDate(w.date)}{w.note && ` · ${w.note}`}</span>
            <span className="font-bold">{fmtWeight(w.weightKg)}</span>
          </div>
        ))}
      </div>
    </Card>
  );
}

export function DocumentsPanel({ ownerId, petId }: { ownerId: string; petId: string }) {
  const { documents } = usePetRecords(ownerId, petId);
  return (
    <ListCard loading={documents.loading} empty={!documents.data.length} emptyIcon={FileText} emptyText="No documents yet">
      {documents.data.map((d) => (
        <RecordRow
          key={d.id}
          icon={FileText}
          accent="documents"
          title={d.name}
          meta={<>{d.date ? fmtDate(d.date) : 'No date'} · {d.contentType === 'application/pdf' ? 'PDF' : 'Image'} · {fmtBytes(d.sizeBytes)}</>}
          actions={<a href={d.fileUrl} target="_blank" rel="noreferrer" className="btn-outline px-3 py-1.5 text-xs">Open</a>}
        />
      ))}
    </ListCard>
  );
}
