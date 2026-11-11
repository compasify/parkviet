import type {
  Align,
  PrintBlock,
  PrintDocument,
  PrintLines,
  PrintRow,
} from '../receipt-template/types';
import type { PrinterTarget } from '../types/print-adapter';

// A resolved document flattened to what a receipt printer does: lines of
// text, feeds, codes and a cut. Each printer language renders these and is
// responsible for escaping the text. Images are skipped: a logo needs a
// raster pipeline, and a receipt is complete without one.

export type PrintCommand =
  | { type: 'text'; text: string; align: Align; bold: boolean; large: boolean }
  | { type: 'feed'; lines: number }
  | { type: 'qr'; value: string; align: Align }
  | { type: 'barcode'; value: string; align: Align }
  | { type: 'cut' };

export type PrintableDocument = Omit<PrintDocument, 'documentType' | 'page'>;

const COLUMNS: Record<PrinterTarget['paper'], number> = { '58mm': 32, '80mm': 48 };
const MM_PER_FEED = 4;

export function printerColumns(printer: Pick<PrinterTarget, 'paper' | 'settings'>): number {
  const configured = printer.settings.char_width;
  return typeof configured === 'number' ? configured : COLUMNS[printer.paper];
}

// Control characters would break a line or reach the printer as commands.
// biome-ignore lint/suspicious/noControlCharactersInRegex: removing them is the point
const clean = (value: string) => value.normalize('NFC').replace(/[\u0000-\u001f\u007f]/g, ' ');
const length = (value: string) => [...value].length;

export function wrapText(input: string, width: number): string[] {
  const lines: string[] = [];
  let line = '';
  for (const word of clean(input).split(' ').filter(Boolean)) {
    let rest = [...word];
    if (line && length(line) + 1 + rest.length <= width) {
      line = `${line} ${word}`;
      continue;
    }
    if (line) lines.push(line);
    line = '';
    while (rest.length > width) {
      lines.push(rest.slice(0, width).join(''));
      rest = rest.slice(width);
    }
    line = rest.join('');
  }
  if (line) lines.push(line);
  return lines;
}

function pairLines(left: string, right: string, width: number): string[] {
  const label = clean(left).trim();
  const value = clean(right).trim();
  const gap = width - length(label) - length(value);
  if (gap >= 1) return [`${label}${' '.repeat(gap)}${value}`];
  const labelLines = wrapText(label, width);
  const valueLines = wrapText(value, width);
  return [...labelLines, ...valueLines.map((line) => `${' '.repeat(width - length(line))}${line}`)];
}

export function documentCommands(
  document: PrintableDocument,
  printer: Pick<PrinterTarget, 'paper' | 'settings'>,
): PrintCommand[] {
  const width = printerColumns(printer);
  const commands: PrintCommand[] = [];
  const text = (line: string, align: Align = 'left', bold = false, large = false) =>
    commands.push({ type: 'text', text: line, align, bold, large });
  const wrapped = (value: string, align: Align = 'left', bold = false, large = false) => {
    for (const line of wrapText(value, large ? Math.floor(width / 2) : width))
      text(line, align, bold, large);
  };
  const row = ({ label, value, strong }: PrintRow) => {
    for (const line of pairLines(label, value, width)) text(line, 'left', strong === true);
  };
  const rule = (mark = '-') => text(mark.repeat(width));

  const block = (item: PrintBlock) => {
    switch (item.kind) {
      case 'text':
        for (const line of item.lines) wrapped(line, item.align, item.bold, item.size === 'l');
        break;
      case 'title':
        wrapped(item.title, 'center', true, true);
        if (item.number) wrapped(item.number, 'center', true);
        break;
      case 'qr':
        commands.push({ type: 'qr', value: item.value, align: item.align });
        if (item.caption) wrapped(item.caption, item.align);
        break;
      case 'barcode':
        commands.push({ type: 'barcode', value: item.value, align: item.align });
        break;
      case 'divider':
        rule(item.style === 'solid' ? '=' : '-');
        break;
      case 'spacer':
        commands.push({ type: 'feed', lines: Math.max(1, Math.round(item.mm / MM_PER_FEED)) });
        break;
      case 'signatures':
        for (const party of item.parties) {
          wrapped(party.label);
          commands.push({ type: 'feed', lines: 3 });
        }
        break;
      case 'image':
        break;
    }
  };

  const lines = (section: PrintLines) => {
    if (section.layout === 'stacked') {
      for (const item of section.items) {
        const name = item.index === null ? item.name : `${item.index}. ${item.name}`;
        if (item.amount === null) wrapped(name);
        else for (const line of pairLines(name, item.amount, width)) text(line);
        for (const detail of item.details) wrapped(`  ${detail}`);
      }
      return;
    }
    if (section.columns.length > 0)
      wrapped(section.columns.map((column) => column.label).join(' | '), 'right', true);
    for (const item of section.rows) {
      wrapped(item.index === null ? item.name : `${item.index}. ${item.name}`);
      if (item.cells.length > 0) wrapped(item.cells.join(' | '), 'right');
      for (const detail of item.details) wrapped(`  ${detail}`);
    }
  };

  for (const banner of document.banners) wrapped(banner, 'center', true);
  document.header.forEach(block);
  document.meta.forEach(row);
  rule();
  lines(document.lines);
  rule();
  document.totals.forEach(row);
  document.payments.forEach(row);
  if (document.payQr) {
    commands.push({ type: 'qr', value: document.payQr.value, align: 'center' });
    wrapped(document.payQr.caption, 'center');
    for (const line of document.payQr.lines) wrapped(line, 'center');
  }
  for (const note of document.notes) wrapped(note);
  document.footer.forEach(block);
  if (document.disclaimer) wrapped(document.disclaimer, 'center');
  commands.push({ type: 'feed', lines: 3 });
  if (printer.settings.cut !== false) commands.push({ type: 'cut' });
  return commands;
}
