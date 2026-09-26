import {
  createUserWithEmailAndPassword,
  GoogleAuthProvider,
  sendPasswordResetEmail,
  signInWithEmailAndPassword,
  signInWithPopup,
  updateProfile as updateAuthProfile,
  type User,
} from 'firebase/auth';
import { getDoc } from 'firebase/firestore';
import { KeyRound, Mail, PawPrint, Stethoscope } from 'lucide-react';
import { useState, type FormEvent, type ReactNode } from 'react';
import { Link, Navigate, useNavigate } from 'react-router-dom';

import logo from '../../assets/logo.png';
import pets from '../../assets/pets.png';
import vet from '../../assets/vaccinations.png';
import { Button, ErrorNote, Input, Textarea } from '../../components/ui';
import { homePathFor, useAuth } from '../../hooks/useAuth';
import { applyAsDoctor, createProfile, errorMessage, userDoc, type DoctorApplication } from '../../lib/api';
import { auth } from '../../lib/firebase';
import { DemoAccounts, demoAccountsEnabled } from './DemoAccounts';

function AuthShell({ title, subtitle, art, children }: { title: string; subtitle: string; art: string; children: ReactNode }) {
  return (
    <div className="grid min-h-screen lg:grid-cols-2">
      <div className="relative hidden overflow-hidden bg-brand p-12 text-white lg:flex lg:flex-col">
        <span className="absolute -right-24 -top-24 h-96 w-96 rounded-full bg-white/10" />
        <span className="absolute -bottom-24 left-10 h-72 w-72 rounded-full bg-white/[.07]" />
        <div className="relative flex items-center gap-3">
          <img src={logo} alt="" className="h-12 w-12 rounded-2xl bg-white p-1.5 shadow-lg" />
          <span className="text-2xl font-extrabold">PetCare</span>
        </div>
        <div className="relative flex flex-1 items-center justify-center py-10">
          <div className="rounded-[2.5rem] bg-white/90 p-8 shadow-2xl">
            <img src={art} alt="" className="max-h-80 w-full object-contain" />
          </div>
        </div>
        <p className="relative text-2xl font-extrabold leading-snug">Healthy pets, happy homes.</p>
        <p className="relative mt-2 text-white/85">Vaccinations, vet visits, medications and records — for owners and their vets.</p>
      </div>
      <div className="flex items-center justify-center px-5 py-10">
        <div className="w-full max-w-md">
          <div className="mb-8 flex items-center gap-3 lg:hidden">
            <img src={logo} alt="" className="h-11 w-11 rounded-2xl bg-white p-1.5 shadow-soft" />
            <span className="text-xl font-extrabold">PetCare</span>
          </div>
          <h1 className="text-3xl font-extrabold tracking-tight">{title}</h1>
          <p className="mb-8 mt-2 text-slate-500">{subtitle}</p>
          {children}
        </div>
      </div>
    </div>
  );
}

const google = new GoogleAuthProvider();

/** Makes sure a Google user has the `users/{uid}` profile the app expects. */
async function ensureProfile(user: User) {
  if (!(await getDoc(userDoc(user.uid))).exists()) {
    await createProfile(user.uid, { fullName: user.displayName ?? '', email: user.email ?? '' });
  }
}

function GoogleButton({
  onUser,
  canStart,
  label = 'Continue with Google',
}: {
  onUser: (u: User) => Promise<void>;
  /** Checked before opening the Google popup. */
  canStart?: () => boolean;
  label?: string;
}) {
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  return (
    <>
      <button
        type="button"
        disabled={busy}
        onClick={async () => {
          if (canStart && !canStart()) return;
          setBusy(true);
          setError(null);
          try {
            const { user } = await signInWithPopup(auth, google);
            await ensureProfile(user);
            await onUser(user);
          } catch (e) {
            setError(errorMessage(e));
          } finally {
            setBusy(false);
          }
        }}
        className="btn w-full border-2 border-slate-200 bg-white text-slate-700 hover:bg-slate-50"
      >
        <svg width="18" height="18" viewBox="0 0 48 48" aria-hidden>
          <path fill="#FFC107" d="M43.6 20.5H42V20H24v8h11.3C33.7 32.7 29.2 36 24 36c-6.6 0-12-5.4-12-12s5.4-12 12-12c3.1 0 5.8 1.2 7.9 3.1l5.7-5.7C34 6.1 29.3 4 24 4 12.9 4 4 12.9 4 24s8.9 20 20 20 20-8.9 20-20c0-1.3-.1-2.4-.4-3.5z" />
          <path fill="#FF3D00" d="M6.3 14.7l6.6 4.8C14.7 15.1 19 12 24 12c3.1 0 5.8 1.2 7.9 3.1l5.7-5.7C34 6.1 29.3 4 24 4 16.3 4 9.7 8.3 6.3 14.7z" />
          <path fill="#4CAF50" d="M24 44c5.2 0 9.9-2 13.4-5.2l-6.2-5.2C29.2 35.1 26.7 36 24 36c-5.2 0-9.6-3.3-11.3-8l-6.5 5C9.5 39.6 16.2 44 24 44z" />
          <path fill="#1976D2" d="M43.6 20.5H42V20H24v8h11.3c-.8 2.2-2.2 4.2-4.1 5.6l6.2 5.2C37 39.2 44 34 44 24c0-1.3-.1-2.4-.4-3.5z" />
        </svg>
        {busy ? 'Signing in…' : label}
      </button>
      <ErrorNote text={error} />
    </>
  );
}

