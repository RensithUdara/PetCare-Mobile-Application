import clsx from 'clsx';
import { Loader2, X, type LucideIcon } from 'lucide-react';
import {
  useEffect,
  type ButtonHTMLAttributes,
  type InputHTMLAttributes,
  type ReactNode,
  type SelectHTMLAttributes,
  type TextareaHTMLAttributes,
} from 'react';

import { SPECIES_EMOJI, type Species } from '../lib/types';

// ── Accents: one colour per feature, as in the mobile app ───────────────
export const ACCENTS = {
  pets: ['#12B39A', '#0E8A76'],
  vaccinations: ['#10B981', '#047857'],
  appointments: ['#3B82F6', '#1D4ED8'],
  medications: ['#8B5CF6', '#6D28D9'],
  documents: ['#F59E0B', '#B45309'],
  weight: ['#EC4899', '#BE185D'],
  emergency: ['#EF4444', '#B91C1C'],
  clinics: ['#06B6D4', '#0E7490'],
  calendar: ['#6366F1', '#4338CA'],
  settings: ['#64748B', '#334155'],
} as const;
export type Accent = keyof typeof ACCENTS;
export const accentGradient = (a: Accent) => `linear-gradient(135deg, ${ACCENTS[a][0]}, ${ACCENTS[a][1]})`;

export function IconBadge({ icon: Icon, accent, size = 44 }: { icon: LucideIcon; accent: Accent; size?: number }) {
  return (
    <span
      className="inline-flex shrink-0 items-center justify-center text-white"
      style={{
        width: size,
        height: size,
        borderRadius: size * 0.32,
        background: accentGradient(accent),
        boxShadow: `0 6px 14px -4px ${ACCENTS[accent][0]}88`,
      }}
    >
      <Icon size={size * 0.5} strokeWidth={2.2} />
    </span>
  );
}

// ── Buttons ─────────────────────────────────────────────────────────────
type Variant = 'primary' | 'outline' | 'ghost' | 'danger';

export function Button({
  variant = 'primary',
  loading,
  icon: Icon,
  children,
  className,
  disabled,
  ...rest
}: ButtonHTMLAttributes<HTMLButtonElement> & { variant?: Variant; loading?: boolean; icon?: LucideIcon }) {
  return (
    <button className={clsx(`btn-${variant}`, className)} disabled={disabled || loading} {...rest}>
      {loading ? <Loader2 size={18} className="animate-spin" /> : Icon ? <Icon size={18} /> : null}
      {children}
    </button>
  );
}

// ── Form fields ─────────────────────────────────────────────────────────
interface FieldProps {
  label: string;
  error?: string | null;
  hint?: string;
}

export function Input({ label, error, hint, className, ...rest }: FieldProps & InputHTMLAttributes<HTMLInputElement>) {
  return (
    <label className={clsx('block', className)}>
      <span className="label">{label}</span>
      <input className={clsx('input', error && 'border-red-400 bg-red-50')} aria-invalid={!!error} {...rest} />
      {error ? <FieldError text={error} /> : hint ? <span className="mt-1 block text-xs text-slate-500">{hint}</span> : null}
    </label>
  );
}

export function Select({
  label,
  error,
  children,
  className,
  ...rest
}: FieldProps & SelectHTMLAttributes<HTMLSelectElement>) {
  return (
    <label className={clsx('block', className)}>
      <span className="label">{label}</span>
      <select className={clsx('input appearance-none', error && 'border-red-400')} {...rest}>
        {children}
      </select>
      {error && <FieldError text={error} />}
    </label>
  );
}

export function Textarea({ label, error, className, ...rest }: FieldProps & TextareaHTMLAttributes<HTMLTextAreaElement>) {
  return (
    <label className={clsx('block', className)}>
      <span className="label">{label}</span>
      <textarea className="input min-h-[96px] resize-y" {...rest} />
      {error && <FieldError text={error} />}
    </label>
  );
}

const FieldError = ({ text }: { text: string }) => (
  <span role="alert" className="mt-1 block text-xs font-semibold text-red-500">
    {text}
  </span>
);

