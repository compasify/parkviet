import { MonitorIcon } from '@spree/dashboard-ui/icons'
import { useParams } from '@tanstack/react-router'
import { useEffect, useState } from 'react'
import { createPortal } from 'react-dom'
import { useTranslation } from 'react-i18next'
import { usePosSession } from '../hooks/use-pos-session'
import { posSellingConfigured, posSellingUrl } from '../lib/pos-selling-url'

// The rail's nav registry only builds in-app links, and those links preload on
// hover. The counter is another origin, so this control is a plain anchor at
// the top of the nav list — above "Việc cần xử lý" — and it opens a new tab.
// Administration stays where it is.
const HOST_CLASS =
  'px-2 pb-3 group-data-[collapsible=icon]:flex group-data-[collapsible=icon]:justify-center group-data-[collapsible=icon]:px-0'
const LINK_CLASS =
  'flex h-11 w-full items-center justify-center gap-2 rounded-lg bg-foreground text-base font-semibold text-background no-underline transition-opacity hover:opacity-90 focus-visible:shadow-[0_0_0_3px_color-mix(in_srgb,var(--ring)_15%,transparent)] focus-visible:outline-none in-data-[mobile=true]:h-12 group-data-[collapsible=icon]:size-10'

function counterHosts(root: ParentNode) {
  const found: HTMLElement[] = []
  for (const content of root.querySelectorAll<HTMLElement>('[data-sidebar="content"]')) {
    let host = content.querySelector<HTMLElement>(':scope > [data-pos-counter-host]')
    if (!host) {
      host = document.createElement('div')
      host.dataset.posCounterHost = ''
      host.className = HOST_CLASS
      content.prepend(host)
    }
    found.push(host)
  }
  return found
}

function sameHosts(left: HTMLElement[], right: HTMLElement[]) {
  return left.length === right.length && left.every((node, index) => node === right[index])
}

export function PosCounterLink() {
  const { t } = useTranslation()
  const { storeId } = useParams({ strict: false }) as { storeId?: string }
  const { selection } = usePosSession()
  const enabled = posSellingConfigured() && Boolean(storeId)
  const url = enabled ? posSellingUrl(storeId, selection.branchId) : null
  const [hosts, setHosts] = useState<HTMLElement[]>([])

  useEffect(() => {
    if (!enabled) return
    const sync = () => {
      const next = counterHosts(document.body)
      setHosts((current) => (sameHosts(current, next) ? current : next))
    }
    sync()
    // The phone drawer mounts its rail only while open, so the host has to
    // follow the sidebar into and out of the document.
    const observer = new MutationObserver(sync)
    observer.observe(document.body, { childList: true, subtree: true })
    return () => {
      observer.disconnect()
      for (const host of document.querySelectorAll('[data-pos-counter-host]')) host.remove()
    }
  }, [enabled])

  if (!url) return null
  return hosts.map((host) =>
    createPortal(
      <a data-pos-counter="" href={url} target="_blank" rel="noopener" className={LINK_CLASS}>
        <MonitorIcon aria-hidden size={16} strokeWidth={2} />
        <span className="group-data-[collapsible=icon]:sr-only">
          {t('posDashboard.openCounter')}
        </span>
      </a>,
      host,
      'pos-counter',
    ),
  )
}
