/** Normalises typed input into a doctor code like `DR-7K3M9Q` (same rules as the app). */
export function normalizeDoctorCode(input: string): string | null {
  let code = input.toUpperCase().replace(/[\s_]/g, '');
  if (code.startsWith('DR-')) code = code.slice(3);
  else if (code.startsWith('DR')) code = code.slice(2);
  code = code.replace(/-/g, '');
  return /^[A-HJ-NP-Z2-9]{6}$/.test(code) ? `DR-${code}` : null;
}
