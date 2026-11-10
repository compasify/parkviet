import { TopologyEditor, type TopologyEditorProps } from './topology-editor'
export function MembershipFormDialog(props: Omit<TopologyEditorProps, 'kind'>) {
  return <TopologyEditor {...props} kind="memberships" />
}
