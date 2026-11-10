import { TopologyEditor, type TopologyEditorProps } from './topology-editor'
export function RegisterFormDialog(props: Omit<TopologyEditorProps, 'kind'>) {
  return <TopologyEditor {...props} kind="registers" />
}
