// biome-ignore-all lint/suspicious/noArrayIndexKey: static decorative artwork; its lists never reorder.
import type { ReactNode } from 'react';

// Decorative artwork for the login feature showcase. Every illustration is
// aria-hidden: the slide and group text next to it carries the meaning.

const C = {
  navy: '#0d2b48',
  blue: '#07569a',
  sky: '#3b8fd9',
  mist: '#e7f2fb',
  tint: '#f4f8fb',
  line: '#d5e0e8',
  bar: '#c9d7e3',
  ink: '#172d40',
  muted: '#8aa3b8',
  teal: '#1f9e86',
  mint: '#dff5ee',
  amber: '#f2a93b',
  sand: '#fff3dc',
  coral: '#e8664f',
  rose: '#fde8e3',
  white: '#ffffff',
};

function Art({ id, children }: { id: string; children: ReactNode }) {
  return (
    <svg
      className="login-art"
      viewBox="0 0 480 340"
      aria-hidden="true"
      focusable="false"
      xmlns="http://www.w3.org/2000/svg"
    >
      <defs>
        <filter id={`${id}-shadow`} x="-20%" y="-20%" width="140%" height="160%">
          <feDropShadow dx="0" dy="8" stdDeviation="9" floodColor="#0d2b48" floodOpacity=".16" />
        </filter>
      </defs>
      <g fontFamily="system-ui, sans-serif">{children}</g>
    </svg>
  );
}

function Card({
  id,
  x,
  y,
  w,
  h,
  r = 14,
  fill = C.white,
}: {
  id: string;
  x: number;
  y: number;
  w: number;
  h: number;
  r?: number;
  fill?: string;
}) {
  return <rect x={x} y={y} width={w} height={h} rx={r} fill={fill} filter={`url(#${id}-shadow)`} />;
}

function Bar({
  x,
  y,
  w,
  h = 6,
  fill = C.bar,
}: {
  x: number;
  y: number;
  w: number;
  h?: number;
  fill?: string;
}) {
  return <rect x={x} y={y} width={w} height={h} rx={h / 2} fill={fill} />;
}

function Avatar({
  cx,
  cy,
  r,
  fill,
  face = C.white,
}: {
  cx: number;
  cy: number;
  r: number;
  fill: string;
  face?: string;
}) {
  return (
    <g>
      <circle cx={cx} cy={cy} r={r} fill={fill} />
      <circle cx={cx} cy={cy - r * 0.18} r={r * 0.34} fill={face} />
      <path
        d={`M${cx - r * 0.58} ${cy + r * 0.62}a${r * 0.58} ${r * 0.46} 0 0 1 ${r * 1.16} 0`}
        fill={face}
      />
    </g>
  );
}

function CheckBadge({
  cx,
  cy,
  r = 11,
  fill = C.teal,
}: {
  cx: number;
  cy: number;
  r?: number;
  fill?: string;
}) {
  return (
    <g>
      <circle cx={cx} cy={cy} r={r} fill={fill} />
      <path
        d={`M${cx - r * 0.45} ${cy}l${r * 0.32} ${r * 0.34} ${r * 0.62}-${r * 0.68}`}
        fill="none"
        stroke={C.white}
        strokeWidth={r * 0.24}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </g>
  );
}

// A deterministic QR-like mark: three finder patterns plus a fixed module field.
function QrMark({
  x,
  y,
  size,
  color = C.ink,
}: {
  x: number;
  y: number;
  size: number;
  color?: string;
}) {
  const n = 21;
  const m = size / n;
  const finder = (fx: number, fy: number) => (
    <g key={`${fx}-${fy}`}>
      <rect x={x + fx * m} y={y + fy * m} width={7 * m} height={7 * m} fill={color} />
      <rect x={x + (fx + 1) * m} y={y + (fy + 1) * m} width={5 * m} height={5 * m} fill={C.white} />
      <rect x={x + (fx + 2) * m} y={y + (fy + 2) * m} width={3 * m} height={3 * m} fill={color} />
    </g>
  );
  const inFinder = (i: number, j: number) =>
    (i < 8 && j < 8) || (i > 12 && j < 8) || (i < 8 && j > 12);
  const modules: ReactNode[] = [];
  for (let i = 0; i < n; i++) {
    for (let j = 0; j < n; j++) {
      if (inFinder(i, j)) continue;
      if ((i * 7 + j * 13 + ((i * j) % 5)) % 3 === 0) {
        modules.push(
          <rect key={`${i}:${j}`} x={x + i * m} y={y + j * m} width={m} height={m} fill={color} />,
        );
      }
    }
  }
  return (
    <g>
      <rect x={x - m} y={y - m} width={size + 2 * m} height={size + 2 * m} fill={C.white} />
      {modules}
      {finder(0, 0)}
      {finder(14, 0)}
      {finder(0, 14)}
    </g>
  );
}

