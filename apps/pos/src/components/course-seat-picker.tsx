import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import type { PosWorkspace } from '../lib/pos-context';
import { conflictReason, posFailureKey } from '../lib/request-failure';
import {
  courseName,
  DEFAULT_COURSE_LABELS,
  heldCourses,
  type TablePlacement,
} from '../lib/table-courses';

const COURSES = Object.keys(DEFAULT_COURSE_LABELS).map(Number);
const SEAT_MAX = 99;

// Where the next dishes of a table go (course, seat, held) and the fire
// buttons of the courses still held back from the kitchen.
export function CourseSeatPicker({
  workspace,
  value,
  onChange,
  onFire,
  disabled,
}: {
  workspace: PosWorkspace;
  value: TablePlacement;
  onChange: (next: TablePlacement) => void;
  onFire: (course: number) => Promise<unknown>;
  disabled: boolean;
}) {
  const { t } = useTranslation();
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState('');
  const held = heldCourses(workspace);
  return (
    <section className="course-seat-picker" aria-label={t('coursePickerTitle')}>
      <div className="row">
        <label>
          {t('courseLabel')}
          <select
            value={value.course ?? ''}
            disabled={disabled}
            onChange={(event) => {
              const course = event.target.value ? Number(event.target.value) : null;
              onChange({ ...value, course, hold: course ? value.hold : false });
            }}
          >
            <option value="">{t('courseNone')}</option>
            {COURSES.map((course) => (
              <option key={course} value={course}>
                {courseName(course)}
              </option>
            ))}
          </select>
        </label>
        <label>
          {t('seatLabel')}
          <input
            type="number"
            min={0}
            max={SEAT_MAX}
            inputMode="numeric"
            value={value.seat ?? ''}
            placeholder={t('seatShared')}
            disabled={disabled}
            onChange={(event) => {
              const seat = Math.min(SEAT_MAX, Math.max(0, Number(event.target.value) || 0));
              onChange({ ...value, seat: seat || null });
            }}
          />
        </label>
        <label className="check-label">
          <input
            type="checkbox"
            checked={Boolean(value.course && value.hold)}
            disabled={disabled || !value.course}
            onChange={(event) => onChange({ ...value, hold: event.target.checked })}
          />
          {t('courseHold')}
        </label>
      </div>
      {held.length > 0 ? (
        <div className="row course-fire-list">
          {held.map((row) => (
            <button
              key={row.course}
              type="button"
              className="checkout-submit"
              disabled={disabled || busy}
              onClick={() => {
                setBusy(true);
                setMessage('');
                void onFire(row.course)
                  .catch((error) =>
                    setMessage(
                      conflictReason(error) === 'course_not_held'
                        ? t('courseAlreadyFired')
                        : t(posFailureKey(error)),
                    ),
                  )
                  .finally(() => setBusy(false));
              }}
            >
              {t('courseFire', { course: courseName(row.course), count: row.lines.length })}
            </button>
          ))}
        </div>
      ) : null}
      {message ? (
        <p className="workspace-hint" role="status">
          {message}
        </p>
      ) : null}
    </section>
  );
}
