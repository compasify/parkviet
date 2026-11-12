// "45000.0" -> "45.000 ₫" in Vietnamese, "₫45,000" in English.
export function formatMoney(amount: string | null | undefined, currency: string, locale: string) {
  const value = Number(amount);
  if (amount === null || amount === undefined || !Number.isFinite(value)) return '—';
  try {
    return new Intl.NumberFormat(locale === 'en' ? 'en-US' : 'vi-VN', {
      style: 'currency',
      currency,
      maximumFractionDigits: currency === 'VND' ? 0 : 2,
    }).format(value);
  } catch {
    return `${value} ${currency}`;
  }
}