function Barcode({
  x,
  y,
  w,
  h,
  color = C.ink,
}: {
  x: number;
  y: number;
  w: number;
  h: number;
  color?: string;
}) {
  const pattern = [2, 1, 1, 3, 1, 2, 1, 1, 2, 3, 1, 1, 2, 1, 3, 1, 1, 2, 1, 2, 1, 3, 1, 1, 2];
  const total = pattern.reduce((sum, value) => sum + value, 0);
  const unit = w / total;
  let cursor = x;
  return (
    <g>
      {pattern.map((width, index) => {
        const bar =
          index % 2 === 0 ? (
            <rect key={index} x={cursor} y={y} width={width * unit} height={h} fill={color} />
          ) : null;
        cursor += width * unit;
        return bar;
      })}
    </g>
  );
}

function SaleArt() {
  const id = 'art-sale';
  const tiles = [
    { fill: C.mist, shape: <rect x={-9} y={-16} width={18} height={30} rx={6} fill={C.sky} /> },
    { fill: C.sand, shape: <rect x={-14} y={-12} width={28} height={24} rx={4} fill={C.amber} /> },
    { fill: C.rose, shape: <circle r={14} fill={C.coral} /> },
    { fill: C.mint, shape: <rect x={-11} y={-15} width={22} height={30} rx={4} fill={C.teal} /> },
    { fill: C.mist, shape: <path d="M-14 -8h28l-4 22h-20Z" fill={C.blue} /> },
    { fill: C.sand, shape: <ellipse rx={15} ry={11} fill={C.amber} /> },
  ];
  return (
    <Art id={id}>
      <Card id={id} x={28} y={24} w={424} h={272} r={16} />
      <rect x={28} y={24} width={424} height={42} rx={16} fill={C.blue} />
      <rect x={28} y={50} width={424} height={16} fill={C.blue} />
      <rect x={44} y={34} width={66} height={24} rx={7} fill={C.white} />
      <text x={77} y={50} textAnchor="middle" fontSize={11} fontWeight={700} fill={C.blue}>
        #1
      </text>
      <rect x={118} y={34} width={66} height={24} rx={7} fill="#2c74b3" />
      <text x={151} y={50} textAnchor="middle" fontSize={11} fontWeight={700} fill={C.white}>
        #2
      </text>
      <circle className="art-pulse" cx={178} cy={40} r={4} fill={C.amber} />
      <rect x={192} y={34} width={66} height={24} rx={7} fill="#2c74b3" />
      <text x={225} y={50} textAnchor="middle" fontSize={11} fontWeight={700} fill={C.white}>
        #3
      </text>
      <circle cx={278} cy={46} r={11} fill="#2c74b3" />
      <path d="M278 41v10M273 46h10" stroke={C.white} strokeWidth={2} strokeLinecap="round" />

      <rect x={44} y={80} width={236} height={30} rx={8} fill={C.tint} stroke={C.line} />
      <circle cx={60} cy={95} r={6} fill="none" stroke={C.muted} strokeWidth={2} />
      <path d="m64.5 99.5 4 4" stroke={C.muted} strokeWidth={2} strokeLinecap="round" />
      <Bar x={76} y={92} w={96} />
      <Barcode x={244} y={87} w={26} h={16} color={C.muted} />
      {tiles.map((tile, index) => {
        const tx = 44 + (index % 3) * 80;
        const ty = 120 + Math.floor(index / 3) * 86;
        return (
          <g key={index}>
            <rect x={tx} y={ty} width={72} height={78} rx={10} fill={C.tint} stroke={C.line} />
            <rect x={tx + 8} y={ty + 8} width={56} height={40} rx={8} fill={tile.fill} />
            <g transform={`translate(${tx + 36} ${ty + 28})`}>{tile.shape}</g>
            <Bar x={tx + 8} y={ty + 55} w={40} h={5} />
            <Bar x={tx + 8} y={ty + 65} w={28} h={5} fill={C.blue} />
          </g>
        );
      })}

      <rect x={292} y={80} width={146} height={202} rx={10} fill={C.tint} stroke={C.line} />
      {[0, 1, 2, 3].map((row) => (
        <g key={row}>
          <rect
            x={302}
            y={92 + row * 34}
            width={22}
            height={22}
            rx={5}
            fill={[C.sky, C.amber, C.coral, C.teal][row]}
          />
          <Bar x={330} y={95 + row * 34} w={52} h={5} fill={C.ink} />
          <Bar x={330} y={106 + row * 34} w={34} h={4} />
          <Bar x={398} y={97 + row * 34} w={30} h={6} fill={C.muted} />
        </g>
      ))}
      <rect x={302} y={236} width={126} height={36} rx={8} fill={C.blue} />
      <text x={365} y={259} textAnchor="middle" fontSize={13} fontWeight={700} fill={C.white}>
        245.000 ₫
      </text>

      <Card id={id} x={10} y={258} w={170} h={68} r={14} />
      <Barcode x={26} y={274} w={92} h={36} />
      <rect className="art-scan" x={20} y={290} width={104} height={3} rx={1.5} fill={C.coral} />
      <rect x={130} y={274} width={38} height={18} rx={9} fill={C.mint} />
      <text x={149} y={287} textAnchor="middle" fontSize={9} fontWeight={700} fill={C.teal}>
        EAN
      </text>
      <Bar x={130} y={298} w={38} h={5} />
    </Art>
  );
}

