import type { PrintCommand } from './commands';

// Epson ePOS-Print: a SOAP envelope posted to the printer's own web service.
// Text, QR and barcode content goes through `xml`. Attributes are written
// unescaped, so only values of a closed type (alignment, flags, counts) go there.

const NAMESPACE = 'http://www.epson-pos.com/schemas/2011/03/epos-print';
const ENVELOPE = 'http://schemas.xmlsoap.org/soap/envelope/';
const TIMEOUT_MS = 10_000;

// XML 1.0 cannot carry most control characters even as references.
export function xml(value: string): string {
  return (
    value
      // biome-ignore lint/suspicious/noControlCharactersInRegex: removing them is the point
      .replace(/[\u0000-\u0008\u000b\u000c\u000e-\u001f￾￿]/g, '')
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&apos;')
  );
}

function element(command: PrintCommand): string {
  switch (command.type) {
    case 'text': {
      const size = command.large ? ' dw="true" dh="true"' : ' dw="false" dh="false"';
      return `<text lang="vi" align="${command.align}" em="${command.bold}"${size}>${xml(command.text)}&#10;</text>`;
    }
    case 'feed':
      return `<feed line="${command.lines}"/>`;
    case 'qr':
      return `<text align="${command.align}"/><symbol type="qrcode_model_2" level="level_m" width="4" height="0" size="0">${xml(command.value)}</symbol><feed line="1"/>`;
    case 'barcode':
      // Code set B; a literal brace is doubled in this format.
      return `<text align="${command.align}"/><barcode type="code128" hri="below" font="font_a" width="2" height="60">{B${xml(command.value.replace(/\{/g, '{{'))}</barcode><feed line="1"/>`;
    case 'cut':
      return '<cut type="feed"/>';
  }
}

export function eposBody(commands: PrintCommand[]): string {
  return `<s:Envelope xmlns:s="${ENVELOPE}"><s:Body><epos-print xmlns="${NAMESPACE}">${commands.map(element).join('')}</epos-print></s:Body></s:Envelope>`;
}

export function eposRequest(origin: string, commands: PrintCommand[]) {
  return {
    url: `${origin}/cgi-bin/epos/service.cgi?devid=local_printer&timeout=${TIMEOUT_MS}`,
    headers: {
      'Content-Type': 'text/xml; charset=utf-8',
      'If-Modified-Since': 'Thu, 01 Jan 1970 00:00:00 GMT',
      SOAPAction: '""',
    },
    body: eposBody(commands),
  };
}

export function eposSucceeded(response: string): boolean {
  return /<response\b[^>]*\bsuccess="true"/.test(response);
}
