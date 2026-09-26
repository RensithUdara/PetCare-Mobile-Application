import { doc, query, where } from 'firebase/firestore';
import {
  CalendarClock,
  Check,
  Clock,
  Copy,
  Mail,
  PawPrint,
  Phone,
  RefreshCw,
  Search,
  Stethoscope,
  UserMinus,
  Users,
  XCircle,
} from 'lucide-react';
import { useState, type FormEvent } from 'react';
import { Link, Navigate, useNavigate, useParams } from 'react-router-dom';

import { useDialogs } from '../../components/dialogs';
import { AppointmentsPanel, DocumentsPanel, MedicationsPanel, VaccinationsPanel, WeightPanel, type Viewer } from '../../components/records';
import {
  Badge,
  Button,
  Card,
  EmptyState,
  ErrorNote,
  Hero,
  IconBadge,
  Initials,
  Input,
  PageHeading,
  PetAvatar,
  SectionTitle,
  Spinner,
  StatCard,
  Tabs,
  Textarea,
} from '../../components/ui';
import { homePathFor, useAuth } from '../../hooks/useAuth';
import { useLiveDoc, useLiveQuery } from '../../hooks/useFirestore';
import { errorMessage, petDoc, revokeShare, sharesCol, updateDoctorProfile } from '../../lib/api';
import { petFromDoc, shareFromDoc } from '../../lib/converters';
import { fmtDate, fmtWeight, petAge } from '../../lib/format';
import { GENDERS, SPECIES, SPECIES_EMOJI } from '../../lib/types';
import { ChangePasswordCard } from '../owner/OwnerPages';

function useMyPatients() {
  const { user } = useAuth();
  const uid = user!.uid;
  const shares = useLiveQuery(query(sharesCol(), where('doctorId', '==', uid)), `patients-${uid}`, shareFromDoc);
  return { ...shares, data: [...shares.data].sort((a, b) => +(b.createdAt ?? 0) - +(a.createdAt ?? 0)) };
}

/** The code owners enter in the app to share a pet with this vet. */
function DoctorCodeCard({ code }: { code: string }) {
  const [copied, setCopied] = useState(false);
  return (
    <div className="flex flex-wrap items-center gap-4 rounded-2xl bg-white/15 p-4 ring-1 ring-white/30">
      <div className="flex-1">
        <div className="text-xs font-bold uppercase tracking-wider text-white/75">Your doctor code</div>
        <div className="mt-1 font-mono text-3xl font-extrabold tracking-widest">{code}</div>
        <div className="mt-1 text-sm text-white/80">Owners enter it in PetCare → pet profile → Vet access.</div>
      </div>
      <button
        onClick={async () => {
          await navigator.clipboard.writeText(code);
          setCopied(true);
          setTimeout(() => setCopied(false), 1500);
        }}
        className="btn bg-white text-brand-tealDeep hover:bg-white/90"
      >
        {copied ? <Check size={18} /> : <Copy size={18} />} {copied ? 'Copied' : 'Copy'}
      </button>
    </div>
  );
}

// ── Pending / rejected application ──────────────────────────────────────
export function DoctorPending() {
  const { role, doctor, refreshRole } = useAuth();
  const navigate = useNavigate();
  const [checking, setChecking] = useState(false);
  if (role === 'doctor') return <Navigate to="/doctor" replace />;
  if (!doctor) return <Navigate to="/owner" replace />;
  const rejected = doctor.status === 'rejected';

  return (
    <div className="flex min-h-screen items-center justify-center bg-surface p-6">
      <Card className="w-full max-w-lg p-8 text-center">
        <span className={`mx-auto mb-5 flex h-24 w-24 items-center justify-center rounded-full text-white ${rejected ? 'bg-red-500' : 'bg-brand shadow-glow'}`}>
          {rejected ? <XCircle size={44} /> : <Clock size={44} />}
        </span>
        <h1 className="text-2xl font-extrabold">{rejected ? 'Application not approved' : 'Application under review'}</h1>
        <p className="mt-2 text-slate-500">
          {rejected
            ? 'An admin reviewed your veterinarian application and couldn’t approve it.'
            : 'Thanks for applying, ' + doctor.fullName + '! An admin will verify your details. You’ll get access to the doctor portal as soon as you’re approved.'}
        </p>
        {doctor.reviewNote && <p className="mt-4 rounded-xl bg-slate-100 p-3 text-sm"><b>Note from the admin:</b> {doctor.reviewNote}</p>}
        <div className="mt-6 grid gap-2 sm:grid-cols-2">
          <Button
            variant="outline"
            icon={RefreshCw}
            loading={checking}
            onClick={async () => {
              setChecking(true);
              const r = await refreshRole();
              setChecking(false);
              if (r === 'doctor') navigate('/doctor');
            }}
          >
            Check again
          </Button>
          <Link to="/owner" className="btn-primary">Go to my pets</Link>
        </div>
      </Card>
    </div>
  );
}