function PaymentArt() {
  const id = 'art-pay';
  return (
    <Art id={id}>
      <g transform="rotate(-8 92 246)">
        <rect x={22} y={210} width={140} height={70} rx={8} fill="#7cc7a8" />
        <rect
          x={30}
          y={218}
          width={124}
          height={54}
          rx={5}
          fill="none"
          stroke="#5aae8c"
          strokeWidth={2}
        />
      </g>
      <rect
        x={18}
        y={226}
        width={140}
        height={70}
        rx={8}
        fill={C.teal}
        filter={`url(#${id}-shadow)`}
      />
      <rect
        x={26}
        y={234}
        width={124}
        height={54}
        rx={5}
        fill="none"
        stroke="#5fc3ab"
        strokeWidth={2}
      />
      <circle cx={88} cy={261} r={16} fill="#5fc3ab" />
      <text x={88} y={266} textAnchor="middle" fontSize={14} fontWeight={800} fill={C.white}>
        ₫
      </text>

      <rect
        x={160}
        y={18}
        width={156}
        height={304}
        rx={26}
        fill={C.navy}
        filter={`url(#${id}-shadow)`}
      />
      <rect x={170} y={34} width={136} height={274} rx={18} fill={C.white} />
      <rect x={218} y={24} width={40} height={5} rx={2.5} fill="#2a4a68" />
      <rect x={170} y={34} width={136} height={44} rx={18} fill={C.mist} />
      <rect x={170} y={60} width={136} height={18} fill={C.mist} />
      <circle cx={190} cy={56} r={9} fill={C.blue} />
      <Bar x={206} y={50} w={58} h={5} fill={C.ink} />
      <Bar x={206} y={59} w={38} h={4} />
      <rect
        className="art-glow"
        x={182}
        y={92}
        width={112}
        height={112}
        rx={10}
        fill="none"
        stroke={C.sky}
        strokeWidth={3}
      />
      <QrMark x={190} y={100} size={96} />
      <text x={238} y={232} textAnchor="middle" fontSize={17} fontWeight={800} fill={C.ink}>
        250.000 ₫
      </text>
      <Bar x={196} y={244} w={84} h={5} />
      <rect x={186} y={264} width={104} height={30} rx={8} fill={C.blue} />
      <Bar x={210} y={276} w={56} h={6} fill="#8ec0ea" />

      <g className="art-toast">
        <Card id={id} x={290} y={50} w={176} h={64} r={14} />
        <CheckBadge cx={316} cy={82} r={14} />
        <Bar x={338} y={70} w={78} h={6} fill={C.ink} />
        <text x={338} y={98} fontSize={14} fontWeight={800} fill={C.teal}>
          +250.000 ₫
        </text>
      </g>

      <Card id={id} x={300} y={186} w={164} h={110} r={14} />
      <circle cx={322} cy={212} r={9} fill={C.mint} />
      <text x={322} y={216} textAnchor="middle" fontSize={10} fontWeight={800} fill={C.teal}>
        ₫
      </text>
      <Bar x={338} y={209} w={56} h={6} fill={C.ink} />
      <Bar x={414} y={209} w={36} h={6} fill={C.teal} />
      <rect x={313} y={233} width={18} height={18} rx={4} fill={C.mist} />
      <rect x={317} y={237} width={4} height={4} fill={C.blue} />
      <rect x={323} y={243} width={4} height={4} fill={C.blue} />
      <Bar x={338} y={239} w={48} h={6} fill={C.ink} />
      <Bar x={414} y={239} w={36} h={6} fill={C.sky} />
      <rect x={314} y={266} width={136} height={12} rx={6} fill={C.tint} />
      <rect x={314} y={266} width={82} height={12} rx={6} fill={C.teal} />
      <rect x={392} y={266} width={58} height={12} rx={6} fill={C.sky} />
      <rect x={392} y={266} width={6} height={12} fill={C.sky} />
    </Art>
  );
}

