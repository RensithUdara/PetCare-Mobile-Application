import { EmailAuthProvider, reauthenticateWithCredential, updatePassword } from 'firebase/auth';
import { query, where } from 'firebase/firestore';
import {
  CalendarClock,
  Cake,
  KeyRound,
  Pencil,
  PawPrint,
  Pill,
  Plus,
  Scale,
  Search,
  ShieldCheck,
  Syringe,
  Trash2,
  UserMinus,
  Venus,
} from 'lucide-react';
import { useState, type FormEvent } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';

import { useDialogs } from '../../components/dialogs';
import { AppointmentsPanel, DocumentsPanel, MedicationsPanel, VaccinationsPanel, WeightPanel, type Viewer } from '../../components/records';
import {
  Badge,
  Button,
  Card,
  ChoiceTiles,
  EmptyState,
  ErrorNote,
  Hero,
  IconBadge,
  Initials,
  Input,
  Modal,
  PageHeading,
  PetAvatar,
  SectionTitle,
  Spinner,
  StatCard,
  Tabs,
  Textarea,
} from '../../components/ui';
import { useAuth } from '../../hooks/useAuth';
import { useLiveDoc, useLiveQuery } from '../../hooks/useFirestore';
import {
  deletePet,
  errorMessage,
  findDoctorByCode,
  petDoc,
  petsCol,
  recordsCol,
  revokeShare,
  savePet,
  sharePet,
  sharesCol,
  updateProfile,
} from '../../lib/api';
import { appointmentFromDoc, medicationFromDoc, petFromDoc, shareFromDoc, vaccinationFromDoc } from '../../lib/converters';
import { auth } from '../../lib/firebase';
import { fmtDate, fmtDateTime, fmtWeight, fromDateInput, petAge, toDateInput, vaccinationStatuses } from '../../lib/format';
import { APPOINTMENT_TYPES, GENDERS, SPECIES, SPECIES_EMOJI, type DoctorProfile, type Gender, type Pet, type Species } from '../../lib/types';

function useMyPets() {
  const { user } = useAuth();
  const uid = user?.uid ?? null;
  const pets = useLiveQuery(uid ? petsCol(uid) : null, `pets-${uid}`, petFromDoc);
  return { ...pets, data: [...pets.data].sort((a, b) => a.name.localeCompare(b.name)) };
}

