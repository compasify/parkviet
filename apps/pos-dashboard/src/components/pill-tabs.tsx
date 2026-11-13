import { Tabs, TabsList, TabsTrigger } from '@spree/dashboard-ui'
import { Link, type LinkProps, useLocation } from '@tanstack/react-router'
import type { ReactNode } from 'react'

export type PillTab = {
  key: string
  label: ReactNode
  to: string
  search?: LinkProps['search']
}

// Sub-navigation for a dashboard screen: the same pill track as a Spree
// settings page. Each tab is a link, so the address follows the selection.
// The strip scrolls inside itself when the labels are wider than the page.
export function PillTabs({ tabs }: { tabs: PillTab[] }) {
  const { pathname } = useLocation()
  const current = tabs.find((tab) => pathname === tab.to)?.key ?? tabs[0]?.key
  if (!current) return null
  return (
    <div className="w-full min-w-0 overflow-x-auto">
      <Tabs value={current}>
        <TabsList>
          {tabs.map((tab) => (
            <TabsTrigger
              key={tab.key}
              value={tab.key}
              render={
                tab.search ? (
                  <Link to={tab.to as never} search={tab.search as never} />
                ) : (
                  <Link to={tab.to as never} />
                )
              }
            >
              {tab.label}
            </TabsTrigger>
          ))}
        </TabsList>
      </Tabs>
    </div>
  )
}