function CreditArt() {
  const id = 'art-credit';
  // Gauge: 65% of a 180° arc.
  const cx = 145;
  const cy = 180;
  const r = 62;
  const angle = Math.PI * (1 - 0.65);
  const ex = cx + r * Math.cos(angle);
  const ey = cy - r * Math.sin(angle);
  return (
    <Art id={id}>
      <Card id={id} x={24} y={28} w={244} h={186} r={16} />
      <Avatar cx={56} cy={62} r={18} fill={C.sky} />
      <Bar x={84} y={52} w={92} h={7} fill={C.ink} />
      <Bar x={84} y={66} w={60} h={5} />
      <rect x={196} y={50} width={56} height={22} rx={11} fill={C.mint} />
      <Bar x={208} y={58} w={32} h={6} fill={C.teal} />
      <path
        d={`M${cx - r} ${cy}a${r} ${r} 0 0 1 ${2 * r} 0`}
        fill="none"
        stroke={C.tint}
        strokeWidth={18}
        strokeLinecap="round"
      />
      <path
        d={`M${cx - r} ${cy}A${r} ${r} 0 0 1 ${ex.toFixed(1)} ${ey.toFixed(1)}`}
        fill="none"
        stroke={C.blue}
        strokeWidth={18}
        strokeLinecap="round"
      />
      <text x={cx} y={cy - 8} textAnchor="middle" fontSize={22} fontWeight={800} fill={C.ink}>
        65%
      </text>
      <Bar x={cx - 26} y={cy + 4} w={52} h={5} />

      <Card id={id} x={286} y={28} w={170} h={186} r={16} />
      <Avatar cx={326} cy={78} r={22} fill={C.amber} />
      <Avatar cx={416} cy={78} r={22} fill={C.blue} />
      <path
        d="M354 78h30"
        stroke={C.muted}
        strokeWidth={3}
        strokeLinecap="round"
        strokeDasharray="2 6"
      />
      <path
        d="m380 72 6 6-6 6"
        fill="none"
        stroke={C.muted}
        strokeWidth={3}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <g className="art-pop">
        <CheckBadge cx={434} cy={98} r={11} />
      </g>
      <rect x={302} y={124} width={138} height={34} rx={9} fill={C.tint} />
      <rect x={312} y={133} width={16} height={16} rx={4} fill={C.mist} />
      <Bar x={336} y={134} w={58} h={5} fill={C.ink} />
      <Bar x={336} y={144} w={40} h={4} />
      <Bar x={402} y={137} w={30} h={7} fill={C.blue} />
      <rect x={302} y={168} width={138} height={30} rx={9} fill={C.blue} />
      <Bar x={336} y={180} w={70} h={6} fill="#8ec0ea" />

      <Card id={id} x={24} y={232} w={432} h={86} r={16} />
      {
        [
          { w: 150, fill: C.teal },
          { w: 110, fill: C.sky },
          { w: 80, fill: C.amber },
          { w: 52, fill: C.coral },
        ].reduce<{ x: number; nodes: ReactNode[] }>(
          (acc, segment, index) => {
            acc.nodes.push(
              <g key={index}>
                <rect
                  x={acc.x}
                  y={254}
                  width={segment.w - 4}
                  height={18}
                  rx={5}
                  fill={segment.fill}
                />
                <Bar x={acc.x} y={284} w={Math.min(48, segment.w - 12)} h={5} />
                <Bar x={acc.x} y={296} w={Math.min(30, segment.w - 20)} h={5} fill={segment.fill} />
              </g>,
            );
            acc.x += segment.w;
            return acc;
          },
          { x: 44, nodes: [] },
        ).nodes
      }
    </Art>
  );
}