// ── Dashboard ───────────────────────────────────────────────────────────
export function OwnerDashboard() {
  const { user, profile } = useAuth();
  const uid = user!.uid;
  const pets = useMyPets();
  const appointments = useLiveQuery(query(recordsCol(uid, 'appointments'), where('status', '==', 'scheduled')), `appts-${uid}`, appointmentFromDoc);
  const vaccinations = useLiveQuery(recordsCol(uid, 'vaccinations'), `vax-${uid}`, vaccinationFromDoc);
  const medications = useLiveQuery(recordsCol(uid, 'medications'), `meds-${uid}`, medicationFromDoc);

  const now = new Date();
  const petName = (id: string) => pets.data.find((p) => p.id === id)?.name ?? 'Pet';
  const upcoming = appointments.data.filter((a) => a.dateTime >= now).sort((a, b) => +a.dateTime - +b.dateTime);
  const statuses = vaccinationStatuses(vaccinations.data);
  const due = vaccinations.data.filter((v) => ['overdue', 'upcoming'].includes(statuses.get(v.id)!)).sort((a, b) => +a.nextDueDate! - +b.nextDueDate!);
  const activeMeds = medications.data.filter((m) => m.startDate <= now && (!m.endDate || m.endDate >= new Date(now.toDateString())));
  const hour = now.getHours();
  const greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';

  return (
    <>
      <Hero>
        <p className="text-sm text-white/85">{now.toLocaleDateString(undefined, { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' })}</p>
        <h1 className="mt-1 text-3xl font-extrabold">{greeting}{profile?.fullName ? `, ${profile.fullName.split(' ')[0]}` : ''} 👋</h1>
        <p className="mt-1 text-white/85">Here’s how your pets are doing.</p>
      </Hero>

      <div className="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard icon={PawPrint} accent="pets" label="Pets" value={pets.data.length} />
        <StatCard icon={CalendarClock} accent="appointments" label="Upcoming visits" value={upcoming.length} />
        <StatCard icon={Syringe} accent="vaccinations" label="Vaccines due" value={due.length} />
        <StatCard icon={Pill} accent="medications" label="Active medications" value={activeMeds.length} />
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <div>
          <SectionTitle icon={Syringe} accent="emergency" title="Vaccines needing attention" />
          <Card padded={false}>
            {due.length === 0 ? (
              <p className="p-5 text-sm text-slate-500">All caught up — no vaccinations due in the next 30 days.</p>
            ) : (
              due.slice(0, 6).map((v) => (
                <Link key={v.id} to={`/owner/pets/${v.petId}`} className="flex items-center gap-4 border-b border-slate-100 p-4 last:border-0 hover:bg-slate-50">
                  <IconBadge icon={Syringe} accent={statuses.get(v.id) === 'overdue' ? 'emergency' : 'documents'} size={40} />
                  <div className="flex-1">
                    <div className="font-bold">{petName(v.petId)} · {v.vaccineName}</div>
                    <div className="text-sm text-slate-500">Due {fmtDate(v.nextDueDate)}</div>
                  </div>
                  <Badge tone={statuses.get(v.id) === 'overdue' ? 'red' : 'amber'}>{statuses.get(v.id) === 'overdue' ? 'Overdue' : 'Due soon'}</Badge>
                </Link>
              ))
            )}
          </Card>
        </div>
        <div>
          <SectionTitle icon={CalendarClock} accent="appointments" title="Upcoming appointments" />
          <Card padded={false}>
            {upcoming.length === 0 ? (
              <p className="p-5 text-sm text-slate-500">No upcoming appointments.</p>
            ) : (
              upcoming.slice(0, 6).map((a) => (
                <Link key={a.id} to={`/owner/pets/${a.petId}`} className="flex items-center gap-4 border-b border-slate-100 p-4 last:border-0 hover:bg-slate-50">
                  <IconBadge icon={CalendarClock} accent="appointments" size={40} />
                  <div>
                    <div className="font-bold">{petName(a.petId)} · {APPOINTMENT_TYPES[a.type]}</div>
                    <div className="text-sm text-slate-500">{fmtDateTime(a.dateTime)}{a.clinic && ` · ${a.clinic}`}</div>
                  </div>
                </Link>
              ))
            )}
          </Card>
        </div>
      </div>

      <SectionTitle icon={PawPrint} accent="pets" title="Your pets" action={<Link to="/owner/pets" className="text-sm font-bold text-brand-tealDeep">See all</Link>} />
      {pets.loading ? <Spinner /> : pets.data.length === 0 ? (
        <Card><EmptyState icon={PawPrint} title="Welcome to PetCare" message="Add your first pet to start tracking their health." action={<Link to="/owner/pets" className="btn-primary">Add a pet</Link>} /></Card>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">{pets.data.slice(0, 8).map((p) => <PetCard key={p.id} pet={p} />)}</div>
      )}
    </>
  );
}

function PetCard({ pet }: { pet: Pet }) {
  return (
    <Link to={`/owner/pets/${pet.id}`} className="card flex flex-col items-center p-5 text-center transition hover:-translate-y-0.5 hover:shadow-glow">
      <span className="rounded-full bg-brand p-[3px]"><span className="block rounded-full bg-white p-0.5"><PetAvatar species={pet.species} photoUrl={pet.photoUrl} size={72} /></span></span>
      <div className="mt-3 font-extrabold">{pet.name}</div>
      <div className="text-sm text-slate-500">{pet.breed ?? SPECIES[pet.species]}</div>
      {petAge(pet.dateOfBirth) && <div className="mt-1 text-xs text-slate-400">{petAge(pet.dateOfBirth)}</div>}
    </Link>
  );
}

// ── Pets ────────────────────────────────────────────────────────────────
export function OwnerPets() {
  const pets = useMyPets();
  const [adding, setAdding] = useState(false);
  const [q, setQ] = useState('');
  const shown = pets.data.filter((p) => `${p.name} ${p.breed ?? ''} ${SPECIES[p.species]}`.toLowerCase().includes(q.toLowerCase()));

  return (
    <>
      <PageHeading title="My pets" subtitle="Everyone in your family, in one place." action={<Button icon={Plus} onClick={() => setAdding(true)}>Add pet</Button>} />
      {pets.data.length > 3 && (
        <div className="relative mb-5 max-w-sm">
          <Search size={18} className="absolute left-4 top-3.5 text-slate-400" />
          <input className="input pl-11" placeholder="Search pets" value={q} onChange={(e) => setQ(e.target.value)} />
        </div>
      )}
      {pets.loading ? <Spinner /> : pets.data.length === 0 ? (
        <Card><EmptyState icon={PawPrint} title="No pets yet" message="Add your first pet to start tracking their health." action={<Button icon={Plus} onClick={() => setAdding(true)}>Add pet</Button>} /></Card>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">{shown.map((p) => <PetCard key={p.id} pet={p} />)}</div>
      )}
      <Modal open={adding} title="Add pet" onClose={() => setAdding(false)} wide>
        {adding && <PetForm onDone={() => setAdding(false)} />}
      </Modal>
    </>
  );
}

function PetForm({ initial, onDone }: { initial?: Pet; onDone: (id?: string) => void }) {
  const { user } = useAuth();
  const { success } = useDialogs();
  const navigate = useNavigate();
  const [f, setF] = useState({
    name: initial?.name ?? '',
    species: (initial?.species ?? null) as Species | null,
    breed: initial?.breed ?? '',
    gender: (initial?.gender ?? 'unknown') as Gender,
    dateOfBirth: toDateInput(initial?.dateOfBirth),
    weightKg: initial?.weightKg?.toString() ?? '',
    color: initial?.color ?? '',
    microchipId: initial?.microchipId ?? '',
    registrationNumber: initial?.registrationNumber ?? '',
    notes: initial?.notes ?? '',
  });
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const set = (k: keyof typeof f) => (e: { target: { value: string } }) => setF((s) => ({ ...s, [k]: e.target.value }));

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    const errs: Record<string, string> = {};
    const weight = f.weightKg.trim() ? Number(f.weightKg.replace(',', '.')) : null;
    const dob = fromDateInput(f.dateOfBirth);
    if (!f.name.trim()) errs.name = 'Pet name is required.';
    if (!f.species) errs.species = 'Choose a species.';
    if (weight !== null && (Number.isNaN(weight) || weight <= 0 || weight > 200)) errs.weightKg = 'Enter a weight between 0 and 200 kg.';
    if (dob && dob > new Date()) errs.dateOfBirth = 'Can’t be in the future.';
    setErrors(errs);
    if (Object.keys(errs).length) return;
    setBusy(true);
    setError(null);
    try {
      const id = await savePet(
        user!.uid,
        {
          name: f.name,
          species: f.species!,
          breed: f.breed,
          gender: f.gender,
          dateOfBirth: dob,
          weightKg: weight,
          color: f.color,
          microchipId: f.microchipId,
          registrationNumber: f.registrationNumber,
          notes: f.notes,
          photoUrl: initial?.photoUrl ?? null,
        },
        initial?.id,
      );
      onDone(id);
      await success({ title: initial ? 'Changes saved' : `${f.name.trim()} added!`, message: initial ? undefined : 'You can now add vaccinations, visits and more.' });
      if (!initial) navigate(`/owner/pets/${id}`);
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <form onSubmit={submit} className="space-y-4" noValidate>
      <Input label="Pet name *" value={f.name} onChange={set('name')} error={errors.name} maxLength={40} />
      <ChoiceTiles
        label="Species *"
        columns={5}
        value={f.species}
        onChange={(v) => setF((s) => ({ ...s, species: v }))}
        options={(Object.keys(SPECIES) as Species[]).map((s) => ({ value: s, label: SPECIES[s], icon: SPECIES_EMOJI[s] }))}
      />
      {errors.species && <p role="alert" className="-mt-2 text-xs font-semibold text-red-500">{errors.species}</p>}
      <div className="grid gap-4 sm:grid-cols-2">
        <Input label="Breed" value={f.breed} onChange={set('breed')} placeholder="e.g. Golden Retriever" />
        <Input label="Date of birth" type="date" value={f.dateOfBirth} onChange={set('dateOfBirth')} error={errors.dateOfBirth} />
      </div>
      <ChoiceTiles label="Gender" value={f.gender} onChange={(v) => setF((s) => ({ ...s, gender: v }))} accent="weight" options={(Object.keys(GENDERS) as Gender[]).map((g) => ({ value: g, label: GENDERS[g] }))} />
      <div className="grid gap-4 sm:grid-cols-2">
        <Input label="Weight (kg)" inputMode="decimal" value={f.weightKg} onChange={set('weightKg')} error={errors.weightKg} />
        <Input label="Color" value={f.color} onChange={set('color')} />
        <Input label="Microchip ID" value={f.microchipId} onChange={set('microchipId')} />
        <Input label="Registration number" value={f.registrationNumber} onChange={set('registrationNumber')} />
      </div>
      <Textarea label="Notes" value={f.notes} onChange={set('notes')} placeholder="Allergies, temperament, favourite treats…" />
      <ErrorNote text={error} />
      <Button type="submit" loading={busy} className="w-full" icon={initial ? undefined : Plus}>{initial ? 'Save changes' : 'Add pet'}</Button>
    </form>
  );
}

// ── Pet detail ──────────────────────────────────────────────────────────
type PetTab = 'vaccinations' | 'appointments' | 'medications' | 'weight' | 'documents' | 'vets';

export function OwnerPetDetail() {
  const { petId = '' } = useParams();
  const { user } = useAuth();
  const uid = user!.uid;
  const { confirm, success } = useDialogs();
  const navigate = useNavigate();
  const pet = useLiveDoc(petDoc(uid, petId), `pet-${uid}-${petId}`, petFromDoc);
  const [tab, setTab] = useState<PetTab>('vaccinations');
  const [editing, setEditing] = useState(false);
  const viewer: Viewer = { uid, isOwner: true };

  if (pet.loading) return <Spinner />;
  if (!pet.data) return <Card><EmptyState icon={PawPrint} title="Pet not found" message="This pet may have been deleted." action={<Link to="/owner/pets" className="btn-primary">Back to pets</Link>} /></Card>;
  const p = pet.data;

  const remove = async () => {
    if (!(await confirm({ title: `Delete ${p.name}?`, message: 'This permanently removes the pet profile and all health records, and revokes vet access.', confirmLabel: 'Delete', icon: Trash2, destructive: true }))) return;
    try {
      await deletePet(uid, p.id);
      navigate('/owner/pets');
      await success({ title: `${p.name} deleted` });
    } catch (e) {
      alert(errorMessage(e));
    }
  };

  return (
    <>
      <Hero>
        <div className="flex flex-wrap items-center gap-5">
          <span className="rounded-full bg-white p-1 shadow-xl"><PetAvatar species={p.species} photoUrl={p.photoUrl} size={96} /></span>
          <div className="flex-1">
            <h1 className="text-3xl font-extrabold">{p.name} {SPECIES_EMOJI[p.species]}</h1>
            <span className="mt-2 inline-block rounded-full bg-white/20 px-3 py-1 text-sm font-semibold">{p.breed ?? SPECIES[p.species]}</span>
          </div>
          <div className="flex gap-2">
            <button onClick={() => setEditing(true)} className="btn border border-white/35 bg-white/15 text-white hover:bg-white/25"><Pencil size={16} /> Edit</button>
            <button onClick={remove} aria-label="Delete pet" className="btn border border-white/35 bg-white/15 px-3 text-white hover:bg-red-500/80"><Trash2 size={16} /></button>
          </div>
        </div>
      </Hero>

      <div className="mt-5 grid gap-4 sm:grid-cols-3">
        <StatCard icon={Cake} accent="pets" label="Age" value={petAge(p.dateOfBirth) ?? '—'} />
        <StatCard icon={Scale} accent="weight" label="Weight" value={p.weightKg ? fmtWeight(p.weightKg) : '—'} />
        <StatCard icon={Venus} accent="appointments" label="Gender" value={GENDERS[p.gender]} />
      </div>

      {(p.microchipId || p.notes || p.color || p.dateOfBirth) && (
        <Card className="mt-4 grid gap-3 text-sm sm:grid-cols-2">
          {p.dateOfBirth && <div><span className="text-slate-500">Born</span> <b className="ml-2">{fmtDate(p.dateOfBirth)}</b></div>}
          {p.color && <div><span className="text-slate-500">Color</span> <b className="ml-2">{p.color}</b></div>}
          {p.microchipId && <div><span className="text-slate-500">Microchip</span> <b className="ml-2">{p.microchipId}</b></div>}
          {p.registrationNumber && <div><span className="text-slate-500">Registration</span> <b className="ml-2">{p.registrationNumber}</b></div>}
          {p.notes && <div className="sm:col-span-2"><span className="text-slate-500">Notes</span> <p className="mt-1">{p.notes}</p></div>}
        </Card>
      )}

      <div className="mb-4 mt-8">
        <Tabs
          value={tab}
          onChange={setTab}
          tabs={[
            { value: 'vaccinations', label: 'Vaccinations' },
            { value: 'appointments', label: 'Appointments' },
            { value: 'medications', label: 'Medications' },
            { value: 'weight', label: 'Weight' },
            { value: 'documents', label: 'Documents' },
            { value: 'vets', label: 'Vet access' },
          ]}
        />
      </div>
      {tab === 'vaccinations' && <VaccinationsPanel ownerId={uid} petId={p.id} viewer={viewer} />}
      {tab === 'appointments' && <AppointmentsPanel ownerId={uid} petId={p.id} viewer={viewer} />}
      {tab === 'medications' && <MedicationsPanel ownerId={uid} petId={p.id} viewer={viewer} />}
      {tab === 'weight' && <WeightPanel ownerId={uid} petId={p.id} />}
      {tab === 'documents' && <DocumentsPanel ownerId={uid} petId={p.id} />}
      {tab === 'vets' && <VetAccessPanel pet={p} />}

      <Modal open={editing} title={`Edit ${p.name}`} onClose={() => setEditing(false)} wide>
        {editing && <PetForm initial={p} onDone={() => setEditing(false)} />}
      </Modal>
    </>
  );
}

/** Share a pet's records with vets by doctor code; revoke any time. */
function VetAccessPanel({ pet }: { pet: Pet }) {
  const { user, profile } = useAuth();
  const { confirm, success } = useDialogs();
  const uid = user!.uid;
  const shares = useLiveQuery(query(sharesCol(), where('ownerId', '==', uid), where('petId', '==', pet.id)), `shares-${uid}-${pet.id}`, shareFromDoc);
  const [code, setCode] = useState('');
  const [found, setFound] = useState<DoctorProfile | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const lookUp = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      setFound(await findDoctorByCode(code));
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  const share = async (doctor: DoctorProfile) => {
    if (!(await confirm({ title: `Share ${pet.name} with ${doctor.fullName}?`, message: `They’ll see ${pet.name}’s records and can add vaccinations, prescriptions and visit notes. You can remove access at any time.`, confirmLabel: 'Share', icon: ShieldCheck, accent: 'clinics' }))) return;
    setBusy(true);
    setError(null);
    try {
      await sharePet(profile ?? { id: uid, fullName: user!.displayName ?? '', email: user!.email ?? '' }, pet, doctor);
      setFound(null);
      setCode('');
      await success({ title: 'Access granted', message: `${doctor.fullName} can now see ${pet.name}’s records.` });
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  const revoke = async (id: string, name: string) => {
    if (!(await confirm({ title: `Remove ${name}?`, message: `They will no longer see ${pet.name}’s records. Records they already added stay.`, confirmLabel: 'Remove', icon: UserMinus, destructive: true }))) return;
    try {
      await revokeShare(id);
      await success({ title: 'Access removed' });
    } catch (err) {
      setError(errorMessage(err));
    }
  };

  return (
    <div className="grid gap-6 lg:grid-cols-2">
      <Card>
        <div className="mb-4 flex items-center gap-3">
          <IconBadge icon={ShieldCheck} accent="clinics" />
          <div>
            <h3 className="font-extrabold">Add a vet</h3>
            <p className="text-sm text-slate-500">Ask your vet for their doctor code, e.g. DR-7K3M9Q.</p>
          </div>
        </div>
        {found ? (
          <div className="rounded-2xl border-2 border-cyan-300 bg-cyan-50 p-4">
            <div className="flex items-center gap-3">
              <Initials name={found.fullName} size={48} />
              <div>
                <div className="font-extrabold">{found.fullName} <Badge tone="blue">Verified</Badge></div>
                <div className="text-sm text-slate-500">{[found.specialization, found.clinicName, found.city].filter(Boolean).join(' · ')}</div>
              </div>
            </div>
            <div className="mt-4 grid grid-cols-2 gap-2">
              <Button variant="outline" onClick={() => setFound(null)}>Cancel</Button>
              <Button loading={busy} onClick={() => share(found)}>Give access</Button>
            </div>
          </div>
        ) : (
          <form onSubmit={lookUp} className="space-y-3">
            <Input label="Doctor code" value={code} onChange={(e) => setCode(e.target.value)} placeholder="DR-7K3M9Q" />
            <Button type="submit" loading={busy} icon={Search} className="w-full">Find vet</Button>
          </form>
        )}
        <div className="mt-3"><ErrorNote text={error} /></div>
      </Card>
      <Card padded={false}>
        <h3 className="px-5 pt-5 font-extrabold">Vets with access</h3>
        {shares.loading ? <Spinner /> : shares.data.length === 0 ? (
          <p className="p-5 text-sm text-slate-500">Only you can see {pet.name}’s records right now.</p>
        ) : (
          shares.data.map((s) => (
            <div key={s.id} className="flex items-center gap-3 border-b border-slate-100 p-4 last:border-0">
              <Initials name={s.doctorName} />
              <div className="flex-1">
                <div className="font-bold">{s.doctorName}</div>
                <div className="text-sm text-slate-500">{[s.clinicName, s.createdAt && `Since ${fmtDate(s.createdAt)}`].filter(Boolean).join(' · ')}</div>
              </div>
              <button aria-label={`Remove ${s.doctorName}`} onClick={() => revoke(s.id, s.doctorName)} className="rounded-lg p-2 text-red-500 hover:bg-red-50"><UserMinus size={18} /></button>
            </div>
          ))
        )}
      </Card>
    </div>
  );
}

// ── Profile ─────────────────────────────────────────────────────────────
export function OwnerProfile() {
  const { user, profile } = useAuth();
  const { success } = useDialogs();
  const [f, setF] = useState({ fullName: profile?.fullName ?? user?.displayName ?? '', phone: profile?.phone ?? '', city: profile?.city ?? '' });
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const usesPassword = user?.providerData.some((p) => p.providerId === 'password');

  const save = async (e: FormEvent) => {
    e.preventDefault();
    if (f.fullName.trim().length < 2) return setError('Please enter your full name.');
    setBusy(true);
    setError(null);
    try {
      await updateProfile(user!.uid, f);
      await success({ title: 'Profile updated', message: 'Your details are saved.' });
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <>
      <PageHeading title="Profile" subtitle="Your details, shared with vets you give access to." />
      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <div className="mb-5 flex items-center gap-4">
            <Initials name={f.fullName || 'PetCare user'} size={64} />
            <div>
              <div className="text-lg font-extrabold">{f.fullName || 'PetCare user'}</div>
              <div className="text-sm text-slate-500">{user?.email}</div>
            </div>
          </div>
          <form onSubmit={save} className="space-y-4">
            <Input label="Full name" value={f.fullName} onChange={(e) => setF({ ...f, fullName: e.target.value })} />
            <Input label="Phone" value={f.phone} onChange={(e) => setF({ ...f, phone: e.target.value })} />
            <Input label="City" value={f.city} onChange={(e) => setF({ ...f, city: e.target.value })} />
            <Input label="Email" value={user?.email ?? ''} disabled hint="Your email is your login and can’t be changed here." />
            <ErrorNote text={error} />
            <Button type="submit" loading={busy} className="w-full">Save changes</Button>
          </form>
        </Card>
        {usesPassword && <ChangePasswordCard />}
      </div>
    </>
  );
}

export function ChangePasswordCard() {
  const { success } = useDialogs();
  const [f, setF] = useState({ current: '', next: '', confirm: '' });
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    if (f.next.length < 8 || !/[A-Za-z]/.test(f.next) || !/\d/.test(f.next)) return setError('Use at least 8 characters with letters and numbers.');
    if (f.next !== f.confirm) return setError('Passwords don’t match.');
    if (f.next === f.current) return setError('Choose a password different from your current one.');
    const u = auth.currentUser!;
    setBusy(true);
    setError(null);
    try {
      await reauthenticateWithCredential(u, EmailAuthProvider.credential(u.email!, f.current));
      await updatePassword(u, f.next);
      setF({ current: '', next: '', confirm: '' });
      await success({ title: 'Password changed', message: 'Use your new password the next time you sign in.' });
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <Card>
      <div className="mb-5 flex items-center gap-3">
        <IconBadge icon={KeyRound} accent="medications" />
        <h3 className="font-extrabold">Change password</h3>
      </div>
      <form onSubmit={submit} className="space-y-4">
        <Input label="Current password" type="password" autoComplete="current-password" value={f.current} onChange={(e) => setF({ ...f, current: e.target.value })} />
        <Input label="New password" type="password" autoComplete="new-password" value={f.next} onChange={(e) => setF({ ...f, next: e.target.value })} />
        <Input label="Confirm new password" type="password" autoComplete="new-password" value={f.confirm} onChange={(e) => setF({ ...f, confirm: e.target.value })} />
        <ErrorNote text={error} />
        <Button type="submit" loading={busy} variant="outline" className="w-full">Update password</Button>
      </form>
    </Card>
  );
}