const Divider = () => (
  <div className="my-5 flex items-center gap-3 text-xs font-bold uppercase text-slate-400">
    <span className="h-px flex-1 bg-slate-200" /> or <span className="h-px flex-1 bg-slate-200" />
  </div>
);

export function LoginPage() {
  const { user, role, doctor, loading } = useAuth();
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  if (!loading && user) return <Navigate to={homePathFor(role, doctor)} replace />;

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      await signInWithEmailAndPassword(auth, email.trim(), password);
      navigate('/');
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <AuthShell title="Welcome back" subtitle="Sign in to your PetCare account." art={pets}>
      <form onSubmit={submit} className="card space-y-4 p-6">
        <Input label="Email" type="email" autoComplete="email" required value={email} onChange={(e) => setEmail(e.target.value)} />
        <Input label="Password" type="password" autoComplete="current-password" required value={password} onChange={(e) => setPassword(e.target.value)} />
        <div className="text-right text-sm">
          <Link to="/forgot" className="font-bold text-brand-tealDeep hover:underline">Forgot password?</Link>
        </div>
        <ErrorNote text={error} />
        <Button type="submit" loading={busy} className="w-full" icon={KeyRound}>Sign in</Button>
        <Divider />
        <GoogleButton onUser={async () => navigate('/')} />
      </form>
      <p className="mt-6 text-center text-sm text-slate-500">
        New to PetCare? <Link to="/register" className="font-bold text-brand-tealDeep hover:underline">Create an account</Link>
      </p>
      {demoAccountsEnabled && <DemoAccounts />}
    </AuthShell>
  );
}

