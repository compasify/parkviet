import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@spree/dashboard-ui'
import { useParams } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'
import { usePosSession } from '../hooks/use-pos-session'

// Branch switcher for store-level pages that act on one branch. Pages reached
// through /branches/$branchId already name their branch, and a store with a
// single branch has nothing to choose, so neither shows it.
export function BranchPicker() {
  const { t } = useTranslation()
  const { context, selection, setSelection } = usePosSession()
  const { branchId } = useParams({ strict: false }) as { branchId?: string }
  const branches = context.data?.branches ?? []
  if (branchId || branches.length < 2) return null
  const items = branches.map((branch) => ({ value: branch.id, label: branch.name }))
  return (
    <Select
      value={selection.branchId ?? ''}
      items={items}
      onValueChange={(next) => setSelection({ branchId: next as string, registerId: null })}
    >
      <SelectTrigger aria-label={t('posDashboard.branch')} className="w-56">
        <SelectValue />
      </SelectTrigger>
      <SelectContent>
        {items.map((item) => (
          <SelectItem key={item.value} value={item.value}>
            {item.label}
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  )
}
