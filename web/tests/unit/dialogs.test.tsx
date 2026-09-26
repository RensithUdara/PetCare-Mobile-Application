import { act, fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';

import { DialogProvider, useDialogs } from '../../src/components/dialogs';

function Harness({ onResult }: { onResult: (v: unknown) => void }) {
  const { confirm, success } = useDialogs();
  return (
    <>
      <button onClick={async () => onResult(await confirm({ title: 'Delete Bruno?', confirmLabel: 'Delete', destructive: true }))}>ask</button>
      <button onClick={async () => onResult(await success({ title: 'Saved!', autoClose: 1000 }))}>celebrate</button>
    </>
  );
}

describe('dialogs', () => {
  it('confirm resolves true on confirm and false on cancel', async () => {
    const onResult = vi.fn();
    render(
      <DialogProvider>
        <Harness onResult={onResult} />
      </DialogProvider>,
    );

    fireEvent.click(screen.getByText('ask'));
    expect(screen.getByRole('alertdialog', { name: 'Delete Bruno?' })).toBeInTheDocument();
    await act(async () => fireEvent.click(screen.getByText('Delete')));
    expect(onResult).toHaveBeenLastCalledWith(true);

    fireEvent.click(screen.getByText('ask'));
    await act(async () => fireEvent.click(screen.getByText('Cancel')));
    expect(onResult).toHaveBeenLastCalledWith(false);
    expect(screen.queryByRole('alertdialog')).not.toBeInTheDocument();
  });

  it('success closes itself after the countdown', async () => {
    vi.useFakeTimers();
    const onResult = vi.fn();
    render(
      <DialogProvider>
        <Harness onResult={onResult} />
      </DialogProvider>,
    );

    fireEvent.click(screen.getByText('celebrate'));
    expect(screen.getByText('Saved!')).toBeInTheDocument();
    await act(async () => {
      vi.advanceTimersByTime(1100);
    });
    expect(screen.queryByText('Saved!')).not.toBeInTheDocument();
    expect(onResult).toHaveBeenCalled();
    vi.useRealTimers();
  });
});
