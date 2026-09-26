import { onIdTokenChanged, signOut as fbSignOut, type User } from 'firebase/auth';
import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';

import { doctorDoc, userDoc } from '../lib/api';
import { doctorFromDoc, profileFromDoc } from '../lib/converters';
import { auth } from '../lib/firebase';
import type { DoctorProfile, Role, UserProfile } from '../lib/types';
import { useLiveDoc } from './useFirestore';

interface AuthState {
  user: User | null;
  /** From the ID token's custom claims (set by Cloud Functions). */
  role: Role;
  loading: boolean;
  profile: UserProfile | null;
  /** The user's doctor application / profile, if they applied. */
  doctor: DoctorProfile | null;
  /** Re-reads the role after an admin changed it. */
  refreshRole: () => Promise<Role>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthState | null>(null);

export const roleFromClaims = (claims: Record<string, unknown>): Role =>
  claims.role === 'admin' || claims.role === 'doctor' ? claims.role : 'owner';

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [role, setRole] = useState<Role>('owner');
  const [loading, setLoading] = useState(true);

  useEffect(
    () =>
      onIdTokenChanged(auth, async (u) => {
        setUser(u);
        setRole(u ? roleFromClaims((await u.getIdTokenResult()).claims) : 'owner');
        setLoading(false);
      }),
    [],
  );

  const uid = user?.uid ?? null;
  const profile = useLiveDoc(uid ? userDoc(uid) : null, `profile-${uid}`, profileFromDoc);
  const doctor = useLiveDoc(uid ? doctorDoc(uid) : null, `doctor-${uid}`, doctorFromDoc);

  const refreshRole = useCallback(async () => {
    const u = auth.currentUser;
    if (!u) return 'owner';
    const next = roleFromClaims((await u.getIdTokenResult(true)).claims);
    setRole(next);
    return next;
  }, []);

  // An approved application means the doctor claim exists — pick it up.
  useEffect(() => {
    if (doctor.data?.status === 'approved' && role === 'owner') void refreshRole();
  }, [doctor.data?.status, role, refreshRole]);

  const value = useMemo<AuthState>(
    () => ({
      user,
      role,
      loading: loading || (user !== null && (profile.loading || doctor.loading)),
      profile: profile.data,
      doctor: doctor.data,
      refreshRole,
      signOut: () => fbSignOut(auth),
    }),
    [user, role, loading, profile.loading, profile.data, doctor.loading, doctor.data, refreshRole],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthState {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used inside <AuthProvider>');
  return ctx;
}

/** Where a signed-in user lands. */
export function homePathFor(role: Role, doctor: DoctorProfile | null): string {
  if (role === 'admin') return '/admin';
  if (role === 'doctor') return '/doctor';
  if (doctor && doctor.status !== 'approved') return '/doctor/pending';
  return '/owner';
}