export function RegisterPage() {
  const navigate = useNavigate();
  const [kind, setKind] = useState<'owner' | 'doctor'>('owner');
  const [form, setForm] = useState({ fullName: '', email: '', phone: '', password: '', clinicName: '', specialization: '', licenseNumber: '', city: '', bio: '' });
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const set = (k: keyof typeof form) => (e: { target: { value: string } }) => setForm((f) => ({ ...f, [k]: e.target.value }));

  const validate = (needPassword: boolean) => {
    const errs: Record<string, string> = {};
    if (form.fullName.trim().length < 2) errs.fullName = 'Enter your full name.';
    if (needPassword && !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(form.email.trim())) errs.email = 'Enter a valid email address.';
    if (needPassword && (form.password.length < 8 || !/[A-Za-z]/.test(form.password) || !/\d/.test(form.password)))
      errs.password = 'Use at least 8 characters with letters and numbers.';
    if (kind === 'doctor') {
      if (!form.clinicName.trim()) errs.clinicName = 'Enter your clinic or practice.';
      if (!form.licenseNumber.trim()) errs.licenseNumber = 'Enter your veterinary licence number.';
    }
    setErrors(errs);
    return Object.keys(errs).length === 0;
  };

  const finish = async (user: User) => {
    if (kind === 'doctor') {
      const application: DoctorApplication = {
        fullName: form.fullName,
        email: user.email ?? form.email.trim(),
        phone: form.phone,
        clinicName: form.clinicName,
        specialization: form.specialization,
        licenseNumber: form.licenseNumber,
        city: form.city,
        bio: form.bio,
      };
      await applyAsDoctor(user.uid, application);
      navigate('/doctor/pending');
    } else {
      navigate('/owner');
    }
  };

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    if (!validate(true)) return;
    setBusy(true);
    setError(null);
    try {
      const { user } = await createUserWithEmailAndPassword(auth, form.email.trim(), form.password);
      await updateAuthProfile(user, { displayName: form.fullName.trim() });
      await createProfile(user.uid, { fullName: form.fullName, email: form.email.trim(), phone: form.phone });
      await finish(user);
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <AuthShell
      title="Create your account"
      subtitle={kind === 'owner' ? 'Keep your pets’ health on track.' : 'Join PetCare as a veterinarian — an admin reviews every application.'}
      art={kind === 'owner' ? pets : vet}
    >
      <div className="mb-5 grid grid-cols-2 gap-2 rounded-2xl bg-white p-1.5 shadow-soft" role="tablist">
        {([['owner', 'Pet owner', PawPrint], ['doctor', 'Veterinarian', Stethoscope]] as const).map(([k, label, Icon]) => (
          <button
            key={k}
            role="tab"
            aria-selected={kind === k}
            onClick={() => setKind(k)}
            className={`flex items-center justify-center gap-2 rounded-xl py-2.5 text-sm font-bold transition ${kind === k ? 'bg-brand text-white shadow-glow' : 'text-slate-500 hover:bg-slate-100'}`}
          >
            <Icon size={17} /> {label}
          </button>
        ))}
      </div>
      <form onSubmit={submit} className="card space-y-4 p-6" noValidate>
        <Input label="Full name" value={form.fullName} onChange={set('fullName')} error={errors.fullName} autoComplete="name" placeholder={kind === 'doctor' ? 'Dr. Nimali Perera' : ''} />
        <div className="grid gap-4 sm:grid-cols-2">
          <Input label="Email" type="email" value={form.email} onChange={set('email')} error={errors.email} autoComplete="email" />
          <Input label="Phone" type="tel" value={form.phone} onChange={set('phone')} autoComplete="tel" />
        </div>
        {kind === 'doctor' && (
          <>
            <div className="grid gap-4 sm:grid-cols-2">
              <Input label="Clinic / practice" value={form.clinicName} onChange={set('clinicName')} error={errors.clinicName} />
              <Input label="Licence number" value={form.licenseNumber} onChange={set('licenseNumber')} error={errors.licenseNumber} />
              <Input label="Specialization" value={form.specialization} onChange={set('specialization')} placeholder="General practice" />
              <Input label="City" value={form.city} onChange={set('city')} />
            </div>
            <Textarea label="About you (optional)" value={form.bio} onChange={set('bio')} />
          </>
        )}
        <Input label="Password" type="password" value={form.password} onChange={set('password')} error={errors.password} autoComplete="new-password" hint="At least 8 characters with letters and numbers." />
        <ErrorNote text={error} />
        <Button type="submit" loading={busy} className="w-full" icon={Mail}>
          {kind === 'doctor' ? 'Apply as a veterinarian' : 'Create account'}
        </Button>
        <Divider />
        <GoogleButton
          label={kind === 'doctor' ? 'Apply with Google' : 'Sign up with Google'}
          canStart={() => kind === 'owner' || validate(false)}
          onUser={finish}
        />
      </form>
      <p className="mt-6 text-center text-sm text-slate-500">
        Already have an account? <Link to="/login" className="font-bold text-brand-tealDeep hover:underline">Sign in</Link>
      </p>
    </AuthShell>
  );
}

export function ForgotPasswordPage() {
  const [email, setEmail] = useState('');
  const [sent, setSent] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  return (
    <AuthShell title="Reset your password" subtitle="We’ll email you a link to choose a new one." art={pets}>
      <form
        className="card space-y-4 p-6"
        onSubmit={async (e) => {
          e.preventDefault();
          setBusy(true);
          setError(null);
          try {
            await sendPasswordResetEmail(auth, email.trim());
            setSent(true);
          } catch (err) {
            setError(errorMessage(err));
          } finally {
            setBusy(false);
          }
        }}
      >
        {sent ? (
          <p className="rounded-xl bg-emerald-50 p-4 text-sm font-semibold text-emerald-700">
            If an account exists for {email}, a reset link is on its way. Check your inbox.
          </p>
        ) : (
          <>
            <Input label="Email" type="email" required value={email} onChange={(e) => setEmail(e.target.value)} />
            <ErrorNote text={error} />
            <Button type="submit" loading={busy} className="w-full" icon={Mail}>Send reset link</Button>
          </>
        )}
      </form>
      <p className="mt-6 text-center text-sm">
        <Link to="/login" className="font-bold text-brand-tealDeep hover:underline">Back to sign in</Link>
      </p>
    </AuthShell>
  );
}
