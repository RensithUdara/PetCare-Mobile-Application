import { Check, HelpCircle, type LucideIcon } from 'lucide-react';
import { createContext, useCallback, useContext, useEffect, useRef, useState, type ReactNode } from 'react';

import { ACCENTS, accentGradient, type Accent } from './ui';

interface ConfirmOptions {
  title: string;
  message?: string;
  confirmLabel?: string;
  cancelLabel?: string;
  icon?: LucideIcon;
  accent?: Accent;
  destructive?: boolean;
}

interface SuccessOptions {
  title: string;
  message?: string;
  /** Closes by itself after this long (ms). */
  autoClose?: number;
}

interface Dialogs {
  confirm: (o: ConfirmOptions) => Promise<boolean>;
  success: (o: SuccessOptions) => Promise<void>;
}

const DialogContext = createContext<Dialogs | null>(null);

type Open =
  | { kind: 'confirm'; options: ConfirmOptions; resolve: (v: boolean) => void }
  | { kind: 'success'; options: SuccessOptions; resolve: () => void };

/** App-wide confirmation and success popups (same look as the mobile app). */
export function DialogProvider({ children }: { children: ReactNode }) {
  const [open, setOpen] = useState<Open | null>(null);

  const confirm = useCallback(
    (options: ConfirmOptions) => new Promise<boolean>((resolve) => setOpen({ kind: 'confirm', options, resolve })),
    [],
  );
  const success = useCallback(
    (options: SuccessOptions) => new Promise<void>((resolve) => setOpen({ kind: 'success', options, resolve })),
    [],
  );

  const close = (value?: boolean) => {
    if (!open) return;
    if (open.kind === 'confirm') open.resolve(value === true);
    else open.resolve();
    setOpen(null);
  };

  return (
    <DialogContext.Provider value={{ confirm, success }}>
      {children}
      {open && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/45 p-6 animate-fade"
          onMouseDown={() => close(false)}
        >
          <div
            role="alertdialog"
            aria-modal="true"
            aria-label={open.options.title}
            onMouseDown={(e) => e.stopPropagation()}
            className="w-full max-w-sm rounded-3xl bg-white p-6 pt-7 text-center shadow-2xl animate-pop"
          >
            {open.kind === 'confirm' ? (
              <ConfirmBody options={open.options} onClose={close} />
            ) : (
              <SuccessBody options={open.options} onClose={() => close()} />
            )}
          </div>
        </div>
      )}
    </DialogContext.Provider>
  );
}

function Halo({ accent, children }: { accent: Accent; children: ReactNode }) {
  return (
    <div className="mx-auto mb-5 w-fit rounded-full p-2.5" style={{ background: `${ACCENTS[accent][0]}1f` }}>
      <div
        className="flex h-[72px] w-[72px] items-center justify-center rounded-full text-white"
        style={{ background: accentGradient(accent), boxShadow: `0 8px 18px -4px ${ACCENTS[accent][0]}99` }}
      >
        {children}
      </div>
    </div>
  );
}

function Texts({ title, message }: { title: string; message?: string }) {
  return (
    <>
      <h2 className="text-xl font-extrabold">{title}</h2>
      {message && <p className="mt-2 text-sm leading-relaxed text-slate-500">{message}</p>}
    </>
  );
}

function ConfirmBody({ options, onClose }: { options: ConfirmOptions; onClose: (v: boolean) => void }) {
  const { icon: Icon = HelpCircle, destructive, accent = 'pets' } = options;
  const confirmRef = useRef<HTMLButtonElement>(null);
  useEffect(() => confirmRef.current?.focus(), []);
  return (
    <>
      <Halo accent={destructive ? 'emergency' : accent}>
        <Icon size={34} />
      </Halo>
      <Texts title={options.title} message={options.message} />
      <div className="mt-6 grid grid-cols-2 gap-3">
        <button className="btn-outline" onClick={() => onClose(false)}>
          {options.cancelLabel ?? 'Cancel'}
        </button>
        <button ref={confirmRef} className={destructive ? 'btn-danger' : 'btn-primary'} onClick={() => onClose(true)}>
          {options.confirmLabel ?? 'Confirm'}
        </button>
      </div>
    </>
  );
}

function SuccessBody({ options, onClose }: { options: SuccessOptions; onClose: () => void }) {
  const duration = options.autoClose ?? 2200;
  // Keep the timer stable across parent re-renders.
  const closeRef = useRef(onClose);
  closeRef.current = onClose;
  useEffect(() => {
    const t = setTimeout(() => closeRef.current(), duration);
    return () => clearTimeout(t);
  }, [duration]);
  return (
    <>
      <Halo accent="vaccinations">
        <svg width="38" height="38" viewBox="0 0 24 24" fill="none" aria-hidden>
          <path
            d="M5 12.5l4.5 4.5L19 7.5"
            stroke="white"
            strokeWidth="3"
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeDasharray="48"
            className="animate-draw"
          />
        </svg>
        <Check className="sr-only" />
      </Halo>
      <Texts title={options.title} message={options.message} />
      <button className="btn mt-6 w-full bg-emerald-500 text-white hover:bg-emerald-600" onClick={onClose} autoFocus>
        Done
      </button>
      <div className="mt-4 h-1 overflow-hidden rounded bg-emerald-100">
        <div className="h-full bg-emerald-500 animate-shrink" style={{ animationDuration: `${duration}ms` }} />
      </div>
    </>
  );
}

export function useDialogs(): Dialogs {
  const ctx = useContext(DialogContext);
  if (!ctx) throw new Error('useDialogs must be used inside <DialogProvider>');
  return ctx;
}
