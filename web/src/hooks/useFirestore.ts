import {
  onSnapshot,
  type DocumentData,
  type DocumentReference,
  type Query,
} from 'firebase/firestore';
import { useEffect, useState } from 'react';

export interface Live<T> {
  data: T;
  loading: boolean;
  error: Error | null;
}

/**
 * Live query results mapped with [map]. Pass `null` to skip; [key] must
 * change whenever the query does (queries aren't comparable).
 */
export function useLiveQuery<T>(
  q: Query<DocumentData> | null,
  key: string,
  map: (id: string, data: DocumentData) => T,
): Live<T[]> {
  const [state, setState] = useState<Live<T[]>>({ data: [], loading: q !== null, error: null });
  useEffect(() => {
    if (!q) {
      setState({ data: [], loading: false, error: null });
      return;
    }
    setState((s) => ({ ...s, loading: true }));
    return onSnapshot(
      q,
      (snap) => setState({ data: snap.docs.map((d) => map(d.id, d.data())), loading: false, error: null }),
      (error) => setState({ data: [], loading: false, error }),
    );
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [key]);
  return state;
}

/** A live single document (`null` when missing). */
export function useLiveDoc<T>(
  ref: DocumentReference<DocumentData> | null,
  key: string,
  map: (id: string, data: DocumentData) => T,
): Live<T | null> {
  const [state, setState] = useState<Live<T | null>>({ data: null, loading: ref !== null, error: null });
  useEffect(() => {
    if (!ref) {
      setState({ data: null, loading: false, error: null });
      return;
    }
    setState((s) => ({ ...s, loading: true }));
    return onSnapshot(
      ref,
      (snap) => setState({ data: snap.exists() ? map(snap.id, snap.data()) : null, loading: false, error: null }),
      (error) => setState({ data: null, loading: false, error }),
    );
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [key]);
  return state;
}
