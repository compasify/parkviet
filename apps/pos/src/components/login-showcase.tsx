import { type KeyboardEvent, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { GroupArt, SlideArt } from './login-illustrations';
import { PosIcon } from './pos-icon';

type Slide = { id: string; tag: string; title: string; body: string; points: string[] };
type GroupItem = { title: string; body: string };
type Group = { id: string; title: string; summary: string; items: GroupItem[] };
type Highlight = { value: string; label: string };

function prefersReducedMotion() {
  return (
    typeof window !== 'undefined' &&
    window.matchMedia?.('(prefers-reduced-motion: reduce)').matches === true
  );
}

export function LoginShowcase() {
  const { t } = useTranslation();
  const slides = t('loginShowcase.slides', { returnObjects: true }) as Slide[];
  const groups = t('loginShowcase.groups', { returnObjects: true }) as Group[];
  const highlights = t('loginShowcase.highlights', { returnObjects: true }) as Highlight[];
  const [index, setIndex] = useState(0);
  const [paused, setPaused] = useState(prefersReducedMotion);
  const [holding, setHolding] = useState(false);
  const slide = slides[index];
  const total = slides.length;
  const go = (next: number) => setIndex((next + total) % total);

  function onCarouselKey(event: KeyboardEvent<HTMLElement>) {
    if (event.key === 'ArrowRight') go(index + 1);
    else if (event.key === 'ArrowLeft') go(index - 1);
    else return;
    event.preventDefault();
  }

  return (
    <section className="login-showcase" aria-label={t('loginShowcase.label')}>
      <div className="login-hero">
        <div className="login-hero-copy">
          <p className="login-eyebrow">{t('loginShowcase.eyebrow')}</p>
          <h2 className="login-headline">{t('loginShowcase.headline')}</h2>
          <p className="login-lead">{t('loginShowcase.lead')}</p>
        </div>

        <section
          className="login-carousel"
          aria-roledescription="carousel"
          aria-label={t('loginShowcase.carouselLabel')}
          onKeyDown={onCarouselKey}
          onMouseEnter={() => setHolding(true)}
          onMouseLeave={() => setHolding(false)}
          onFocus={() => setHolding(true)}
          onBlur={(event) => {
            if (!event.currentTarget.contains(event.relatedTarget as Node | null))
              setHolding(false);
          }}
        >
          <div className="login-slide-tags">
            {slides.map((item, itemIndex) => (
              <button
                key={item.id}
                type="button"
                className="login-slide-tag"
                aria-current={itemIndex === index ? 'true' : undefined}
                onClick={() => go(itemIndex)}
              >
                <span aria-hidden="true">{String(itemIndex + 1).padStart(2, '0')}</span>
                {item.tag}
              </button>
            ))}
          </div>

          {/* biome-ignore lint/a11y/useSemanticElements: the carousel slide pattern names a group, not a form fieldset. */}
          <div
            key={slide.id}
            className="login-slide"
            role="group"
            aria-roledescription="slide"
            aria-label={t('loginShowcase.slideLabel', { n: index + 1, total })}
          >
            <div className="login-slide-art">
              <SlideArt id={slide.id} />
            </div>
            <div className="login-slide-copy">
              <span className="login-slide-kicker">{slide.tag}</span>
              <h3>{slide.title}</h3>
              <p>{slide.body}</p>
              <ul>
                {slide.points.map((point) => (
                  <li key={point}>
                    <PosIcon name="check" />
                    {point}
                  </li>
                ))}
              </ul>
            </div>
          </div>

          <div className="login-carousel-controls">
            <div className="login-progress" aria-hidden="true">
              <span
                key={`${slide.id}-${paused}`}
                className="login-progress-fill"
                data-running={!paused && !holding ? 'true' : 'false'}
                onAnimationEnd={() => go(index + 1)}
              />
            </div>
            <span className="login-carousel-count" aria-hidden="true">
              {String(index + 1).padStart(2, '0')} / {String(total).padStart(2, '0')}
            </span>
            <button
              type="button"
              className="login-carousel-button"
              aria-label={t(paused ? 'loginShowcase.resume' : 'loginShowcase.pause')}
              onClick={() => setPaused((current) => !current)}
            >
              <PosIcon name={paused ? 'play' : 'pause'} />
            </button>
            <button
              type="button"
              className="login-carousel-button"
              aria-label={t('loginShowcase.previous')}
              onClick={() => go(index - 1)}
            >
              <PosIcon name="back" />
            </button>
            <button
              type="button"
              className="login-carousel-button login-carousel-next"
              aria-label={t('loginShowcase.next')}
              onClick={() => go(index + 1)}
            >
              <PosIcon name="back" />
            </button>
          </div>
        </section>

        <ul className="login-highlights" aria-label={t('loginShowcase.highlightsLabel')}>
          {highlights.map((highlight) => (
            <li key={highlight.label}>
              <strong>{highlight.value}</strong>
              <span>{highlight.label}</span>
            </li>
          ))}
        </ul>
      </div>

      <div className="login-details">
        <header className="login-details-head">
          <p className="login-eyebrow">{t('loginShowcase.groupsEyebrow')}</p>
          <h2>{t('loginShowcase.groupsTitle')}</h2>
          <p>{t('loginShowcase.groupsLead')}</p>
          <nav className="login-group-nav" aria-label={t('loginShowcase.groupsNav')}>
            {groups.map((group) => (
              <a
                key={group.id}
                href={`#feature-${group.id}`}
                data-tone={group.id}
                onClick={(event) => {
                  event.preventDefault();
                  const target = document.getElementById(`feature-${group.id}`);
                  target?.scrollIntoView({
                    behavior: prefersReducedMotion() ? 'auto' : 'smooth',
                    block: 'start',
                  });
                  target?.focus({ preventScroll: true });
                }}
              >
                <GroupArt id={group.id} />
                {group.title}
              </a>
            ))}
          </nav>
        </header>
        <div className="login-groups">
          {groups.map((group) => (
            <article
              key={group.id}
              id={`feature-${group.id}`}
              className="login-group"
              data-tone={group.id}
              tabIndex={-1}
            >
              <header>
                <span className="login-group-emblem">
                  <GroupArt id={group.id} />
                </span>
                <div>
                  <h3>{group.title}</h3>
                  <p>{group.summary}</p>
                </div>
              </header>
              <dl>
                {group.items.map((item) => (
                  <div key={item.title}>
                    <dt>{item.title}</dt>
                    <dd>{item.body}</dd>
                  </div>
                ))}
              </dl>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