// ── Dashboard ───────────────────────────────────────────────────────────
export function DoctorDashboard() {
  const { doctor } = useAuth();
  const patients = useMyPatients();
  const owners = new Set(patients.data.map((p) => p.ownerId)).size;
  const recent = patients.data.slice(0, 6);
  const thisMonth = patients.data.filter((p) => p.createdAt && p.createdAt > new Date(Date.now() - 30 * 864e5)).length;

  return (
    <>
      <Hero>
        <p className="text-sm text-white/85">Welcome back</p>
        <h1 className="mt-1 text-3xl font-extrabold">{doctor?.fullName ?? 'Doctor'}</h1>
        <p className="mb-5 mt-1 text-white/85">{[doctor?.specialization, doctor?.clinicName].filter(Boolean).join(' · ')}</p>
        {doctor?.doctorCode && <DoctorCodeCard code={doctor.doctorCode} />}
      </Hero>
      <div className="mt-6 grid gap-4 sm:grid-cols-3">
        <StatCard icon={PawPrint} accent="pets" label="Patients" value={patients.data.length} />
        <StatCard icon={Users} accent="appointments" label="Pet owners" value={owners} />
        <StatCard icon={CalendarClock} accent="vaccinations" label="New in the last 30 days" value={thisMonth} />
      </div>
      <SectionTitle icon={PawPrint} accent="pets" title="Recent patients" action={<Link to="/doctor/patients" className="text-sm font-bold text-brand-tealDeep">See all</Link>} />
      {patients.loading ? <Spinner /> : recent.length === 0 ? (
        <Card>
          <EmptyState icon={Stethoscope} title="No patients yet" message="When an owner shares a pet with your doctor code, it appears here." />
        </Card>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {recent.map((s) => <PatientCard key={s.id} share={s} />)}
        </div>
      )}
    </>
  );
}

function PatientCard({ share }: { share: ReturnType<typeof shareFromDoc> }) {
  return (
    <Link to={`/doctor/patients/${share.id}`} className="card flex items-center gap-4 p-4 transition hover:-translate-y-0.5 hover:shadow-glow">
      <PetAvatar species={share.petSpecies} photoUrl={share.petPhotoUrl} size={56} />
      <div className="min-w-0">
        <div className="truncate font-extrabold">{share.petName}</div>
        <div className="truncate text-sm text-slate-500">Owner: {share.ownerName ?? share.ownerEmail ?? '—'}</div>
        {share.createdAt && <div className="text-xs text-slate-400">Shared {fmtDate(share.createdAt)}</div>}
      </div>
    </Link>
  );
}

// ── Patients ────────────────────────────────────────────────────────────
export function DoctorPatients() {
  const patients = useMyPatients();
  const [q, setQ] = useState('');
  const shown = patients.data.filter((s) => `${s.petName} ${s.ownerName ?? ''} ${s.ownerEmail ?? ''}`.toLowerCase().includes(q.toLowerCase()));
  return (
    <>
      <PageHeading title="Patients" subtitle="Pets whose owners have shared their records with you." />
      <div className="relative mb-5 max-w-sm">
        <Search size={18} className="absolute left-4 top-3.5 text-slate-400" />
        <input className="input pl-11" placeholder="Search by pet or owner" value={q} onChange={(e) => setQ(e.target.value)} />
      </div>
      {patients.loading ? <Spinner /> : shown.length === 0 ? (
        <Card><EmptyState icon={PawPrint} title={q ? 'No matches' : 'No patients yet'} message={q ? undefined : 'Give owners your doctor code so they can share their pets with you.'} /></Card>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">{shown.map((s) => <PatientCard key={s.id} share={s} />)}</div>
      )}
    </>
  );
}

