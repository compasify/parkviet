// The table's code arrives once in the address (/table/t/<code>); it is
// exchanged for a session token and taken out of the address. The token and
// the code stay in this tab's sessionStorage only, never in a URL: the token
// for every call, the code only while the table is not open yet, to try
// again once staff open it. A session that ordered and ended needs a new
// scan, so a phone that left keeps no way onto the next guests' order.

const TOKEN_KEY = 'parkviet.table.token';
const CODE_KEY = 'parkviet.table.code';
const CODE = /^[A-Za-z0-9_-]{16,64}$/;

type Store = Pick<Storage, 'getItem' | 'setItem' | 'removeItem'>;

// The code in a path such as /table/t/<code>, or null.
export function codeFromPath(pathname: string): string | null {
  const match = /\/t\/([^/?#]+)\/?$/.exec(pathname);
  if (!match) return null;
  const code = decodeURIComponent(match[1]);
  return CODE.test(code) ? code : null;
}

// The page's own address without the code.
export function pathWithoutCode(pathname: string): string {
  return pathname.replace(/\/t\/[^/?#]+\/?$/, '/');
}

function store(): Store | null {
  try {
    return globalThis.sessionStorage ?? null;
  } catch {
    return null;
  }
}

export function readToken(storage: Store | null = store()): string | null {
  return storage?.getItem(TOKEN_KEY) ?? null;
}

export function saveToken(token: string | null, storage: Store | null = store()) {
  if (!storage) return;
  if (token) storage.setItem(TOKEN_KEY, token);
  else storage.removeItem(TOKEN_KEY);
}

export function readCode(storage: Store | null = store()): string | null {
  const code = storage?.getItem(CODE_KEY) ?? null;
  return code && CODE.test(code) ? code : null;
}

export function saveCode(code: string, storage: Store | null = store()) {
  storage?.setItem(CODE_KEY, code);
}

export function forgetCode(storage: Store | null = store()) {
  storage?.removeItem(CODE_KEY);
}

// Takes the code out of the address bar (and so out of history and of any
// screenshot), keeping it in this tab's storage.
export function takeCodeFromAddress(location: Location, history: History): string | null {
  const code = codeFromPath(location.pathname);
  if (!code) return null;
  saveCode(code);
  history.replaceState(null, '', pathWithoutCode(location.pathname));
  return code;
}
