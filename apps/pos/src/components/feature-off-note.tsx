import { useTranslation } from 'react-i18next';
import type { PosFeature } from '../lib/pos-features';

// Why an entry point is missing or disabled: the branch switched the feature
// off. The id lets a disabled control point at it with aria-describedby.
export function FeatureOffNote({ feature, id }: { feature: PosFeature; id?: string }) {
  const { t } = useTranslation();
  return (
    <p className="muted feature-off" id={id} role="note" data-feature={feature}>
      {t(`featureOff_${feature}`)}
    </p>
  );
}
