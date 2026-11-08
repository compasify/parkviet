import { useTranslation } from 'react-i18next';
import type { PosFeature } from '../lib/pos-features';
import { moduleTextKey } from '../lib/pos-modules';

// Why an entry point is missing or disabled: the branch switched the feature
// off, or has not turned the module on. The id lets a disabled control point
// at it with aria-describedby.
export function FeatureOffNote(
  props: { feature: PosFeature; id?: string } | { module: string; id?: string },
) {
  const { t } = useTranslation();
  if ('module' in props) {
    const text = moduleTextKey(props.module);
    return (
      <p className="muted feature-off" id={props.id} role="note" data-module={props.module}>
        {t(text ? `posModules.${text}.off` : 'moduleOff')}
      </p>
    );
  }
  return (
    <p className="muted feature-off" id={props.id} role="note" data-feature={props.feature}>
      {t(`featureOff_${props.feature}`)}
    </p>
  );
}
