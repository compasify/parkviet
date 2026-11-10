// The signed export link is a path on the API (e.g. /api/v3/admin/pos/export_files/…);
// it is resolved against the API origin the dashboard talks to.
export function exportFileUrl(
  url: string,
  apiBase: string = import.meta.env.VITE_SPREE_API_URL || '',
) {
  return /^https?:\/\//.test(url) ? url : `${apiBase}${url}`
}

// Starts a browser download of a signed export link; the file streams from
// the server and is never held in page memory.
export function startDownload(url: string, filename: string) {
  const link = document.createElement('a')
  link.href = exportFileUrl(url)
  link.download = filename
  link.rel = 'noopener'
  document.body.append(link)
  link.click()
  link.remove()
}
