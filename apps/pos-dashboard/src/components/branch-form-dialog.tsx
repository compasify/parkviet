import { TopologyEditor, type TopologyEditorProps } from './topology-editor'
export function BranchFormDialog(props: Omit<TopologyEditorProps, 'kind'>) {
  return <TopologyEditor {...props} kind="branches" />
}
