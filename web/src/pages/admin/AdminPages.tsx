import { sendEmailVerification } from 'firebase/auth';
import { collection, query, where } from 'firebase/firestore';
import {
  Ban,
  CalendarClock,
  Check,
  CircleCheck,
  FileText,
  PawPrint,
  Pill,
  RefreshCw,
  Search,
  ShieldCheck,
  Stethoscope,
  Syringe,
  UserCog,
  Users,
  X,
} from 'lucide-react';
import { useCallback, useEffect, useState } from 'react';
import { Link, Navigate, useNavigate } from 'react-router-dom';
import { Bar, BarChart, CartesianGrid, Cell, Pie, PieChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';

import { useDialogs } from '../../components/dialogs';
import {
  Badge,
  Button,
  Card,
  EmptyState,
  ErrorNote,
  Hero,
  IconBadge,
  Initials,
  Modal,
  PageHeading,
  SectionTitle,
  Spinner,
  StatCard,
  Tabs,
  Textarea,
} from '../../components/ui';
import { useAuth } from '../../hooks/useAuth';
import { useLiveQuery } from '../../hooks/useFirestore';
import { adminApi, errorMessage, type AdminStats, type AdminUser } from '../../lib/api';
import { doctorFromDoc } from '../../lib/converters';
import { db } from '../../lib/firebase';
import { fmtDate } from '../../lib/format';
import type { DoctorProfile, DoctorStatus, Role } from '../../lib/types';

// ── Dashboard ───────────────────────────────────────────────────────────
export function AdminDashboard() {
  const [stats, setStats] = useState<AdminStats | null>(null);
  const [error, setError] = useState<string | null>(null);
  const pending = useLiveQuery(query(collection(db, 'doctors'), where('status', '==', 'pending')), 'pending-doctors', doctorFromDoc);

  const load = useCallback(async () => {
    setError(null);
    try {
      setStats(await adminApi.stats());
    } catch (e) {
      setError(errorMessage(e));
    }
  }, []);
  useEffect(() => void load(), [load]);

  const records = stats
    ? [
        { name: 'Vaccinations', value: stats.vaccinations, fill: '#10B981' },
        { name: 'Appointments', value: stats.appointments, fill: '#3B82F6' },
        { name: 'Medications', value: stats.medications, fill: '#8B5CF6' },
        { name: 'Documents', value: stats.documents, fill: '#F59E0B' },
      ]
    : [];
  const doctors = stats
    ? [
        { name: 'Approved', value: stats.doctors.approved, fill: '#12B39A' },
        { name: 'Pending', value: stats.doctors.pending, fill: '#F59E0B' },
        { name: 'Rejected', value: stats.doctors.rejected, fill: '#EF4444' },
      ]
    : [];

  return (
    <>
      <Hero>
        <div className="flex flex-wrap items-center justify-between gap-4">
          <div>
            <p className="text-sm text-white/85">Admin console</p>
            <h1 className="mt-1 text-3xl font-extrabold">Platform overview</h1>
            <p className="mt-1 text-white/85">Counts only — owners’ pet records stay private.</p>
          </div>
          <button onClick={load} className="btn border border-white/35 bg-white/15 text-white hover:bg-white/25"><RefreshCw size={16} /> Refresh</button>
        </div>
      </Hero>
      <div className="mt-4"><ErrorNote text={error} /></div>
      {!stats && !error ? <Spinner /> : stats && (
        <>
          <div className="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
            <StatCard icon={Users} accent="appointments" label="Users" value={stats.users} />
            <StatCard icon={Stethoscope} accent="clinics" label="Approved vets" value={stats.doctors.approved} />
            <StatCard icon={PawPrint} accent="pets" label="Pets" value={stats.pets} />
            <StatCard icon={ShieldCheck} accent="medications" label="Active shares" value={stats.shares} />
          </div>
          <div className="mt-6 grid gap-6 lg:grid-cols-3">
            <Card className="lg:col-span-2">
              <h3 className="mb-4 font-extrabold">Health records</h3>
              <div className="h-64">
                <ResponsiveContainer>
                  <BarChart data={records} margin={{ left: -20 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" vertical={false} />
                    <XAxis dataKey="name" fontSize={12} tickLine={false} axisLine={false} />
                    <YAxis fontSize={12} tickLine={false} axisLine={false} allowDecimals={false} />
                    <Tooltip cursor={{ fill: '#f1f5f9' }} />
                    <Bar dataKey="value" radius={[10, 10, 0, 0]}>{records.map((r) => <Cell key={r.name} fill={r.fill} />)}</Bar>
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </Card>
            <Card>
              <h3 className="mb-4 font-extrabold">Vet applications</h3>
              <div className="h-48">
                <ResponsiveContainer>
                  <PieChart>
                    <Pie data={doctors} dataKey="value" nameKey="name" innerRadius={45} outerRadius={75} paddingAngle={3}>
                      {doctors.map((d) => <Cell key={d.name} fill={d.fill} />)}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
              </div>
              <div className="mt-3 space-y-1.5 text-sm">
                {doctors.map((d) => (
                  <div key={d.name} className="flex items-center gap-2">
                    <span className="h-3 w-3 rounded-full" style={{ background: d.fill }} />
                    <span className="flex-1 text-slate-500">{d.name}</span>
                    <b>{d.value}</b>
                  </div>
                ))}
              </div>
            </Card>
          </div>
          <div className="mt-6 grid gap-4 sm:grid-cols-4">
            <StatCard icon={Syringe} accent="vaccinations" label="Vaccinations" value={stats.vaccinations} />
            <StatCard icon={CalendarClock} accent="appointments" label="Appointments" value={stats.appointments} />
            <StatCard icon={Pill} accent="medications" label="Medications" value={stats.medications} />
            <StatCard icon={FileText} accent="documents" label="Documents" value={stats.documents} />
          </div>
        </>
      )}
      <SectionTitle icon={Stethoscope} accent="documents" title={`Waiting for review (${pending.data.length})`} action={<Link to="/admin/doctors" className="text-sm font-bold text-brand-tealDeep">Review all</Link>} />
      <Card padded={false}>
        {pending.data.length === 0 ? (
          <p className="p-5 text-sm text-slate-500">No applications waiting.</p>
        ) : (
          pending.data.slice(0, 5).map((d) => (
            <Link key={d.uid} to="/admin/doctors" className="flex items-center gap-3 border-b border-slate-100 p-4 last:border-0 hover:bg-slate-50">
              <Initials name={d.fullName} />
              <div className="flex-1">
                <div className="font-bold">{d.fullName}</div>
                <div className="text-sm text-slate-500">{[d.clinicName, d.city].filter(Boolean).join(' · ')}</div>
              </div>
              <span className="text-xs text-slate-400">{fmtDate(d.createdAt)}</span>
            </Link>
          ))
        )}
      </Card>
    </>
  );
}

// ── Doctors ─────────────────────────────────────────────────────────────
export function AdminDoctors() {
  const { confirm, success } = useDialogs();
  const doctors = useLiveQuery(collection(db, 'doctors'), 'all-doctors', doctorFromDoc);
  const [tab, setTab] = useState<DoctorStatus>('pending');
  const [q, setQ] = useState('');
  const [rejecting, setRejecting] = useState<DoctorProfile | null>(null);
  const [note, setNote] = useState('');
  const [busy, setBusy] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const byStatus = (s: DoctorStatus) => doctors.data.filter((d) => d.status === s);
  const shown = byStatus(tab)
    .filter((d) => `${d.fullName} ${d.email} ${d.clinicName ?? ''} ${d.licenseNumber ?? ''}`.toLowerCase().includes(q.toLowerCase()))
    .sort((a, b) => +(b.createdAt ?? 0) - +(a.createdAt ?? 0));

  const approve = async (d: DoctorProfile) => {
    if (!(await confirm({ title: `Approve ${d.fullName}?`, message: `Licence ${d.licenseNumber ?? '—'}. They’ll get a doctor code and access to the doctor portal.`, confirmLabel: 'Approve', icon: CircleCheck, accent: 'vaccinations' }))) return;
    setBusy(d.uid);
    setError(null);
    try {
      const res = await adminApi.reviewDoctor({ uid: d.uid, approve: true });
      await success({ title: `${d.fullName} approved`, message: `Doctor code: ${res.doctorCode}` });
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setBusy(null);
    }
  };

  const reject = async () => {
    if (!rejecting) return;
    const d = rejecting;
    setBusy(d.uid);
    setError(null);
    try {
      await adminApi.reviewDoctor({ uid: d.uid, approve: false, note: note.trim() || undefined });
      setRejecting(null);
      setNote('');
      await success({ title: 'Application rejected' });
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setBusy(null);
    }
  };

  return (
    <>
      <PageHeading title="Doctors" subtitle="Verify veterinarians before they can see shared records." />
      <div className="mb-5 flex flex-wrap items-center gap-3">
        <Tabs
          value={tab}
          onChange={setTab}
          tabs={[
            { value: 'pending', label: 'Pending', count: byStatus('pending').length },
            { value: 'approved', label: 'Approved', count: byStatus('approved').length },
            { value: 'rejected', label: 'Rejected', count: byStatus('rejected').length },
          ]}
        />
        <div className="relative ml-auto w-full max-w-xs">
          <Search size={18} className="absolute left-4 top-3.5 text-slate-400" />
          <input className="input pl-11" placeholder="Search doctors" value={q} onChange={(e) => setQ(e.target.value)} />
        </div>
      </div>
      <ErrorNote text={error} />
      {doctors.loading ? <Spinner /> : shown.length === 0 ? (
        <Card><EmptyState icon={Stethoscope} title={tab === 'pending' ? 'No applications waiting' : `No ${tab} doctors`} /></Card>
      ) : (
        <div className="grid gap-4 lg:grid-cols-2">
          {shown.map((d) => (
            <Card key={d.uid}>
              <div className="flex items-start gap-4">
                <Initials name={d.fullName} size={52} />
                <div className="min-w-0 flex-1">
                  <div className="flex flex-wrap items-center gap-2">
                    <span className="font-extrabold">{d.fullName}</span>
                    {d.doctorCode && <Badge tone="blue">{d.doctorCode}</Badge>}
                  </div>
                  <div className="text-sm text-slate-500">{d.email}{d.phone && ` · ${d.phone}`}</div>
                  <dl className="mt-3 grid grid-cols-2 gap-x-4 gap-y-1 text-sm">
                    <dt className="text-slate-400">Clinic</dt><dd className="font-semibold">{d.clinicName ?? '—'}</dd>
                    <dt className="text-slate-400">Licence</dt><dd className="font-semibold">{d.licenseNumber ?? '—'}</dd>
                    <dt className="text-slate-400">Specialization</dt><dd className="font-semibold">{d.specialization ?? '—'}</dd>
                    <dt className="text-slate-400">City</dt><dd className="font-semibold">{d.city ?? '—'}</dd>
                    <dt className="text-slate-400">Applied</dt><dd className="font-semibold">{fmtDate(d.createdAt)}</dd>
                  </dl>
                  {d.bio && <p className="mt-3 rounded-xl bg-slate-50 p-3 text-sm text-slate-600">{d.bio}</p>}
                  {d.reviewNote && <p className="mt-2 text-sm text-slate-500"><b>Review note:</b> {d.reviewNote}</p>}
                </div>
              </div>
              {d.status !== 'approved' && (
                <div className="mt-4 grid grid-cols-2 gap-2">
                  {d.status === 'pending' ? (
                    <Button variant="outline" icon={X} onClick={() => setRejecting(d)} disabled={busy === d.uid}>Reject</Button>
                  ) : <span />}
                  <Button icon={Check} loading={busy === d.uid} onClick={() => approve(d)}>Approve</Button>
                </div>
              )}
              {d.status === 'approved' && (
                <div className="mt-4 flex justify-end">
                  <Button variant="ghost" icon={Ban} onClick={() => setRejecting(d)} disabled={busy === d.uid}>Revoke approval</Button>
                </div>
              )}
            </Card>
          ))}
        </div>
      )}
      <Modal open={rejecting !== null} title={rejecting?.status === 'approved' ? `Revoke ${rejecting?.fullName}` : `Reject ${rejecting?.fullName}`} onClose={() => setRejecting(null)}>
        <p className="mb-4 text-sm text-slate-500">
          {rejecting?.status === 'approved'
            ? 'They are signed out and lose the doctor portal and shared records (at the latest within an hour, when their session refreshes). Existing shares stay but stop working.'
            : 'The applicant sees your note on their review page.'}
        </p>
        <Textarea label="Note (optional)" value={note} onChange={(e) => setNote(e.target.value)} placeholder="e.g. Licence number could not be verified." />
        <div className="mt-5 grid grid-cols-2 gap-2">
          <Button variant="outline" onClick={() => setRejecting(null)}>Cancel</Button>
          <Button variant="danger" loading={busy === rejecting?.uid} onClick={reject}>{rejecting?.status === 'approved' ? 'Revoke' : 'Reject'}</Button>
        </div>
      </Modal>
    </>
  );
}

// ── Users ───────────────────────────────────────────────────────────────
const ROLE_BADGE: Record<Role, ['blue' | 'violet' | 'slate', string]> = {
  admin: ['violet', 'Admin'],
  doctor: ['blue', 'Doctor'],
  owner: ['slate', 'Owner'],
};

export function AdminUsers() {
  const { user: me } = useAuth();
  const { confirm, success } = useDialogs();
  const [users, setUsers] = useState<AdminUser[] | null>(null);
  const [q, setQ] = useState('');
  const [roleFilter, setRoleFilter] = useState<Role | 'all'>('all');
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState<string | null>(null);

  const load = useCallback(async () => {
    setError(null);
    try {
      const all: AdminUser[] = [];
      let token: string | undefined;
      do {
        const page = await adminApi.listUsers({ pageToken: token });
        all.push(...page.users);
        token = page.nextPageToken ?? undefined;
      } while (token);
      setUsers(all.sort((a, b) => (b.createdAt ? Date.parse(b.createdAt) : 0) - (a.createdAt ? Date.parse(a.createdAt) : 0)));
    } catch (e) {
      setError(errorMessage(e));
      setUsers([]);
    }
  }, []);
  useEffect(() => void load(), [load]);

  const changeRole = async (u: AdminUser, role: Role) => {
    if (role === u.role) return;
    if (!(await confirm({ title: `Make ${u.displayName ?? u.email} ${ROLE_BADGE[role][1].toLowerCase()}?`, message: role === 'admin' ? 'Admins can manage all users, roles and doctor approvals.' : undefined, confirmLabel: 'Change role', icon: UserCog, accent: 'medications' }))) return;
    setBusy(u.uid);
    try {
      await adminApi.setUserRole({ uid: u.uid, role });
      setUsers((list) => list?.map((x) => (x.uid === u.uid ? { ...x, role } : x)) ?? null);
      await success({ title: 'Role updated', message: 'It applies the next time they sign in or refresh.' });
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setBusy(null);
    }
  };

  const toggleDisabled = async (u: AdminUser) => {
    const disabling = !u.disabled;
    if (!(await confirm({ title: `${disabling ? 'Disable' : 'Enable'} ${u.displayName ?? u.email}?`, message: disabling ? 'They are signed out and can’t sign in until re-enabled. Their data is kept.' : undefined, confirmLabel: disabling ? 'Disable' : 'Enable', icon: Ban, destructive: disabling }))) return;
    setBusy(u.uid);
    try {
      await adminApi.setUserDisabled({ uid: u.uid, disabled: disabling });
      setUsers((list) => list?.map((x) => (x.uid === u.uid ? { ...x, disabled: disabling } : x)) ?? null);
      await success({ title: disabling ? 'Account disabled' : 'Account enabled' });
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setBusy(null);
    }
  };

  const shown = (users ?? []).filter(
    (u) => (roleFilter === 'all' || u.role === roleFilter) && `${u.displayName ?? ''} ${u.email ?? ''}`.toLowerCase().includes(q.toLowerCase()),
  );

  return (
    <>
      <PageHeading title="Users" subtitle="Manage roles and account access." action={<Button variant="outline" icon={RefreshCw} onClick={load}>Refresh</Button>} />
      <div className="mb-5 flex flex-wrap items-center gap-3">
        <Tabs
          value={roleFilter}
          onChange={setRoleFilter}
          tabs={[
            { value: 'all', label: 'All', count: users?.length },
            { value: 'owner', label: 'Owners', count: users?.filter((u) => u.role === 'owner').length },
            { value: 'doctor', label: 'Doctors', count: users?.filter((u) => u.role === 'doctor').length },
            { value: 'admin', label: 'Admins', count: users?.filter((u) => u.role === 'admin').length },
          ]}
        />
        <div className="relative ml-auto w-full max-w-xs">
          <Search size={18} className="absolute left-4 top-3.5 text-slate-400" />
          <input className="input pl-11" placeholder="Search name or email" value={q} onChange={(e) => setQ(e.target.value)} />
        </div>
      </div>
      <ErrorNote text={error} />
      {users === null ? <Spinner /> : (
        <Card padded={false} className="overflow-x-auto">
          <table className="w-full min-w-[720px] text-left text-sm">
            <thead className="border-b border-slate-100 text-xs uppercase tracking-wide text-slate-400">
              <tr>
                <th className="px-5 py-3">User</th>
                <th className="px-5 py-3">Role</th>
                <th className="px-5 py-3">Joined</th>
                <th className="px-5 py-3">Last sign-in</th>
                <th className="px-5 py-3 text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {shown.map((u) => (
                <tr key={u.uid} className={`border-b border-slate-50 last:border-0 ${u.disabled ? 'opacity-50' : ''}`}>
                  <td className="px-5 py-3">
                    <div className="flex items-center gap-3">
                      <Initials name={u.displayName || u.email || '?'} size={36} />
                      <div>
                        <div className="font-bold">{u.displayName || '—'} {u.uid === me?.uid && <Badge tone="green">You</Badge>} {u.disabled && <Badge tone="red">Disabled</Badge>}</div>
                        <div className="text-slate-500">{u.email}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-5 py-3">
                    <select
                      aria-label={`Role for ${u.email}`}
                      value={u.role}
                      disabled={busy === u.uid || u.uid === me?.uid}
                      onChange={(e) => changeRole(u, e.target.value as Role)}
                      className="rounded-lg border border-slate-200 bg-white px-2 py-1.5 text-sm font-semibold"
                    >
                      <option value="owner">Owner</option>
                      <option value="doctor">Doctor</option>
                      <option value="admin">Admin</option>
                    </select>
                  </td>
                  <td className="px-5 py-3 text-slate-500">{u.createdAt ? fmtDate(new Date(u.createdAt)) : '—'}</td>
                  <td className="px-5 py-3 text-slate-500">{u.lastSignInAt ? fmtDate(new Date(u.lastSignInAt)) : '—'}</td>
                  <td className="px-5 py-3 text-right">
                    {u.uid !== me?.uid && (
                      <button onClick={() => toggleDisabled(u)} disabled={busy === u.uid} className={`rounded-lg px-3 py-1.5 text-xs font-bold ${u.disabled ? 'bg-emerald-50 text-emerald-700' : 'bg-red-50 text-red-600'}`}>
                        {u.disabled ? 'Enable' : 'Disable'}
                      </button>
                    )}
                  </td>
                </tr>
              ))}
              {shown.length === 0 && (
                <tr><td colSpan={5} className="px-5 py-10 text-center text-slate-500">No users found.</td></tr>
              )}
            </tbody>
          </table>
        </Card>
      )}
    </>
  );
}