function InventoryArt() {
  const id = 'art-stock';
  const box = (x: number, y: number, label: string, date: string, highlight = false) => (
    <g>
      <rect
        x={x}
        y={y}
        width={112}
        height={90}
        rx={8}
        fill="#e8b46e"
        filter={`url(#${id}-shadow)`}
      />
      <rect x={x + 46} y={y} width={20} height={90} fill="#d69a4c" />
      <rect x={x + 12} y={y + 40} width={64} height={38} rx={5} fill={C.white} />
      <text x={x + 20} y={y + 56} fontSize={10} fontWeight={800} fill={C.ink}>
        {label}
      </text>
      <text x={x + 20} y={y + 70} fontSize={9} fontWeight={600} fill={C.muted}>
        {date}
      </text>
      {highlight && (
        <>
          <rect
            x={x - 5}
            y={y - 5}
            width={122}
            height={100}
            rx={12}
            fill="none"
            stroke={C.blue}
            strokeWidth={3}
          />
          <rect x={x + 62} y={y - 16} width={56} height={22} rx={11} fill={C.blue} />
          <text
            x={x + 90}
            y={y - 1}
            textAnchor="middle"
            fontSize={10}
            fontWeight={800}
            fill={C.white}
          >
            FEFO
          </text>
        </>
      )}
    </g>
  );
  return (
    <Art id={id}>
      {box(36, 150, 'LOT B', '03/27')}
      {box(160, 150, 'LOT C', '06/27')}
      {box(98, 46, 'LOT A', '12/26', true)}

      <path d="M40 286h236" stroke={C.line} strokeWidth={4} strokeLinecap="round" />
      <path
        className="art-flow"
        d="M40 286h236"
        stroke={C.blue}
        strokeWidth={4}
        strokeLinecap="round"
        strokeDasharray="8 10"
      />
      {[60, 150, 240].map((dx, index) => (
        <g key={dx}>
          <circle
            cx={dx}
            cy={286}
            r={index === 0 ? 10 : 7}
            fill={index === 0 ? C.blue : C.white}
            stroke={C.blue}
            strokeWidth={3}
          />
          <Bar x={dx - 16} y={304} w={32} h={5} fill={index === 0 ? C.blue : C.bar} />
        </g>
      ))}

      <Card id={id} x={300} y={34} w={156} h={104} r={14} />
      <Bar x={316} y={50} w={60} h={6} fill={C.ink} />
      <Barcode x={316} y={66} w={124} h={40} />
      <text x={316} y={126} fontSize={11} fontWeight={700} fill={C.muted} letterSpacing={1}>
        SN 0042-7781
      </text>
      <g className="art-float">
        <circle
          cx={434}
          cy={160}
          r={30}
          fill={C.white}
          fillOpacity={0.35}
          stroke={C.navy}
          strokeWidth={7}
        />
        <path d="m455 181 16 16" stroke={C.navy} strokeWidth={10} strokeLinecap="round" />
      </g>

      <Card id={id} x={300} y={196} w={156} h={112} r={14} />
      <path
        d="M330 214l22 8v16c0 14-10 22-22 26-12-4-22-12-22-26v-16Z"
        fill={C.sand}
        stroke={C.amber}
        strokeWidth={3}
        strokeLinejoin="round"
      />
      <rect x={323} y={236} width={14} height={11} rx={2} fill={C.amber} />
      <path d="M326 236v-4a4 4 0 0 1 8 0v4" fill="none" stroke={C.amber} strokeWidth={2.5} />
      <Bar x={364} y={222} w={74} h={6} fill={C.ink} />
      <Bar x={364} y={236} w={52} h={5} />
      <rect x={316} y={274} width={58} height={22} rx={11} fill={C.sand} />
      <Bar x={328} y={282} w={34} h={6} fill={C.amber} />
      <rect x={382} y={274} width={58} height={22} rx={11} fill={C.mint} />
      <Bar x={394} y={282} w={34} h={6} fill={C.teal} />
    </Art>
  );
}