type PatientTab = 'vaccinations' | 'appointments' | 'medications' | 'weight' | 'documents';

export function DoctorPatientDetail() {
  const { shareId = '' } = useParams();
  const { user, doctor } = useAuth();
  const { confirm, success } = useDialogs();
  const navigate = useNavigate();
  const share = useLiveDoc(doc(sharesCol(), shareId), `share-${shareId}`, shareFromDoc);
  const s = share.data;
  const pet = useLiveDoc(s ? petDoc(s.ownerId, s.petId) : null, `patient-${s?.ownerId}-${s?.petId}`, petFromDoc);
  const [tab, setTab] = useState<PatientTab>('vaccinations');

  if (share.loading || (s && pet.loading)) return <Spinner />;
  if (!s || !pet.data)
    return <Card><EmptyState icon={PawPrint} title="Patient not available" message="The owner may have removed your access." action={<Link to="/doctor/patients" className="btn-primary">Back to patients</Link>} /></Card>;
  const p = pet.data;
  const viewer: Viewer = { uid: user!.uid, isOwner: false, name: doctor?.fullName ?? 'Veterinarian' };

  const remove = async () => {
    if (!(await confirm({ title: `Remove ${p.name}?`, message: 'The pet leaves your patient list. The owner can share again later.', confirmLabel: 'Remove', icon: UserMinus, destructive: true }))) return;
    await revokeShare(s.id);
    navigate('/doctor/patients');
    await success({ title: 'Patient removed' });
  };

  return (
    <>
      <Hero>
        <div className="flex flex-wrap items-center gap-5">
          <span className="rounded-full bg-white p-1 shadow-xl"><PetAvatar species={p.species} photoUrl={p.photoUrl} size={88} /></span>
          <div className="flex-1">
            <h1 className="text-3xl font-extrabold">{p.name} {SPECIES_EMOJI[p.species]}</h1>
            <p className="mt-1 text-white/90">
              {[p.breed ?? SPECIES[p.species], GENDERS[p.gender], petAge(p.dateOfBirth), p.weightKg ? fmtWeight(p.weightKg) : null].filter(Boolean).join(' · ')}
            </p>
          </div>
          <button onClick={remove} className="btn border border-white/35 bg-white/15 text-white hover:bg-white/25"><UserMinus size={16} /> Remove patient</button>
        </div>
      </Hero>

      <div className="mt-5 grid gap-4 lg:grid-cols-3">
        <Card className="lg:col-span-1">
          <div className="mb-3 flex items-center gap-3">
            <Initials name={s.ownerName ?? 'Owner'} />
            <div>
              <div className="text-xs font-bold uppercase text-slate-400">Owner</div>
              <div className="font-extrabold">{s.ownerName ?? '—'}</div>
            </div>
          </div>
          {s.ownerPhone && <a href={`tel:${s.ownerPhone}`} className="flex items-center gap-2 py-1 text-sm font-semibold text-brand-tealDeep"><Phone size={16} /> {s.ownerPhone}</a>}
          {s.ownerEmail && <a href={`mailto:${s.ownerEmail}`} className="flex items-center gap-2 py-1 text-sm font-semibold text-brand-tealDeep"><Mail size={16} /> {s.ownerEmail}</a>}
        </Card>
        <Card className="text-sm lg:col-span-2">
          <div className="grid gap-2 sm:grid-cols-2">
            <div><span className="text-slate-500">Born</span> <b className="ml-2">{fmtDate(p.dateOfBirth)}</b></div>
            <div><span className="text-slate-500">Microchip</span> <b className="ml-2">{p.microchipId ?? '—'}</b></div>
            <div><span className="text-slate-500">Color</span> <b className="ml-2">{p.color ?? '—'}</b></div>
            <div><span className="text-slate-500">Shared</span> <b className="ml-2">{fmtDate(s.createdAt)}</b></div>
          </div>
          {p.notes && <p className="mt-3 rounded-xl bg-amber-50 p-3"><b>Owner’s notes:</b> {p.notes}</p>}
        </Card>
      </div>

      <div className="mb-4 mt-8 flex flex-wrap items-center justify-between gap-3">
        <Tabs
          value={tab}
          onChange={setTab}
          tabs={[
            { value: 'vaccinations', label: 'Vaccinations' },
            { value: 'appointments', label: 'Visits' },
            { value: 'medications', label: 'Prescriptions' },
            { value: 'weight', label: 'Weight' },
            { value: 'documents', label: 'Documents' },
          ]}
        />
        <Badge tone="violet">You can add records; only the owner can delete</Badge>
      </div>
      {tab === 'vaccinations' && <VaccinationsPanel ownerId={s.ownerId} petId={s.petId} viewer={viewer} />}
      {tab === 'appointments' && <AppointmentsPanel ownerId={s.ownerId} petId={s.petId} viewer={viewer} />}
      {tab === 'medications' && <MedicationsPanel ownerId={s.ownerId} petId={s.petId} viewer={viewer} />}
      {tab === 'weight' && <WeightPanel ownerId={s.ownerId} petId={s.petId} />}
      {tab === 'documents' && <DocumentsPanel ownerId={s.ownerId} petId={s.petId} />}
    </>
  );
}

