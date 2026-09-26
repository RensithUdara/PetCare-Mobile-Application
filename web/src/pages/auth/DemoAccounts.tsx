import { GoogleAuthProvider, signInWithCredential, signInWithEmailAndPassword } from 'firebase/auth';
import { FlaskConical } from 'lucide-react';
import { useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';

import { errorMessage } from '../../lib/api';
import { auth, usingEmulators } from '../../lib/firebase';

/** Demo accounts created by `npm run seed` (emulators only). */
const DEMO = {
  owner: { label: 'Pet owner', email: 'owner@petcare.test' },
  vet: { label: 'Veterinarian', email: 'vet@petcare.test' },
  pending: { label: 'Pending vet', email: 'pending.vet@petcare.test' },
  admin: { label: 'Admin', email: 'admin@petcare.test' },
} as const;
type Demo = keyof typeof DEMO;

/** Only in local development against the emulators — never in production builds. */
export const demoAccountsEnabled = import.meta.env.DEV && usingEmulators;

async function signInAs(who: Demo) {
  if (who === 'admin') {
    // The Auth emulator accepts unsigned Google tokens.
    const token = JSON.stringify({ sub: 'demo-admin', email: DEMO.admin.email, email_verified: true, name: 'Ayesha Admin' });
    await signInWithCredential(auth, GoogleAuthProvider.credential(token));
  } else {
    await signInWithEmailAndPassword(auth, DEMO[who].email, 'demo1234');
  }
}

export function DemoAccounts() {
  const navigate = useNavigate();
  const [params] = useSearchParams();
  const [error, setError] = useState<string | null>(null);

  const go = async (who: Demo) => {
    setError(null);
    try {
      await signInAs(who);
      navigate('/');
    } catch (e) {
      setError(`${errorMessage(e)} — did you run \`npm run seed\`?`);
    }
  };

  // `?demo=owner` signs straight in (handy for screenshots and quick checks).
  const demo = params.get('demo') as Demo | null;
  useEffect(() => {
    if (demo && demo in DEMO) void go(demo);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [demo]);

  return (
    <div className="mt-6 rounded-2xl border-2 border-dashed border-amber-300 bg-amber-50 p-4">
      <div className="mb-3 flex items-center gap-2 text-sm font-bold text-amber-800">
        <FlaskConical size={16} /> Local demo accounts (emulators)
      </div>
      <div className="grid grid-cols-2 gap-2">
        {(Object.keys(DEMO) as Demo[]).map((k) => (
          <button key={k} type="button" onClick={() => go(k)} className="btn bg-white px-3 py-2 text-xs text-amber-900 shadow-sm hover:bg-amber-100">
            {DEMO[k].label}
          </button>
        ))}
      </div>
      {error && <p className="mt-2 text-xs font-semibold text-red-600">{error}</p>}
    </div>
  );
}
