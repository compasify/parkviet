import { createPortal } from 'react-dom';
import { useTranslation } from 'react-i18next';
import type { InvoiceTicket, TicketPaper, TicketRow } from '../lib/invoice-ticket';
import '../styles/receipt.css';

function Rows({ rows, className }: { rows: TicketRow[]; className: string }) {
  if (rows.length === 0) return null;
  return (
    <dl className={className}>
      {rows.map((row, index) => (
        // biome-ignore lint/suspicious/noArrayIndexKey: labels may repeat (two cash tenders)
        <div key={index} className={row.strong ? 'receipt-strong' : undefined}>
          <dt>{row.label}</dt>
          <dd>{row.value}</dd>
        </div>
      ))}
    </dl>
  );
}

// Plain thermal-printer layout: centred text header, one items table
// (name on its own row, then quantity / price / discount / total), totals.
export function InvoiceTicketSheet({
  ticket,
  paper,
  testId = 'invoice-ticket',
}: {
  ticket: InvoiceTicket;
  paper: TicketPaper;
  testId?: string;
}) {
  const { t } = useTranslation();
  return (
    <article
      className={`receipt-sheet invoice-ticket receipt-${paper}`}
      data-testid={testId}
      data-paper={paper}
    >
      <header className="receipt-header">
        {ticket.header.map((line) => (
          <p key={line}>{line}</p>
        ))}
        <h2>{ticket.title}</h2>
      </header>
      <Rows rows={ticket.meta} className="receipt-meta" />
      {ticket.lines.length > 0 ? (
        <table className="ticket-table">
          <thead>
            <tr>
              <th scope="col">{t('ticketQty')}</th>
              <th scope="col">{t('ticketPrice')}</th>
              <th scope="col">{t('ticketDiscount')}</th>
              <th scope="col">{t('ticketTotal')}</th>
            </tr>
          </thead>
          {ticket.lines.map((line, index) => (
            // biome-ignore lint/suspicious/noArrayIndexKey: lines keep their printed order
            <tbody key={index}>
              <tr className="ticket-name">
                <td colSpan={4}>
                  {index + 1}. {line.name}
                </td>
              </tr>
              <tr className="ticket-figures">
                <td>{line.quantity}</td>
                <td>{line.price}</td>
                <td>{line.discount}</td>
                <td>{line.total}</td>
              </tr>
            </tbody>
          ))}
        </table>
      ) : null}
      <Rows rows={ticket.totals} className="receipt-totals" />
      <Rows rows={ticket.payments} className="receipt-payments" />
      <p className="receipt-disclaimer">{ticket.footer}</p>
    </article>
  );
}

// The printed copy: at the end of <body>, hidden on screen and the only
// visible content while the print adapter's marker is set.
export function InvoiceTicketPrintPortal(props: { ticket: InvoiceTicket; paper: TicketPaper }) {
  return createPortal(
    <div className="receipt-print-root receipt-print-portal">
      <InvoiceTicketSheet {...props} testId="invoice-ticket-print" />
    </div>,
    window.document.body,
  );
}