// ── First admin setup ───────────────────────────────────────────────────
/** Lets an email listed in ADMIN_EMAILS (functions/.env) claim admin once. */
export function AdminSetup() {
  const { user, role, refreshRole } = useAuth();
  const navigate = useNavigate();
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [sent, setSent] = useState(false);
  if (role === 'admin') return <Navigate to="/admin" replace />;
  if (!user) return <Navigate to="/login" replace />;

  return (
    <div className="flex min-h-screen items-center justify-center bg-surface p-6">
      <Card className="w-full max-w-md p-8 text-center">
        <div className="mb-4 flex justify-center"><IconBadge icon={ShieldCheck} accent="medications" size={72} /></div>
        <h1 className="text-2xl font-extrabold">Admin setup</h1>
        <p className="mt-2 text-sm text-slate-500">
          Signed in as <b>{user.email}</b>. If this email is listed in <code>ADMIN_EMAILS</code> in <code>functions/.env</code>, you can claim admin access.
        </p>
        {!user.emailVerified && (
          <div className="mt-4 rounded-xl bg-amber-50 p-3 text-sm text-amber-800">
            Verify your email first.{' '}
            <button
              className="font-bold underline"
              onClick={async () => {
                await sendEmailVerification(user);
                setSent(true);
              }}
            >
              {sent ? 'Email sent — check your inbox, then sign in again' : 'Send verification email'}
            </button>
          </div>
        )}
        <div className="mt-4"><ErrorNote text={error} /></div>
        <Button
          className="mt-5 w-full"
          icon={ShieldCheck}
          loading={busy}
          onClick={async () => {
            setBusy(true);
            setError(null);
            try {
              await adminApi.bootstrapAdmin();
              if ((await refreshRole()) === 'admin') navigate('/admin');
            } catch (e) {
              setError(errorMessage(e));
            } finally {
              setBusy(false);
            }
          }}
        >
          Claim admin access
        </Button>
        <Link to="/" className="mt-4 inline-block text-sm font-bold text-brand-tealDeep">Back</Link>
      </Card>
    </div>
  );
}