function ShiftArt() {
  const id = 'art-shift';
  const noteColors = [C.teal, C.sky, C.amber, C.coral];
  return (
    <Art id={id}>
      <Card id={id} x={24} y={26} w={276} h={84} r={16} />
      <circle cx={58} cy={68} r={18} fill={C.mist} />
      <path
        d="M47 68s4-7 11-7 11 7 11 7-4 7-11 7-11-7-11-7Z"
        fill="none"
        stroke={C.blue}
        strokeWidth={2.4}
      />
      <path d="m48 78 20-20" stroke={C.blue} strokeWidth={2.4} strokeLinecap="round" />
      <Bar x={88} y={50} w={60} h={5} />
      <text x={88} y={82} fontSize={20} fontWeight={800} fill={C.muted} letterSpacing={3}>
        ••••••
      </text>
      <path d="M182 44v48" stroke={C.line} strokeWidth={2} />
      <Bar x={198} y={50} w={58} h={5} />
      <text x={198} y={82} fontSize={17} fontWeight={800} fill={C.ink}>
        5.200.000
      </text>

      <rect
        x={44}
        y={124}
        width={236}
        height={70}
        rx={10}
        fill={C.tint}
        filter={`url(#${id}-shadow)`}
      />
      {[0, 1, 2, 3].map((slot) => (
        <g key={slot}>
          <rect x={54 + slot * 56} y={134} width={48} height={50} rx={6} fill={C.white} />
          <rect x={60 + slot * 56} y={142} width={36} height={22} rx={3} fill={noteColors[slot]} />
          <rect
            x={60 + slot * 56}
            y={150}
            width={36}
            height={22}
            rx={3}
            fill={noteColors[slot]}
            opacity={0.75}
          />
        </g>
      ))}
      <rect
        x={28}
        y={188}
        width={268}
        height={110}
        rx={14}
        fill="#25445f"
        filter={`url(#${id}-shadow)`}
      />
      <rect x={128} y={210} width={68} height={10} rx={5} fill="#3f6383" />
      <circle cx={70} cy={252} r={12} fill="#3f6383" />
      <circle cx={70} cy={252} r={5} fill={C.amber} />
      <Bar x={110} y={248} w={150} h={8} fill="#3f6383" />
      <Bar x={110} y={266} w={96} h={8} fill="#3f6383" />

      <Card id={id} x={316} y={26} w={140} h={160} r={16} />
      {['1', '2', '3'].map((step, index) => (
        <g key={step}>
          {index < 2 ? (
            <CheckBadge cx={342} cy={60 + index * 44} r={13} />
          ) : (
            <g>
              <circle className="art-pulse" cx={342} cy={60 + index * 44} r={13} fill={C.blue} />
              <text
                x={342}
                y={65 + index * 44}
                textAnchor="middle"
                fontSize={12}
                fontWeight={800}
                fill={C.white}
              >
                {step}
              </text>
            </g>
          )}
          <Bar x={364} y={54 + index * 44} w={70} h={6} fill={index < 2 ? C.ink : C.blue} />
          <Bar x={364} y={66 + index * 44} w={46} h={5} />
          {index < 2 && <path d={`M342 ${75 + index * 44}v14`} stroke={C.teal} strokeWidth={3} />}
        </g>
      ))}

      <Card id={id} x={316} y={204} w={140} h={94} r={16} />
      <Avatar cx={350} cy={240} r={18} fill={C.amber} />
      <Avatar cx={386} cy={240} r={18} fill={C.blue} />
      <CheckBadge cx={428} cy={240} r={13} />
      <Bar x={334} y={272} w={96} h={6} />
    </Art>
  );
}

function DisplayArt() {
  const id = 'art-display';
  const code = ['K', '7', 'Q', '2', 'M', '9', 'X', 'A'];
  return (
    <Art id={id}>
      <rect
        x={24}
        y={26}
        width={262}
        height={180}
        rx={14}
        fill={C.navy}
        filter={`url(#${id}-shadow)`}
      />
      <rect x={36} y={38} width={238} height={148} rx={8} fill={C.white} />
      {[0, 1, 2, 3].map((row) => (
        <g key={row}>
          <Bar x={50} y={56 + row * 22} w={74} h={6} fill={C.ink} />
          <Bar x={132} y={56 + row * 22} w={30} h={6} fill={C.muted} />
        </g>
      ))}
      <rect x={50} y={150} width={112} height={24} rx={6} fill={C.blue} />
      <Bar x={62} y={159} w={60} h={6} fill="#8ec0ea" />
      <QrMark x={178} y={58} size={82} />
      <Bar x={180} y={154} w={78} h={6} />
      <Bar x={192} y={166} w={54} h={5} />
      <rect x={136} y={206} width={38} height={28} fill="#25445f" />
      <rect x={100} y={232} width={110} height={10} rx={5} fill="#25445f" />

      <Card id={id} x={24} y={258} w={262} h={56} r={14} />
      {code.map((char, index) => (
        <g key={index}>
          <rect
            x={38 + index * 30}
            y={272}
            width={24}
            height={28}
            rx={6}
            fill={index < 6 ? C.mist : C.tint}
            stroke={index === 6 ? C.blue : 'none'}
            strokeWidth={2}
          />
          <text
            x={50 + index * 30}
            y={291}
            textAnchor="middle"
            fontSize={13}
            fontWeight={800}
            fill={index < 6 ? C.blue : C.muted}
          >
            {index < 6 ? char : ''}
          </text>
        </g>
      ))}

      <g filter={`url(#${id}-shadow)`}>
        <path
          d="M310 20h144v282l-9 8-9-8-9 8-9-8-9 8-9-8-9 8-9-8-9 8-9-8-9 8-9-8-9 8-9-8-9 8-9-8Z"
          fill={C.white}
        />
      </g>
      <rect x={358} y={36} width={48} height={14} rx={7} fill={C.blue} />
      <Bar x={340} y={60} w={84} h={5} />
      <path d="M326 76h112" stroke={C.line} strokeDasharray="4 4" />
      {[0, 1, 2, 3, 4].map((row) => (
        <g key={row}>
          <Bar x={326} y={90 + row * 20} w={60} h={5} fill={C.ink} />
          <Bar x={404} y={90 + row * 20} w={34} h={5} fill={C.muted} />
          {row % 2 === 0 && <Bar x={326} y={99 + row * 20} w={40} h={4} />}
        </g>
      ))}
      <path d="M326 196h112" stroke={C.line} strokeDasharray="4 4" />
      <Bar x={326} y={210} w={44} h={7} fill={C.ink} />
      <Bar x={392} y={210} w={46} h={7} fill={C.blue} />
      <Barcode x={334} y={236} w={96} h={30} />
      <g transform="rotate(-14 418 150)" className="art-pop">
        <rect
          x={384}
          y={132}
          width={70}
          height={34}
          rx={6}
          fill="none"
          stroke={C.coral}
          strokeWidth={3}
        />
        <rect
          x={394}
          y={141}
          width={12}
          height={14}
          rx={2}
          fill="none"
          stroke={C.coral}
          strokeWidth={2.4}
        />
        <rect
          x={398}
          y={145}
          width={12}
          height={14}
          rx={2}
          fill={C.white}
          stroke={C.coral}
          strokeWidth={2.4}
        />
        <text x={432} y={156} textAnchor="middle" fontSize={16} fontWeight={800} fill={C.coral}>
          ×2
        </text>
      </g>
    </Art>
  );
}