// ── Profile ─────────────────────────────────────────────────────────────
export function DoctorProfilePage() {
  const { user, doctor, role } = useAuth();
  const { success } = useDialogs();
  const [f, setF] = useState({
    fullName: doctor?.fullName ?? '',
    phone: doctor?.phone ?? '',
    clinicName: doctor?.clinicName ?? '',
    specialization: doctor?.specialization ?? '',
    licenseNumber: doctor?.licenseNumber ?? '',
    city: doctor?.city ?? '',
    bio: doctor?.bio ?? '',
  });
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  if (!doctor) return <Navigate to={homePathFor(role, doctor)} replace />;
  const set = (k: keyof typeof f) => (e: { target: { value: string } }) => setF((s) => ({ ...s, [k]: e.target.value }));
  const usesPassword = user?.providerData.some((p) => p.providerId === 'password');

  const save = async (e: FormEvent) => {
    e.preventDefault();
    if (f.fullName.trim().length < 2) return setError('Please enter your full name.');
    setBusy(true);
    setError(null);
    try {
      await updateDoctorProfile(user!.uid, f);
      await success({ title: 'Profile updated', message: 'Owners see these details when they share a pet with you.' });
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <>
      <PageHeading title="My profile" subtitle="Shown to owners when they look up your doctor code." />
      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <div className="mb-5 flex items-center gap-3">
            <IconBadge icon={Stethoscope} accent="clinics" />
            <div className="flex-1">
              <h3 className="font-extrabold">{doctor.fullName}</h3>
              <div className="text-sm text-slate-500">{doctor.email}</div>
            </div>
            {doctor.doctorCode && <Badge tone="blue">{doctor.doctorCode}</Badge>}
          </div>
          <form onSubmit={save} className="space-y-4">
            <Input label="Full name" value={f.fullName} onChange={set('fullName')} />
            <div className="grid gap-4 sm:grid-cols-2">
              <Input label="Phone" value={f.phone} onChange={set('phone')} />
              <Input label="City" value={f.city} onChange={set('city')} />
              <Input label="Clinic / practice" value={f.clinicName} onChange={set('clinicName')} />
              <Input label="Specialization" value={f.specialization} onChange={set('specialization')} />
            </div>
            <Input label="Licence number" value={f.licenseNumber} onChange={set('licenseNumber')} />
            <Textarea label="About you" value={f.bio} onChange={set('bio')} />
            <ErrorNote text={error} />
            <Button type="submit" loading={busy} className="w-full">Save changes</Button>
          </form>
        </Card>
        {usesPassword && <ChangePasswordCard />}
      </div>
    </>
  );
}
