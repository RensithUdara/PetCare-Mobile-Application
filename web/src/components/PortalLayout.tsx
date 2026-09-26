import clsx from 'clsx';
import {
  LayoutDashboard,
  LogOut,
  Menu,
  PawPrint,
  ShieldCheck,
  Stethoscope,
  User,
  Users,
  X,
  type LucideIcon,
} from 'lucide-react';
import { useState } from 'react';
import { NavLink, Outlet, useNavigate } from 'react-router-dom';

import logo from '../assets/logo.png';
import { useAuth } from '../hooks/useAuth';
import { useDialogs } from './dialogs';
import { Initials } from './ui';

export type Portal = 'owner' | 'doctor' | 'admin';

const NAV: Record<Portal, { to: string; label: string; icon: LucideIcon; end?: boolean }[]> = {
  owner: [
    { to: '/owner', label: 'Dashboard', icon: LayoutDashboard, end: true },
    { to: '/owner/pets', label: 'My pets', icon: PawPrint },
    { to: '/owner/profile', label: 'Profile', icon: User },
  ],
  doctor: [
    { to: '/doctor', label: 'Dashboard', icon: LayoutDashboard, end: true },
    { to: '/doctor/patients', label: 'Patients', icon: PawPrint },
    { to: '/doctor/profile', label: 'My profile', icon: Stethoscope },
  ],
  admin: [
    { to: '/admin', label: 'Dashboard', icon: LayoutDashboard, end: true },
    { to: '/admin/doctors', label: 'Doctors', icon: Stethoscope },
    { to: '/admin/users', label: 'Users', icon: Users },
  ],
};

const PORTAL_LABEL: Record<Portal, string> = { owner: 'Pet owner', doctor: 'Veterinarian', admin: 'Admin' };
const PORTAL_ICON: Record<Portal, LucideIcon> = { owner: PawPrint, doctor: Stethoscope, admin: ShieldCheck };

export function PortalLayout({ portal }: { portal: Portal }) {
  const { user, role, profile, doctor, signOut } = useAuth();
  const { confirm } = useDialogs();
  const navigate = useNavigate();
  const [menuOpen, setMenuOpen] = useState(false);

  // Doctors and admins can also use the owner portal for their own pets.
  const portals: Portal[] = ['owner', ...(role === 'doctor' ? (['doctor'] as const) : []), ...(role === 'admin' ? (['admin'] as const) : [])];
  const name = (portal === 'doctor' ? doctor?.fullName : profile?.fullName) || user?.displayName || user?.email || 'PetCare user';

  const logOut = async () => {
    if (await confirm({ title: 'Log out?', message: 'You’ll need to sign in again.', confirmLabel: 'Log out', icon: LogOut, accent: 'settings' })) {
      await signOut();
      navigate('/login');
    }
  };

  const sidebar = (
    <div className="flex h-full flex-col bg-gradient-to-b from-[#0E8A76] via-[#0f766e] to-[#1e3a8a] p-5 text-white">
      <div className="mb-8 flex items-center gap-3 px-1">
        <span className="rounded-2xl bg-white p-1.5 shadow-lg">
          <img src={logo} alt="" className="h-9 w-9" />
        </span>
        <div>
          <div className="text-lg font-extrabold leading-tight">PetCare</div>
          <div className="text-xs font-semibold text-white/70">{PORTAL_LABEL[portal]} portal</div>
        </div>
      </div>

      <nav className="flex flex-1 flex-col gap-1">
        {NAV[portal].map(({ to, label, icon: Icon, end }) => (
          <NavLink
            key={to}
            to={to}
            end={end}
            onClick={() => setMenuOpen(false)}
            className={({ isActive }) =>
              clsx(
                'flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-bold transition',
                isActive ? 'bg-white text-brand-tealDeep shadow-lg' : 'text-white/80 hover:bg-white/10 hover:text-white',
              )
            }
          >
            <Icon size={19} /> {label}
          </NavLink>
        ))}

        {portals.length > 1 && (
          <div className="mt-6">
            <div className="mb-2 px-3 text-[11px] font-bold uppercase tracking-wider text-white/50">Switch portal</div>
            {portals
              .filter((p) => p !== portal)
              .map((p) => {
                const Icon = PORTAL_ICON[p];
                return (
                  <NavLink
                    key={p}
                    to={`/${p}`}
                    onClick={() => setMenuOpen(false)}
                    className="flex items-center gap-3 rounded-xl px-3 py-2 text-sm font-semibold text-white/80 hover:bg-white/10"
                  >
                    <Icon size={18} /> {PORTAL_LABEL[p]}
                  </NavLink>
                );
              })}
          </div>
        )}
      </nav>

      <div className="mt-6 flex items-center gap-3 rounded-2xl bg-white/10 p-3">
        <Initials name={name} size={38} />
        <div className="min-w-0 flex-1">
          <div className="truncate text-sm font-bold">{name}</div>
          <div className="truncate text-xs text-white/70">{user?.email}</div>
        </div>
        <button onClick={logOut} aria-label="Log out" className="rounded-lg p-2 text-white/80 hover:bg-white/15">
          <LogOut size={18} />
        </button>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen lg:pl-72">
      <aside className="fixed inset-y-0 left-0 z-30 hidden w-72 lg:block">{sidebar}</aside>

      {/* Mobile top bar + drawer */}
      <header className="sticky top-0 z-20 flex items-center gap-3 bg-brand px-4 py-3 text-white shadow-glow lg:hidden">
        <button onClick={() => setMenuOpen(true)} aria-label="Open menu" className="rounded-xl bg-white/15 p-2">
          <Menu size={20} />
        </button>
        <img src={logo} alt="" className="h-8 w-8 rounded-xl bg-white p-1" />
        <span className="font-extrabold">PetCare</span>
      </header>
      {menuOpen && (
        <div className="fixed inset-0 z-40 bg-black/40 lg:hidden" onClick={() => setMenuOpen(false)}>
          <div className="h-full w-72 animate-pop" onClick={(e) => e.stopPropagation()}>
            <button onClick={() => setMenuOpen(false)} aria-label="Close menu" className="absolute left-60 top-4 z-10 rounded-lg p-1 text-white">
              <X />
            </button>
            {sidebar}
          </div>
        </div>
      )}

      <main className="mx-auto max-w-6xl px-4 py-6 sm:px-8 sm:py-10">
        <Outlet />
      </main>
    </div>
  );
}