function ReportsArt() {
  const id = 'art-report';
  const bars = [58, 92, 74, 120, 96, 140, 118];
  const linePoints = bars
    .map((height, index) => `${64 + index * 36},${262 - height * 0.8 - 18}`)
    .join(' ');
  return (
    <Art id={id}>
      <Card id={id} x={24} y={26} w={300} h={288} r={16} />
      {[0, 1, 2, 3, 4].map((tab) => (
        <rect
          key={tab}
          x={40 + tab * 54}
          y={42}
          width={48}
          height={20}
          rx={10}
          fill={tab === 0 ? C.blue : C.tint}
        />
      ))}
      <Bar x={40} y={78} w={70} h={6} />
      <text x={40} y={110} fontSize={22} fontWeight={800} fill={C.ink}>
        48.250.000 ₫
      </text>
      <rect x={214} y={94} width={52} height={20} rx={10} fill={C.mint} />
      <Bar x={224} y={101} w={32} h={6} fill={C.teal} />
      {[0, 1, 2, 3].map((line) => (
        <path key={line} d={`M40 ${150 + line * 36}h268`} stroke={C.tint} strokeWidth={2} />
      ))}
      {bars.map((height, index) => (
        <rect
          key={index}
          className="art-grow"
          x={52 + index * 36}
          y={262 - height}
          width={24}
          height={height}
          rx={6}
          fill={index === 5 ? C.blue : C.mist}
        />
      ))}
      <polyline
        points={linePoints}
        fill="none"
        stroke={C.amber}
        strokeWidth={3}
        strokeLinejoin="round"
        strokeLinecap="round"
      />
      {bars.map((height, index) => (
        <circle
          key={index}
          cx={64 + index * 36}
          cy={262 - height * 0.8 - 18}
          r={4}
          fill={C.white}
          stroke={C.amber}
          strokeWidth={2.5}
        />
      ))}
      {bars.map((_, index) => (
        <Bar key={index} x={54 + index * 36} y={276} w={20} h={5} />
      ))}

      <Card id={id} x={340} y={26} w={116} h={136} r={16} />
      <circle cx={398} cy={88} r={36} fill="none" stroke={C.mist} strokeWidth={16} />
      <circle
        cx={398}
        cy={88}
        r={36}
        fill="none"
        stroke={C.blue}
        strokeWidth={16}
        strokeDasharray={`${2 * Math.PI * 36 * 0.62} ${2 * Math.PI * 36}`}
        transform="rotate(-90 398 88)"
      />
      <circle
        cx={398}
        cy={88}
        r={36}
        fill="none"
        stroke={C.teal}
        strokeWidth={16}
        strokeDasharray={`${2 * Math.PI * 36 * 0.24} ${2 * Math.PI * 36}`}
        transform={`rotate(${-90 + 360 * 0.62} 398 88)`}
      />
      <Bar x={368} y={140} w={60} h={6} />

      <Card id={id} x={340} y={178} w={116} h={136} r={16} />
      <path
        d="M368 196h40l20 20v64a6 6 0 0 1-6 6h-54a6 6 0 0 1-6-6v-78a6 6 0 0 1 6-6Z"
        fill={C.mint}
      />
      <path d="M408 196v14a6 6 0 0 0 6 6h14" fill="#bfe9dc" />
      <text x={395} y={244} textAnchor="middle" fontSize={14} fontWeight={800} fill={C.teal}>
        CSV
      </text>
      <path
        className="art-drop"
        d="M395 254v18m-8-8 8 8 8-8"
        fill="none"
        stroke={C.teal}
        strokeWidth={3}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <rect x={410} y={268} width={40} height={22} rx={11} fill={C.white} stroke={C.line} />
      <text x={430} y={283} textAnchor="middle" fontSize={10} fontWeight={800} fill={C.muted}>
        24h
      </text>
    </Art>
  );
}