/** Row of selectable tiles (species, types…). */
export function ChoiceTiles<T extends string>({
  label,
  options,
  value,
  onChange,
  accent = 'pets',
  columns = 3,
}: {
  label: string;
  options: { value: T; label: string; icon?: ReactNode }[];
  value: T | null;
  onChange: (v: T) => void;
  accent?: Accent;
  columns?: number;
}) {
  return (
    <div>
      <span className="label">{label}</span>
      <div className="grid gap-2" style={{ gridTemplateColumns: `repeat(${columns}, minmax(0, 1fr))` }}>
        {options.map((o) => {
          const selected = o.value === value;
          return (
            <button
              type="button"
              key={o.value}
              aria-pressed={selected}
              onClick={() => onChange(o.value)}
              className={clsx(
                'flex flex-col items-center gap-1.5 rounded-2xl border-2 px-2 py-3 text-xs font-bold transition',
                selected ? 'shadow-soft' : 'border-transparent bg-slate-100 text-slate-600 hover:bg-slate-200/70',
              )}
              style={selected ? { borderColor: ACCENTS[accent][0], background: `${ACCENTS[accent][0]}18`, color: ACCENTS[accent][1] } : undefined}
            >
              {o.icon && <span className="text-xl leading-none">{o.icon}</span>}
              {o.label}
            </button>
          );
        })}
      </div>
    </div>
  );
}

// ── Surfaces ────────────────────────────────────────────────────────────
export function Card({ children, className, padded = true }: { children: ReactNode; className?: string; padded?: boolean }) {
  return <div className={clsx('card', padded && 'p-5', className)}>{children}</div>;
}

/** Gradient hero banner, like the app's GradientHeader. */
export function Hero({ children, accent, className }: { children: ReactNode; accent?: Accent; className?: string }) {
  return (
    <div
      className={clsx('relative overflow-hidden rounded-3xl p-6 text-white shadow-glow', className)}
      style={{ background: accent ? accentGradient(accent) : 'linear-gradient(135deg,#12B39A,#3B82F6)' }}
    >
      <span className="pointer-events-none absolute -right-10 -top-12 h-44 w-44 rounded-full bg-white/10" />
      <span className="pointer-events-none absolute -bottom-16 right-24 h-32 w-32 rounded-full bg-white/[.07]" />
      <div className="relative">{children}</div>
    </div>
  );
}

export function SectionTitle({
  icon,
  accent,
  title,
  action,
}: {
  icon: LucideIcon;
  accent: Accent;
  title: string;
  action?: ReactNode;
}) {
  return (
    <div className="mb-3 mt-8 flex items-center gap-3">
      <IconBadge icon={icon} accent={accent} size={30} />
      <h2 className="flex-1 text-base font-extrabold">{title}</h2>
      {action}
    </div>
  );
}

export function StatCard({ icon, accent, label, value }: { icon: LucideIcon; accent: Accent; label: string; value: ReactNode }) {
  return (
    <Card className="flex items-center gap-4">
      <IconBadge icon={icon} accent={accent} size={48} />
      <div>
        <div className="text-2xl font-extrabold leading-tight">{value}</div>
        <div className="text-sm text-slate-500">{label}</div>
      </div>
    </Card>
  );
}

export function Badge({ children, tone = 'slate' }: { children: ReactNode; tone?: 'green' | 'amber' | 'red' | 'blue' | 'slate' | 'violet' }) {
  const tones = {
    green: 'bg-emerald-100 text-emerald-700',
    amber: 'bg-amber-100 text-amber-700',
    red: 'bg-red-100 text-red-700',
    blue: 'bg-blue-100 text-blue-700',
    slate: 'bg-slate-100 text-slate-600',
    violet: 'bg-violet-100 text-violet-700',
  };
  return <span className={clsx('chip', tones[tone])}>{children}</span>;
}

export function Spinner({ label = 'Loading…' }: { label?: string }) {
  return (
    <div className="flex items-center justify-center gap-3 py-16 text-slate-500" role="status">
      <Loader2 className="animate-spin text-brand-teal" /> {label}
    </div>
  );
}

