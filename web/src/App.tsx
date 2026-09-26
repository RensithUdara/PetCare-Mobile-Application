import type { ReactNode } from 'react';
import { createBrowserRouter, Navigate, RouterProvider } from 'react-router-dom';

import { DialogProvider } from './components/dialogs';
import { PortalLayout } from './components/PortalLayout';
import { Spinner } from './components/ui';
import { AuthProvider, homePathFor, useAuth } from './hooks/useAuth';
import type { Role } from './lib/types';
import { AdminDashboard, AdminDoctors, AdminSetup, AdminUsers } from './pages/admin/AdminPages';
import { ForgotPasswordPage, LoginPage, RegisterPage } from './pages/auth/AuthPages';
import { DoctorDashboard, DoctorPatientDetail, DoctorPatients, DoctorPending, DoctorProfilePage } from './pages/doctor/DoctorPages';
import { OwnerDashboard, OwnerPetDetail, OwnerPets, OwnerProfile } from './pages/owner/OwnerPages';

/** Signed-in users only; with [role], only that role (others go home). */
export function RequireAuth({ role, children }: { role?: Exclude<Role, 'owner'>; children: ReactNode }) {
  const { user, role: myRole, doctor, loading } = useAuth();
  if (loading) return <Spinner label="Loading your account…" />;
  if (!user) return <Navigate to="/login" replace />;
  if (role && myRole !== role) return <Navigate to={homePathFor(myRole, doctor)} replace />;
  return <>{children}</>;
}

function Home() {
  const { user, role, doctor, loading } = useAuth();
  if (loading) return <Spinner label="Loading your account…" />;
  return <Navigate to={user ? homePathFor(role, doctor) : '/login'} replace />;
}

const router = createBrowserRouter(
  [
    { path: '/', element: <Home /> },
    { path: '/login', element: <LoginPage /> },
    { path: '/register', element: <RegisterPage /> },
    { path: '/forgot', element: <ForgotPasswordPage /> },
    { path: '/setup-admin', element: <RequireAuth><AdminSetup /></RequireAuth> },
    { path: '/doctor/pending', element: <RequireAuth><DoctorPending /></RequireAuth> },
    {
      path: '/owner',
      element: <RequireAuth><PortalLayout portal="owner" /></RequireAuth>,
      children: [
        { index: true, element: <OwnerDashboard /> },
        { path: 'pets', element: <OwnerPets /> },
        { path: 'pets/:petId', element: <OwnerPetDetail /> },
        { path: 'profile', element: <OwnerProfile /> },
      ],
    },
    {
      path: '/doctor',
      element: <RequireAuth role="doctor"><PortalLayout portal="doctor" /></RequireAuth>,
      children: [
        { index: true, element: <DoctorDashboard /> },
        { path: 'patients', element: <DoctorPatients /> },
        { path: 'patients/:shareId', element: <DoctorPatientDetail /> },
        { path: 'profile', element: <DoctorProfilePage /> },
      ],
    },
    {
      path: '/admin',
      element: <RequireAuth role="admin"><PortalLayout portal="admin" /></RequireAuth>,
      children: [
        { index: true, element: <AdminDashboard /> },
        { path: 'doctors', element: <AdminDoctors /> },
        { path: 'users', element: <AdminUsers /> },
      ],
    },
    { path: '*', element: <Navigate to="/" replace /> },
  ],
  { basename: import.meta.env.BASE_URL.replace(/\/$/, '') },
);

export default function App() {
  return (
    <AuthProvider>
      <DialogProvider>
        <RouterProvider router={router} />
      </DialogProvider>
    </AuthProvider>
  );
}
