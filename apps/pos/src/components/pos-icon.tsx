import type { CSSProperties } from 'react';

const paths = {
  close: <path d="m6 6 12 12 M18 6 6 18" />,
  edit: <path d="M17 3a2.83 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z M15 5l4 4" />,
  cog: (
    <>
      <path d="m9 3-.5 2-2 .9-1.9-.6-2 3.4 1.5 1.4v2.3l-1.5 1.4 2 3.4 1.9-.6 2 .9.5 2h4l.5-2 2-.9 1.9.6 2-3.4-1.5-1.4v-2.3l1.5-1.4-2-3.4-1.9.6-2-.9-.5-2Z" />
      <circle cx="11" cy="11.5" r="3" />
    </>
  ),
  search: (
    <>
      <circle cx="10.5" cy="10.5" r="6.5" />
      <path d="m16 16 4.5 4.5" />
    </>
  ),
  box: (
    <>
      <path d="m12 3 9 5-9 5-9-5 9-5Z M3 8v9l9 5 9-5V8 M12 13v9 M7.5 5.5l9 5" />
    </>
  ),
  plus: <path d="M12 5v14 M5 12h14" />,
  minus: <path d="M5 12h14" />,
  trash: (
    <>
      <path d="M3 6h18 M9 6V3h6v3 M5 6l1 15h12l1-15 M10 10v7 M14 10v7" />
    </>
  ),
  grid: (
    <>
      <rect x="3" y="3" width="7" height="7" rx="1" />
      <rect x="14" y="3" width="7" height="7" rx="1" />
      <rect x="3" y="14" width="7" height="7" rx="1" />
      <rect x="14" y="14" width="7" height="7" rx="1" />
    </>
  ),
  list: <path d="M3 5h2 M9 5h12 M3 12h2 M9 12h12 M3 19h2 M9 19h12" />,
  user: (
    <>
      <circle cx="12" cy="8" r="4" />
      <path d="M4 21v-2a8 8 0 0 1 16 0v2" />
    </>
  ),
  cash: (
    <>
      <rect x="2" y="5" width="20" height="14" rx="2" />
      <circle cx="12" cy="12" r="3" />
      <path d="M5 12h1 M18 12h1" />
    </>
  ),
  bank: (
    <>
      <path d="m3 8 9-5 9 5H3Z M3 21h18 M6 11v7 M12 11v7 M18 11v7" />
    </>
  ),
  chevron: <path d="m6 9 6 6 6-6" />,
  check: <path d="m5 12 4 4L19 6" />,
  back: <path d="m10 5-7 7 7 7 M3 12h18" />,
  lock: (
    <>
      <rect x="5" y="10" width="14" height="11" rx="2" />
      <path d="M8 10V7a4 4 0 0 1 8 0v3 M12 14v3" />
    </>
  ),
  eye: (
    <>
      <path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12Z" />
      <circle cx="12" cy="12" r="3" />
    </>
  ),
  eyeOff: (
    <>
      <path d="m3 3 18 18 M10.5 5.1 12 5c6 0 10 7 10 7a20 20 0 0 1-3 3.8 M6 6.5A22 22 0 0 0 2 12s4 7 10 7c2 0 3.7-.7 5.2-1.7" />
    </>
  ),
  alert: (
    <>
      <path d="m12 3 10 18H2L12 3Z M12 9v5 M12 17h.01" />
    </>
  ),
  settings: (
    <>
      <path d="M4 6h16 M4 12h16 M4 18h16" />
      <circle cx="8" cy="6" r="2" fill="currentColor" />
      <circle cx="16" cy="12" r="2" fill="currentColor" />
      <circle cx="10" cy="18" r="2" fill="currentColor" />
    </>
  ),
} as const;

export function PosIcon({ name, style }: { name: keyof typeof paths; style?: CSSProperties }) {
  return (
    <svg
      className="pos-icon"
      style={style}
      width="20"
      height="20"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.7"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      {paths[name]}
    </svg>
  );
}