export function EmptyState({ icon: Icon, title, message, action }: { icon: LucideIcon; title: string; message?: string; action?: ReactNode }) {
  return (
    <div className="flex flex-col items-center px-6 py-14 text-center">
      <span className="mb-5 flex h-24 w-24 items-center justify-center rounded-full bg-brand text-white shadow-glow">
        <Icon size={42} />
      </span>
      <h3 className="text-lg font-extrabold">{title}</h3>
      {message && <p className="mt-1 max-w-sm text-sm text-slate-500">{message}</p>}
      {action && <div className="mt-5">{action}</div>}
    </div>
  );
}

export function ErrorNote({ text }: { text: string | null }) {
  if (!text) return null;
  return (
    <div role="alert" className="rounded-xl bg-red-50 px-4 py-3 text-sm font-semibold text-red-600">
      {text}
    </div>
  );
}

export function PetAvatar({ species, photoUrl, size = 48 }: { species?: Species | null; photoUrl?: string | null; size?: number }) {
  return photoUrl ? (
    <img src={photoUrl} alt="" className="shrink-0 rounded-full object-cover" style={{ width: size, height: size }} />
  ) : (
    <span
      className="inline-flex shrink-0 items-center justify-center rounded-full bg-emerald-100"
      style={{ width: size, height: size, fontSize: size * 0.5 }}
    >
      {SPECIES_EMOJI[species ?? 'other']}
    </span>
  );
}

export function Initials({ name, size = 44 }: { name: string; size?: number }) {
  const initials = name
    .replace(/^Dr\.?\s*/i, '')
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((p) => p[0]!.toUpperCase())
    .join('');
  return (
    <span
      className="inline-flex shrink-0 items-center justify-center rounded-full bg-brand font-extrabold text-white"
      style={{ width: size, height: size, fontSize: size * 0.36 }}
    >
      {initials || '?'}
    </span>
  );
}

export function Tabs<T extends string>({
  tabs,
  value,
  onChange,
}: {
  tabs: { value: T; label: string; count?: number }[];
  value: T;
  onChange: (v: T) => void;
}) {
  return (
    <div role="tablist" className="flex gap-1 overflow-x-auto rounded-2xl bg-white p-1.5 shadow-soft">
      {tabs.map((t) => (
        <button
          key={t.value}
          role="tab"
          aria-selected={t.value === value}
          onClick={() => onChange(t.value)}
          className={clsx(
            'whitespace-nowrap rounded-xl px-4 py-2 text-sm font-bold transition',
            t.value === value ? 'bg-brand text-white shadow-glow' : 'text-slate-500 hover:bg-slate-100',
          )}
        >
          {t.label}
          {t.count !== undefined && <span className="ml-1.5 opacity-75">{t.count}</span>}
        </button>
      ))}
    </div>
  );
}

// ── Modal ───────────────────────────────────────────────────────────────
export function Modal({
  open,
  title,
  onClose,
  children,
  wide,
}: {
  open: boolean;
  title: string;
  onClose: () => void;
  children: ReactNode;
  wide?: boolean;
}) {
  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => e.key === 'Escape' && onClose();
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [open, onClose]);
  if (!open) return null;
  return (
    <div className="fixed inset-0 z-40 flex items-end justify-center bg-black/45 p-0 animate-fade sm:items-center sm:p-6" onMouseDown={onClose}>
      <div
        role="dialog"
        aria-modal="true"
        aria-label={title}
        onMouseDown={(e) => e.stopPropagation()}
        className={clsx(
          'max-h-[92vh] w-full overflow-y-auto rounded-t-3xl bg-white p-6 shadow-2xl animate-pop sm:rounded-3xl',
          wide ? 'sm:max-w-2xl' : 'sm:max-w-lg',
        )}
      >
        <div className="mb-5 flex items-center justify-between">
          <h2 className="text-lg font-extrabold">{title}</h2>
          <button onClick={onClose} aria-label="Close" className="rounded-xl p-2 text-slate-500 hover:bg-slate-100">
            <X size={20} />
          </button>
        </div>
        {children}
      </div>
    </div>
  );
}

export function PageHeading({ title, subtitle, action }: { title: string; subtitle?: string; action?: ReactNode }) {
  return (
    <div className="mb-6 flex flex-wrap items-end justify-between gap-4">
      <div>
        <h1 className="text-2xl font-extrabold tracking-tight">{title}</h1>
        {subtitle && <p className="mt-1 text-sm text-slate-500">{subtitle}</p>}
      </div>
      {action}
    </div>
  );
}