const slideArt: Record<string, () => ReactNode> = {
  sale: SaleArt,
  payment: PaymentArt,
  credit: CreditArt,
  inventory: InventoryArt,
  shift: ShiftArt,
  display: DisplayArt,
  reports: ReportsArt,
};

export function SlideArt({ id }: { id: string }) {
  const Component = slideArt[id];
  return Component ? <Component /> : null;
}

// Group emblems: 48×48 duotone marks for the detailed feature groups.
const groupPaths: Record<string, ReactNode> = {
  sale: (
    <>
      <path d="M8 12h4l4 20h20l4-14H14" className="tone" />
      <path d="M8 12h4l4 20h20l4-14H14" />
      <circle cx="19" cy="38" r="2.5" />
      <circle cx="33" cy="38" r="2.5" />
    </>
  ),
  payment: (
    <>
      <rect x="6" y="10" width="20" height="20" rx="3" className="tone" />
      <path d="M6 10h20v20H6Z M10 14h5v5h-5Z M17 21h5v5h-5Z M17 14h5 M10 26h3" />
      <rect x="22" y="22" width="20" height="14" rx="3" className="tone" />
      <rect x="22" y="22" width="20" height="14" rx="3" />
      <circle cx="32" cy="29" r="3" />
    </>
  ),
  credit: (
    <>
      <rect x="6" y="12" width="36" height="24" rx="4" className="tone" />
      <rect x="6" y="12" width="36" height="24" rx="4" />
      <path d="M6 19h36 M12 29h8" />
      <path d="m30 30 3 3 6-7" />
    </>
  ),
  returns: (
    <>
      <path d="M10 24a14 14 0 1 0 4-10" className="tone" />
      <path d="M10 24a14 14 0 1 0 4-10 M10 8v8h8" />
      <path d="M18 24h12 M24 18v12" />
    </>
  ),
  inventory: (
    <>
      <path d="m24 6 16 8v18l-16 8-16-8V14Z" className="tone" />
      <path d="m24 6 16 8v18l-16 8-16-8V14Z M8 14l16 8 16-8 M24 22v18" />
      <path d="M15 10l16 8" />
    </>
  ),
  shift: (
    <>
      <rect x="6" y="20" width="36" height="20" rx="4" className="tone" />
      <path d="M6 20h36v16a4 4 0 0 1-4 4H10a4 4 0 0 1-4-4Z M10 20l4-10h20l4 10 M19 28h10" />
    </>
  ),
  reports: (
    <>
      <rect x="6" y="6" width="36" height="36" rx="5" className="tone" />
      <path d="M14 34V24 M22 34V14 M30 34V20 M38 34V10" />
      <path d="M8 40h34" />
    </>
  ),
  display: (
    <>
      <rect x="4" y="8" width="28" height="20" rx="3" className="tone" />
      <path d="M4 8h28v20H4Z M14 36h8 M18 28v8" />
      <path d="M30 18h14v24l-3.5-2-3.5 2-3.5-2-3.5 2Z" className="tone" />
      <path d="M30 18h14v24l-3.5-2-3.5 2-3.5-2-3.5 2Z M34 25h6 M34 31h6" />
    </>
  ),
  admin: (
    <>
      <circle cx="18" cy="16" r="7" className="tone" />
      <path d="M6 40c0-7 5-12 12-12s12 5 12 12" className="tone" />
      <circle cx="18" cy="16" r="7" />
      <path d="M6 40c0-7 5-12 12-12s12 5 12 12" />
      <path d="M36 18v4 M36 30v4 M30 26h-4 M46 26h-4 M36 30a4 4 0 1 0 0-8 4 4 0 0 0 0 8Z" />
    </>
  ),
  safety: (
    <>
      <path d="m24 4 16 6v12c0 10-7 18-16 22-9-4-16-12-16-22V10Z" className="tone" />
      <path d="m24 4 16 6v12c0 10-7 18-16 22-9-4-16-12-16-22V10Z" />
      <path d="m17 24 5 5 9-10" />
    </>
  ),
};

export function GroupArt({ id }: { id: string }) {
  return (
    <svg className="login-group-art" viewBox="0 0 48 48" aria-hidden="true" focusable="false">
      {groupPaths[id]}
    </svg>
  );
}
