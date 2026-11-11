import type { PrintCommand } from './commands';

// Star WebPRNT: printer markup carried as text inside a small XML envelope.
// A document value is escaped twice, as the SDK does: `\xHH` sequences make it
// safe inside the markup, and the whole markup is then XML-escaped.

const hex = (code: number) => `\\x${code.toString(16).padStart(2, '0')}`;

// biome-ignore lint/suspicious/noControlCharactersInRegex: these are what must be escaped
const TEXT_ESCAPED = /[\\\u0000- &<>\u007f]/g;

export function starText(value: string): string {
  return value.replace(TEXT_ESCAPED, (char) => (char === '\\' ? '\\\\' : hex(char.charCodeAt(0))));
}

// Codes are bytes, so anything outside printable ASCII goes as its UTF-8 bytes.
export function starBinary(value: string): string {
  let result = '';
  for (const byte of new TextEncoder().encode(value)) {
    const char = String.fromCharCode(byte);
    if (char === '\\') result += '\\\\';
    else if (byte <= 0x20 || byte >= 0x7f || char === '&' || char === '<' || char === '>')
      result += hex(byte);
    else result += char;
  }
  return result;
}

const envelopeEscape = (value: string) =>
  value.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

function element(command: PrintCommand): string {
  switch (command.type) {
    case 'text': {
      const scale = command.large ? '2' : '1';
      return `<alignment position='${command.align}'/><text emphasis='${command.bold}' width='${scale}' height='${scale}' codepage='utf8'>${starText(command.text)}\\x0a</text>`;
    }
    case 'feed':
      return `<feed line='${command.lines}'/>`;
    case 'qr':
      return `<alignment position='${command.align}'/><qrcode model='model2' level='level_m' cell='4'>${starBinary(command.value)}</qrcode>`;
    case 'barcode':
      return `<alignment position='${command.align}'/><barcode symbology='Code128' width='width2' height='60' hri='true'>${starBinary(command.value)}</barcode>`;
    case 'cut':
      return "<cutpaper feed='true' type='partial'/>";
  }
}

export function starMarkup(commands: PrintCommand[]): string {
  return `<root>${commands.map(element).join('')}</root>`;
}

export function starBody(commands: PrintCommand[]): string {
  return `<StarWebPrint xmlns="http://www.star-m.jp" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><Request>${envelopeEscape(starMarkup(commands))}</Request></StarWebPrint>`;
}

export function starRequest(origin: string, commands: PrintCommand[]) {
  return {
    url: `${origin}/StarWebPRNT/SendMessage`,
    headers: { 'Content-Type': 'text/xml; charset=UTF-8' },
    body: starBody(commands),
  };
}

// The answer is escaped markup inside `<Response>`, like the request.
export function starSucceeded(response: string): boolean {
  const body = response.replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&');
  return /<success>\s*true\s*<\/success>/.test(body);
}
